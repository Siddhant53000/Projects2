//
//  MapViewController.h
// LextTalk
//
//  Created by nacho on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
#import "AdInheritanceViewController.h"
#import "TutViewController.h"
#import "LTDataSource.h"
#import "LTUser.h"
#import "LocalUserViewController.h"


@protocol FilterDelegate<NSObject>
@optional

- (void) filterCompleted: (NSArray*) results;
- (void) matchMe;

@end

@interface MapViewController : AdInheritanceViewController <MKMapViewDelegate,UIActionSheetDelegate, LTDataDelegate, UIPopoverControllerDelegate, PushControllerProtocol, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, FilterDelegate> {
    MKMapView					*mapView;
    UIActivityIndicatorView	*indicatorView;
    
    
    MKCoordinateRegion                  _searchRegion;
    BOOL                                mapReady;
    
	
	id									_child;
    
    UIPopoverController * popoverController;
}

@property (nonatomic, assign) MKCoordinateRegion searchRegion;
@property (nonatomic, strong) id child;
@property (nonatomic, strong) UIImage *profileImage;


//@property (nonatomic, weak) MapFilter filter;
// Tutorial: Added in, winstojl
@property (nonatomic, strong) TutViewController *tut;
@property (nonatomic,strong) UIButton *removeTutBtn;

- (IBAction) shareOnFacebook;
- (IBAction) shareOnTwitter;
- (IBAction) shareByEmail;
- (IBAction) share;
- (IBAction) centerMapOnLocalUser;
- (IBAction) showResultList;
- (IBAction) searchByName;
- (IBAction) showHelp;

- (void) goToLongitude: (CGFloat) longitude andLatitude: (CGFloat) latitude;
- (void) refreshAnnotations;

//Outlets
@property (nonatomic, strong) MKMapView					*mapView;
@property (nonatomic, strong) UIActivityIndicatorView	*indicatorView;




@property (nonatomic, strong) UIPopoverController * popoverController;

@end
