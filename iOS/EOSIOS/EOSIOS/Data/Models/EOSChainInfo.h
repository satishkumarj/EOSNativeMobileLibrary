//
//  EOSChainInfo.h
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EOSChainInfo : NSObject
{
    
}

@property (nonatomic, strong) NSString *server_version;
@property (nonatomic, strong) NSString *chain_id;
@property (nonatomic, strong) NSString *head_block_num;
@property (nonatomic, strong) NSString *last_irreversible_block_num;
@property (nonatomic, strong) NSString *last_irreversible_block_id;
@property (nonatomic, strong) NSString *head_block_id;
@property (nonatomic, strong) NSString *head_block_time;
@property (nonatomic, strong) NSString *head_block_producer;
@property (nonatomic, strong) NSString *virtual_block_cpu_limit;
@property (nonatomic, strong) NSString *virtual_block_net_limit;
@property (nonatomic, strong) NSString *block_cpu_limit;
@property (nonatomic, strong) NSString *block_net_limit;
@property (nonatomic, strong) NSString *server_version_string;

- (id)initWithDictionary:(NSDictionary *)disc;

@end

NS_ASSUME_NONNULL_END
