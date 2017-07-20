//
//  SplashViewController.m
// LextTalk
//
//  Created by nacho on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SplashViewController.h"
#import "LextTalkAppDelegate.h"
#import "LTDataSource.h"
#import "Reference.h"
#import "Reachability.h"
#import "Flurry.h"

@interface SplashViewController (PrivateMethods)
- (void) restoreLogin;
- (void) animateAndHide;

- (void) rotateToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation;
@end

@implementation SplashViewController
@synthesize delegate = _delegate;
@synthesize imageView;

#pragma mark -
#pragma mark LTDataDelegate methods
- (void) didLoginUser {
    IQVerbose(VERBOSE_DEBUG,@"[%@] Did restore login", [self class]);
    [activityIndicator stopAnimating]; 
	[self.delegate splashWillDisapear];
	[self animateAndHide];
    
    LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
    [del updateChatList];
    [del.chatRoomListViewController reloadController:YES];
}

- (void) didFail: (NSDictionary*) result {
    IQVerbose(VERBOSE_DEBUG,@"[%@] Restore login did fail", [self class]);    
    [activityIndicator stopAnimating];         
	[self.delegate splashWillDisapear];
	[self animateAndHide];   
    
    LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
    [del.chatRoomListViewController reloadController:YES];
}

#pragma mark -
#pragma mark ReferenceDelegate methods
- (void)reference: (Reference*)inReference didUpdateDownloadProgress: (CGFloat) percent {
    //IQVerbose(VERBOSE_DEBUG,@"[%@] Downloaded %d\%% so far", [self class], (int) (percent));
	[progressBar setCurrentValue: percent];
}

- (void)reference: (Reference*)inReference didFailWithError: (NSError*)inError {
    [self restoreLogin];    
}

- (void)referenceDidUpdate: (Reference*)inReference {
    [self restoreLogin];    
}

#pragma mark -
#pragma mark SplashViewController methods

- (void) restoreLogin {
	[statusLabel setText: NSLocalizedString(@"Restoring session",@"Restoring session")];	
    //[[LTDataSource sharedDataSource] restoreLoginWithDelegate: self];
    [[LTDataSource sharedDataSource] newSessionWithDelegate: self];
	[progressBar setHidden: YES];
	[activityIndicator startAnimating];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[self.view removeFromSuperview];
	[self.delegate splashDidDisapear];
}

- (void) animateAndHide {
	[UIView beginAnimations: @"AnimateAndHide" context: nil];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	[UIView setAnimationDuration: 1.0];
	[self.view setAlpha: 0.0];
	[UIView commitAnimations];
}

- (void) continueLaunchingApplication {
    
    // check for internet connection
	Reachability *internetReach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [internetReach currentReachabilityStatus];
	
	switch(status) {
		case NotReachable: IQVerbose(VERBOSE_DEBUG,@"[%@] Reachability: not reachable", [self class]); break;
		case ReachableViaWiFi: IQVerbose(VERBOSE_DEBUG,@"[%@] Reachability: reachable via Wifi", [self class]); break;				
		case ReachableViaWWAN: IQVerbose(VERBOSE_DEBUG,@"[%@] Reachability: reachable via WWAN", [self class]); break;				
	}    
    
    if(status == NotReachable) {
        [statusLabel setText: NSLocalizedString(@"No internet connection is available", @"No internet connection is available")];   
        [activityIndicator stopAnimating];
        return; // do nothing, user can only exit the app
    }
    
    [[Reference sharedReference] setDelegate: self];
    [[Reference sharedReference] installFromBundleIfNeeded];
    
    if([[Reference sharedReference] isLoaded]) {
        [self restoreLogin];
        return;
    }
    [statusLabel setText: NSLocalizedString(@"Updating database...", @"Updating database...")];      
	[progressBar setHidden: NO];
	[activityIndicator stopAnimating];
}

#pragma mark -
#pragma mark UIViewController methods
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [statusLabel setText: @""];
    statusLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:16];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.backgroundColor=[UIColor clearColor];
    statusLabel.textAlignment=NSTextAlignmentCenter;
    
    [activityIndicator startAnimating];
    
	[progressBar setHidden: YES];
	[progressBar setMinValue: 0.0];
	[progressBar setMaxValue: 100.0];
	[progressBar setLineColor: [UIColor grayColor]];
	[progressBar setProgressColor: [UIColor whiteColor]];
	[progressBar setProgressRemainingColor: [UIColor clearColor]];
	[progressBar setBackgroundColor: [UIColor clearColor]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self rotateToInterfaceOrientation:self.interfaceOrientation];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        return YES;
    else 
    {
        if (interfaceOrientation==UIInterfaceOrientationPortrait || interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
            return YES;
        else 
            return NO;
    }
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    
    if ([[UIDevice currentDevice] orientation]==UIInterfaceOrientationPortrait || [[UIDevice currentDevice] orientation]==UIInterfaceOrientationPortraitUpsideDown)
        [self rotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
    else 
        [self rotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
}

- (void) rotateToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        CGRect rect=[[UIScreen mainScreen] applicationFrame];
        if (rect.size.height<=480)
        {
            if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 7)
                self.imageView.frame=CGRectMake(0, 0, 320, 480);
            else
                self.imageView.frame=CGRectMake(0, -20, 320, 480);
            self.imageView.image=[UIImage imageNamed:@"Default"];
            
            statusLabel.frame = CGRectMake(0, 130, 320, 21);
            activityIndicator.frame = CGRectMake((320 - 37)/2.0, 160, 37, 37);
            progressBar.frame = CGRectMake(50, 206, 220, 16);
        }
        else
        {
            if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 7)
                self.imageView.frame=CGRectMake(0, 0, 320, 568);
            else
                self.imageView.frame=CGRectMake(0, -20, 320, 568);
            self.imageView.image=[UIImage imageNamed:@"Default-568h"];

            statusLabel.frame = CGRectMake(0, 130 + 44, 320, 21);
            activityIndicator.frame = CGRectMake((320 - 37)/2.0, 160 + 44, 37, 37);
            progressBar.frame = CGRectMake(50, 206 + 44, 220, 16);
        }
        
        
        
        /*
        if (toInterfaceOrientation==UIInterfaceOrientationPortrait || toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
        {
            self.imageView.frame=CGRectMake(0, 0, 320, 480);
            self.imageView.image=[UIImage imageNamed:@"Default"];
        }
        else 
        {
            self.imageView.frame=CGRectMake(0, 0, 480, 320);
            self.imageView.image=[UIImage imageNamed:@"Default"];
        }
         */
    }
    else 
    {
        if (toInterfaceOrientation==UIInterfaceOrientationPortrait || toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
        {
            //Very weird, but in iOS 7, the image for the splash is stretched if it has the size of iOS<7.
            //So in order to make it stay the same, I have to give these strange dimensions to the imageView
            if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 7)
                self.imageView.frame=CGRectMake(0, 0, 768, 1024);
            else
                self.imageView.frame=CGRectMake(0, -20, 768, 1024);
            self.imageView.image=[UIImage imageNamed:@"Default-Portrait"];
            
            statusLabel.frame=CGRectMake(0, 350, 768, 21);
            activityIndicator.frame=CGRectMake((768 - 37)/2.0, 380, 37, 37);
            progressBar.frame=CGRectMake((768 - 300)/2.0, 426, 300, 16);
        }
        else 
        {
            //Very weird, but in iOS 7, the image for the splash is stretched if it has the size of iOS<7.
            //So in order to make it stay the same, I have to give these strange dimensions to the imageView
            if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 7)
                self.imageView.frame=CGRectMake(0, 0, 1024, 768);
            else
                self.imageView.frame=CGRectMake(0, -20, 1024, 768);
            self.imageView.image=[UIImage imageNamed:@"Default-Landscape"];
            
            statusLabel.frame=CGRectMake(0, 210, 1024, 21);
            activityIndicator.frame=CGRectMake((1024 - 37)/2.0, 240, 37, 37);
            progressBar.frame=CGRectMake((1024 - 300)/2.0, 286, 300, 16);
        }
    }
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
	[[LTDataSource sharedDataSource] removeFromRequestDelegates: self];	
    self.imageView=nil;
}


@end
