//
//  LextTalkAppDelegate.h
// LextTalk
//
//  Created by David on 10/7/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplashViewController.h"
#import "SettingsTableViewController.h" // winstojl
#import "ChatListViewController.h"
#import "ChatRoomListViewController.h"
#import "MapViewController.h"
#import "TranslatorViewController2.h"
#import "DictionaryViewController.h"
#import "CustomTabBarController.h"
#import "LTUser.h"
#import "IQKit.h"
#import "LoginUserViewController.h"
#import "ImageCache.h"
#import <AudioToolbox/AudioToolbox.h>
#import <Google/Analytics.h>

#import <iAd/iAd.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
//#import "GADBannerView.h"
//#import "GADBannerViewDelegate.h"
//#import "GADInterstitial.h"
//#import "GADInterstitialDelegate.h"
#import "ChatRoomListViewController.h"
#import "ListsViewController.h"
#import "ContactViewController.h"

#import "MBProgressHUD.h"

#import "IQStoreManager.h"

extern NSString *const LTTeacherAdProductID;
extern NSString *const LTSchoolAdProductID;
extern NSString *const LTRemoveAdsProductID;


void uncaughtExceptionHandler(NSException *exception);

@interface LextTalkAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, SplashDelegate, IQLocalizableProtocol, ADBannerViewDelegate, GADBannerViewDelegate, GADInterstitialDelegate> {
    UIWindow                    *window;
    CustomTabBarController          *tabBarController;
    SplashViewController        *splashViewController;
    ChatListViewController      *chatListViewController;
    LoginUserViewController        *loginUserViewController;
    MapViewController           *mapViewController;
    
    //LextTalk
    TranslatorViewController2 * translatorViewController;
    
    ChatRoomListViewController * chatRoomListViewController;
    
    ImageCache * imageCache;
    
    SystemSoundID chatSoundId;
}

@property (nonatomic, strong) IBOutlet UIWindow					*window;
@property (nonatomic, strong) CustomTabBarController		*tabBarController;
@property (nonatomic, strong) ChatListViewController	*chatListViewController;
@property (nonatomic, strong) LoginUserViewController		*loginUserViewController;
@property (nonatomic, strong) MapViewController		*mapViewController;
@property (nonatomic, strong) SplashViewController				*splashViewController;

@property (nonatomic, strong) TranslatorViewController2 * translatorViewController;

@property (nonatomic, strong) SettingsTableViewController * settingsViewController; // winstojl

@property (nonatomic, strong) ChatRoomListViewController * chatRoomListViewController;
@property (nonatomic, strong) ListsViewController * listsViewController;
@property (nonatomic, strong) ContactViewController * contactViewController;

@property (nonatomic, strong) ImageCache * imageCache;

@property (nonatomic, strong) IQStoreManager *storeManager;


- (void) loadRequestWithLocation;
@property (nonatomic, strong) GADInterstitial * gadInterstitial;
@property (nonatomic, assign) BOOL showingInterstitial;
@property (nonatomic, strong) NSTimer * gadInterstitialTimer;
@property (nonatomic, strong) MBProgressHUD * HUD;

@property (atomic, assign) BOOL showingError;


+ (LextTalkAppDelegate*) sharedDelegate;
- (void) goToUserAtLongitude: (CGFloat) longitude andLatitude: (CGFloat) latitude;
- (void) resetNavgationControllers;
- (void) updateUserInfo;
- (void) updateChatList;
- (void) goToSignInView;
- (void) closeSignInView;

- (void) tellUserToSignIn;
- (void) setBadgeValueTo: (NSInteger) badge;
- (NSInteger) numberOfChatControllers;

- (void) countBingUses;

//Ad removal
- (void) startSpinnerWithText:(NSString *) str;
- (void) removeAds;
- (BOOL) hasAds;
@end
