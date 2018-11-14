//
//  AccountDetailsService.h
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOSAction.h"


@protocol AccountDetialsServiceDelegate
- (void)getAccountDetailsReceivedResponse:(NSArray *)data request:(EOSAction *)eosAction;
- (void)getAccountDetailsFailedWithError:(NSString *)error;
@end

@interface AccountDetailsService : NSObject
{
    
}


@property (nonatomic, weak) id    delegate;

- (void)getAccountDetails:(EOSAction *)eosAction;

@end
