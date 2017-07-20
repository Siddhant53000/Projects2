//
//  IQAsyncImageView.m
//
//  Created by David on 4/3/11.
//  Copyright 2011 Telephony Media. All rights reserved.
//

#import "IQAsyncImageView.h"
#import "IQVerbose.h"

@interface IQAsyncImageView (PrivateMethods)
- (void)loadDoneEffect;
@end

@implementation IQAsyncImageView
@synthesize loading, loaded, resizesOnLoad, delegate, loadType, spinnerType, preventsReload;
@synthesize URL = _URL;

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data{
	[dlData appendData:data];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error{
	dlData = nil;
	
	connection = nil;
	loading = NO;
	loaded = NO;
	
	IQVerbose(VERBOSE_WARNING, @"[%@] Connection did fail: %@", [self class], [error localizedDescription] );

	[self.delegate imageView: self didFailWithError: error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn{
	connection = nil;
	
	loading = NO;
	self.image = [UIImage imageWithData: dlData];

	[self loadDoneEffect];	
	
	if (self.image==nil){
		IQVerbose(VERBOSE_WARNING, @"[%@] URL did not provide valid image", [self class]);
		return;
	}
	
	if (resizesOnLoad)
		self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.image.size.width, self.image.size.height);

	loaded = YES;

	[self.delegate imageView: self didFinishLoadingImage: self.image withData: dlData];
	dlData = nil;
}

#pragma mark -
#pragma mark IQAsyncImageView methods

- (void) loadStartEffect {
	
	switch (self.loadType) {
		case IQAsyncImageViewFadeLoad:
			self.alpha = 0;
			break;
		case IQAsyncImageViewSpinnerLoad:
			spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: spinnerType];
			
			spinner.frame = CGRectMake(0,0,25,25);
			spinner.center = self.center;
			spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
			[spinner startAnimating];
			spinner.alpha = 0;			
			[self addSubview:spinner];

			[UIView beginAnimations:@"IQAsyncImageViewSpinnerFadeIn" context:(__bridge void *)(self)];
			spinner.alpha = 1;
			[UIView commitAnimations];
			break;
		default:
			break;
	}
}

- (void)loadDoneEffect {
	switch (loadType) {
		case IQAsyncImageViewFadeLoad:
			[UIView beginAnimations:@"IQAsyncImageViewFadeIn" context:(__bridge void *)(self)];
			self.alpha = 1;
			[UIView commitAnimations];
			break;
			
		case IQAsyncImageViewSpinnerLoad:
			[UIView beginAnimations:@"IQAsyncImageViewSpinnerFadeOut" context:(__bridge void *)(self)];
			[UIView setAnimationDelegate:self];
			//[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
			spinner.alpha = 0;
			[UIView commitAnimations];
			break;
	}
}

- (void)load:(NSURL *) url {

	if (preventsReload && url==self.URL)
		return;
	
	self.URL = url;
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	
	if (dlData) {
		dlData = nil;
	}
	
	if (connection){
		[connection cancel];
		connection = nil;
	}
	
	dlData = [[NSMutableData alloc] init];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	loading = YES;
	loaded = NO;
	
	[self loadStartEffect];
	
}

#pragma mark -
#pragma mark NSObject methods

- (id) init{
	if (self = [super init]){
		self.spinnerType = UIActivityIndicatorViewStyleWhite;
		self.preventsReload = YES;
	}
	return self;
}


@end
