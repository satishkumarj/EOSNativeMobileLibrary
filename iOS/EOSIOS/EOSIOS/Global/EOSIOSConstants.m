//
//  EOSIOSConstants.m
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft. All rights reserved.
//

#import "EOSIOSConstants.h"

NSString *const transaction_data_template = @"{\"code\": \"%@\", \"action\": \"%@\", \"args\": {%@}}";
NSString *const get_required_keys_template = @"{"
"\"transaction\": {"
"\"expiration\": :PARAM:EXPIRY:,"
"\"ref_block_num\": :PARAM:REF_BLOCK_NUM:,"
"\"ref_block_prefix\": :PARAM:REF_BLOCK_PREFIX:,"
"\"max_net_usage_words\": 0,"
"\"max_cpu_usage_ms\": 0,"
"\"delay_sec\": 0,"
"\"context_free_actions\": [],"
"\"actions\": [:PARAM:ACTIONS:],"
"\"transaction_extensions\": []"
"},"
"\"available_keys\": [:PARAM:AVAILABLE:KEYS:] }";
NSString *const transaction_template = @"{"
"\"expiration\": :PARAM:EXPIRY:,"
"\"ref_block_num\": :PARAM:REF_BLOCK_NUM:,"
"\"ref_block_prefix\": :PARAM:REF_BLOCK_PREFIX:,"
"\"max_net_usage_words\": 0,"
"\"max_cpu_usage_ms\": 0,"
"\"delay_sec\": 0,"
"\"context_free_actions\": [],"
"\"actions\": [:PARAM:ACTIONS:],"
"\"transaction_extensions\": []"
"}";
NSString *const sing_transaction_template = @"["
"{"
"\"expiration\": :PARAM:EXPIRY:,"
"\"ref_block_num\": :PARAM:REF_BLOCK_NUM:,"
"\"ref_block_prefix\": :PARAM:REF_BLOCK_PREFIX:,"
"\"max_net_usage_words\": 0,"
"\"max_cpu_usage_ms\": 0,"
"\"delay_sec\": 0,"
"\"context_free_actions\": [],"
"\"actions\": [:PARAM:ACTIONS:"
"],"
"\"transaction_extensions\": [],"
"\"signatures\":[]"
"},"
"[:PARAM:REQUIRED:KEYS:],"
":PARAM:CHAIN:ID:"
"]";

NSString *const single_action_template = @"{"
"\"account\": :PARAM:ACCOUNT:,"
"\"name\": :PARAM:ACTION:,"
"\"authorization\": [{"
"\"actor\": :PARAM:AUTH:USER:,"
"\"permission\": \"active\"}"
"],"
"\"data\": :PARAM:BIN:DATA:}";

NSString *const push_transaction_template = @"{"
"\"compression\": \"none\","
"\"packed_context_free_data\": \"00\","
"\"packed_trx\": :PARAM:PACKED:TRX:,"
"\"signatures\": [:PARAM:SINGNATURES:]"
"}";

@implementation EOSIOSConstants

static EOSIOSConstants *sharedSingleton = nil;
+ (EOSIOSConstants *)sharedInstance
{
    @synchronized(self)
    {
        if(!sharedSingleton)
        {
            sharedSingleton = [[EOSIOSConstants alloc] init];
        }
        return sharedSingleton;
    }    
}

@end
