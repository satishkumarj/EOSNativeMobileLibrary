//
//  EOSIOS.h
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOSAction.h"


@protocol EOSIOSDelegate

@optional
- (void)getAccountDetailsResponse:(NSArray *)data request:(EOSAction *)eosAction;
- (void)getAccountDetailsFailed:(NSString *)error;

- (void)getTableRowsResponse:(NSArray *)data request:(EOSAction *)eosAction;
- (void)getTableRowsFailed:(NSString *)error;

- (void)pushTransactionResponse:(NSDictionary *)data request:(NSArray *)eosActions;
- (void)pushTransactionFailed:(NSString *)error;
@end

NS_ASSUME_NONNULL_BEGIN

@interface EOSIOS : NSObject
{
    
}

@property (nonatomic, weak) id    delegate;

- (id)initWithRPCChainURL:(NSString *)chainURL andWalletURL:(NSString *)walletURL;

- (void)getAccountDetails:(EOSAction *)eosAction;
- (void)getTableRows:(EOSAction *)eosAction;
- (void)initiateTransaction:(NSArray *)eosActions;

@end

NS_ASSUME_NONNULL_END
