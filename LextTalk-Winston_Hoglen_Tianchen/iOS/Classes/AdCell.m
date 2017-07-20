//
//  AdCell.m
//  LextTalk
//
//  Created by Tianchen Zhang on 10/3/16.
//
//

#import "AdCell.h"

@implementation AdCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //NSLog(@"Anchura contentView: %f", self.contentView.bounds.size.width);
        //NSLog(@"Anchura cell: %f", self.bounds.size.width);
        
        
//        _button = [UIButton buttonWithType:UIButtonTypeCustom];
//        _button.frame = CGRectMake(0, 0, 50, 50);
//        _button.layer.cornerRadius = 25.0;
//        _button.layer.masksToBounds=YES;
//        _button.backgroundColor = [UIColor greenColor];
//        [self.contentView addSubview:_button];
        
        self.messageLabel=[[UILabel alloc] initWithFrame:CGRectMake(70, 20, 175, 16)];
        self.messageLabel.font=[UIFont fontWithName:@"Ubuntu-Medium" size:13];
        [self.messageLabel setText:@"Ad is Loading.."];
        self.messageLabel.textColor=[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
        self.messageLabel.textAlignment=NSTextAlignmentLeft;
        self.messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:self.messageLabel];

    }
    [self loadAdView:@"app"];
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    //[self loadAdView:@"app"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    NSLog(@"select!");
}


- (void) loadAdView: (NSString*) adtype
{
    NSMutableArray *adTypes = [[NSMutableArray alloc] init];
    if ([adtype isEqualToString:@"app"])
    {
        [adTypes addObject:kGADAdLoaderAdTypeNativeAppInstall];
    }
    else if ([adtype isEqualToString:@"content"])
    {
        [adTypes addObject:kGADAdLoaderAdTypeNativeContent];
    }
    else if ([adtype isEqualToString:@"app&content"])
    {
        [adTypes addObject:kGADAdLoaderAdTypeNativeAppInstall];
        [adTypes addObject:kGADAdLoaderAdTypeNativeContent];
    }


    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:@"ca-app-pub-3940256099942544/3986624511" rootViewController:self
                                                  adTypes:adTypes
                                                  options:nil];
    self.adLoader.delegate = self;
    [self.adLoader loadRequest:[GADRequest request]];
}


//helper function
- (void)setAdView:(UIView *)view {
    // Remove previous ad view.
    [self addSubview:view];
    [view layoutIfNeeded];
//    [self.nativeAdPlaceholder removeFromSuperview];
//    self.nativeAdPlaceholder = view;
    
    // Add new ad view and set constraints to fill its container.
   // [self.nativeAdPlaceholder addSubview:view];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
   NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(view);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewDictionary]];

}

/// Gets an image representing the number of stars. Returns nil if rating is less than 3.5 stars.
- (UIImage *)imageForStars:(NSDecimalNumber *)numberOfStars {
    double starRating = [numberOfStars doubleValue];
    if (starRating >= 5) {
        return [UIImage imageNamed:@"stars_5"];
    } else if (starRating >= 4.5) {
        return [UIImage imageNamed:@"stars_4_5"];
    } else if (starRating >= 4) {
        return [UIImage imageNamed:@"stars_4"];
    } else if (starRating >= 3.5) {
        return [UIImage imageNamed:@"stars_3_5"];
    } else {
        return nil;
    }
}


#pragma mark GADAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"%@ failed with error: %@", adLoader, [error localizedDescription]);
    //self.refreshButton.enabled = YES;
}

#pragma mark GADNativeAppInstallAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader
didReceiveNativeAppInstallAd:(GADNativeAppInstallAd *)nativeAppInstallAd {
    NSLog(@"Received native app install ad: %@", nativeAppInstallAd);
    //self.refreshButton.enabled = YES;
    
    // Create and place ad in view hierarchy.
    GADNativeAppInstallAdView *appInstallAdView = [[GADNativeAppInstallAdView alloc] init];
    appInstallAdView =
    [[[NSBundle mainBundle] loadNibNamed:@"NativeAppInstallAdView"
                                   owner:nil
                                 options:nil] firstObject];
    //[appInstallAdView setBounds: CGRectMake(0, 0, 50, 50)];
    [self setAdView:appInstallAdView];
    
    // Associate the app install ad view with the app install ad object. This is required to make the
    // ad clickable.
    appInstallAdView.nativeAppInstallAd = nativeAppInstallAd;
    
    // Populate the app install ad view with the app install ad assets.
    // Some assets are guaranteed to be present in every app install ad.
    self.button.backgroundColor = [UIColor grayColor];
    self.messageLabel.backgroundColor = [UIColor grayColor];
    self.messageLabel.text = nativeAppInstallAd.headline;
    
    ((UILabel *)appInstallAdView.headlineView).text = nativeAppInstallAd.headline;
    ((UILabel *)appInstallAdView.headlineView).font=[UIFont fontWithName:@"Ubuntu-Medium" size:14];
    ((UIImageView *)appInstallAdView.iconView).image = nativeAppInstallAd.icon.image;
    [((UIButton *)appInstallAdView.callToActionView)setTitle:nativeAppInstallAd.callToAction
                                                    forState:UIControlStateNormal];
    
    // Other assets are not, however, and should be checked first.
    if (nativeAppInstallAd.starRating) {
        ((UIImageView *)appInstallAdView.starRatingView).image =
        [self imageForStars:nativeAppInstallAd.starRating];
        appInstallAdView.starRatingView.hidden = NO;
    } else {
        appInstallAdView.starRatingView.hidden = YES;
    }
    
    if (nativeAppInstallAd.store) {
        ((UILabel *)appInstallAdView.storeView).text = nativeAppInstallAd.store;
        appInstallAdView.storeView.hidden = NO;
    } else {
        appInstallAdView.storeView.hidden = YES;
    }
    
    if (nativeAppInstallAd.price) {
        ((UILabel *)appInstallAdView.priceView).text = nativeAppInstallAd.price;
        appInstallAdView.priceView.hidden = NO;
    } else {
        appInstallAdView.priceView.hidden = YES;
    }
    
    // In order for the SDK to process touch events properly, user interaction should be disabled.
    appInstallAdView.callToActionView.userInteractionEnabled = NO;
}

#pragma mark GADNativeContentAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader
didReceiveNativeContentAd:(GADNativeContentAd *)nativeContentAd {
    NSLog(@"Received native content ad: %@", nativeContentAd);
    //self.refreshButton.enabled = YES;
    
    // Create and place ad in view hierarchy.
    
    //For contentAD in Cell. Maybe for future use
//    GADNativeContentAdView *contentAdView =
//    [[[NSBundle mainBundle] loadNibNamed:@"NativeContentAdView"
//                                   owner:nil
//                                 options:nil] firstObject];
//    [self setAdView:contentAdView];
//    
//    // Associate the content ad view with the content ad object. This is required to make the ad
//    // clickable.
//    contentAdView.nativeContentAd = nativeContentAd;
//    
//    // Populate the content ad view with the content ad assets.
//    // Some assets are guaranteed to be present in every content ad.
//    ((UILabel *)contentAdView.headlineView).text = nativeContentAd.headline;
//    ((UILabel *)contentAdView.bodyView).text = nativeContentAd.body;
//    ((UIImageView *)contentAdView.imageView).image =
//    ((GADNativeAdImage *)[nativeContentAd.images firstObject]).image;
//    ((UILabel *)contentAdView.advertiserView).text = nativeContentAd.advertiser;
//    [((UIButton *)contentAdView.callToActionView)setTitle:nativeContentAd.callToAction
//                                                 forState:UIControlStateNormal];
//    
//    // Other assets are not, however, and should be checked first.
//    if (nativeContentAd.logo && nativeContentAd.logo.image) {
//        ((UIImageView *)contentAdView.logoView).image = nativeContentAd.logo.image;
//        contentAdView.logoView.hidden = NO;
//    } else {
//        contentAdView.logoView.hidden = YES;
//    }
//    
//    // In order for the SDK to process touch events properly, user interaction should be disabled.
//    contentAdView.callToActionView.userInteractionEnabled = NO;
}


@end
