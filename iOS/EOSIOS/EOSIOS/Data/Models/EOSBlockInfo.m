//
//  EOSBlockInfo.m
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft. All rights reserved.
//

#import "EOSBlockInfo.h"

@implementation EOSBlockInfo

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
    
    self.timestamp  = [disc objectForKey:@"server_version"];
    self.producer  = [disc objectForKey:@"producer"];
    self.confirmed  = [disc objectForKey:@"confirmed"];
    self.transaction_mroot = [disc objectForKey:@"transaction_mroot"];
    self.action_mroot  = [disc objectForKey:@"action_mroot"];
    self.schedule_version  = [disc objectForKey:@"schedule_version"];
    self.producers_new  = [disc objectForKey:@"new_producers"];
    self.header_extensions = (NSArray *)[disc objectForKey:@"header_extensions"];
    self.producer_signature  = [disc objectForKey:@"producer_signature"];
    self.transactions = (NSArray *)[disc objectForKey:@"transactions"];;
    self.block_extensions = (NSArray *)[disc objectForKey:@"block_extensions"];
    self.block_id  = [disc objectForKey:@"id"];
    self.block_num  = [[disc objectForKey:@"block_num"] stringValue];
    self.ref_block_prefix  = [[disc objectForKey:@"ref_block_prefix"] stringValue];
    
    return self;
}

@end
