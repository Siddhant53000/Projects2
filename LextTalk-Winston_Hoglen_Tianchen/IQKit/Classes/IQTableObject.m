//
//  IQTableObject.m
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import "IQVerbose.h"
#import "IQTableObject.h"
#import "UIImage+RoundedCorner.h"

@implementation IQTableObject
@synthesize cell = _cell;
@synthesize updateDelegate = _updateDelegate;
@synthesize showingTable = _showingTable;

#pragma mark -
#pragma mark IQAsyncImageDelegate methods

- (void) didFinishLoadingImage: (IQAsyncImage*) img {
	IQVerbose(VERBOSE_ALL,@"[%@] Got image from %@", [self class], [img imageURL]);

	// apply rounded corners to incoming image
	img.image = [img.image roundedCornerImage: 15 borderSize: 1];
	
	[self.showingTable reloadData];
	[self.updateDelegate didUpdateTableObject: self];
}

- (void) errorLoadingImage: (IQAsyncImage*) img {
	IQVerbose(VERBOSE_WARNING,@"[%@] Could not get image from %@", [self class], [img imageURL]);	
}

#pragma mark -
#pragma mark IQTableObject methods

- (void) cancelUpdateDelegates {
	self.showingTable = nil;
	self.updateDelegate = nil;
}

- (BOOL)loadNibFile:(NSString *)nibName {
    // The myNib file must be in the bundle that defines self's class.
    if ([[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] == nil)
    {
        IQVerbose(VERBOSE_ERROR,@"[%@] Warning! Could not load %@ file.\n", [self class], nibName);
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark NSObject methods


@end
