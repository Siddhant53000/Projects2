//
//  WallpaperViewController.h
// LextTalk
//
//  Created by David on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WallpaperViewController : UIViewController {
	NSInteger	_wallpaperIndex;
	UIImageView	*_wallpaper;
	BOOL		shouldShowWallpaper;
}

@property (nonatomic, assign) NSInteger wallpaperIndex;
@property (nonatomic, strong) UIImageView *wallpaper;

- (void) showWallpaper;
- (void) pushWallpaperViewController:(WallpaperViewController *)viewController animated:(BOOL)animated;
@end
