//
//  AdViewController2.m
// LextTalk
//
//  Created by Yo on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AdViewController2.h"
#import "LextTalkAppDelegate.h"
#import <iAd/iAd.h>
//#import "GADBannerView.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

//#define IAD_FIRST NO

@interface AdViewController2 ()

@property (nonatomic, strong) UIButton * removeAdButton;

@end

@implementation AdViewController2
@synthesize disableAds, adOffset;

#pragma mark - AD Handling methods

- (CGFloat) layoutBanners:(BOOL) animated
{
    CGFloat result=0.0;
    
    if (!self.disableAds)
    {
        //Take the banner views from the delegate
        LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
        ADBannerView * iadBannerView=del.iadBannerView;
        GADBannerView * gadBannerView=del.gadBannerView;
        BOOL gadLoaded=del.gadLoaded;
        BOOL IAD_FIRST=del.iAdFirst;
        
        CGFloat margin = 0.0;
        
        if ([gadBannerView isDescendantOfView:self.view] && [iadBannerView isDescendantOfView:self.view])
        {
            CGFloat animationDuration = animated ? 0.2f : 0.0f;
            // by default content consumes the entire view area
            CGRect contentFrame = self.view.bounds;
            // the banner still needs to be adjusted further, but this is a reasonable starting point
            // the y value will need to be adjusted by the banner height to get the final position
            CGPoint bannerOriginGad = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame));
            CGFloat bannerHeightGad = 0.0f;
            CGPoint bannerOriginIAd = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame));
            CGFloat bannerHeightIAd = 0.0f;
            
            
            //Condiciones
            BOOL gadCondition, iAdCondition;
            if (IAD_FIRST)
            {
                iAdCondition=iadBannerView.bannerLoaded;
                gadCondition=(!iadBannerView.bannerLoaded) && gadLoaded;
            }
            else
            {
                gadCondition=gadLoaded;
                iAdCondition=(!gadLoaded) && iadBannerView.bannerLoaded;
            }
            
            
            
            /*
             CGSize adSize = anAdView.frame.size;
             CGRect newFrame = anAdView.frame; 
             newFrame = anAdView.frame; 
             newFrame.size.height = adSize.height; // fit the ad 
             newFrame.size.width = adSize.width; 
             newFrame.origin.x = (self.view.bounds.size.width - adSize.width)/2; // center 
             newFrame.origin.y = self.view.frame.size.height - adSize.height;
             */
            //GAD
            bannerHeightGad=gadBannerView.frame.size.height;
            
            // Depending on if the banner has been loaded, we adjust the content frame and banner location
            // to accomodate the ad being on or off screen.
            // This layout is for an ad at the bottom of the view.
            if (gadCondition)
            {
                bannerOriginGad.y=self.view.frame.size.height - bannerHeightGad - self.adOffset;
                result = bannerHeightGad;
            }
            else
            {
                bannerOriginGad.y = self.view.frame.size.height;
            }
            //iAD always uses the whole width of the screen, gad does not
            bannerOriginGad.x=(self.view.bounds.size.width - gadBannerView.bounds.size.width)/2;
            if (gadCondition)
                margin = bannerOriginGad.x;
            /*
             CGPoint gadInitialOrigin=gadBannerView.frame.origin;
             gadInitialOrigin.x=bannerOriginGad.x;
             gadBannerView.frame=CGRectMake(gadInitialOrigin.x, gadInitialOrigin.y, gadBannerView.frame.size.width, gadBannerView.frame.size.height);
             */
            
            
            
            //IAD
//            if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
//                iadBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
//            else
//                iadBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait; 
            [iadBannerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            
            bannerHeightIAd = iadBannerView.bounds.size.height;
            
            if (iAdCondition)
            {
                bannerOriginIAd.y=self.view.frame.size.height - bannerHeightIAd - self.adOffset;
                result=bannerHeightIAd;
            }
            else
            {
                bannerOriginIAd.y = self.view.frame.size.height;
            }
            
            
            
            // And finally animate the changes, running layout for the content view if required.
            //It is strange, although the notification is removed in viewWillDisappear, it seems that
            //the method is called anyway, so I make sure the banners are in self.view before doing anything.
            [UIView animateWithDuration:animationDuration
                             animations:^{
                                 //self.view.frame = contentFrame;
                                 //[mainView layoutIfNeeded];
                                 gadBannerView.frame = CGRectMake(bannerOriginGad.x, bannerOriginGad.y, gadBannerView.frame.size.width, gadBannerView.frame.size.height);
                                 iadBannerView.frame = CGRectMake(bannerOriginIAd.x, bannerOriginIAd.y, iadBannerView.frame.size.width, iadBannerView.frame.size.height);
                             }];
            /*
             NSLog(@"------------------ADController----------------");
             NSLog(@"Bounds width: %f, height: %f", self.view.bounds.size.width, self.view.bounds.size.height);
             NSLog(@"Frame width: %f, height: %f", self.view.frame.size.width, self.view.frame.size.height);
             NSLog(@"Frame x: %f, y: %f", self.view.frame.origin.x, self.view.frame.origin.y);
             NSLog(@"Dimension: %f, %f, %f, %f:", bannerOriginGad.x, bannerOriginGad.y, gadBannerView.frame.size.width, gadBannerView.frame.size.height);
             NSLog(@"------------------FIN ADController----------------");
             */
        }
        
        if (result> 0.0)
        {
            //GAD banners do not take all the width in iPad, that's why I use margin
            //Do not like it, do not use for the moment
            //if ([self isKindOfClass:[MapViewController class]])
                self.removeAdButton.frame = CGRectMake(self.view.frame.size.width - self.removeAdButton.frame.size.width, self.view.frame.size.height - result - self.adOffset - 25.0, self.removeAdButton.frame.size.width, self.removeAdButton.frame.size.height);
            /*
            else
                self.removeAdButton.frame = CGRectMake(0, self.view.frame.size.height - result - self.adOffset - 25.0, self.removeAdButton.frame.size.width, self.removeAdButton.frame.size.height);
             */
            if (![self.removeAdButton isDescendantOfView:self.view])
            {
                [self.view addSubview:self.removeAdButton];
            }
            if (self.adOffset>0)
                self.removeAdButton.alpha = 0.0;
            else
                self.removeAdButton.alpha = 0.90;
                
        }
        else
            [self.removeAdButton removeFromSuperview];
        
    }
    
    
    return result;
}

- (void) layoutNeeded
{
    [self layoutBanners:YES];
}

- (void) removeAds
{
    LextTalkAppDelegate * del = (LextTalkAppDelegate *) [UIApplication sharedApplication].delegate;

    [del startSpinnerWithText:NSLocalizedString(@"Purchasing remove ads...", nil)];
    [del.storeManager startPurchaseProcessForProduct:LTRemoveAdsProductID];
}

#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.disableAds)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutNeeded) name:@"LayoutForBannersNeeded" object:nil];
        //I add the banners to the view, and force a layout
        LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
        ADBannerView * iadBannerView=del.iadBannerView;
        GADBannerView * gadBannerView=del.gadBannerView;
        [self.view addSubview:iadBannerView];
        [self.view addSubview:gadBannerView];
    }
    
    //¿DEJARLO QUITADO?
    //[self layoutBanners:NO];
}

- (void) viewDidAppear:(BOOL)animated
{
    //¿DEJARLO PUESTO AQUÍ?
    [super viewDidAppear:animated];
    
    //Si no pongo esto parece que en viewWillAppear no ha hecho correctamente el calculo de los bounds
    //y posiciona mal el banner si he vuelvo desde otra pantalla donde haya cambiado la orientación
    [self layoutBanners:NO];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!self.disableAds)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LayoutForBannersNeeded" object:nil];
    //Remove the banners from the superview, not needed probably
    //It must be removed, viewWillDisapper and viewWillAppear are not called in the order expected
    /*
    LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
    ADBannerView * iadBannerView=del.iadBannerView;
    GADBannerView * gadBannerView=del.gadBannerView;
    [iadBannerView removeFromSuperview];
    [gadBannerView removeFromSuperview];
     */
}

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
  */

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Just for translation use later
    self.removeAdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.removeAdButton setBackgroundImage:[[UIImage imageNamed:@"RemoveAdImage"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 28, 0, 29)] forState:UIControlStateNormal];
    self.removeAdButton.titleEdgeInsets = UIEdgeInsetsMake(0, 23, 0, 0);
    [self.removeAdButton setTitle:NSLocalizedString(@"Remove", nil) forState:UIControlStateNormal];
    [self.removeAdButton setTitleColor:[UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:0.9] forState:UIControlStateNormal];
    self.removeAdButton.titleLabel.font = [UIFont fontWithName:@"Ubuntu-Light" size:10];
    self.removeAdButton.alpha = 0.90;
    
    CGSize labelSize = [self.removeAdButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.removeAdButton.titleLabel.font}];
    // Values are fractional -- you should take the ceilf to get equivalent values
    CGSize size = CGSizeMake(ceilf(labelSize.width), ceilf(labelSize.height));
    
    self.removeAdButton.frame = CGRectMake(0, 0, 27 + size.width + 2, 25);
    
    [self.removeAdButton addTarget:self action:@selector(removeAds) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutBanners:YES];
}

- (void) dealloc
{
    self.removeAdButton = nil;
    if (!self.disableAds)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LayoutForBannersNeeded" object:nil];
    
}

@end
