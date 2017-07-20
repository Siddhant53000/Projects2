//
//  LextTalkAppDelegate.m
// LextTalk
//
//  Created by David on 10/7/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "LextTalkAppDelegate.h"
#import "global.h"
#import "LTDataSource.h"
#import "MapViewController.h"
#import "ChatListViewController.h"
#import "ChatViewController.h"
#import "DictionaryHandler.h"
#import "BingTranslator.h"
#import "DBLangsGenerator.h"
#import "MBProgressHUD.h"
#import "TutViewController.h"
// Stats and other external libraries
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <LAWalkthrough/LAWalkthroughViewController.h>
#import <Flurry.h>
#import "Appirater.h"
#import "MessageHandler.h"
#import "NotepadHandler.h"
#import "DictionaryDBHandler.h"
#import "AdModel.h"
#import "LocationDBHandler.h"

// IQTools import
#import "../version.h"

#import "IQAppStoreTransactionValidator.h"


#define kTimeBetweenInterstitials 300.0

//NSString *const LTTeacherAdProductID = @"com.inqbarna.lexttalk.ads.teacher";
//NSString *const LTSchoolAdProductID = @"com.inqbarna.lexttalk.ads.school";
NSString *const LTRemoveAdsProductID = @"com.inqbarna.lexttalk.removetheads";

//<IQStoreDelegate>

@interface LextTalkAppDelegate () <IQStoreManagerDelegate>
@property (nonatomic, assign) BOOL raiseUncaughtException;
@end

@implementation LextTalkAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize chatListViewController;
@synthesize loginUserViewController;
@synthesize mapViewController;
@synthesize splashViewController;
@synthesize translatorViewController;
@synthesize chatRoomListViewController;
@synthesize imageCache;
@synthesize raiseUncaughtException;

#pragma mark -
#pragma mark IQLocalizableProtocol methods

- (void) localize {
	// localize tabs
	[[[self.tabBarController viewControllers] objectAtIndex: 0] setTitle: NSLocalizedString(@"Map",@"Map")];
	[[[self.tabBarController viewControllers] objectAtIndex: 1] setTitle: NSLocalizedString(@"Chats",@"Chats")];
	[[[self.tabBarController viewControllers] objectAtIndex: 2] setTitle: NSLocalizedString(@"My Profile",@"My Profile")];
	[[[self.tabBarController viewControllers] objectAtIndex: 3] setTitle: NSLocalizedString(@"Events",@"Events")];
	[[[self.tabBarController viewControllers] objectAtIndex: 4] setTitle: NSLocalizedString(@"Statistics",@"Statistics")];	
}

#pragma mark -
#pragma mark SplashDelegate methods
- (void) splashWillDisapear {
    
    //[window addSubview:tabBarController.view];
    self.window.rootViewController=self.tabBarController;
    //[window sendSubviewToBack: tabBarController.view];
	
	// read badge number and set it into the chat tab icon
	NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
	
	[self setBadgeValueTo: badge];
    
    
    //ADs
    //Interstitials
    [self performSelector:@selector(reloadGadInterstitial) withObject:nil afterDelay:1.0];
}

- (void) splashDidDisapear {
	self.splashViewController = nil;
	
    // tell appirater the app has launched now that the splash is gone
    [Appirater setAppId:@"484851963"];
    [Appirater setDaysUntilPrompt:4];
    [Appirater setUsesUntilPrompt:4];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:1];
    //[Appirater setDebug:YES];
    
    [Appirater appLaunched: YES];
}


#pragma mark -
#pragma mark  tabBarControllerDelegate methods
- (BOOL)tabBarController:(UITabBarController *)theTabBarController shouldSelectViewController:(UIViewController *)viewController {
    if( theTabBarController.selectedIndex == 2) {
        if( [theTabBarController.viewControllers objectAtIndex: 2] == viewController) {
            return NO;
        }
    }
    return YES;
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex != 0) {
        // sign in now
        NSLog(@"HELLLLOOOOO---*******_____----~*~*~*~*~*~*~");
        [self goToSignInView];
	}
}

#pragma mark -
#pragma mark LextTalkAppDelegate methods

+ (LextTalkAppDelegate*) sharedDelegate {
    return (LextTalkAppDelegate*) [UIApplication sharedApplication].delegate;
}


- (void) tellUserToSignIn {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"You are not signed in", @"You are not signed in") 
                                                    message: NSLocalizedString(@"You must be signed in in order to use the features of LextTalk . Creating an account is free!", @"You must be signed in in order to use the features of LextTalk. Creating an account is free!")
                                                   delegate: self
                                          cancelButtonTitle: NSLocalizedString(@"Close", @"Close") 
                                          otherButtonTitles: NSLocalizedString(@"Sign in now!", @"Sign in now!"), nil];
    [alert show];
}

- (void) updateChatList {
    IQVerbose(VERBOSE_DEBUG, @"[%@] Updating chat list %@", [self class], [self.chatListViewController class]);
    [self.chatListViewController startUpdateProcess];
    //[self.chatRoomListViewController updateChatRooms];
}

- (void) updateUserInfo {
    /*
    if([self.signInViewController.navigationController.viewControllers count] < 2 ) return;
    ProfileEditorViewController *profileEditor = (ProfileEditorViewController*) [self.signInViewController.navigationController.viewControllers objectAtIndex: 1];
    IQVerbose(VERBOSE_DEBUG,@"[%@] Found profile editor, forcing to update", [self class]);
    [profileEditor update];    
     */
    
    if([self.loginUserViewController.navigationController.viewControllers count] < 2 ) return;
    LocalUserViewController *localUserViewController = (LocalUserViewController*) [self.loginUserViewController.navigationController.viewControllers objectAtIndex: 1];
    IQVerbose(VERBOSE_DEBUG,@"[%@] Found profile editor, forcing to update", [self class]);
    [localUserViewController customizeForUser];
    
    //[self.localUserViewController customizeForUser];
}

- (void) goToSignInView {
    [self.window.rootViewController presentViewController:self.loginUserViewController animated:true completion:^{
        NSLog(@"Presented log-in");
    }];
    
}

- (void) closeSignInView{
    [self.loginUserViewController dismissViewControllerAnimated:true completion:^{
    }];
}

- (void) resetNavgationControllers {
    // bring all navigation view controllers to the root view controller, except the one for the login
    for (int i=0; i<[self.tabBarController.viewControllers count]; i ++)
    {
        if (i!=3)
            [[self.tabBarController.viewControllers objectAtIndex:i] popToRootViewControllerAnimated:NO];
    }
    /*
	for(UINavigationController *nav in tabBarController.viewControllers) {
        [nav popToRootViewControllerAnimated: NO];
    }
     */
    [self.mapViewController refreshAnnotations];
}

- (void) goToUserAtLongitude: (CGFloat) longitude andLatitude: (CGFloat) latitude {
    [self.mapViewController.navigationController popToRootViewControllerAnimated: YES];
    [self.mapViewController goToLongitude: longitude andLatitude: latitude];
    //[tabBarController setSelectedIndex: 0];   
    [self.tabBarController selectTab:0];
}

- (void) setBadgeValueTo: (NSInteger) badge {
	
	// if user is not logged, badge must be null
	if(![[LTDataSource sharedDataSource] isUserLogged]) {
        [[[tabBarController.tabBar items] objectAtIndex: 1] setBadgeValue: nil];
        [self.tabBarController removeAllBadges];
		[UIApplication sharedApplication].applicationIconBadgeNumber = 0;		
		return;
	}
	
    if(badge == 0) {
        [self.tabBarController removeBadgeAtPosition:1];
        [[[tabBarController.tabBar items] objectAtIndex: 1] setBadgeValue: nil];
    } else {
        [[[tabBarController.tabBar items] objectAtIndex: 1] setBadgeValue: [NSString stringWithFormat: @"%ld", (long)badge]]; 
        [self.tabBarController setBadgeValue:[NSString stringWithFormat: @"%ld", (long)badge] atPosition:1];
    }
	
    [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
}

- (NSInteger) numberOfChatControllers
{
    NSInteger result=0;
    
    NSArray * array=self.mapViewController.navigationController.viewControllers;
    for (UIViewController * controller in array)
    {
        if ([controller isKindOfClass:[ChatViewController class]])
        {
            result++;
            break;
        }
    }
    array=self.listsViewController.navigationController.viewControllers;
    for (UIViewController * controller in array)
    {
        if ([controller isKindOfClass:[ChatViewController class]])
        {
            result++;
            break;
        }
    }
    
    return result;
}

- (void) countBingUses
{
    NSUserDefaults * defs=[NSUserDefaults standardUserDefaults];
    NSNumber * number=[defs objectForKey:@"bingUses"];
    
    NSInteger counter;
    if (number==nil)
        counter=1;
    else
        counter=[number intValue] +1;
    
    number = [NSNumber numberWithInteger:counter];
    [defs setObject:number forKey:@"bingUses"];
    [defs synchronize];
    
    if (counter % 100 == 0)
    {
        NSString * format=NSLocalizedString(@"%d Translations!", @"%d Translations!");
        NSString * message=NSLocalizedString(@"You have already used %d translations. For the time being, you can use the translation feature with no restrictions", @"You have already used %d translations. For the time being, you can use the translation feature with no restrictions");
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:format, counter]
                                                       message:[NSString stringWithFormat:message, counter]
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                             otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark -
#pragma mark IQStoreManagerDelegate methods

// data source
- (NSArray*)listOfProductsToValidateForStoreManager:(IQStoreManager*)mgr {
    return @[LTRemoveAdsProductID];
}

// downloads
- (void)storeManager:(IQStoreManager*)mgr didStartDownloadingHostedContent:(NSString *)productId {
    NSLog(@"didStartDownloadingHostedContent:%@", productId);
}

- (void)storeManager:(IQStoreManager*)mgr didUpdateDownloadProgress:(CGFloat)val timeRemaining:(NSTimeInterval)time forHostedContent:(NSString*)productId {
    NSLog(@"didUpdateDownloadProgress: %f timeRemaining:%f forHostedContent:%@", val, time,productId);
}

- (void)storeManager:(IQStoreManager*)mgr didDownloadHostedContent:(NSString *)productId inDirectory:(NSString *)path {
    NSLog(@"didDownloadHostedContent:%@ inDirectory:%@", productId, path);
}

- (void)storeManager:(IQStoreManager*)mgr didFailDownloadingHostedContent:(NSString *)productId error:(NSError*)error {
    NSLog(@"didFailDownloadingHostedContent:%@ error:%@", productId, error);
}

// transactions
- (void)storeManager:(IQStoreManager *)mgr transactionForProduct:(NSString*)productId failedWithError:(NSError*)error {
    
    [self.HUD hide:YES];
    self.HUD = nil;
    
    NSLog(@"transactionForProduct:%@ failedWithError:%@", productId, error);
    UIAlertView *v = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                message:error.localizedDescription
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"Close", nil)
                                      otherButtonTitles:nil];
    [v show];
}

- (void)storeManager:(IQStoreManager *)mgr transactionForProduct:(NSString*)productId cancelledWithError:(NSError*)error {
    NSLog(@"transactionForProduct:%@ cancelledWithError:%@", productId, error);
    
    [self.HUD hide:YES];
    self.HUD = nil;
}

- (void)storeManager:(IQStoreManager *)mgr transactionForProduct:(NSString*)productId notVerifiedWithError:(NSError*)error {
    
    [self.HUD hide:YES];
    self.HUD = nil;
    
    NSLog(@"transactionForProduct:%@ notVerifiedWithError:%@", productId, error);
    UIAlertView *v = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                message:error.localizedDescription
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"Close", nil)
                                      otherButtonTitles:nil];
    [v show];
}

- (void)storeManager:(IQStoreManager *)mgr transactionFinishedForProduct:(NSString*)productId {
    NSLog(@"transactionFinishedForProduct:%@", productId);
    
    [self.HUD hide:YES];
    self.HUD = nil;
}

// restores
- (void)storeManager:(IQStoreManager *)mgr restoreTransactionsFailedWithError:(NSError*)error {
    NSLog(@"restoreTransactionsFailedWithError:%@", error);
    
    [self.HUD hide:YES];
    self.HUD = nil;
    
    UIAlertView *v = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                message:error.localizedDescription
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"Close", nil)
                                      otherButtonTitles:nil];
    [v show];
}

- (void)storeManager:(IQStoreManager *)mgr restoreTransactionsCancelledWithError:(NSError*)error {
    NSLog(@"restoreTransactionsCancelledWithError:%@", error);
    
    [self.HUD hide:YES];
    self.HUD = nil;
}

- (void)restoreTransactionsDoneInStoreManager:(IQStoreManager*)mgr {
    NSLog(@"restoreTransactionsDoneInStoreManager");
    
    [self.HUD hide:YES];
    self.HUD = nil;
}

// product enable/disable
- (void)storeManager:(IQStoreManager*)mgr didEnableProduct:(NSString*)productId isPurchase:(BOOL)isPurchase {
    NSLog(@"didEnableProduct:%@ isPurchase:%d", productId, isPurchase);
    
    [self.HUD hide:YES];
    self.HUD = nil;
    
    if ([productId isEqualToString:LTRemoveAdsProductID]) {
        [[AdModel sharedInstance] removeBanners];
        [AdModel sharedInstance].disableAds = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAdsBought" object:self];
    }
    
    UIAlertView *v = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Thanks for your purchase!", nil)
                                                message: NSLocalizedString(@"Thanks for removing the ads", nil)
                                               delegate: nil
                                      cancelButtonTitle: NSLocalizedString(@"Close", nil)
                                      otherButtonTitles: nil];
    [v show];
}

- (void)storeManager:(IQStoreManager*)mgr didDisableProduct:(NSString*)productId {
    NSLog(@"didDisableProduct:%@", productId);
    
    [self.HUD hide:YES];
    self.HUD = nil;
}

// purchases are disabled
- (void)purchasesAreDisabledForStoreManager:(IQStoreManager*)mgr {
    
    [self.HUD hide:YES];
    self.HUD = nil;
    
    UIAlertView *v = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purchases are not enabled", nil)
                                                message:NSLocalizedString(@"Please, enable them in Settings app", nil)
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"Close", nil)
                                      otherButtonTitles:nil];
    
    [v show];
}


#pragma mark -
#pragma mark IQStoreDelegate methods
//- (void) didFailRestoreWithError:(NSError *)error
//{
//    // products are consumable !!!
//    NSLog(@"WARNING: failed product restore: %@", error);
//}
//
//- (void) didEndPaymentQueue
//{
//    NSLog(@"WARNING: all products have been restored/purchased.");
//}
//
//- (void)didRestoreProduct:(StoreProduct *)product
//{
//    // products are consumable !!!
//    NSLog(@"WARNING: restored product: %@", product.productId);
//}
//
//- (void)didGetProducts:(NSArray *)products
//{
//    NSLog(@"VERBOSE: There are %d products.", products.count);
//}
//
//- (void)emptyProductsList
//{
//    static BOOL validated = NO;
//    if (validated) {
//        NSLog(@"WARNING: there are not any products.");
//        return;
//    }
//    IQStore *store = [IQStore sharedStore];
//    StoreProduct *product = nil;
//    // Teacher ad product
//    //product = [[StoreProduct alloc] initWithProductId:LTTeacherAdProductID];
//    //[store addStoreProduct:product];
//    // School ad product
//    //product = [[StoreProduct alloc] initWithProductId:LTSchoolAdProductID];
//    //[store addStoreProduct:product];
//    // Remove ads product
//    product = [[StoreProduct alloc] initWithProductId:LTRemoveAdsProductID];
//    [store addStoreProduct:product];
//    // Validate
//    validated = YES;
//    [store validateInAppProducts];
//}
//
//- (void) didFailPurchasingProduct: (StoreProduct*) product withError:(NSError *)error
//{
//    // TODO handle?
//    NSLog(@"ERROR: purchased failed: %@", error);
//}
//
//- (void)didPurchaseProduct:(StoreProduct *)product
//{
//    // TODO handle
//    NSLog(@"TODO: Purchased product: %@", product.productId);
//}

#pragma mark -
#pragma mark UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions { 
    
    //Solo para generar las traducciones para la BBDD en otros idiomas... Dejar comentado siempre
    //DBLangsGenerator * generator=[[DBLangsGenerator alloc] init];
    //[generator translateTo:@"French" withAppLan:@"fr"];
    //NSLog(@"Locale: %@", [[NSLocale preferredLanguages] objectAtIndex:0]);
    
#if DEBUG
    NSLog(@"path=%@", [[NSBundle mainBundle] bundlePath]);
    NSLog(@"version=%@", BUNDLE_VERSION);
#endif
   // [Fabric with:@[[Crashlytics class]]];
  //AO

  [Fabric with:@[CrashlyticsKit]];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    //iOS 7 only stuff here
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    else
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
#endif
    
    //Chat sound
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"chat" ofType:@"wav"];
    NSURL * spokenUrl=[NSURL fileURLWithPath:filePath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) spokenUrl, &chatSoundId);
    
    //AO
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);

    // Exception and signal handlers
    // installs HandleExceptions as the Uncaught Exception Handler
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    //Flurry
    [Flurry setSessionContinueSeconds:1800];
    [Flurry startSession:@"EWD7B5AT19N7TJAWR5I4"];
    // logAllPageViews is done on splash viewDidLoad
    
    //Messages DDBB
    //[MessageHandler deleteDatabase];
    [MessageHandler installDatabase];
    [[NotepadHandler getSharedInstance] installDatabase];
    [[DictionaryDBHandler getSharedInstance] installDatabase];
    [[LocationDBHandler getSharedInstance] installDatabase];
    
//    NSArray *notePadResults = [[NotepadHandler getSharedInstance] getUserNotepad];
//    if (!notePadResults || [notePadResults count] == 0) {
//        NSLog(@"Adding first note");
//        [[NotepadHandler getSharedInstance] saveData:@"Hello world"];
//    }
//    notePadResults = [[NotepadHandler getSharedInstance] getUserNotepad];
//    NSLog(@"Notepad results: %@", notePadResults[0]);
    //[NotepadHandler installDatabase];

    
    //Chat config
    NSUserDefaults * defs=[NSUserDefaults standardUserDefaults];
    [defs setObject:@"on" forKey:@"config_chatSound"];
    [defs setObject:@"on" forKey:@"config_chatVibration"];
    [defs synchronize];

    
    //Image cache
    self.imageCache=[[ImageCache alloc] init];
    [self.imageCache fillInCache];
    
	IQVerboseLevel(VERBOSE_NO);
	
	// init the data source
	[LTDataSource sharedDataSource];
	
#if !TARGET_IPHONE_SIMULATOR
    IQVerbose(VERBOSE_DEBUG,@"[%@] Registering for push notifications...", [self class]);    
    if ( NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 ) {
        // iOS8
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
        
    }
#endif
    
    // Start location updates
    [[LTDataSource sharedDataSource] updateLocation];
    
    //ChatListViewController and ChatRoomListViewController
    //self.chatListViewController=[[[ChatListViewController alloc] initWithNibName:@"ChatListViewController-iPhone" bundle:nil] autorelease];
    //self.chatRoomListViewController=[[[ChatRoomListViewController alloc] init] autorelease];
    
    
    // Configure IQStore
    //[[IQStore sharedStore] loadStoreWithDelegate:self];
    self.storeManager = [[IQStoreManager alloc]init];
    self.storeManager.delegate = self;
    self.storeManager.useKeychain = NO;
    self.storeManager.transactionValidator = [[IQAppStoreTransactionValidator alloc]initWithContentProviderSharedSecret:@"0d096d9020054551ab6f9396d03e814a"];
    [self.storeManager startLoadingProducts];
    
    //Dicitionary for the users to store their definitions
    [DictionaryHandler createDictionaryIfItDoesntExist];
    
    
    //Creación en código en vez de con el xib
    self.tabBarController = [[CustomTabBarController alloc] init];
    //Map
    self.mapViewController = [[MapViewController alloc] init];
    
    self.mapViewController.title = NSLocalizedString(@"Map", nil);
    UITabBarItem * item=[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Map", nil) image:[UIImage imageNamed:@"map_tab_icon"] tag:0];
    self.mapViewController.tabBarItem = item;
    //Chat
    self.chatListViewController = [[ChatListViewController alloc] init];
    self.chatListViewController.title = NSLocalizedString(@"Chats", nil);
    item=[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Chats", nil) image:[UIImage imageNamed:@"chat_tab_icon"] tag:0];
    self.chatListViewController.tabBarItem = item;
    //ChatRooms
    self.chatRoomListViewController = [[ChatRoomListViewController alloc] init];
    self.chatRoomListViewController.title = NSLocalizedString(@"Chat rooms", nil);
    item=[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Chat rooms", nil) image:[UIImage imageNamed:@"chat_tab_icon"] tag:0];
    self.chatRoomListViewController.tabBarItem = item;
    //Login
    self.loginUserViewController = [[LoginUserViewController alloc] init];
    self.loginUserViewController.title = NSLocalizedString(@"Profile", nil);
    //item=[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Profile", nil) image:[UIImage imageNamed:@"profile_tab_icon"] tag:0];
    //self.loginUserViewController.tabBarItem = item;*/
    //Translator
    self.translatorViewController = [[TranslatorViewController2 alloc] init];
    self.translatorViewController.title = NSLocalizedString(@"Translator", nil);
    item=[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Translator", nil) image:[UIImage imageNamed:@"profile_tab_icon"] tag:0];
    self.translatorViewController.tabBarItem = item;
    
    
    //Lists
    self.listsViewController = [[ListsViewController alloc] init];
    self.listsViewController.title = NSLocalizedString(@"Chats & Chatrooms", nil);
    item=[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Chats & Chatrooms", nil) image:[UIImage imageNamed:@"chat_tab_icon"] tag:0];
    self.listsViewController.tabBarItem = item;
    self.listsViewController.chatListViewController = self.chatListViewController;
    self.listsViewController.chatRoomListViewController = self.chatRoomListViewController;
    
    //Contact
    /*self.contactViewController = [[ContactViewController alloc] init];
    self.contactViewController.title = NSLocalizedString(@"Contacts", nil);
    item=[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Contacts", nil) image:[UIImage imageNamed:@"chat_tab_icon"] tag:0];
    self.contactViewController.tabBarItem = item;
    */
    //Settings
    
    self.settingsViewController = [[SettingsTableViewController alloc] init];
    self.settingsViewController.title = NSLocalizedString(@"Settings", nil);
    item=[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Settings", nil) image:[UIImage imageNamed:@"chat_tab_icon"] tag:0];
    self.settingsViewController.tabBarItem = item;
    
    //Navigation Controllers
    UINavigationController * nav0 = [[UINavigationController alloc] initWithRootViewController:self.mapViewController];
    
    //UINavigationController * nav1 = [[[UINavigationController alloc] initWithRootViewController:self.chatListViewController] autorelease];
    UINavigationController * nav1 = [[UINavigationController alloc] initWithRootViewController:self.listsViewController];
    UINavigationController * nav2 = [[UINavigationController alloc] initWithRootViewController:self.settingsViewController];
    //UINavigationController * nav3 = [[UINavigationController alloc] initWithRootViewController:self.loginUserViewController];
    UINavigationController * nav3 = [[UINavigationController alloc] initWithRootViewController:self.translatorViewController];
    
    [self.tabBarController setViewControllers:[NSArray arrayWithObjects:nav0, nav1, nav2, nav3, /*nav4*/ nil] animated:NO];
    
    
    // Update databse if needed
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.splashViewController = [[SplashViewController alloc] initWithNibName: @"SplashViewController-iPad" bundle: nil];        
    } else {
        self.splashViewController = [[SplashViewController alloc] initWithNibName: @"SplashViewController-iPhone" bundle: nil];        
    }
    
    
    [self.splashViewController setDelegate: self];
    //[window addSubview:self.splashViewController.view];
    self.window.rootViewController=self.splashViewController;
    [self.window makeKeyAndVisible];
    
    
    [self.splashViewController continueLaunchingApplication];
   
    
    //ADS
    if ([self hasAds])
    {
        [AdModel sharedInstance].onlyAdMob = YES;
        [AdModel sharedInstance].disableAds =  NO;


        [AdModel sharedInstance].iPhoneAdUnitId = @"ca-app-pub-7555499327210360/5289251336";
        [AdModel sharedInstance].iPadAdUnitId = @"ca-app-pub-7358890911856557/3393175220";
        
        //AO Old adMob configuration
        
//        [AdModel sharedInstance].iPhoneAdUnitId = @"ca-app-pub-7358890911856557/1916442027";
//        [AdModel sharedInstance].iPadAdUnitId = @"ca-app-pub-7358890911856557/3393175220";
//
        
        //[AdModel sharedInstance].appId = 843768718;
        //[AdModel sharedInstance].iAdFirstUrl = @"https://dl.dropboxusercontent.com/u/4218146/TraficoNO_ad.cfg";
        [AdModel sharedInstance].iAdFirstUrl = nil;
        [AdModel sharedInstance].removeText = NSLocalizedString(@"Remove", nil);
        
        [AdModel sharedInstance].target = self;
        [AdModel sharedInstance].selector = @selector(removeAds);
        
        [[AdModel sharedInstance] start];
    }
    else
    {
        [AdModel sharedInstance].disableAds =  YES;
    }
    
    
    //Font Configuration in all app
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.5]];    
    NSDictionary * dic;
    dic = [NSDictionary dictionaryWithObjectsAndKeys:
           [UIFont fontWithName:@"Ubuntu-Bold" size:12], NSFontAttributeName,
           [UIColor whiteColor], NSForegroundColorAttributeName,
           shadow, NSShadowAttributeName, nil];
    
    //Configuration for search display controllers search bars
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], [UIToolbar class], nil] setTitleTextAttributes:dic forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], [UIToolbar class], nil] setTitleTextAttributes:dic forState:UIControlStateHighlighted];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:dic forState:UIControlStateSelected];
    [[UISegmentedControl appearance] setTitleTextAttributes:dic forState:UIControlStateHighlighted];
    [[UISegmentedControl appearance] setTitleTextAttributes:dic forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setTitleTextAttributes:dic forState:UIControlStateDisabled];
    
    [[UISearchBar appearance] setScopeBarButtonTitleTextAttributes:dic forState:UIControlStateNormal];
    
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:@"Ubuntu" size:12]];
    
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:dic forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundImage:[[UIImage imageNamed:@"clear"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]  forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	IQVerbose(VERBOSE_DEBUG,@"[%@] Application will enter foreground", [self class]);
    
    // Appirater
    [Appirater appEnteredForeground:YES];
    
	// prevent a lock
	[self.splashViewController continueLaunchingApplication];	
	
    [[LTDataSource sharedDataSource] updateLocation];
	
	// read badge number and set it into the chat tab icon
	NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
	
	[self setBadgeValueTo: badge];
	
	// if there are unreaded messages,we should force the chatViewController to refresh the list of messages...
	[self updateChatList];
    //Llamar al método para actualizar las chatrooms cuando la app se lanza desde 
    [self.chatRoomListViewController reloadController:YES];
    
    //Renew Microsoft Translator token
    [self.translatorViewController.bingTranslator downloadToken];
    
    //Renew timer for interstitials
    //self.gadInterstitialTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeBetweenInterstitials target:self selector:@selector(reloadGadInterstitial) userInfo:nil repeats:YES];
    //always show an add when coming from the background
    //[self reloadGadInterstitial];
    [self performSelector:@selector(reloadGadInterstitial) withObject:nil afterDelay:1.0];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	IQVerbose(VERBOSE_DEBUG,@"[%@] Application will enter background", [self class]);	
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
//    [FBSettings publishInstall:@"335477276468847"];
    [FBAppEvents activateApp];
    [[LTDataSource sharedDataSource] handleFacebookDidBecomeActive];
}

- (void) applicationWillTerminate:(UIApplication *)application
{
    [[LTDataSource sharedDataSource] handleFacebookApplicatinWillTerminate];
}

#pragma mark - Push Notifications Methods
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        [application registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken { 
	NSString *token = [NSString stringWithFormat: @"%@",[deviceToken description]];
    token = [token stringByReplacingOccurrencesOfString: @">" withString: @""];
    token = [token stringByReplacingOccurrencesOfString: @"<" withString: @""];    
    token = [token stringByReplacingOccurrencesOfString: @" " withString: @""];    

    IQVerbose(VERBOSE_DEBUG,@"[%@] Did get APNS token: %@", [self class], token);
    NSLog(@"[%@] Did get APNS token: %@", [self class], token);
	[[LTDataSource sharedDataSource] setAndSaveApnsToken: token];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err { 
    IQVerbose(VERBOSE_DEBUG,@"[%@] Failed to get APNS token: %@", [self class], [err description]);
    NSLog(@"[%@] Failed to get APNS token: %@", [self class], [err description]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    //NSLog(@"Dic Notificacion: %@", userInfo);
    
    NSUserDefaults * defs=[NSUserDefaults standardUserDefaults];
    BOOL playSound=NO;
    BOOL vibrate=NO;
    if ([[defs objectForKey:@"config_chatSound"] isEqualToString:@"on"])
        playSound=YES;
    if ([[defs objectForKey:@"config_chatVibration"] isEqualToString:@"on"])
        vibrate=YES;


    if (playSound)
    {
        if (vibrate)
            AudioServicesPlayAlertSound(chatSoundId);
        else
            AudioServicesPlaySystemSound(chatSoundId);
    }
    else
    {
        if (vibrate)
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    if ([userInfo objectForKey:@"glocal"]!=nil)
    {
        NSDictionary * glocal=[userInfo objectForKey:@"glocal"];
        if (([glocal objectForKey:@"msg_id"]!=nil) && ([[glocal objectForKey:@"room"] intValue]==1))
        {
            NSInteger chatroomId=[[glocal objectForKey:@"msg_id"] intValue];
            
            [self.chatRoomListViewController newMessagesInChatroom:chatroomId];
        }
        else 
            [self updateChatList];
    }
}

- (void)dealloc {
    AudioServicesDisposeSystemSoundID(chatSoundId);
    
    
    
    self.gadInterstitial = nil;
    [self.gadInterstitialTimer invalidate];
    
    
}

#pragma mark -
#pragma mark iAD delegate methods
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    //[self layoutForCurrentOrientation:YES];
    //[self layoutMobFoxForCurrentOrientation:YES];
    
    IQVerbose(VERBOSE_DEBUG,@"[%@] iAd: did load ad", [self class]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LayoutForBannersNeeded" object:self];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    //[self layoutForCurrentOrientation:YES];
    //[self layoutMobFoxForCurrentOrientation:YES];
    
    IQVerbose(VERBOSE_DEBUG,@"[%@] iAd: did NOT load ad", [self class]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LayoutForBannersNeeded" object:self];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    // While the banner is visible, we don't need to tie up Core Location to track the user location
    // so we turn off the map's display of the user location. We'll turn it back on when the ad is dismissed.
    //mapView.showsUserLocation = NO;
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    // Now that the banner is dismissed, we track the user's location again.
    //mapView.showsUserLocation = YES;
}

#pragma mark -
#pragma mark GAD delegate methods
- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    IQVerbose(VERBOSE_DEBUG,@"[%@] GAD: did load ad", [self class]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LayoutForBannersNeeded" object:self];
}

- (void)adView:(GADBannerView *)view
didFailToReceiveAdWithError:(GADRequestError *)error
{
    IQVerbose(VERBOSE_DEBUG,@"[%@] GAD: did NOT load ad", [self class]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LayoutForBannersNeeded" object:self];
}

#pragma mark -
#pragma mark GAD Interstitial reload

- (void) reloadGadInterstitial
{
    //NSLog(@"Timer fired");
    
    NSDate * lastInterstitialDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastInterstitialDate"];
    if ((!self.showingInterstitial) && ([self hasAds]) && ( (- [lastInterstitialDate timeIntervalSinceNow] > 24*3600) || (lastInterstitialDate==nil)))
    {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            //AO old config
//            self.gadInterstitial =[[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-7358890911856557/7149018022"];
            //AO new config
            self.gadInterstitial =[[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-7555499327210360/3672917333"];
        } else {
            self.gadInterstitial =[[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-7358890911856557/8625751224"];
        }
        self.gadInterstitial.delegate = self;
        GADRequest * request = [GADRequest request];
        //request.testDevices = @[ kGADSimulatorID ];
        [self.gadInterstitial loadRequest:request];
    }
}

#pragma mark -
#pragma mark GAD Interstitial delegate
- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastInterstitialDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.gadInterstitial presentFromRootViewController:self.tabBarController];
}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error
{
    
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)interstitial
{
    self.showingInterstitial = YES;
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)interstitial
{
    
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial
{
    self.showingInterstitial = NO;
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)interstitial
{
    
}

#pragma mark -
#pragma mark Other AD methods


- (void) removeAds
{
    [self startSpinnerWithText:NSLocalizedString(@"Purchasing remove ads...", nil)];
    [self.storeManager startPurchaseProcessForProduct:LTRemoveAdsProductID];
}

#pragma mark -
#pragma mark AD removal methods

- (void) startSpinnerWithText:(NSString *) str
{
    self.HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.view];
    [self.tabBarController.view addSubview:self.HUD];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.labelText = str;
    [self.HUD show:YES];
}


- (BOOL) hasAds
{
    return ![self.storeManager productIsEnabled:LTRemoveAdsProductID];
}

#pragma mark -
#pragma mark Facebook

- (BOOL)handleOpenURL:(NSURL*)url
{
    /*
    NSString* scheme = [url scheme];
    NSString* prefix = [NSString stringWithFormat:@"fb%@", SHKCONFIG(facebookAppId)];
    if ([scheme hasPrefix:prefix])
        return [SHKFacebook handleOpenURL:url];
     */
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation 
{
    return [[LTDataSource sharedDataSource] handleFacebookUrl:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
    return [self handleOpenURL:url];  
}

#pragma mark - UIAlertViewDelegate methods

+ (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // Uncaught exception handler alert view has been dismissed...
    if(buttonIndex == alertView.cancelButtonIndex) {
        // user selected to let the app crash
        [LextTalkAppDelegate sharedDelegate].raiseUncaughtException = YES;
    }
}

@end

void uncaughtExceptionHandler(NSException *exception) {
    NSString *message, *title;
#ifdef DEBUG
    title = NSLocalizedString(@"Unhandled exception", nil);
    message = [NSString stringWithFormat:
               NSLocalizedString(@"You can try to continue but the application may be unstable.\n\nDebug details follow:\n%@\n%@",nil),
               [exception reason],
               [[exception userInfo] objectForKey:@"UncaughtExceptionHandlerAddressesKey"]];
#else
    title = NSLocalizedString(@"Error", nil);
    message = NSLocalizedString(@"You can try to continue but the application may be unstable.",nil);
    NSLog(@"Unhandled Exception: %@\n%@", [exception reason], [exception userInfo]);
    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
#endif
    [[[UIAlertView alloc]
      initWithTitle:title
      message:message
      delegate:[LextTalkAppDelegate class]
      cancelButtonTitle:NSLocalizedString(@"Quit", nil)
      otherButtonTitles:NSLocalizedString(@"Continue", nil), nil]show];
    
	// Use active wait to keep runing the loop alive
	CFRunLoopRef runLoop = CFRunLoopGetCurrent();
	CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    NSArray *modes = (__bridge NSArray *)allModes;
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	while (![LextTalkAppDelegate sharedDelegate].raiseUncaughtException) {
        // loop forever or until user touches "Quit" button or until there is another exception
		for (NSString *mode in modes) {
			CFRunLoopRunInMode((CFStringRef)mode, 0.01, true);
		}
	}
    // User has selected to quit the app...
    [exception raise];
}


