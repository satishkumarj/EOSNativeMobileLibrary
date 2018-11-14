//
//  GetTableRowsService.h
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOSAction.h"

@protocol GetTableRowsServiceDelegate
- (void)getTableRowsReceivedResponse:(NSArray *)data request:(EOSAction *)eosAction;
- (void)getTableRowsFailedWithError:(NSString *) error;
@end

@interface GetTableRowsService : NSObject
{
    
}

@property (nonatomic, strong) id                delegate;

- (void)getTableRows:(EOSAction *)eosAction;

@end
