//
//  AdViewController.m
//  FastTexts
//
//  Created by Raúl Martín Carbonell on 15/04/14.
//
//

#import "AdModel.h"


@interface AdModel ()
@end

@implementation AdModel

- (id) init
{
    self=[super init];
    if (self)
    {
        _iAdFirst = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AdModel_iAdFirst"] boolValue];
    }
    return self;
}

- (void) setIAdFirst:(BOOL)iAdFirst
{
    if (_iAdFirst != iAdFirst)
    {
        _iAdFirst = iAdFirst;
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:iAdFirst] forKey:@"AdModel_iAdFirst"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LayoutForBannersNeeded" object:self];
    }
}



+ (AdModel *) sharedInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
        
    });
    return _sharedInstance;
}

- (void) start
{
    [self determineIAdFirst];
    [self setUpBanners];
}

- (void) setUpBanners
{
#ifdef HASADS
    if ( ! self.disableAds)
    {
        //iAd
        if ( ! self.onlyAdMob )
        {
            self.iadBannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
            // Set the autoresizing mask so that the banner is pinned to the bottom
            self.iadBannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
            self.iadBannerView.delegate=self;
        }
        
        //GAD
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
            self.gadBannerView=[[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        else
            self.gadBannerView=[[GADBannerView alloc] initWithAdSize:kGADAdSizeLeaderboard];
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
            self.gadBannerView.adUnitID=self.iPhoneAdUnitId;
        else
            self.gadBannerView.adUnitID=self.iPadAdUnitId;//Solo lo voy a sacar para el iPhone, no debería afectar
        //self.gadBannerView.rootViewController=self.tabBarController;//Poner en el controlador
        self.gadBannerView.delegate=self;
        //[self.gadBannerView loadRequest:[GADRequest request]];
    }
#endif
}

- (void) removeBanners
{
#ifdef HASADS
    [self.gadBannerView removeFromSuperview];
    self.gadBannerView.delegate = nil;
    self.gadBannerView = nil;
    
    [self.iadBannerView removeFromSuperview];
    self.iadBannerView.delegate = nil;
    self.iadBannerView = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LayoutForBannersNeeded" object:self];
#endif
}

- (void) determineIAdFirst
{
#ifdef HASADS
    //Get Value from defaults first
    if (self.onlyAdMob)
        self.iAdFirst = NO;
    else
    {
        //Now, get it from the network
        if (self.iAdFirstUrl != nil)
        {
            dispatch_queue_t queue = dispatch_queue_create("Determine iAd First", NULL);
            dispatch_async(queue, ^{
                
                NSString * str = [NSString stringWithContentsOfURL:[NSURL URLWithString:self.iAdFirstUrl] encoding:NSUTF8StringEncoding error:NULL];
                //NSLog(@"iad: %@", str);
                
                if (str != nil)
                {
                    BOOL iAdFirst;
                    if ([str rangeOfString:@"iad=1" options:NSCaseInsensitiveSearch].location != NSNotFound)
                    {
                        //NSLog(@"cumplido");
                        //Solo si se cumple, el otro es el valor por defecto, y si el fichero no lo cambia, no hago nada más.
                        iAdFirst = YES;
                    }
                    else
                    {
                        //NSLog(@"No cumplido");
                        iAdFirst = NO;
                    }
                    //Update only if it has changed
                    if (iAdFirst != self.iAdFirst)
                    {
                        self.iAdFirst = iAdFirst;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"LayoutForBannersNeeded" object:self];
                        });
                    }
                }
                
            });
        }
    }
#endif
}



#ifdef HASADS

#pragma mark -
#pragma mark iAD delegate methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LayoutForBannersNeeded" object:self];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
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
    self.gadLoaded=YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LayoutForBannersNeeded" object:self];
}

- (void)adView:(GADBannerView *)view
didFailToReceiveAdWithError:(GADRequestError *)error
{
    self.gadLoaded=NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LayoutForBannersNeeded" object:self];
}

#pragma mark - UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        //Go to App Store. Use appId of the free version. Open, but do not leave the app
        SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
        NSNumber *appId = [NSNumber numberWithInteger: self.appId];
        [storeViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:appId} completionBlock:nil];
        storeViewController.delegate = self.presentFromController;
        
        [self.presentFromController presentViewController:storeViewController animated:YES completion:NULL];
    }
}

#endif

@end

