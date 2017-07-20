//
//  MapViewController.m
// LextTalk
//
//  Created by nacho on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LextTalkAppDelegate.h"
#import "MapViewController.h"
#import "UserListViewController.h"
#import "global.h"
#import "HelpViewController.h"
#import "SearchViewController.h"
#import "Flurry.h"
#import "UIColor+ColorFromImage.h"
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "GeneralHelper.h"
#import "MapLayoutGuide.h"

#import "TutViewController.h"
//AO for Google Analytics
#import <Google/Analytics.h>
#import "GAITrackedViewController.h"
#import "GAIDictionaryBuilder.h"
#import <stdio.h>
#import "LextTalk-Swift.h"

#define SEARCH_REGION_FACTOR    4.0
#define ZOOMIN_REGION_FACTOR    5.0

@interface MapViewController (PrivateMethods)
- (void) refreshAnnotations;
- (void) hideOverlay;
- (void) update;

@end

@implementation MapViewController
@synthesize searchRegion = _searchRegion;
@synthesize child = _child;
@synthesize mapView, indicatorView;
@synthesize popoverController;

MapFilter* mapFilter;

#pragma mark -
#pragma mark MKMapViewDelegate methods
- (void) dumpRegion: (MKCoordinateRegion) region {
    IQVerbose(VERBOSE_DEBUG,@"[%@] Region:", [self class]);
    IQVerbose(VERBOSE_DEBUG,@"   Center: %f, %f",region.center.longitude, region.center.latitude);    
    IQVerbose(VERBOSE_DEBUG,@"     Span: %f, %f",region.span.longitudeDelta, region.span.latitudeDelta);        
}

- (BOOL) region: (MKCoordinateRegion) region1 fitsInRegion: (MKCoordinateRegion) region2 {
    //[self dumpRegion: region1];
    //[self dumpRegion: region2];    
    
    CLLocationCoordinate2D  region1TopLeft, region1BottomRight;
    region1TopLeft.longitude = region1.center.longitude - region1.span.longitudeDelta/2.0;
    region1TopLeft.latitude = region1.center.latitude + region1.span.latitudeDelta/2.0;    
    //IQVerbose(VERBOSE_DEBUG,@"region1TopLeft: %f, %f", region1TopLeft.longitude, region1TopLeft.latitude);

    region1BottomRight.longitude = region1.center.longitude + region1.span.longitudeDelta/2.0;
    region1BottomRight.latitude = region1.center.latitude - region1.span.latitudeDelta/2.0;    
    //IQVerbose(VERBOSE_DEBUG,@"region1BottomRight: %f, %f", region1BottomRight.longitude, region1BottomRight.latitude);    
    
    CLLocationCoordinate2D  region2TopLeft, region2BottomRight;
    region2TopLeft.longitude = region2.center.longitude - region2.span.longitudeDelta/2.0;
    region2TopLeft.latitude = region2.center.latitude + region2.span.latitudeDelta/2.0;   
    //IQVerbose(VERBOSE_DEBUG,@"region2TopLeft: %f, %f", region2TopLeft.longitude, region2TopLeft.latitude);    
    
    region2BottomRight.longitude = region2.center.longitude + region2.span.longitudeDelta/2.0;
    region2BottomRight.latitude = region2.center.latitude - region2.span.latitudeDelta/2.0; 
    //IQVerbose(VERBOSE_DEBUG,@"region2BottomRight: %f, %f", region2BottomRight.longitude, region2BottomRight.latitude);        
    
    if(region1TopLeft.longitude < region2TopLeft.longitude) return NO;
    if(region1TopLeft.latitude > region2TopLeft.latitude) return NO;    
    if(region1BottomRight.longitude > region2BottomRight.longitude) return NO;    
    if(region1BottomRight.latitude < region2BottomRight.latitude) return NO;        

    return YES;
}

- (void)mapView:(MKMapView *)theMapView regionDidChangeAnimated:(BOOL)animated {
	
	//[self dumpRegion: mapView.region];	
    // update map only if new map region is outside the search region
    if(!mapReady) {
        mapReady = YES;
        IQVerbose(VERBOSE_DEBUG,@"[%@] RegionWillChange: map not ready", [self class]);  		
        return;
    }
	
    if( [self region: theMapView.region fitsInRegion: self.searchRegion] ) {
        
        if( (theMapView.region.span.longitudeDelta > self.searchRegion.span.longitudeDelta/ZOOMIN_REGION_FACTOR) &&
           (theMapView.region.span.latitudeDelta > self.searchRegion.span.latitudeDelta/ZOOMIN_REGION_FACTOR) ){
            IQVerbose(VERBOSE_DEBUG,@"[%@] RegionWillChange: No update needed.", [self class]);
            return;
        }
    }
    
    
	IQVerbose(VERBOSE_DEBUG,@"[%@] RegionWillChange: Update needed", [self class]);  			

    // set new search region to double of map region
    _searchRegion.center.longitude = theMapView.region.center.longitude;
    _searchRegion.center.latitude = theMapView.region.center.latitude;    
    _searchRegion.span.longitudeDelta = SEARCH_REGION_FACTOR * theMapView.region.span.longitudeDelta;
    _searchRegion.span.latitudeDelta = SEARCH_REGION_FACTOR * theMapView.region.span.latitudeDelta;    
    [self update];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
	if([annotation class] == [LTUser class]) {
		LTUser *user = (LTUser*) annotation;
		MKAnnotationView *userView = [user annotationViewInMapView: theMapView];
    
		//UIButton* rightButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
		//[rightButton addTarget: self action: @selector(showUserDetails:) forControlEvents: UIControlEventTouchUpInside];
        
		//userView.rightCalloutAccessoryView = rightButton;
        userView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        userView.rightCalloutAccessoryView.tag=1;
        userView.canShowCallout = YES;
        
        // Fixes the issue where user images would load only after tapping into a user's profile.
        if(user.url != nil)
        {
            [self.indicatorView startAnimating];
            [[LTDataSource sharedDataSource] getImageForUrl:user.url withUserId:user.userId andExecuteBlockInMainQueue:^(UIImage *image, BOOL gotFromCache) {
                
                [self.indicatorView stopAnimating];
                if (image!=nil)
                {
                    UIImageView *profilePicture = [[UIImageView alloc] initWithImage: image];
                    profilePicture.frame = CGRectMake(50.0f, 50.0f, 50.0f, 50.0f);
                    userView.leftCalloutAccessoryView = profilePicture;
                }
            }];
        }
        else
        {
            UIImageView *myCustomImage = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"Contact"]];
            myCustomImage.frame = CGRectMake(50, 50, 50, 50);
            userView.leftCalloutAccessoryView = myCustomImage;
        }
        
		return userView;
	}
	
	// this must be a not logged user
	LTNotLoggedUser *notLoggedUser = (LTNotLoggedUser*) annotation;

    MKAnnotationView *notLoggedUserView = [notLoggedUser annotationViewInMapView: theMapView];  
    
    UIButton* rightButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
    [rightButton addTarget: self
                    action: @selector(signIn:)
          forControlEvents: UIControlEventTouchUpInside];
    
    notLoggedUserView.rightCalloutAccessoryView = rightButton;
     
    notLoggedUserView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    notLoggedUserView.rightCalloutAccessoryView.tag=2;
    notLoggedUserView.canShowCallout = YES;
    
	return notLoggedUserView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if (control.tag==1)//Show users details when the i button is clicked.
    {
        LTUser *user = (LTUser*)[view annotation];
        
        LocalUserViewController *userViewController;
        
        userViewController = [[LocalUserViewController alloc] init];
        userViewController.user=user;
        userViewController.title = NSLocalizedString(@"Users on the map", @"Users on the map");
        
        [self.mapView deselectAnnotation:view.annotation animated:YES];
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
            [self.navigationController pushViewController: userViewController animated: YES];
        else
        {
            UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:userViewController];
            nav.navigationBarHidden = YES;
            
            userViewController.disableAds=YES;
            
            CLLocationCoordinate2D coor=user.coordinate;
            CGPoint center=[self.mapView convertCoordinate:coor toPointToView:self.view];
            CGRect showRect=CGRectMake(center.x, center.y, 1, 1);
            
            userViewController.delegate=self;
            // SEARCH TAG
            self.popoverController=[[UIPopoverController alloc] initWithContentViewController:nav];
            self.popoverController.delegate=self;
            [self.popoverController presentPopoverFromRect:showRect inView:self.mapView permittedArrowDirections:UIPopoverArrowDirectionAny  animated:YES];
        }
        [self setChild: userViewController];
    }
    else//Sign in
    {
        LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
        [del goToSignInView];
    }
}

#pragma mark -
#pragma mark LTDataDelegate methods

/*
- (void) didUpdateSearchResults {
	[indicatorView stopAnimating];
	[self refreshAnnotations];
}
 */

- (void) didUpdateSearchResultsUsers:(NSArray *)results
{
    [indicatorView stopAnimating];
    [LTDataSource sharedDataSource].userList = [NSMutableArray arrayWithArray:results];
    [self refreshAnnotations];
    //I have not removed the local user, changed in the refreshAnnotations
}

- (void) didFail: (NSDictionary*) result {
	[indicatorView stopAnimating];
	
    // handle error
	if(result == nil) return;
	
    //	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"LextTalk server error", @"LextTalk server error")
    //													message: [result objectForKey: @"message"]
    //												   delegate: self
    //										  cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
    //										  otherButtonTitles: nil];
    
    LextTalkAppDelegate * del = (LextTalkAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!del.showingError)
    {
        del.showingError=YES;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: [result objectForKey: @"error_title"]
                                                        message: [result objectForKey: @"error_message"]
                                                       delegate: self
                                              cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
                                              otherButtonTitles: nil];
        alert.tag = 404;
        [alert show];
    }
}

#pragma mark -
#pragma mark UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((buttonIndex==0) && (alertView.tag==404))
    {
        LextTalkAppDelegate * del = (LextTalkAppDelegate *) [[UIApplication sharedApplication] delegate];
        del.showingError = NO;
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    /*
	switch( buttonIndex ) {
		case 0: [self shareOnFacebook]; break;
		case 1: [self shareOnTwitter]; break;
		case 2: [self shareByEmail]; break;
	}
     */
    
	switch( buttonIndex ) {
		case 0: [self performSelector:@selector(shareOnFacebook) withObject:nil afterDelay:1.0]; break;
		case 1: [self performSelector:@selector(shareOnTwitter) withObject:nil afterDelay:1.0]; break;
		case 2: [self performSelector:@selector(shareByEmail) withObject:nil afterDelay:1.0]; break;
	}
}

#pragma mark -
#pragma mark MapViewController methods

- (void) sementedControlPressed: (UISegmentedControl *) seg
{
    switch (seg.selectedSegmentIndex)
    {
        case 0:
            [self share];
            break;
        case 1:
            [self centerMapOnLocalUser];
            break;
        case 2:
            [self showResultList];
            break;
        case 3:
            [self searchByName];
            break;
        case 4:
            [self showHelp];
            break;
    }
}

- (IBAction) searchByName {
	[Flurry logEvent:@"SEARCH_BY_NAME_ACTION"];
	SearchViewController *searchViewController;
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		searchViewController = [[SearchViewController alloc] init];
	} else {
		searchViewController = [[SearchViewController alloc] init];		
	}

    searchViewController.region=self.mapView.region;
	[self.navigationController pushViewController: searchViewController animated: YES];
	//[self setChild: searchViewController];
}

- (IBAction) showHelp {
    [Flurry logEvent:@"SHOW_HELP_ACTION"];
	HelpViewController *helpViewController;
    
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		helpViewController = [[HelpViewController alloc] initWithNibName: @"HelpViewController-iPad" bundle: nil];
	} else {
		helpViewController = [[HelpViewController alloc] initWithNibName: @"HelpViewController-iPhone" bundle: nil];		
	}    
    
	[self.navigationController pushViewController: helpViewController animated: YES];
	[self setChild: helpViewController];
}

- (IBAction) showResultList {
    [Flurry logEvent:@"SHOW_RESULT_LIST_ACTION"];
    
    //iPhone xib is enough, it is the same as the iPad one but for the size, and it is resized when loaded
	UserListViewController *userList = [[UserListViewController alloc] init];
	
	// remove not logged local user
	NSMutableArray *list = [[NSMutableArray alloc] init];
	
	// add all users
	for(id object in mapView.annotations) {
		if([object class] == [LTNotLoggedUser class]) {
			continue;
		}
		if([object class] == [LTUser class]) {
			LTUser *u = (LTUser*) object;
			if( [[LTDataSource sharedDataSource] localUser].userId != u.userId ) {
				[list addObject: object];
			}
			continue;			
		}
	}


		
	[userList setObjects: list];
	[userList setTitle: NSLocalizedString(@"Users on the map", @"Users on the map")];
    // The above line modifies the title of the bar displayed when the user taps the top middle button.
	[self.navigationController pushViewController: userList animated: YES];
	[self setChild: userList];
}

- (void) goToLongitude: (CGFloat) longitude andLatitude: (CGFloat) latitude {
    
	IQVerbose(VERBOSE_DEBUG,@"[%@] Moving map:", [self class]);
	IQVerbose(VERBOSE_DEBUG,@"  Latitude: %f", latitude);	
	IQVerbose(VERBOSE_DEBUG,@"  Longitude: %f", longitude);
	
	// force the view to be loaded
    UIView *viewTemp = self.view;
    NSLog(@"self.view :::: %@", viewTemp);
	
    CLLocationCoordinate2D cord;
    cord.longitude = longitude;
    cord.latitude = latitude;
    
    [mapView setRegion: MKCoordinateRegionMakeWithDistance( cord, MAP_SPAN, MAP_SPAN)
              animated: YES];    
}



- (void) refreshAnnotations {
	[mapView removeAnnotations: mapView.annotations];
	
	for(LTUser *u in [[LTDataSource sharedDataSource] userList]) {        
		if( (u.coordinate.longitude != 0) && (u.coordinate.latitude != 0) ) {
            
            if([mapFilter checkUserWithUser: u]) {
                [mapView addAnnotation: u];
            }
		}
	}

    if(![[LTDataSource sharedDataSource] isUserLogged])
		[mapView addAnnotation: [[LTDataSource sharedDataSource] noUser]];
	// add local user
	if([[LTDataSource sharedDataSource] isUserLogged]) {
		[mapView addAnnotation: [[LTDataSource sharedDataSource] localUser]];
    } else {
		[mapView addAnnotation: [[LTDataSource sharedDataSource] noUser]];
	}
}

- (UIImage *) takeScreenshot {
	LextTalkAppDelegate *delegate = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];

	UIGraphicsBeginImageContext(delegate.window.bounds.size);
	[delegate.window.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	// crop image
	CGRect cropRect;
	cropRect.origin.x = 0;
	cropRect.origin.y = 20;
	cropRect.size.width = image.size.width;
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {    
        cropRect.size.height = 955;
    } else {
        cropRect.size.height = 411;
    }        
	
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
	
	image = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);	
	
	return image;
	
//	UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);	
}

- (void) centerMapOnUser: (LTUser*) user {
	IQVerbose(VERBOSE_DEBUG,@"Moving map to user %@", user.name);
	IQVerbose(VERBOSE_DEBUG,@"  Latitude: %f", user.coordinate.latitude);	
	IQVerbose(VERBOSE_DEBUG,@"  Longitude: %f", user.coordinate.longitude);		
	
    if ((user.coordinate.longitude!=0) && (user.coordinate.latitude!=0))
        [self goToLongitude: user.coordinate.longitude andLatitude: user.coordinate.latitude];
}

// This is the method to be called when the new zoom button is implemented!
	 
- (IBAction) centerMapOnLocalUser {
    [Flurry logEvent:@"CENTER_MAP_ON_USER_ACTION"];
    
    if([[LTDataSource sharedDataSource] isUserLogged]) {
        [self centerMapOnUser: [[LTDataSource sharedDataSource] localUser]];
    } else {
        if (([[LTDataSource sharedDataSource] latestLocation].longitude!=0) && ([[LTDataSource sharedDataSource] latestLocation].latitude!=0))
            [self goToLongitude: [[LTDataSource sharedDataSource] latestLocation].longitude 
                    andLatitude: [[LTDataSource sharedDataSource] latestLocation].latitude];        
    }
}

- (IBAction) shareOnFacebook {
    [Flurry logEvent:@"SHARE_ACTION" withParameters:[NSDictionary dictionaryWithObject:@"Facebook" forKey:@"Sharer"]];
    
	NSString *title = NSLocalizedString(@"Learning languages with Lext Talk is great!", nil);
	//UIImage *image = [self takeScreenshot];
    
    [[LTDataSource sharedDataSource] handleFacebookShare:title andImage:nil];
}

- (IBAction) shareOnTwitter {
    [Flurry logEvent:@"SHARE_ACTION" withParameters:[NSDictionary dictionaryWithObject:@"Twitter" forKey:@"Sharer"]];

	NSString *title = NSLocalizedString(@"Learning languages with Lext Talk is great!", nil);
	//UIImage *image = [self takeScreenshot];
    
    if ([SLComposeViewController class]) //iOS 6, use Social framework
    {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [controller setInitialText:title];
            //[controller addImage:image];
            [controller addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/lext-talk-language-exchange/id484851963?mt=8"]];
            
            controller.completionHandler = ^(SLComposeViewControllerResult result)  {
                
                [self dismissViewControllerAnimated:YES completion:NULL];
                
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        break;
                        
                    case SLComposeViewControllerResultDone:
                        break;
                        
                    default:
                        break;
                }
            };
            
            [self presentViewController:controller animated:YES completion:NULL];
        }
        else {
            UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Configure Twitter!", nil)
                                                           message:NSLocalizedString(@"You either do not have a data connection at this time, or you have not configured Twitter in this device. You can do that in the Settings of your device, section Twitter", nil)
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                 otherButtonTitles: nil ];
            [alert show];
        }
    }
}

- (IBAction) shareByEmail {
    [Flurry logEvent:@"SHARE_ACTION" withParameters:[NSDictionary dictionaryWithObject:@"Mail" forKey:@"Sharer"]];

    
	if ( ![MFMailComposeViewController canSendMail] ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Cannot share by email", @"Cannot share by email")
														message: NSLocalizedString(@"Your mail account is not configured", @"Your mail account is not configured")
													   delegate: nil 
											  cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
											  otherButtonTitles: nil];
		
		[alert show];
		return;
	}	
	
	NSString *title = NSLocalizedString(@"Learning languages with Lext Talk is great!", nil);
	//UIImage *image = [self takeScreenshot];
    
    MFMailComposeViewController * mailController=[[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    //[mailController setToRecipients:];
    [mailController setSubject:title];
    //NSData *imageData = UIImagePNGRepresentation(image);
    //[mailController addAttachmentData:imageData mimeType:@"image/png" fileName:title];
    
    //Texto
    [mailController setMessageBody:@"https://itunes.apple.com/us/app/lext-talk-language-exchange/id484851963?mt=8" isHTML:NO];
    
    [self presentViewController:mailController animated:YES completion:NULL];
    
    [Flurry logEvent:@"FastText_Send_E-Mail"];
}

- (IBAction) share {
    [Flurry logEvent:@"SHARE_ATTEMPT_ACTION"];

	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: NSLocalizedString(@"Tell your friends about Lext Talk!", nil)
															  delegate: self 
													 cancelButtonTitle: NSLocalizedString(@"Cancel", @"Cancel") 
												destructiveButtonTitle: nil
													 otherButtonTitles: @"Facebook", @"Twitter", @"Email", nil];
	
	[actionSheet showFromTabBar: [self.tabBarController tabBar]];
}

- (void) presentFilter {
    NSLog(@"Hello buddy");
    UIStoryboard* storyboard  = [UIStoryboard storyboardWithName:@"Filter" bundle:nil];
    FilterViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"FilterVC"];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:^{
        NSLog(@"Filter VC presented");
        if (mapFilter != nil) {
            [vc configureWithFilter:mapFilter];
        }
    }];
}

- (void) filterCompleted: (NSArray*) results {
    // set a filter variable via constructor of the parameters returned in results
    // in the annotations delegate call a checkUser function on Filter
    // we'll want to read from this variable when we re-launch the filter
    [mapFilter initWithResults: results];
}

- (void) matchMe {
    NSArray* potentialMatches = [[NSArray alloc] init];
    for(LTUser *u in [[LTDataSource sharedDataSource] userList]) {
            if([mapFilter checkUserWithUser: u]) {
                potentialMatches = [potentialMatches arrayByAddingObject:u];
            }
    }
    if ([potentialMatches count] > 0) {
        LTUser* randomMatch = [potentialMatches objectAtIndex:arc4random() % potentialMatches.count];
        
        //    if (control.tag==1)//Show users details
        //    { should be checking if the user is logged in
        
        
        LocalUserViewController *userViewController;
        
        userViewController = [[LocalUserViewController alloc] init];
        userViewController.user = randomMatch;
        userViewController.title = NSLocalizedString(@"Users on the map", @"Users on the map");
        
        
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
            [self.navigationController pushViewController: userViewController animated: YES];
        else
        {
            UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:userViewController];
            nav.navigationBarHidden = YES;
            
            userViewController.disableAds=YES;
            
            CLLocationCoordinate2D coor = randomMatch.coordinate;
            CGPoint center=[self.mapView convertCoordinate:coor toPointToView:self.view];
            CGRect showRect=CGRectMake(center.x, center.y, 1, 1);
            
            userViewController.delegate=self;
            
            self.popoverController=[[UIPopoverController alloc] initWithContentViewController:nav];
            self.popoverController.delegate=self;
            [self.popoverController presentPopoverFromRect:showRect inView:self.mapView permittedArrowDirections:UIPopoverArrowDirectionAny  animated:YES];
        }
        [self setChild: userViewController];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"No users match your filter" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okayAction];
        [self presentViewController:alert animated:true completion:^{
            //
        }];
    }
    
    
//    }
//    else//Sign in
//    {
//        LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
//        [del goToSignInView];
//    }
//    randomMatch
}

- (void) update {
    
    if ([LTDataSource isLextTalkCatalan])
        [[LTDataSource sharedDataSource] searchUsers:nil learningLan:@"Catalan" speakingLan:@"Catalan" inRegion:self.searchRegion withBothLangs:YES delegate:self];
    else
        [[LTDataSource sharedDataSource] searchUsers:nil learningLan:nil speakingLan:nil inRegion:self.searchRegion withBothLangs:NO delegate:self];
	
    [indicatorView startAnimating];    
}

#pragma mark -
#pragma mark MFMailComposeViewController delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	if (result==MFMailComposeResultFailed)
	{
		UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"¡Error when sending your e-mail!"
													   message:[error localizedDescription]
													  delegate:nil
											 cancelButtonTitle:@"OK"
											 otherButtonTitles:nil];
		[alert show];
	}
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void) loadView
{
    
    
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.mapView = [[MKMapView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    //SHANE
    UIButton* filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterButton addTarget:self action:@selector(presentFilter) forControlEvents:UIControlEventTouchUpInside];
//    [filterButton setTitle:@"Filter" forState:UIControlStateNormal];
    UIImage* filterButtonImage = [UIImage imageNamed:@"filter.png"];
    [filterButton setImage: filterButtonImage forState:UIControlStateNormal];
    //filterButton.frame = CGRectMake(0.0, 80.0, 80.0, 40.0);
    filterButton.frame = CGRectMake(20.0, 80.0, 20.0, 20.0);
    [self.mapView addSubview:filterButton];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.indicatorView.center = self.mapView.center;
    [self.mapView addSubview:self.indicatorView];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

// This is where we will add the zoom button!
- (void)viewDidLoad {
    [super viewDidLoad]; 
    mapReady = NO;
    
    mapFilter = [[MapFilter alloc] init];
    [self refreshAnnotations];
    
    // SHANE remove segmented control buttons here
    //Just added:winstojl
    if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 7)
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"bar-orange-ios7"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] forBarMetrics:UIBarMetricsDefault];
    else
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"bar-orange"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] forBarMetrics:UIBarMetricsDefault];

    
    
    /*
    //Buttons on the navigationBar
    UISegmentedControl * seg=[[UISegmentedControl alloc] 
                               initWithItems:[NSArray arrayWithObjects:[UIImage imageNamed:@"ShareIcon"], [UIImage imageNamed:@"LocateIcon"], [UIImage imageNamed:@"ListIcon"], [UIImage imageNamed:@"SearchIcon"], [UIImage imageNamed:@"HelpIcon"], nil]];
    seg.momentary=YES;
    seg.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [seg addTarget:self action:@selector(sementedControlPressed:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView=seg;

    //Color de la barra
    if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 7)
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"bar-orange-ios7"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] forBarMetrics:UIBarMetricsDefault];
    else
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"bar-orange"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] forBarMetrics:UIBarMetricsDefault];
    
    if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 7)
        seg.tintColor = [UIColor whiteColor];
    else
        seg.tintColor = [UIColor colorFromImage:[UIImage imageNamed:@"bar-orange"]];
    */
    
    
    [GeneralHelper setTitleTextAttributesForController:self];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    
    [self addZoomButton];
    self.tut = [[TutViewController alloc] init];
    [self.view addSubview:self.tut.view];
    
    self.removeTutBtn = [[UIButton alloc] init];
    self.removeTutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.removeTutBtn addTarget:self
               action:@selector(dismissTut)
     forControlEvents:UIControlEventTouchUpInside];
    [self.removeTutBtn setTitle:@"Got it!" forState:UIControlStateNormal];
    self.removeTutBtn.frame = CGRectMake(80.0, self.view.frame.size.height-(200.0), 160.0, 40.0);
    [self.view addSubview:self.removeTutBtn];

}

-(void) addZoomButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(centerMapOnLocalUser)
     forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(280.0, 80.0, 20.0, 20.0); // Changes the location of the button. The second parameter changes the y-axis position; the first changes the x-axis. Unknown what the last two do.
    UIImage *location = [UIImage imageNamed:@"center_map_btn.png"];
    [button setImage:location forState:UIControlStateNormal];
    [self.view addSubview:button]; // Adds the button to the view.
}
-(void)dismissTut{
    NSLog(@"Dismissed");
    [self.tut.view removeFromSuperview];
    [self.removeTutBtn removeFromSuperview];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void) viewWillAppear:(BOOL)animated {
    //If I do not do this, ads are not shown right because when hiding the navigation bar
    //the view frame is messed up until view did appear.
    /*
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        self.view.frame=CGRectMake(0, 0, 320, 411);
    else
        self.view.frame=CGRectMake(0, 0, 768, 955);
     */
    
    [super viewWillAppear:animated];

    
    //[Flurry logEvent:@"MAP_EVENT" timed:YES];
    
    /*
	[self.navigationController setNavigationBarHidden: YES animated: YES];
    [self.view setNeedsLayout];
     */
    
    self.indicatorView.center = self.mapView.center;
    
    //Size of the buttons on the bar
    CGRect frame=self.navigationItem.titleView.frame;
    frame.size.width=self.view.bounds.size.width;
    self.navigationItem.titleView.frame=frame;
    
	[self refreshAnnotations];
    
    //self.view.backgroundColor=[UIColor colorWithRed:0 green:0.44 blue:0.76 alpha:1.0];
    //self.view.backgroundColor=[UIColor colorWithRed:0.29 green:0.68 blue:0.98 alpha:1.0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
	if (mapReady == NO) {
		MKCoordinateRegion newRegion;
		newRegion.center.longitude = 2.460181;
		newRegion.center.latitude =  34.453125;
		newRegion.span.longitudeDelta = 225.000;
		newRegion.span.latitudeDelta =  161.617127;
		
		[mapView setRegion: newRegion];
		
		self.searchRegion = mapView.region;
		[self update];
	}
}
- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    //[Flurry endTimedEvent:@"MAP_EVENT" withParameters:nil];
}

- (void)dealloc {
	[[LTDataSource sharedDataSource] removeFromRequestDelegates: self];	
    
    self.mapView=nil;
    self.indicatorView=nil;
}

#pragma mark -
#pragma mark UIPopoverController Delegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverController=nil;//Lo libero así
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

#pragma mark -
#pragma mark PushControllerProtocol Delegate Methods

- (void) pushController:(UIViewController *) controller
{
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController=nil;

    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Reimplementation from UIViewController

//Show the legal notices of the map, while part of it is under the translucent UITabBar
//While the bars are not translucent, this reimplementation has no effect
-(id <UILayoutSupport>)bottomLayoutGuide
{
    return [[MapLayoutGuide alloc] initWithLength:self.tabBarController.tabBar.frame.size.height + self.lastAdHeight];
}

-(id <UILayoutSupport>)topLayoutGuide
{
    // The 65.0 is by the view for the boxes of text with the directions
    //Los 65.0 son por la vista con las cajas de texto para las direcciones
    return [[MapLayoutGuide alloc] initWithLength:self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 65.0];
}

#pragma mark Ad Reimplementation
- (CGFloat) layoutBanners:(BOOL) animated
{
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    
    CGFloat adHeight=[super layoutBanners:animated];
    CGRect newFrame=self.view.frame;//If I do it with the table, it reduces itself everytime an ad is refreshed
    newFrame.size.height=newFrame.size.height - adHeight;
    
    //Needed in iOS 7
        newFrame.origin = CGPointMake(0, 0);
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.mapView.frame=newFrame;
                         self.indicatorView.center = self.mapView.center;
                     }];
    
    return 0.0;
}

@end
