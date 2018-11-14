//
//  PushTransaction.m
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 ToSoC Inc. All rights reserved.
//

#import "PushTransactionService.h"
#import "WebService.h"
#import "EOSRequest.h"
#import "Utility.h"
#import "EOSChainInfo.h"
#import "EOSBlockInfo.h"
#import "NSData+Hash.h"
#import "EosByteWriter.h"
#import "EOSIOSConstants.h"

typedef enum {
    EOSTransactionStepABItoBIN = 0,
    EOSTransactionStepGetChainInfo,
    EOSTransactionStepGetPublicKeys,
    EOSTransactionStepGetBlock,
    EOSTransactionStepGetRequiredKeys,
    EOSTransactionStepSignTransaction,
    EOSTransactionStepPushTransaction
} EOSTransactionStep;


@interface PushTransactionService()
{
    EOSTransactionStep  _currentEOSTransactionStep;
    NSInteger           _actionCounter;
}

@property (nonatomic, strong)   EOSAction       *currentActionObject;
@property (nonatomic, strong)   WebService      *webService;
@property (nonatomic, strong)   NSMutableArray  *binaryArgs;
@property (nonatomic, strong)   EOSBlockInfo    *blockInfo;
@property (nonatomic, strong)   EOSChainInfo    *chainInfo;
@property (nonatomic, strong)   NSArray         *public_keys;
@property (nonatomic, strong)   NSArray         *reqired_keys;
@property (nonatomic, strong)   NSArray         *signatures;
@property (nonatomic, strong)   NSArray         *eosActions;

@end

@implementation PushTransactionService

- (id)init
{
    self = [super init];
    if (self)
    {
        _actionCounter = 0;
        _binaryArgs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)initiateTransaction:(NSArray *)eosActions
{
    if ([eosActions count] > 0)
    {
        _eosActions = eosActions;
        _actionCounter = 0;
        [self abiToJson:[_eosActions objectAtIndex:_actionCounter]];
        _actionCounter++;
    }
}

- (void)abiToJson:(EOSAction *)eosAction;
{
    _currentActionObject = eosAction;
    _currentEOSTransactionStep = EOSTransactionStepABItoBIN;
    EOSRequest *request = [[EOSRequest alloc] init];
    request.requestEndPointKey = @"abi_json_to_bin";
    request.requestURL = [EOSIOSConstants sharedInstance].rpcChainURL;
    request.requestType = @"POST";
    request.http_body = [NSString stringWithFormat:transaction_data_template, _currentActionObject.account, _currentActionObject.action, _currentActionObject.args];
    _webService = [[WebService alloc] init];
    _webService.delegate = self;
    [_webService sendRequest:request];
}

- (void)getChainInfo
{
    _currentEOSTransactionStep = EOSTransactionStepGetChainInfo;
    EOSRequest *request = [[EOSRequest alloc] init];
    request.requestEndPointKey = @"get_info";
    request.requestURL = [EOSIOSConstants sharedInstance].rpcChainURL;
    request.requestType = @"POST";
    _webService = [[WebService alloc] init];
    _webService.delegate = self;
    [_webService sendRequest:request];
}

- (void)getPublicKeys
{
    _currentEOSTransactionStep = EOSTransactionStepGetPublicKeys;
    EOSRequest *request = [[EOSRequest alloc] init];
    request.requestEndPointKey = @"get_public_keys";
    request.requestURL = [EOSIOSConstants sharedInstance].rpcWalletURL;
    request.requestType = @"POST";
    _webService = [[WebService alloc] init];
    _webService.delegate = self;
    [_webService sendRequest:request];
}

- (void)getBlock
{
    _currentEOSTransactionStep = EOSTransactionStepGetBlock;
    EOSRequest *request = [[EOSRequest alloc] init];
    request.requestEndPointKey = @"get_block";
    request.requestURL = [EOSIOSConstants sharedInstance].rpcChainURL;
    request.requestType = @"POST";
    if(![Utility isEmptyString:_chainInfo.last_irreversible_block_id])
    {
        request.http_body = [NSString stringWithFormat:@"{ \"block_num_or_id\" : \"%@\"}", _chainInfo.last_irreversible_block_id];
    }
    _webService = [[WebService alloc] init];
    _webService.delegate = self;
    [_webService sendRequest:request];
}

- (void)getRequiredKeys
{
    _currentEOSTransactionStep = EOSTransactionStepGetRequiredKeys;
    EOSRequest *request = [[EOSRequest alloc] init];
    request.requestEndPointKey = @"get_required_keys";
    request.requestURL = [EOSIOSConstants sharedInstance].rpcChainURL;
    request.requestType = @"POST";
    request.http_body = [self getRequiredKeysHTTPBody];
    _webService = [[WebService alloc] init];
    _webService.delegate = self;
    [_webService sendRequest:request];
}

- (void)signTransaction
{
    _currentEOSTransactionStep = EOSTransactionStepSignTransaction;
    EOSRequest *request = [[EOSRequest alloc] init];
    request.requestEndPointKey = @"sign_transaction";
    request.requestURL = [EOSIOSConstants sharedInstance].rpcWalletURL;
    request.requestType = @"POST";
    request.http_body = [self getSignTransactionHTTPBody];
    _webService = [[WebService alloc] init];
    _webService.delegate = self;
    [_webService sendRequest:request];
}

- (void)pushTransaction:(NSDictionary *)discTrans
{
    _currentEOSTransactionStep = EOSTransactionStepPushTransaction;
    EOSRequest *request = [[EOSRequest alloc] init];
    request.requestEndPointKey = @"push_transaction";
    request.requestURL = [EOSIOSConstants sharedInstance].rpcChainURL;
    request.requestType = @"POST";
    request.http_body = [self getPushTransactionHTTPBody:discTrans];
    _webService = [[WebService alloc] init];
    _webService.delegate = self;
    [_webService sendRequest:request];
}

- (void)unlockWallet
{    
    EOSRequest *request = [[EOSRequest alloc] init];
    request.requestEndPointKey = @"unlock_wallet";
    request.requestURL = [EOSIOSConstants sharedInstance].rpcWalletURL;
    request.requestType = @"POST";
    request.http_body = [NSString stringWithFormat:@"[\"%@\",\"%@\"]", _currentActionObject.action_wallet_name, _currentActionObject.action_wallet_private_key];
    _webService = [[WebService alloc] init];
    _webService.delegate = self;
    [_webService sendRequest:request];
}

- (void)handleError:(NSDictionary *)config
{
    NSDictionary *discError = [config objectForKey:@"error"];
    NSString *error = [discError objectForKey:@"name"];
    if ([error isEqualToString:@"wallet_locked_exception"])
    {
        [self unlockWallet];
    }
    else
    {
        if (_delegate && [_delegate respondsToSelector:@selector(pushTransactionFailedWithError:)])
        {
            NSLog(@"Chain Error :%@", config);
            NSArray *details = [discError objectForKey:@"details"];
            if ([details count] > 0)
            {
                NSString *message = [[details objectAtIndex:0] objectForKey:@"message"];
                if (![Utility isEmptyString:message])
                {
                    error = [NSString stringWithFormat:@"%@ : %@", error,  message];
                }
            }
            [_delegate pushTransactionFailedWithError:error];
        }
    }
}

- (NSString *)getRequiredKeysHTTPBody
{
    NSString *httpBody = @"";
    httpBody = get_required_keys_template;
    if (![Utility isEmptyString:httpBody])
    {
        httpBody = [httpBody stringByReplacingOccurrencesOfString:@":PARAM:EXPIRY:" withString:[NSString stringWithFormat:@"\"%@\"", [Utility getExpiryDateAsString]]];
        httpBody = [httpBody stringByReplacingOccurrencesOfString:@":PARAM:REF_BLOCK_NUM:" withString:_blockInfo.block_num];
        httpBody = [httpBody stringByReplacingOccurrencesOfString:@":PARAM:REF_BLOCK_PREFIX:" withString:_blockInfo.ref_block_prefix];
        NSString *strActions;
        for (int i = 0; i < [_eosActions count]; i++)
        {
            EOSAction *action = [_eosActions objectAtIndex:i];
            NSString *singleAction = single_action_template;
            singleAction = [singleAction stringByReplacingOccurrencesOfString:@":PARAM:ACCOUNT:" withString:[NSString stringWithFormat:@"\"%@\"", action.account]];
            singleAction = [singleAction stringByReplacingOccurrencesOfString:@":PARAM:ACTION:" withString:[NSString stringWithFormat:@"\"%@\"", action.action]];
            singleAction = [singleAction stringByReplacingOccurrencesOfString:@":PARAM:AUTH:USER:" withString:[NSString stringWithFormat:@"\"%@\"", action.auth_userid]];
            singleAction = [singleAction stringByReplacingOccurrencesOfString:@":PARAM:BIN:DATA:" withString:[NSString stringWithFormat:@"\"%@\"", [_binaryArgs objectAtIndex:i]]];
            if (i > 0)
            {
                strActions = [NSString stringWithFormat:@"%@,%@", strActions, singleAction];
            }
            else
            {
                strActions = singleAction;
            }
        }
        httpBody = [httpBody stringByReplacingOccurrencesOfString:@":PARAM:ACTIONS:" withString:strActions];
        NSString *strFirstKey = @"";
        if ([_public_keys count] > 0)
        {
            strFirstKey = [NSString stringWithFormat:@"\"%@\"", [_public_keys objectAtIndex:0]];
        }
        NSMutableString *strAvailableKeys = [NSMutableString stringWithString:strFirstKey];
        for (int i = 1; i < [_public_keys count]; i++)
        {
            [strAvailableKeys appendFormat:@",\"%@\"", [_public_keys objectAtIndex:i]];
        }
        httpBody = [httpBody stringByReplacingOccurrencesOfString:@":PARAM:AVAILABLE:KEYS:" withString:[NSString stringWithFormat:@"%@", strAvailableKeys]];
    }
    return httpBody;
}

- (NSString *)getSignTransactionHTTPBody
{
    NSString *httpBody = @"";
    httpBody = sing_transaction_template;
    if (![Utility isEmptyString:httpBody])
    {
        httpBody = [httpBody stringByReplacingOccurrencesOfString:@":PARAM:EXPIRY:" withString:[NSString stringWithFormat:@"\"%@\"", [Utility getExpiryDateAsString]]];
        httpBody = [httpBody stringByReplacingOccurrencesOfString:@":PARAM:REF_BLOCK_NUM:" withString:_blockInfo.block_num];
        httpBody = [httpBody stringByReplacingOccurrencesOfString:@":PARAM:REF_BLOCK_PREFIX:" withString:_blockInfo.ref_block_prefix];
        NSString *strActions;
        for (int i = 0; i < [_eosActions count]; i++)
        {
            EOSAction *action = [_eosActions objectAtIndex:i];
            NSString *singleAction = single_action_template;
            singleAction = [singleAction stringByReplacingOccurrencesOfString:@":PARAM:ACCOUNT:" withString:[NSString stringWithFormat:@"\"%@\"", action.account]];
            singleAction = [singleAction stringByReplacingOccurrencesOfString:@":PARAM:ACTION:" withString:[NSString stringWithFormat:@"\"%@\"", action.action]];
            singleAction = [singleAction stringByReplacingOccurrencesOfString:@":PARAM:AUTH:USER:" withString:[NSString stringWithFormat:@"\"%@\"", action.auth_userid]];
            singleAction = [singleAction stringByReplacingOccurrencesOfString:@":PARAM:BIN:DATA:" withString:[NSString stringWithFormat:@"\"%@\"", [_binaryArgs objectAtIndex:i]]];
            if (i > 0)
            {
                strActions = [NSString stringWithFormat:@"%@,%@", strActions, singleAction];
            }
            else
            {
                strActions = singleAction;
            }
        }
        httpBody = [httpBody stringByReplacingOccurrencesOfString:@":PARAM:ACTIONS:" withString:strActions];
        NSString *strFirstKey = @"";
        if ([_public_keys count] > 0)
        {
            strFirstKey = [NSString stringWithFormat:@"\"%@\"", [_reqired_keys objectAtIndex:0]];
        }
        httpBody = [httpBody stringByReplacingOccurrencesOfString:@":PARAM:REQUIRED:KEYS:" withString:[NSString stringWithFormat:@"%@", strFirstKey]];
        if (![Utility isEmptyString:_chainInfo.chain_id])
        {
            httpBody = [httpBody stringByReplacingOccurrencesOfString:@":PARAM:CHAIN:ID:" withString:[NSString stringWithFormat:@"\"%@\"", _chainInfo.chain_id]];
        }
    }
    NSLog(@"Sign Transaction Http Body : %@", httpBody);
    return httpBody;
}

- (NSString *)getPushTransactionHTTPBody:(NSDictionary *)config
{
    NSString *httpBody = @"";
    NSString *transaction = @"";
    
    transaction = transaction_template;
    transaction = [transaction stringByReplacingOccurrencesOfString:@":PARAM:EXPIRY:" withString:[NSString stringWithFormat:@"\"%@\"", [config objectForKey:@"expiration"]]];
    transaction = [transaction stringByReplacingOccurrencesOfString:@":PARAM:REF_BLOCK_NUM:" withString:[NSString stringWithFormat:@"\"%@\"", _blockInfo.block_num]];
    transaction = [transaction stringByReplacingOccurrencesOfString:@":PARAM:REF_BLOCK_PREFIX:" withString:[NSString stringWithFormat:@"\"%@\"", _blockInfo.ref_block_prefix]];
    NSString *strActions;
    for (int i = 0; i < [_eosActions count]; i++)
    {
        EOSAction *action = [_eosActions objectAtIndex:i];
        NSString *singleAction = single_action_template;
        singleAction = [singleAction stringByReplacingOccurrencesOfString:@":PARAM:ACCOUNT:" withString:[NSString stringWithFormat:@"\"%@\"", action.account]];
        singleAction = [singleAction stringByReplacingOccurrencesOfString:@":PARAM:ACTION:" withString:[NSString stringWithFormat:@"\"%@\"", action.action]];
        singleAction = [singleAction stringByReplacingOccurrencesOfString:@":PARAM:AUTH:USER:" withString:[NSString stringWithFormat:@"\"%@\"", action.auth_userid]];
        singleAction = [singleAction stringByReplacingOccurrencesOfString:@":PARAM:BIN:DATA:" withString:[NSString stringWithFormat:@"\"%@\"", [_binaryArgs objectAtIndex:i]]];
        if (i > 0)
        {
            strActions = [NSString stringWithFormat:@"%@,%@", strActions, singleAction];
        }
        else
        {
            strActions = singleAction;
        }
    }
    transaction = [transaction stringByReplacingOccurrencesOfString:@":PARAM:ACTIONS:" withString:strActions];
    
    NSError *error;
    NSData *pckdata = [transaction dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *discTrans = [NSJSONSerialization JSONObjectWithData:pckdata options:NSJSONReadingMutableContainers error:&error];
    NSString *pckdtx = [[EosByteWriter getBytesForSignature:nil andParams: discTrans  andCapacity:512] hexadecimalString];
    
    NSLog(@"Packed Trxn : %@", pckdtx);
    
    httpBody = push_transaction_template;
    if (![Utility isEmptyString:httpBody])
    {
        NSString *strFirstKey = @"";
        if ([_public_keys count] > 0)
        {
            strFirstKey = [NSString stringWithFormat:@"\"%@\"", [_signatures objectAtIndex:0]];
        }
        httpBody = [httpBody stringByReplacingOccurrencesOfString:@":PARAM:SINGNATURES:" withString:[NSString stringWithFormat:@"%@", strFirstKey]];
        httpBody = [httpBody stringByReplacingOccurrencesOfString:@":PARAM:PACKED:TRX:" withString:[NSString stringWithFormat:@"\"%@\"", pckdtx]];
    }
    NSLog(@"Push transacton : %@", httpBody);
    return httpBody;
}


- (void)continuePushTransaction
{
    switch (_currentEOSTransactionStep)
    {
        case EOSTransactionStepABItoBIN:
            [self abiToJson:_currentActionObject];
            break;
        case EOSTransactionStepGetChainInfo:
            [self getChainInfo];
            break;
        case EOSTransactionStepGetPublicKeys:
            [self getPublicKeys];
            break;
        case EOSTransactionStepGetBlock:
            [self getBlock];
            break;
        case EOSTransactionStepGetRequiredKeys:
            [self getRequiredKeys];
            break;
        default:
            if (_delegate && [_delegate respondsToSelector:@selector(pushTransactionFailedWithError:)])
            {
                [_delegate pushTransactionFailedWithError:NSLocalizedString(@"Unknown Error!", nil)];
            }
            break;
    }
}

- (void)webServiceReceivedResponse:(NSData *)data request:(EOSRequest *)request withSender:(id)sender
{
    NSString *content = [[NSString alloc]  initWithBytes:[data bytes]
                                                  length:[data length] encoding: NSUTF8StringEncoding];
    if (content.length > 0)
    {
        NSLog(@"WS Response %@: %@", request.requestEndPointKey, content);
        id config;
        NSError *error = nil;
        @try
        {
            config = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
            
            if ([config respondsToSelector:@selector(objectForKey:)])
            {
                if ([config objectForKey:@"error"] != nil)
                {
                    [self handleError:config];
                    return;
                }
            }
            
            if ([request.requestEndPointKey isEqualToString:@"unlock_wallet"])
            {
                [self continuePushTransaction];
            }
            else if ([request.requestEndPointKey isEqualToString:@"abi_json_to_bin"])
            {
                NSString *binArgs = [(NSDictionary *)config objectForKey:@"binargs"];
                if (![Utility isEmptyString:binArgs])
                {
                    [_binaryArgs addObject:binArgs];
                    if (_actionCounter < [_eosActions count])
                    {
                        [self abiToJson:[_eosActions objectAtIndex:_actionCounter]];
                        _actionCounter++;
                    }
                    else
                    {
                        [self getChainInfo];
                    }
                }
            }
            else if([request.requestEndPointKey isEqualToString:@"get_info"])
            {
                if (config != nil)
                {
                    _chainInfo = [[EOSChainInfo alloc] initWithDictionary:(NSDictionary *)config];
                    [self getPublicKeys];
                }
            }
            else if([request.requestEndPointKey isEqualToString:@"get_public_keys"])
            {
                _public_keys = (NSArray *)config;
                [self getBlock];
            }
            else if([request.requestEndPointKey isEqualToString:@"get_block"])
            {
                _blockInfo = [[EOSBlockInfo alloc] initWithDictionary:(NSDictionary *)config];
                [self getRequiredKeys];
            }
            else if([request.requestEndPointKey isEqualToString:@"get_required_keys"])
            {
                _reqired_keys = (NSArray *)[config objectForKey:@"required_keys"];
                [self signTransaction];
            }
            else if([request.requestEndPointKey isEqualToString:@"sign_transaction"])
            {
                _signatures = (NSArray *)[config objectForKey:@"signatures"];
                [self pushTransaction:config];
                NSLog(@"%@", config);
            }
            else if([request.requestEndPointKey isEqualToString:@"push_transaction"])
            {
                NSLog(@"%@", config);
                if (_delegate && [_delegate respondsToSelector:@selector(pushTransactionReceivedResponse:request:)])
                {
                    [_delegate pushTransactionReceivedResponse:config request:_eosActions];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception parsing Json %@", [exception description]);
        }
    }
}

- (void)webServiceFailedWithError:(NSError *) error withSender:(id)sender
{
    NSLog(@"%@", error);
    if (_delegate && [_delegate respondsToSelector:@selector(pushTransactionFailedWithError:)])
    {
        [_delegate pushTransactionFailedWithError:[error description]];
    }
}


@end
