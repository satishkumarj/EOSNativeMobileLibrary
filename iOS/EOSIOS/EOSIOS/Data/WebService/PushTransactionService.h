//
//  PushTransaction.h
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOSAction.h"

@protocol PushTransactionServiceDelegate
- (void)pushTransactionReceivedResponse:(NSDictionary *)data request:(NSArray *)eosActions;
- (void)pushTransactionFailedWithError:(NSString *) error;
@end

@interface PushTransactionService : NSObject
{
    
}

@property (nonatomic, strong) id                delegate;

- (void)initiateTransaction:(NSArray *)eosActions;

@end
