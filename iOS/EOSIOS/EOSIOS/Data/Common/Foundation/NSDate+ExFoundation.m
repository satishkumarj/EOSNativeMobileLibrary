//
//  NSDate+NSDate_ExFoundation.m
//  Giivv
//
//  Created by Xiong,Zijun on 16/5/1.
//  Copyright © 2016  Youdar . All rights reserved.
//

#import "NSDate+ExFoundation.h"

#define IsNilOrNull(_ref)   (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) || ([(_ref) isEqual:[NSNull class]]))

@implementation NSDate (ExFoundation)
#pragma makr - date fransfer
+ (NSDate *)dateWithDouble:(double) timeSpan{
    return [NSDate dateWithTimeIntervalSince1970: timeSpan / 1000.0f];
}

#pragma mark - tommorrow date
+ (NSDate *)tommorrow{
    return  [NSDate dateWithTimeIntervalSinceNow:24 * 60 * 60];
}

#pragma mark - ISO 8601
+ (NSDate *)dateFromISO8601String:(NSString *)string {
    if (IsNilOrNull(string)){
        return nil;
    }
    
    struct tm tm;
    time_t t;
    
    strptime([string cStringUsingEncoding:NSUTF8StringEncoding], "%Y-%m-%dT%H:%M:%S%z", &tm);
    tm.tm_isdst = -1;
    t = mktime(&tm);
    
    return [NSDate dateWithTimeIntervalSince1970:t];
}

#pragma mark - ISO 8601
- (NSString *)formatterToISO8601{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    
    NSString *formattedDateString = [dateFormatter stringFromDate: self];
    return formattedDateString;
}


+ (NSDate *)dateFromString:(NSString *)string
{
    NSString *dateString = string;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    if ([string containsString:@"."]) {
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    }else{
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    }
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    
    NSDate *date=[formatter dateFromString:dateString];
    return date;
}

- (NSString *)formatterToWeekDay{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEE MM/dd HH:mma";
    
    NSString *formattedDateString = [dateFormatter stringFromDate: self];
    return formattedDateString;
}

#pragma mark - date formate
- (NSString *)stringFormate:(NSString *) formation{
    if(IsNilOrNull(formation)){
        return nil;
    }
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat: formation];
    return [dateFormater stringFromDate: self];
}

#pragma mark - timeStamp from date
- (NSNumber *)timeStamp{
//    NSLog(@"%@", [self stringFormate: @"yyyy-MM-dd"]);
    NSString *dateString = [self stringFormate: @"MM/dd/yyyy"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *utcDate = [dateFormatter dateFromString: dateString];
    return @((long long)[utcDate timeIntervalSince1970] * 1000);
}

- (BOOL)largeAndEqualDate:(NSDate *)date{
    
    if(IsNilOrNull(date)){
        return YES;
    }
    
    NSComparisonResult result = [self compare: date];
    switch (result){
            
        case NSOrderedAscending:
            //date2比date1大
            return NO;
        case NSOrderedDescending:
            //date2比date1小
            return YES;
        case NSOrderedSame:
            //date2=date1
            return YES;
    }
}

- (BOOL)lowerAndEqualDate:(NSDate *)date{
    
    if(IsNilOrNull(date)){
        return YES;
    }
    
    NSComparisonResult result = [self compare: date];
    switch (result){
            
        case NSOrderedAscending:
            //date2比date1大
            return YES;
        case NSOrderedDescending:
            //date2比date1小
            return NO;
        case NSOrderedSame:
            //date2=date1
            return YES;
    }
}



+ (int)getTimeStampUTCWithTimeString:(NSString *)timeString{
    
    NSDate *date = [NSDate dateFromString:timeString];//format :@"2018-01-01T08:00:00"
    int a = [date timeIntervalSince1970];
    NSLog(@"\n=====%@\n ====%d\n", date, a);
    return a;
}


@end
