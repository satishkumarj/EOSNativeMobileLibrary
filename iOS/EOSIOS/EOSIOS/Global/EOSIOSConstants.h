//
//  EOSIOSConstants.h
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EOSIOSConstants : NSObject
{
    
}

+ (EOSIOSConstants *)sharedInstance;

extern NSString *const push_transaction_template;
extern NSString *const single_action_template;
extern NSString *const sing_transaction_template;
extern NSString *const transaction_template;
extern NSString *const get_required_keys_template;
extern NSString *const transaction_data_template;


@property (nonatomic, strong)   NSString    *rpcChainURL;
@property (nonatomic, strong)   NSString    *rpcWalletURL;

@end



NS_ASSUME_NONNULL_END
