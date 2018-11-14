//
//  WebService.h
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft Inc. All rights reserved.
//

#import "WebService.h"
#import "WebContentParser.h"
#import "Utility.h"
#import <Foundation/Foundation.h>

const float TIMEOUTINTERVAL = 300.0;


@interface WebService()<NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate, NSURLSessionStreamDelegate> {
    NSDictionary* headers;
    NSArray *allCookies;
    EOSRequest *_requestCopy;
    NSData   *_fileBytesCopy;
    
}

@property (nonatomic, strong) NSURLSessionDataTask *urlSessionTask;
@property (nonatomic, strong) NSURLSession *urlSession;

@property (nonatomic, assign) BOOL isUntrustedServerRefused;
@property (nonatomic, assign) BOOL isCertificateExpired;
@property (nonatomic, assign) BOOL isCNMismatchedWithHost;

@end


@implementation WebService

static NSMutableDictionary *cookies;

- (void)sendRequest:(EOSRequest *)request
{
    if (_webServiceTimeout < 5)
        _webServiceTimeout = TIMEOUTINTERVAL;
    if (cookies == nil)
        cookies = [[NSMutableDictionary alloc] init];
    _requestCopy  = request;
    if (_urlSession == nil)
    {
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:self delegateQueue: [NSOperationQueue mainQueue]];
    }
    @try
    {
        NSDictionary *headers = @{ @"content-type": @"application/json",
                                   @"cache-control": @"no-cache"};
        
        NSURL *url = [NSURL URLWithString:[self getRequestEndpoint:request]];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:_webServiceTimeout];
        [urlRequest setHTTPMethod:request.requestType];
        [urlRequest setAllHTTPHeaderFields:headers];
        if (![Utility isEmptyString:request.http_body])
        {
            [urlRequest setHTTPBody:[request.http_body dataUsingEncoding:NSUTF8StringEncoding]];
        }
        _urlSessionTask = [_urlSession dataTaskWithRequest:urlRequest];
        [_urlSessionTask resume];
    }
    @catch (NSException *ex) {
        NSError *connectionError = [NSError errorWithDomain:NSLocalizedString(@"Error receiving data from server.",nil) code:0 userInfo:nil];
        if(_delegate && [_delegate respondsToSelector:@selector(webServiceFailedWithError:withSender:)]) {
            [_delegate webServiceFailedWithError:connectionError withSender:self];
        }
    }
    return;
}

- (NSString *)getRequestEndpoint:(EOSRequest *)objRequest
{
    NSString *url = @"";
    NSString *endPoint = @"";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"/Frameworks/EOSIOS.framework/EndPoints" ofType:@"json"];
    
    if (path != nil)
    {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSError *error = nil;
        NSDictionary *json;
        
        @try
        {
            json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (![Utility isEmptyString:objRequest.requestEndPointKey])
            {
                endPoint = [json objectForKey:objRequest.requestEndPointKey];
            }
            url = [NSString stringWithFormat:@"%@/%@", objRequest.requestURL, endPoint];
        }
        @catch (NSException *exception)
        {
            url = @"";
        }
    }
    return url;
}

- (void)handleSession:(NSData *)responseData response:(NSURLResponse *)response withError:(NSError *)error
{
    if(!error)
    {
        WebContentParser *webContentHandler = [[WebContentParser alloc] init];
        NSData *soap;
        NSData *file;
        self.data = [NSMutableData dataWithData:responseData];
        [webContentHandler parseContent:self.data headers:headers soap:&soap file:&file];
        if(_delegate && [_delegate respondsToSelector:@selector(webServiceReceivedResponse:request:withSender:)]) {
            [_delegate webServiceReceivedResponse:soap request:_requestCopy withSender:self];
        }
    }
    else
    {
        if(_delegate && [_delegate respondsToSelector:@selector(webServiceFailedWithError:withSender:)]) {
            [_delegate webServiceFailedWithError:error withSender:self];
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location
{
    NSLog(@"downloadTask nsurl location %@", location);
    NSData *fileData = [NSData dataWithContentsOfURL:location];
    if (fileData != nil)
    {
        if (self.data == nil)
            self.data = [[NSMutableData alloc] initWithData:fileData];
        else
            [self.data appendData:fileData];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSLog(@"response: %@", response.debugDescription);
    
    headers = [(NSHTTPURLResponse *)response allHeaderFields];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", _requestCopy.requestURL, _requestCopy.requestEndPointKey]];
    allCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:headers forURL:url];
    
    for (NSHTTPCookie *aCookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url]){
        NSLog(@"Cookie deleted %@", aCookie);
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:aCookie];
    }
    
    NSURLSessionResponseDisposition disposition = NSURLSessionResponseAllow;
    if (completionHandler)
    {
        completionHandler(disposition);
    }
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)_data
{
    if (self.data == nil)
        self.data = [[NSMutableData alloc] initWithData:_data];
    else
        [self.data appendData:_data];
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error != nil)
    {
        NSLog(@"Task: %@ completed with error: %@", task, [error localizedDescription]);
    }
    [self handleSession:self.data response:nil withError:error];
}

@end
