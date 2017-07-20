//
//  IQDataSource.h
//
//  Created by David on 2/10/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IQDataRequest.h"
#import "ASIHTTPRequestDelegate.h"
#import "ASIFormDataRequest.h"

@interface IQDataSource : NSObject <ASIHTTPRequestDelegate> {
	NSMutableArray			*_requests;
}

@property (nonatomic, strong) NSMutableArray *requests;

- (void) voidAllRequests;
- (void) removeFromRequestDelegates: (id) del;
- (void) sendRequest:(IQDataRequest*) dataRequest;

@end
