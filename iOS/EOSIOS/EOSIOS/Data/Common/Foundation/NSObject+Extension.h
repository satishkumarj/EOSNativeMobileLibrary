//
//  NSObject+Extension.h
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Extension)

- (long)string_to_long:(NSString *)str;
- (NSString *)stringFromHexString:(NSString *)hexString ;
-(NSString *)randomStringWithLength:(NSInteger)len ;
- (void)out_char:(unsigned char * )base andLength:(int)length;
- (void)out_Hex:(unsigned char * )base andLength:(int)length;
+ (void)out_Int8_t:( char * )base andLength:(int)length;
- (NSString *)hexFromBytes:(unsigned char *)Hex andLength:(int)length;
- (NSData *)convertHexStrToData:(NSString *)str;
+ (void)logoutByteWithNSData:(NSData *)buf andLength:(int)length;
+ (NSInteger)compare_charWithCharA:(unsigned char *)charA andCharB:(unsigned char *)charB;


@end
