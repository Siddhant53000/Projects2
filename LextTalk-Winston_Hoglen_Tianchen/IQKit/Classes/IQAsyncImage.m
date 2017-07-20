//
//  IQAsyncImage.m
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import "IQVerbose.h"
#import "IQAsyncImage.h"


@implementation IQAsyncImage
@synthesize image = _image;
@synthesize imageURL = _imageURL;
@synthesize imageId = _imageId;
@synthesize cached = _cached;
@synthesize loading = _loading;
@synthesize delegate = _delegate;

#pragma mark NSURLConnection delegate methods

- (void)connection: (NSURLConnection *)connection didFailWithError: (NSError *)error {
	IQVerbose(VERBOSE_WARNING,@"[%@] Error loading image %d (%@)", [self class], self.imageId, [self.imageURL description]);
	_connection = nil;
	self.loading = NO;

	[self.delegate errorLoadingImage: self];
}

- (void)connection: (NSURLConnection *)connection didReceiveData: (NSData *)data {
	[_mutData appendData:data];
	IQVerbose(VERBOSE_ALL,@"[%@] Got %d bytes, %d bytes so far", [self class], self.imageId, [data length], [_mutData length]);		
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	_connection = nil;

	IQVerbose(VERBOSE_DEBUG,@"[%@] Image %d (%@) loaded (%d bytes)", [self class], self.imageId, [self.imageURL description], [_mutData length]);
    UIImage *anImage = [[UIImage alloc] initWithData: _mutData];
    self.image = anImage;
	
	self.cached = YES;
	self.loading = NO;
	
	[self.delegate didFinishLoadingImage: self];	
}

#pragma mark -
#pragma mark IQAsyncImage methods

- (id) initWithImageUrl: (NSString*) url defaultImage: (UIImage*) img {
    [self setImage: img];
    [self setImageURL: url];
	
	self.cached = NO;
	self.loading = NO;
    
    return self;
}

- (void) loadWithDelegate: (id<IQAsyncImageDelegate>) del{
	if(self.imageURL == nil) return;
    IQVerbose(VERBOSE_DEBUG,@"[%@] Loading image from %@", [self class], self.imageURL);
	self.delegate = del;
	
	
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString: self.imageURL]];
    _mutData = [[NSMutableData alloc] init];    
	[_mutData setLength: 0];
	
	_connection = [[NSURLConnection alloc] initWithRequest: request
												  delegate: self];
	
	self.cached = NO;
	self.loading = YES;
}

- (void)dealloc {
	self.delegate = nil;
}
@end
