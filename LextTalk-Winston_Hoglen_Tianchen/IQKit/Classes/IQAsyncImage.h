//
//  IQAsyncImage.h
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQAsyncImage;

@protocol IQAsyncImageDelegate
@required
- (void) didFinishLoadingImage: (IQAsyncImage*) img;
- (void) errorLoadingImage: (IQAsyncImage*) img;
@end

@interface IQAsyncImage : NSObject {
	id<IQAsyncImageDelegate>	__weak _delegate;
	
	NSURLConnection				*_connection;
	NSMutableData				*_mutData;
	UIImage						*_image;
	NSString					*_imageURL;
	bool						_cached;
	bool						_loading;
	int							_imageId;
}

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, assign) int imageId;
@property (nonatomic, assign) bool cached;
@property (nonatomic, assign) bool loading;
@property (nonatomic, weak) id<IQAsyncImageDelegate> delegate;

- (id) initWithImageUrl: (NSString*) url defaultImage: (UIImage*) img;


- (void) loadWithDelegate: (id<IQAsyncImageDelegate>) del;

@end
