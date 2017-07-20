//
//  IQDataSource.m
//
//  Created by David on 2/10/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import "IQDataSource.h"
#import "IQVerbose.h"
#import "IQDataRequest.h"
#import "ASIFormDataRequest.h"

@interface IQDataSource (PrivateMethods)
- (IQDataRequest*) dataRequestForCon:(NSURLConnection *) con;
- (BOOL) dispatchNote: (IQDataRequest*) dataRequest;
- (void) dispatchError: (IQDataRequest *) dataRequest;
- (IQDataRequest*) dataRequestForASIHTTPRequest:( ASIHTTPRequest *) req;

@end

@implementation IQDataSource
@synthesize requests = _requests;

#pragma mark -
#pragma mark ASIHTTPRequestDelegate methods

- (void)requestFinished:(ASIHTTPRequest *)request {
	
	IQDataRequest *dataRequest = [self dataRequestForASIHTTPRequest: request];
    if(dataRequest == nil) {
        // FIXME
        return;
    }
    
    if ([request responseStatusCode]>=400) {
        NSLog(@"ERRORRRR DE BRAIS: %d", [request responseStatusCode]);
        [self requestFailed:request];
        return;
    }
	
	IQVerbose(VERBOSE_DEBUG, @"[%@] DataRequest finished loading ASIHTTPRequest (%@) URL: %@", [self class], dataRequest.note, dataRequest.url);
	[self dispatchNote: dataRequest];
    
    dataRequest.delegate = nil;
    
	[self.requests removeObject: dataRequest];
    if ([self.requests count] == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
	}    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
	IQDataRequest *dataRequest = [self dataRequestForASIHTTPRequest: request];
    if(dataRequest == nil) {
        // FIXME
        return;
    }
	
	NSLog(@"[%@] DataRequest failed loading ASIHTTPRequest (%@) URL: %@", [self class], dataRequest.note, dataRequest.url);
	
    [self dispatchError: dataRequest];
    
	[self.requests removeObject: dataRequest];
    
	if ([self.requests count] == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
	}    
}

#pragma mark -
#pragma mark NSURLRequestDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	IQDataRequest *dataRequest = [self dataRequestForCon: connection];
	if (dataRequest == nil) {
		IQVerbose(VERBOSE_WARNING,@"[%@] Data connection does not have a %@ associated!", [self class], [IQDataRequest class]);
		return;
	}
	[dataRequest.data appendData: data];
	IQVerbose(VERBOSE_DEBUG,@"[%@] Received %d bytes for %@ note", [self class], [data length], dataRequest.note);	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	IQDataRequest *dataRequest = [self dataRequestForCon: connection];
	if (dataRequest == nil) {
		IQVerbose(VERBOSE_WARNING,@"[%@] Data connection does not have a %@ associated!", [self class], [IQDataRequest class]);
		return;
	}
	
	IQVerbose(VERBOSE_DEBUG,@"[%@] Request finished loading GET request (%@)", [self class], dataRequest.note);
	
    if([self dispatchNote: dataRequest]) {
        // the note
    } else {
        IQVerbose(VERBOSE_WARNING, @"[%@] Unknown note: %@", [self class], dataRequest.note);
    }

    dataRequest.delegate = nil;
	[self.requests removeObject: dataRequest];	

	if ([self.requests count] == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
	}	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	IQDataRequest *dataRequest = [self dataRequestForCon: connection];
	if (dataRequest == nil) {
		IQVerbose(VERBOSE_WARNING,@"[%@] Data connection does not have any %@ associated!", [self class], [IQDataRequest class]);
		return;
	}
	
	IQVerbose(VERBOSE_WARNING,@"[%@] Request failed loading GET request (%@)", [self class], dataRequest.note);
    [self dispatchError: dataRequest];

    dataRequest.delegate = nil;
	[self.requests removeObject: dataRequest];	
	
	if ([self.requests count] == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
	}	
}

#pragma mark -
#pragma mark IQDataSource methods

- (BOOL) dispatchNote:(IQDataRequest *)dataRequest {
    // Override in subclasses to process each note
    // return YES if note is known by the subclass
    return YES;
}

- (void) dispatchError: (IQDataRequest *) dataRequest {
    // Override in subclasses to process each note
}

- (void) removeFromRequestDelegates: (id) del {
	for (IQDataRequest *dataRequest in self.requests) {
        if(dataRequest.delegate == del) {
            dataRequest.delegate = nil;
            IQVerbose(VERBOSE_DEBUG,@"[%@] %@ no longer delegate of %@ dataRequest", [self class], [del class], dataRequest.note);            
        }
	}
}

- (void) voidAllRequests {
	for (IQDataRequest *dataRequest in self.requests) {
		IQVerbose(VERBOSE_DEBUG,@"[%@] DataRequest %@ voided with note %@", [self class], dataRequest.url, dataRequest.note);
		[dataRequest.connection cancel];
	}
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
	[self.requests removeAllObjects];
}

- (void) sendRequest:(IQDataRequest*) dataRequest {
	IQVerbose(VERBOSE_DEBUG,@"[%@] DataRequest Sent (%@) URL: %@", [self class], dataRequest.note, dataRequest.url);
	NSURLRequest *r = [NSURLRequest requestWithURL: [NSURL URLWithString: dataRequest.url]];
	dataRequest.connection = [NSURLConnection connectionWithRequest: r delegate: self];
	[self.requests addObject: dataRequest];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
}

- (IQDataRequest*) dataRequestForCon:(NSURLConnection *) con {
	for (IQDataRequest *r in self.requests) {
		if (r.connection == con) {
			IQVerbose(VERBOSE_DEBUG, @"[%@] %@ found for note %@",[self class], [con class], r.note);			
			return r;
		}
	}
    IQVerbose(VERBOSE_WARNING, @"[%@] No %@ found",[self class], [con class]);	
	return nil;
}

- (IQDataRequest*) dataRequestForASIHTTPRequest:( ASIHTTPRequest *) req {
    for (IQDataRequest *c in self.requests) {
		if (c.request == req) {
            IQVerbose(VERBOSE_DEBUG, @"[%@] %@ found for note %@",[self class], [req class], c.note);
            return c;
		}
	}
    IQVerbose(VERBOSE_WARNING, @"[%@] No %@ found",[self class], [req class]);
    return nil;
}

#pragma mark -
#pragma mark NSObject methods


@end
