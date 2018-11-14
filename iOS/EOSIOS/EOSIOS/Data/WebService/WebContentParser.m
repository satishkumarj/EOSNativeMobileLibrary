//
//  WebContentParser.m
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft Inc. All rights reserved.
//

#import "WebContentParser.h"

NSString *const CONST_REQUEST_BOUNDARY =  @"----=_Part_0_9717476.1180609409200";
NSString *const CONST_REQUEST_CONTENTTYPE =  @"Content-Type: text/xml; charset=UTF-8";
NSString *const CONST_REQUEST_CONTENTENCODING =  @"Content-Transfer-Encoding: binary";
NSString *const CONST_REQUEST_CONTENTID1 =  @"Content-Id: <A580516814ED19F6ED98A81DECA9CCB2>";
NSString *const CONST_REQUEST_APPLICATION =  @"Content-Type: application/octet-stream";
NSString *const CONST_REQUEST_CONTENTID2 =  @"Content-Id: <8D5F8659328CB17A9737107B27614C07>";
NSString *const CONST_REQUEST_BOUNDARYPREFIX =  @"--";
NSString *const CONST_RESPONSE_CONTENTTYPE =  @"Content-Type";
NSString *const CONST_RESPONSE_APPLICATION =  @"application";
NSString *const CONST_RESPONSE_CONTENTENCODING =  @"Content-Transfer-Encoding";
NSString *const CONST_RESPONSE_CONTENTID =  @"----=_Part_0_9717476.1180609409200";

@interface WebContentParser() {
    
}

@property (nonatomic, ) BOOL multipart;
@property (nonatomic, strong ) NSString * boundary;

- (void)parseMultiPart:(NSData *)content soap:(NSData **)soap file:(NSData **)file;


@end

@implementation WebContentParser

@synthesize multipart;
@synthesize boundary;

- (void)parseContent:(NSData *)content headers:(NSDictionary *)headers soap:(NSData **)soap file:(NSData **)file
{
    NSString *contentType =  [headers valueForKey:@"Content-Type"];
    
    if ( [contentType rangeOfString:@"multipart"].length > 0 )
    {
        self.multipart = YES;
        
        NSArray *chunks = [contentType componentsSeparatedByString: @";"];
        
        for (NSString *value in chunks) {
            if ( [value rangeOfString:@"boundary"].length )
            {
                NSArray *chunks2 = [value componentsSeparatedByString: @"="];
                self.boundary = [chunks2 objectAtIndex:1];
                self.boundary = [self.boundary stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                self.boundary = [NSString stringWithFormat:@"--%@",self.boundary];
                
            }
        }
        
        [self parseMultiPart:content soap:soap file:file];
    }
    else
    {
        self.multipart = NO;
        *soap = [[NSData alloc] initWithData:content];
    }

    
}

- (void)parseMultiPart:(NSData *)content soap:(NSData **)soap file:(NSData **)file
{
    NSData *boundaryData = [boundary dataUsingEncoding:NSUTF8StringEncoding];
    NSString *newLine = @"\r\n";
    NSData *newLineData = [newLine dataUsingEncoding:NSUTF8StringEncoding];
    NSRange rangeFrom = NSMakeRange(0,content.length);
    NSRange rangeNext; 
    for (int i = 0; i < 5; i ++)
    {
        rangeNext = [content rangeOfData:newLineData options:0 range:rangeFrom]; 
        rangeFrom = NSMakeRange(rangeNext.location + 2, content.length - (rangeNext.location + 2) );
    }
    
    rangeNext = [content rangeOfData:boundaryData options:0 range:NSMakeRange(rangeFrom.location,content.length - rangeFrom.location)];
    
    NSRange rangeSoap = NSMakeRange(rangeFrom.location, rangeNext.location - rangeFrom.location - 2);
    *soap = [content subdataWithRange:rangeSoap];
     
    rangeFrom = NSMakeRange(rangeNext.location - 2,content.length - (rangeNext.location - 2));
    for (int i = 0; i < 6; i ++)
    {
        rangeNext = [content rangeOfData:newLineData options:0 range:rangeFrom]; 
        rangeFrom = NSMakeRange(rangeNext.location + 2, content.length - (rangeNext.location + 2) );
    }
    
    rangeNext = [content rangeOfData:boundaryData options:0 range:NSMakeRange(rangeFrom.location,content.length - rangeFrom.location)];
    NSRange rangeFile = NSMakeRange(rangeFrom.location, rangeNext.location - rangeFrom.location - 2);
    *file = [content subdataWithRange:rangeFile];
}

- (void)writeLine:(NSMutableData **)data value:(NSString *)value
{
    [*data appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *newLine = @"\r\n";
    NSData *newLineData = [newLine dataUsingEncoding:NSUTF8StringEncoding];
    [*data appendData:newLineData];
}

- (NSData *)buildContent:(NSString *)soap buffer:(NSData *)buffer
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [self writeLine:&data value:@""];
    [self writeLine:&data value:[NSString stringWithFormat:@"%@%@",CONST_REQUEST_BOUNDARYPREFIX,CONST_REQUEST_BOUNDARY]];
    [self writeLine:&data value:CONST_REQUEST_CONTENTTYPE];
    [self writeLine:&data value:CONST_REQUEST_CONTENTENCODING];
    [self writeLine:&data value:CONST_REQUEST_CONTENTID1];
    [self writeLine:&data value:@""];
    [self writeLine:&data value:soap];
    [self writeLine:&data value:@""];
    [self writeLine:&data value:[NSString stringWithFormat:@"%@%@",CONST_REQUEST_BOUNDARYPREFIX,CONST_REQUEST_BOUNDARY]];
    [self writeLine:&data value:CONST_REQUEST_APPLICATION];
    [self writeLine:&data value:CONST_REQUEST_CONTENTENCODING];
    [self writeLine:&data value:CONST_REQUEST_CONTENTID2];
    [self writeLine:&data value:@""];
    [data appendData:buffer];
    [self writeLine:&data value:@""];
    [self writeLine:&data value:[NSString stringWithFormat:@"%@%@%@",CONST_REQUEST_BOUNDARYPREFIX,CONST_REQUEST_BOUNDARY,CONST_REQUEST_BOUNDARYPREFIX]];
    return data;
}
@end
