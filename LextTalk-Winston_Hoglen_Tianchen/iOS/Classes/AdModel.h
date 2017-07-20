//
//  AdViewController.h
//  FastTexts
//
//  Created by Raúl Martín Carbonell on 15/04/14.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

#ifdef HASADS

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <iAd/iAd.h>

@interface AdModel : NSObject <ADBannerViewDelegate, GADBannerViewDelegate, UIAlertViewDelegate>

+ (AdModel *) sharedInstance;
- (void) start;
- (void) removeBanners;

@property (nonatomic, assign) BOOL onlyAdMob;

@property (nonatomic, strong) ADBannerView * iadBannerView;
@property (nonatomic, strong) GADBannerView * gadBannerView;

#else

@interface AdModel : NSObject 

+ (AdModel *) sharedInstance;
- (void) removeBanners;

@property (nonatomic, assign) BOOL onlyAdMob;

@property (nonatomic, strong) UIView * iadBannerView;
@property (nonatomic, strong) UIView * gadBannerView;

#endif

@property (nonatomic) BOOL gadLoaded;
@property (nonatomic) BOOL iAdFirst;
@property (nonatomic, strong) NSString * iPhoneAdUnitId;
@property (nonatomic, strong) NSString * iPadAdUnitId;

//Inapp
@property (nonatomic, assign) NSInteger appId;
@property (nonatomic, strong) NSString * iAdFirstUrl;
@property (nonatomic, weak) UIViewController<SKStoreProductViewControllerDelegate> * presentFromController;
@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) BOOL disableAds;

//Localized texts
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) NSString * yesText;
@property (nonatomic, strong) NSString * noText;
@property (nonatomic, strong) NSString * removeText;

@end