//
//  IQUpdatableZipFile.h
//
//  Created by David on 16/11/10.
//  Copyright 2010 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IQUpdatableZipFileDelegate;

@interface IQUpdatableZipFile : NSObject {
    NSString *_filename;
    NSString *_url;
    
@private
	id<IQUpdatableZipFileDelegate>  __weak _delegate;    
	NSMutableData                   *_responseData;
	NSInteger                       _installedVersion;
	NSInteger                       _remoteVersion;
	NSInteger                       _remoteSize;	
    BOOL                            _upToDate;
}

@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, weak) id<IQUpdatableZipFileDelegate> delegate;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, assign) BOOL upToDate;
@property (nonatomic, assign) NSInteger remoteVersion;
@property (nonatomic, assign) NSInteger installedVersion;
@property (nonatomic, assign) NSInteger remoteSize;

- (void) checkForUpdates;
- (BOOL) isLoaded;

@end

@protocol IQUpdatableZipFileDelegate <NSObject>
@required
- (void) updateableZipFile: (IQUpdatableZipFile*) file didFailWithError: (NSError*)inError;
- (void) updateableZipFileDidUpdate: (IQUpdatableZipFile*) file;

@optional
- (void) updateableZipFile: (IQUpdatableZipFile*) file didUpdateDownloadProgress: (CGFloat) percent;
@end 