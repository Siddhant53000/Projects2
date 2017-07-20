    //
//  WallpaperViewController.m
// LextTalk
//
//  Created by David on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WallpaperViewController.h"
#import "IQKit.h"


@implementation WallpaperViewController
@synthesize wallpaperIndex = _wallpaperIndex;
@synthesize wallpaper = _wallpaper;

#pragma mark -
#pragma mark WallpaperViewController methods

- (void) pushWallpaperViewController:(WallpaperViewController *)viewController animated:(BOOL)animated {
	[viewController setWallpaperIndex: self.wallpaperIndex+1];
	IQVerbose(VERBOSE_DEBUG,@"[%@] Pushing new View Controller of class %@", [self class], [viewController class]);
	[self.navigationController pushViewController: viewController animated: animated];
	[self viewDidDisappear: NO];
}

- (void) showWallpaper {

	if(self.wallpaperIndex) {
		NSString *filename;
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {		
			filename = [NSString stringWithFormat: @"wp1%02ld@2x.jpg",(long)self.wallpaperIndex];
		} else {
			filename = [NSString stringWithFormat: @"wp1%02ld.jpg",(long)self.wallpaperIndex];
		}

		//IQVerbose(VERBOSE_DEBUG,@"Loading %@", filename);

        UIImage *theImage = [UIImage imageNamed: filename];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:theImage];                    
        self.wallpaper = imageView;
		[self.view addSubview:self.wallpaper];
		CGRect newFrame = self.view.frame;
		newFrame.origin.y = 0;
		[self.wallpaper setFrame: newFrame];
		[self.view sendSubviewToBack: self.wallpaper];
		shouldShowWallpaper = YES;
		IQVerbose(VERBOSE_DEBUG,@"[%@] Loaded image %@ as wallpaper (index %d)", [self class], filename, self.wallpaperIndex);		
	}
}

#pragma mark -
#pragma mark UIViewController methods
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void) viewDidDisappear:(BOOL)animated {
	[self.wallpaper removeFromSuperview];
	self.wallpaper = nil;
	IQVerbose(VERBOSE_DEBUG,@"[%@] Unloaded wallpaper (index %d)", [self class], self.wallpaperIndex);	
	
	[super viewDidDisappear: animated];
}

- (void) viewWillAppear:(BOOL)animated {
	if(shouldShowWallpaper)
		[self showWallpaper];
	
	[super viewWillAppear: animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	/*
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {	
		return YES;
	}
	 */
    // Return YES for supported orientations.
	if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) return YES;
	if (interfaceOrientation == UIInterfaceOrientationPortrait) return YES;
	
	return NO;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    IQVerbose(VERBOSE_DEBUG,@"[%@] Releasing wallpaper",[self class]);
    self.wallpaper = nil;
}


@end
