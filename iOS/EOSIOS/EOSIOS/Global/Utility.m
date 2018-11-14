//
//  Utility.m
//  cogneosapp
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft. All rights reserved.
//

#import "Utility.h"

@interface Utility()
{
    
}

@end

@implementation Utility

+ (BOOL)isEmptyString:(NSString *)str
{
    if (str == nil || [str isEqualToString:@""])
    {
        return YES;
    }
    return ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0);
}

+ (NSString *)getExpiryDateAsString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd'T'HH:mm:ss.SSS"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    NSDate *date = [[NSDate date] dateByAddingTimeInterval: 90 ];
    NSString *stringFromDate = [formatter stringFromDate:date];
    
    return stringFromDate;
}

@end
