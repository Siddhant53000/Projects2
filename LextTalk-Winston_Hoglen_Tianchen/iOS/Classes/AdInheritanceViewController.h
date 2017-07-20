//
//  AdViewController.h
//  FastTexts
//
//  Created by Raúl Martín Carbonell on 15/04/14.
//
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <StoreKit/StoreKit.h>
#ifdef HASADS
#import <GoogleMobileAds/GoogleMobileAds.h>
#endif

//Things to change
// GAD ID
// removeAds code for button
// disableAds depending on targets

@interface AdInheritanceViewController : UIViewController <UIAlertViewDelegate, SKStoreProductViewControllerDelegate>


@property (nonatomic, strong, readonly) UIButton * removeAdButton;
@property (nonatomic, assign) BOOL hideRemoveButtonWhenKeyboardUp;


@property (nonatomic, assign) BOOL disableAds;
@property (nonatomic, assign) BOOL moveUpWhenKeyboardShown;
@property (nonatomic, assign) CGFloat keyboardDistance;
@property (nonatomic, assign) BOOL layoutDisabled;
@property (nonatomic, assign) BOOL alignRemoveButtonToLeft;

@property (nonatomic, strong) UIScrollView * scrollViewToLayout;
@property (nonatomic, strong) UIView * viewToLayout;

@property (nonatomic, assign) CGFloat lastAdHeight;

@property (nonatomic, assign) CGFloat extraTopInset;
@property (nonatomic, assign) CGFloat extraBottomInset;

- (void) bringBannersToFront;
- (CGFloat) layoutBanners:(BOOL) animated;

//To reimplement
- (void) keyboardWillShow:(NSNotification *) notif;
- (void) keyboardWillHide:(NSNotification *) notif;

@end
