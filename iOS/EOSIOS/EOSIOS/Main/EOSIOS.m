//
//  EOSIOS.m
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft. All rights reserved.
//

#import "EOSIOS.h"
#import "EOSIOSConstants.h"
#import "AccountDetailsService.h"
#import "GetTableRowsService.h"
#import "PushTransactionService.h"

@interface EOSIOS ()
{
    
}

@property (nonatomic, strong)   AccountDetailsService   *accountDetailService;
@property (nonatomic, strong)   GetTableRowsService     *getTableRowService;
@property (nonatomic, strong)   PushTransactionService  *pushTransactionService;

@end

@implementation EOSIOS


- (id)initWithRPCChainURL:(NSString *)chainURL andWalletURL:(NSString *)walletURL
{
    self = [super init];
    if (self)
    {
        [EOSIOSConstants sharedInstance].rpcChainURL = chainURL;
        [EOSIOSConstants sharedInstance].rpcWalletURL = walletURL;
    }
    return self;
}

- (void)getAccountDetails:(EOSAction *)eosAction
{
    if (_accountDetailService == nil)
    {
        _accountDetailService = [[AccountDetailsService alloc] init];
    }
    _accountDetailService.delegate = self;
    [_accountDetailService getAccountDetails:eosAction];
}

- (void)getTableRows:(EOSAction *)eosAction
{
    if (_getTableRowService == nil)
    {
        _getTableRowService = [[GetTableRowsService alloc] init];
    }
    _getTableRowService.delegate = self;
    [_getTableRowService getTableRows:eosAction];
}

- (void)initiateTransaction:(NSArray *)eosActions
{
    if (_pushTransactionService == nil)
    {
        _pushTransactionService = [[PushTransactionService alloc] init];
    }
    _pushTransactionService.delegate = self;
    [_pushTransactionService initiateTransaction:eosActions];
}

#pragma mark - Account Details Service

- (void)getAccountDetailsReceivedResponse:(NSArray *)data request:(EOSAction *)eosAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(getAccountDetailsReceivedResponse:request:)])
    {
        [_delegate getAccountDetailsReceivedResponse:data request:eosAction];
    }
}

- (void)getAccountDetailsFailedWithError:(NSString *) error
{
    if (_delegate && [_delegate respondsToSelector:@selector(getAccountDetailsFailed:)])
    {
        [_delegate getAccountDetailsFailed:error];
    }
}

#pragma mark - Get Table Rows Service

- (void)getTableRequestSuccessful:(NSArray *)objectList andRequestObject:(EOSAction *)request;
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(getAccountDetailsReceivedResponse:request:)])
    {
        [self.delegate getTableRowsResponse:objectList request:request];
    }
}

- (void)getTableFailedWithError:(NSString *)error andRequestObject:(EOSAction *)request
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(getTableRowsFailed:)])
    {
        [self.delegate getTableRowsFailed:error];
    }
    else
    {
        NSLog(@"Error %@", error);
    }
}

#pragma mark - Push Transaction Service

- (void)pushTransactionReceivedResponse:(NSDictionary *)data request:(NSArray *)eosActions
{
    if (_delegate && [_delegate respondsToSelector:@selector(pushTransactionReceivedResponse:request:)])
    {
        [_delegate pushTransactionReceivedResponse:data request:eosActions];
    }
}

- (void)pushTransactionFailedWithError:(NSString *) error
{
    if (_delegate && [_delegate respondsToSelector:@selector(pushTransactionFailed:)])
    {
        [_delegate pushTransactionFailed:error];
    }
}

#pragma mark -

@end
