//
//  NSObject+Extension.h
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft Inc. All rights reserved.
//

#import "NSObject+Extension.h"

@implementation NSObject (Extension)

- (long)string_to_long:(NSString *)str{
    if (str == NULL ) {
        return 0L;
    }
    
    NSUInteger len = str.length;
    long value = 0;
    int MAX_NAME_IDX = 12;
    for (int i = 0; i <= MAX_NAME_IDX; i++) {
        long c = 0;
        
        if( i < len && i <= MAX_NAME_IDX) c = [self char_to_symbol:[str characterAtIndex:i] ];
        
        if( i < MAX_NAME_IDX) {
            c &= 0x1f;
            c <<= 64-5*(i+1);
        }
        else {
            c &= 0x0f;
        }
        value |= c;
    }
    return value;
}
- (Byte)char_to_symbol:(char)c{
    if( c >= 'a' && c <= 'z' )
        return (Byte)((c - 'a') + 6);
    if( c >= '1' && c <= '5' )
        return (Byte)((c - '1') + 1);
    return (Byte)0;
}

- (NSString *)stringFromHexString:(NSString *)hexString {
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(NSLocalizedString(@"String %@", nil),unicodeString);
    return unicodeString;
}


-(NSString *)randomStringWithLength:(NSInteger)len {
    NSString *letters = @"0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (NSInteger i = 0; i < len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    return randomString;
}


- (void)out_char:(unsigned char * )base andLength:(int)length{
    
    for (int i=0;i<length;i++){
        printf("%c",base[i]);
    }
    printf("\n");
}

- (void)out_Hex:(unsigned char * )base andLength:(int)length{
    printf("hex::\n");
    for (int i=0;i<length;i++){
        printf("%02x ",base[i]);
    }
    printf("\n");
}

+ (void)out_Int8_t:( char * )base andLength:(int)length{
    printf("Int8_t::\n");
    for (int i=0;i<length;i++){
        printf("currentInt8_t:%d, currentIndex:%d\n",base[i], i);
    }
    printf("\n");
}


- (NSString *)hexFromBytes:(unsigned char *)Hex andLength:(int)length{
    NSMutableString * result = [[NSMutableString alloc] init];
    for (int i=0; i<length; i++) {
        [result appendString:[NSString stringWithFormat:@"%02x",Hex[i]]];
    }
    return result;
}

// getByte16FromString
- (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

+ (void)logoutByteWithNSData:(NSData *)buf andLength:(int)length{
    printf("int ::%d\n", length);
    char *a = [buf bytes];
    for (int i=0;i<length;i++){
        printf("currentByte:%d ,  currentIndex:%d\n ",a[i], i);
    }
    printf("\n");
}



+ (NSInteger)compare_charWithCharA:(unsigned char *)charA andCharB:(unsigned char *)charB{
    if (sizeof(charA) == sizeof(charB)) {
        int i;
        for(i=0; i< sizeof(charA);i++){
            if(charA[i] != charB[i]){
                return 0;
            }
        }
        return 1;
    }else{
        return 0;
    }
}


@end
