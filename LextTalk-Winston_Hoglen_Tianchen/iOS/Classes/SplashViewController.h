//
//  SplashViewController.h
// LextTalk
//
//  Created by nacho on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reference.h"
#import "LTDataDelegate.h"
#import "IQKit.h"

@protocol SplashDelegate
- (void) splashWillDisapear;
- (void) splashDidDisapear;
@end


@interface SplashViewController : UIViewController <ReferenceDelegate, LTDataDelegate>{
    IBOutlet UIImageView                * imageView;
    IBOutlet UIActivityIndicatorView	*activityIndicator;
	IBOutlet UILabel                    *statusLabel;
	IBOutlet IQProgressBar				*progressBar;
	id									__weak _delegate;
}

@property (nonatomic,weak) id<SplashDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIImageView * imageView;

- (void) continueLaunchingApplication;

@end
