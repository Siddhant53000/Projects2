//
//  IQAsyncImageView.h
//
//  Created by David on 4/3/11.
//  Copyright 2011 Telephony Media. All rights reserved.
//

#import <Foundation/Foundation.h>

enum IQAsyncImageViewLoadType{
	IQAsyncImageViewFadeLoad,
	IQAsyncImageViewSpinnerLoad,
	IQAsyncImageViewPopLoad
};

@protocol IQAsyncImageViewDelegate;

@interface IQAsyncImageView : UIImageView {
	NSMutableData *dlData;
	NSURLConnection *connection;
	
	id <IQAsyncImageViewDelegate> __weak delegate;
	
	BOOL loading;
	BOOL loaded;
	
	NSURL *_URL;
	
	BOOL preventsReload;
	BOOL resizesOnLoad;
	
	NSInteger loadType;
	
	UIActivityIndicatorViewStyle spinnerType;
	UIActivityIndicatorView *spinner;
}

@property (nonatomic, readonly) BOOL loading;
@property (nonatomic, readonly) BOOL loaded;
@property (nonatomic, assign) NSInteger loadType;
@property (nonatomic, assign) BOOL resizesOnLoad;
@property (nonatomic, assign) UIActivityIndicatorViewStyle spinnerType;
@property (nonatomic, assign) BOOL preventsReload;
@property (nonatomic, weak) IBOutlet id<IQAsyncImageViewDelegate> delegate;
@property (nonatomic, strong) NSURL *URL;

- (void)load:(NSURL *)url;

@end

@protocol IQAsyncImageViewDelegate
@required
- (void) imageView: (IQAsyncImageView*) imageView didFailWithError: (NSError*) error;
- (void) imageView: (IQAsyncImageView*) imageView didFinishLoadingImage: (UIImage*) image withData: (NSData*) data;
@end