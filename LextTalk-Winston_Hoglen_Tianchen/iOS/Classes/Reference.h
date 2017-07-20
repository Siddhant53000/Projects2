//
//  TeamReference.h
// LextTalk
//
//  Created by David on 16/11/10.
//  Copyright 2010 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReferenceDelegate;

@interface Reference : NSObject {
@private
	id<ReferenceDelegate>       __weak _delegate;    
	NSMutableData               *responseData;
	int                         dbInstalledVersion;
	int                         dbRemoteVersion;
	int                         dbRemoteSize;	
    BOOL                        upToDate;
}

@property (nonatomic, weak) id<ReferenceDelegate> delegate;

+ (id) sharedReference;

- (void) installFromBundleIfNeeded;
- (BOOL) isLoaded;
+ (NSString*) getDatabasePath;

@end

@protocol ReferenceDelegate <NSObject>
@required
- (void)reference: (Reference*)inReference didFailWithError: (NSError*)inError;
- (void)referenceDidUpdate: (Reference*)inReference;

@optional
- (void)reference: (Reference*)inReference didUpdateDownloadProgress: (CGFloat) percent;
@end 