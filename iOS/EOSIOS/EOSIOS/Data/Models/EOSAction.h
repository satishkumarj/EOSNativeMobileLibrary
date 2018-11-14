//
//  EOSAction.h
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface EOSAction : NSObject
{
    
}

@property (nonatomic, strong)   NSString    *url_endpoint_key;
@property (nonatomic, strong)   NSString    *url_port;
@property (nonatomic, strong)   NSString    *action;
@property (nonatomic, strong)   NSString    *account;
@property (nonatomic, strong)   NSString    *auth_userid;
@property (nonatomic, strong)   NSString    *scope;
@property (nonatomic, strong)   NSString    *args;
@property (nonatomic, strong)   NSString    *action_wallet_name;
@property (nonatomic, strong)   NSString    *action_wallet_private_key;

@end
