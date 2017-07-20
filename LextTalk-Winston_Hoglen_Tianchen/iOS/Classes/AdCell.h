//
//  AdCell.h
//  LextTalk
//
//  Created by Tianchen Zhang on 10/3/16.
//
//

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <iAd/iAd.h>
#import <UIKit/UIKit.h>

@interface AdCell : UITableViewCell<GADNativeAppInstallAdLoaderDelegate, GADNativeContentAdLoaderDelegate>
@property (weak, nonatomic) IBOutlet UIButton *tempButton;

/// Container that holds the native ad.
@property (weak, nonatomic) IBOutlet UIView *nativeAdPlaceholder;
/// You must keep a strong reference to the GADAdLoader during the ad loading process.
@property(nonatomic, strong) GADAdLoader *adLoader;

/// The native ad view that is being presented.
@property(nonatomic, strong) UIView *nativeAdView;

@property (nonatomic, strong, readonly) UIButton * button;
@property (nonatomic, strong) UILabel * messageLabel;
@end
