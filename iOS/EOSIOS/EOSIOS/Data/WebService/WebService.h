//
//  WebService.h
//  EOSIOS
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOSRequest.h"


@protocol WebServiceDelegate
- (void)webServiceReceivedResponse:(NSData *)data request:(EOSRequest *)request withSender:(id)sender;
- (void)webServiceFailedWithError:(NSError *)error withSender:(id)sender;
@end

@interface WebService : NSObject

@property (nonatomic, strong) NSMutableData             *data;
@property (nonatomic, strong) id                        delegate;
@property (nonatomic        ) float                     webServiceTimeout;

- (void)sendRequest:(EOSRequest *) request;

@end
