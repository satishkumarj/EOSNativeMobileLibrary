//
//  EOSRequest.h
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EOSRequest : NSObject
{
    
}

@property (nonatomic, strong)   NSString            *requestType;
@property (nonatomic, strong)   NSString            *requestEndPointKey;
@property (nonatomic        )   BOOL                requestSuccessful;
@property (nonatomic, strong)   NSString            *requestParam;
@property (nonatomic, strong)   NSString            *responseError;
@property (nonatomic        )   NSInteger           erroCode;
@property (nonatomic, strong)   NSDictionary        *responseData;
@property (nonatomic, strong)   NSArray             *responseList;
@property (nonatomic        )   BOOL                httpBodyTypeisCollection;
@property (nonatomic, strong)   NSArray             *requestBodyObjects;
@property (nonatomic, strong)   NSString            *http_body;
@property (nonatomic, strong)   NSString            *requestURL;

@end

NS_ASSUME_NONNULL_END
