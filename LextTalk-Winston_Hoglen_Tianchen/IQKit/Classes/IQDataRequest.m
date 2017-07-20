//
//  IQDataRequest.m
//
//  Created by David on 2/10/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import "IQDataRequest.h"

@implementation IQDataRequest
@synthesize url = _url;
@synthesize delegate = _delegate;
@synthesize connection = _connection;
@synthesize data = _data;
@synthesize cacheDate = _cacheDate;
@synthesize cachedResponse = _cachedResponse;
@synthesize note = _note;
@synthesize context = _context;
@synthesize request = _request;

- (id) init {
	if (self = [super init]) {
		self.data = [NSMutableData data];
	}
	return self;
}

+ (IQDataRequest*) withURL: (NSString*)nURL delegate:(id)del note: (NSString*) nNote {
    
	IQDataRequest* cdr = [[IQDataRequest alloc] init];
	cdr.url = nURL;
	cdr.delegate = del;
	cdr.note = nNote;
	return cdr;
}

#pragma mark -
#pragma mark NSObject methods

- (void) dealloc{
    self.delegate = nil;	
}

@end
