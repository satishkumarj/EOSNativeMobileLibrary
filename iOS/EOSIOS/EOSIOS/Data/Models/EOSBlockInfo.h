//
//  EOSBlockInfo.h
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EOSBlockInfo : NSObject
{
    
}

@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, strong) NSString *producer;
@property (nonatomic, strong) NSString *confirmed;
@property (nonatomic, strong) NSString *transaction_mroot;
@property (nonatomic, strong) NSString *action_mroot;
@property (nonatomic, strong) NSString *schedule_version;
@property (nonatomic, strong) NSString *producers_new;
@property (nonatomic, strong) NSArray  *header_extensions;
@property (nonatomic, strong) NSString *producer_signature;
@property (nonatomic, strong) NSArray  *transactions;
@property (nonatomic, strong) NSArray  *block_extensions;
@property (nonatomic, strong) NSString *block_id;
@property (nonatomic, strong) NSString *block_num;
@property (nonatomic, strong) NSString *ref_block_prefix;

- (id)initWithDictionary:(NSDictionary *)disc;

@end

NS_ASSUME_NONNULL_END
