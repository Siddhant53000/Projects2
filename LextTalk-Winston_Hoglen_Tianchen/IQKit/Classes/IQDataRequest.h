//
//  IQDataRequest.h
//
//  Created by David on 2/10/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IQDataRequest : NSObject {
	NSString			*_url;
	id					__weak _delegate;
	NSMutableData		*_data;
	NSURLConnection		*_connection;
	NSDate				*_cacheDate;
	NSDictionary		*_cachedResponse;
	NSString			*_note;
	id					_context;
    id					_request;
}

@property (nonatomic,strong) NSString *url;
@property (nonatomic,weak) id delegate;
@property (nonatomic,strong) NSURLConnection *connection;
@property (nonatomic,strong) NSMutableData *data;
@property (nonatomic,strong) NSDate *cacheDate;
@property (nonatomic,strong) NSDictionary *cachedResponse;
@property (nonatomic,strong) NSString *note;
@property (nonatomic,strong) id context;
@property (nonatomic,strong) id request;

+ (IQDataRequest*) withURL: (NSString*)nURL delegate:(id)del note: (NSString*) nNote;


@end
