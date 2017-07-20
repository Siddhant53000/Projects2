//
//  IQTabBarController.m
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import "IQTabBarController.h"

@implementation IQTabBarController
@synthesize tabBar1;

#pragma mark -
#pragma mark IQSkinProtocol

- (void) applySkin:(IQSkin *)skin {
    if(!skin.active) return;
    
	UIImage *img = [IQSkin applyColor: skin.tabBarColor  toGrayscaleImage: skin.tabBarImage];
	
	UIImageView *imgView = [[UIImageView alloc] initWithImage: img];
	imgView.frame = CGRectOffset(imgView.frame, 0, 1);
	[tabBar1 insertSubview:imgView atIndex:0];
}

#pragma mark -
#pragma mark UITabBarController methods

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self applySkin: [IQSkin defaultSkin]];
}

#pragma mark -
#pragma mark NSObject methods

@end