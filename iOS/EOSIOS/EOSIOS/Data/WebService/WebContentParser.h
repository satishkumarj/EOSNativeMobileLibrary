//
//  WebContentParser.h
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebContentParser : NSObject

- (void)parseContent:(NSData *)content headers:(NSDictionary *)headers soap:(NSData **)soap file:(NSData **)file;
- (NSData *)buildContent:(NSString *)soap buffer:(NSData *)buffer;

@end
