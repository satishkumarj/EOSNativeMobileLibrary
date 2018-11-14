//
//  GetTableRowsService.m
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft Inc. All rights reserved.
//

#import "GetTableRowsService.h"
#import "WebService.h"
#import "EOSRequest.h"
#import "Utility.h"
#import "EOSIOSConstants.h"

@interface GetTableRowsService()
{
    
}

@property (nonatomic, strong)   EOSAction       *currentActionObject;
@property (nonatomic, strong)   WebService      *webService;

@end


@implementation GetTableRowsService

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)getTableRows:(EOSAction *)eosAction
{
    _currentActionObject = eosAction;
    EOSRequest *request = [[EOSRequest alloc] init];
    request.requestEndPointKey = eosAction.url_endpoint_key;
    request.requestURL = [EOSIOSConstants sharedInstance].rpcChainURL;
    request.requestType = @"POST";
    request.http_body = [NSString stringWithFormat:@"{%@}", _currentActionObject.args];
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
        if (_delegate && [_delegate respondsToSelector:@selector(getTableRowsFailedWithError:)])
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
            [_delegate getTableRowsFailedWithError:error];
        }
    }
}

#pragma mark - Web Service Delegate Methods

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
            NSLog(@"%@", config);
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
                [self getTableRows:_currentActionObject];
            }
            else
            {
                if (_delegate && [_delegate respondsToSelector:@selector(getTableRowsReceivedResponse:request:)])
                {
                    if (![config isKindOfClass:[NSArray class]])
                    {
                        NSArray *data = [config objectForKey:@"rows"];
                        [_delegate getTableRowsReceivedResponse:data request:_currentActionObject];
                    }
                    else
                    {
                        NSArray *rows = [[config objectAtIndex:0] objectForKey:@"rows"];
                        [_delegate getTableRowsReceivedResponse:rows request:_currentActionObject];
                    }
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
    if (_delegate && [_delegate respondsToSelector:@selector(getTableRowsFailedWithError:)])
    {
        [_delegate getTableRowsFailedWithError:[error description]];
    }
}

@end
