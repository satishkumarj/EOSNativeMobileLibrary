//
//  Utility.h
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Utility : NSObject
{
    
}

+ (BOOL)isEmptyString:(NSString *)str;
+ (NSString *)getExpiryDateAsString;;

@end

NS_ASSUME_NONNULL_END
