//
//  EOSChainInfo.m
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft. All rights reserved.
//

#import "EOSChainInfo.h"

@implementation EOSChainInfo

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)disc
{
    self = [self init];
    
    self.server_version = [disc objectForKey:@"server_version"];
    self.chain_id = [disc objectForKey:@"chain_id"];
    self.head_block_num = [disc objectForKey:@"head_block_num"];
    self.last_irreversible_block_num = [disc objectForKey:@"last_irreversible_block_num"];
    self.last_irreversible_block_id = [disc objectForKey:@"last_irreversible_block_id"];
    self.head_block_id = [disc objectForKey:@"head_block_id"];
    self.head_block_time = [disc objectForKey:@"head_block_time"];
    self.head_block_producer = [disc objectForKey:@"head_block_producer"];
    self.virtual_block_cpu_limit = [disc objectForKey:@"virtual_block_cpu_limit"];
    self.virtual_block_net_limit = [disc objectForKey:@"virtual_block_net_limit"];
    self.block_cpu_limit = [disc objectForKey:@"block_cpu_limit"];
    self.block_net_limit = [disc objectForKey:@"block_net_limit"];
    self.server_version_string = [disc objectForKey:@"server_version_string"];
    
    return self;
}

@end
