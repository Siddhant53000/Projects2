//
//  AdViewController.m
//  FastTexts
//
//  Created by Raúl Martín Carbonell on 15/04/14.
//
//

#import "AdInheritanceViewController.h"
#import "AdModel.h"



@interface AdInheritanceViewController ()

@property (nonatomic, strong) UIButton * removeAdButton;
@property (nonatomic, assign) BOOL visible;

@end

@implementation AdInheritanceViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        #ifdef HASADS
        self.disableAds = [AdModel sharedInstance].disableAds;
        #else
        self.disableAds = YES;
        #endif
        
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void) setMoveUpWhenKeyboardShown:(BOOL)moveUpWhenKeyboardShown
{
    _moveUpWhenKeyboardShown = moveUpWhenKeyboardShown;
    
    if (_moveUpWhenKeyboardShown)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Button
    if (!self.disableAds)
    {
        self.removeAdButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.removeAdButton setBackgroundImage:[[UIImage imageNamed:@"RemoveAdImage"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 28, 0, 29)] forState:UIControlStateNormal];
        self.removeAdButton.titleEdgeInsets = UIEdgeInsetsMake(0, 23, 0, 0);
        [self.removeAdButton setTitle:[AdModel sharedInstance].removeText forState:UIControlStateNormal];
        [self.removeAdButton setTitleColor:[UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:0.9] forState:UIControlStateNormal];
        self.removeAdButton.titleLabel.font = [UIFont systemFontOfSize:10];
        self.removeAdButton.alpha = 0.90;
        
        CGSize size = [self.removeAdButton.titleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:self.removeAdButton.titleLabel.font forKey:NSFontAttributeName]];
        self.removeAdButton.frame = CGRectMake(0, 0, 27 + size.width + 2, 25);
        
        if (([AdModel sharedInstance].target != nil) && [AdModel sharedInstance].selector != nil)
            [self.removeAdButton addTarget:[AdModel sharedInstance].target action:[AdModel sharedInstance].selector forControlEvents:UIControlEventTouchUpInside];
        else
            [self.removeAdButton addTarget:self action:@selector(removeAds) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self layoutBanners:NO];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.visible = YES;
    
    //Ads
    if (!self.disableAds)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutNeeded) name:@"LayoutForBannersNeeded" object:nil];
        //I add the banners to the view, and force a layout

        #ifdef HASADS
        [AdModel sharedInstance].gadBannerView.rootViewController = self;
        if (![AdModel sharedInstance].gadLoaded)
            [[AdModel sharedInstance].gadBannerView loadRequest:[GADRequest request]];
        
        [self.view addSubview:[AdModel sharedInstance].iadBannerView];
        [self.view addSubview:[AdModel sharedInstance].gadBannerView];
        #endif
    }
    
    
    [self layoutBanners:NO];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.visible = NO;
    
    if (!self.disableAds)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LayoutForBannersNeeded" object:nil];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self layoutBanners:NO];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self layoutBanners:NO];
}

- (void) layoutNeeded
{
    [self layoutBanners:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */

- (CGFloat) layoutBanners:(BOOL) animated
{
    CGFloat result=0.0;
    
    //keyboard space
    CGFloat keyboardDistanceMinusBars = 0.0;
    if (self.moveUpWhenKeyboardShown)
        keyboardDistanceMinusBars = self.keyboardDistance - self.tabBarController.tabBar.frame.size.height - (self.navigationController.toolbarHidden ? 0 : self.navigationController.toolbar.frame.size.height);
    if (keyboardDistanceMinusBars < 0)
        keyboardDistanceMinusBars = 0;
    
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    
    
    //Scroll insets
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
#ifdef HASADS
    
    
    if (!self.disableAds)
    {
        CGFloat margin = 0.0;
        
        static BOOL goon;
        goon = NO;
        if ([AdModel sharedInstance].onlyAdMob)
        {
            if ([[AdModel sharedInstance].gadBannerView isDescendantOfView:self.view])
                goon = YES;
        }
        else
        {
            if ([[AdModel sharedInstance].gadBannerView isDescendantOfView:self.view] && [[AdModel sharedInstance].iadBannerView isDescendantOfView:self.view])
                goon = YES;
        }
        
        
        if (goon)
        {
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
            if ([AdModel sharedInstance].iAdFirst)
            {
                iAdCondition=[AdModel sharedInstance].iadBannerView.bannerLoaded;
                gadCondition=(![AdModel sharedInstance].iadBannerView.bannerLoaded) && [AdModel sharedInstance].gadLoaded;
            }
            else
            {
                gadCondition=[AdModel sharedInstance].gadLoaded;
                iAdCondition=(![AdModel sharedInstance].gadLoaded) && [AdModel sharedInstance].iadBannerView.bannerLoaded;
            }
            
            
            //GAD
            bannerHeightGad=[AdModel sharedInstance].gadBannerView.frame.size.height;
            if (gadCondition)
            {
                bannerOriginGad.y=self.view.bounds.size.height - bannerHeightGad - keyboardDistanceMinusBars;
                result = bannerHeightGad;
                bannerOriginGad.y -= self.tabBarController.tabBar.frame.size.height + (self.navigationController.toolbarHidden ? 0 : self.navigationController.toolbar.frame.size.height);
            }
            else
                bannerOriginGad.y = self.view.bounds.size.height;
            //iAD always uses the whole width of the screen, gad does not
            bannerOriginGad.x=(self.view.bounds.size.width - [AdModel sharedInstance].gadBannerView.bounds.size.width)/2;
            if (gadCondition)
                margin = bannerOriginGad.x;
            
            
            //iAD
            bannerHeightIAd = [AdModel sharedInstance].iadBannerView.bounds.size.height;
            if (iAdCondition)
            {
                bannerOriginIAd.y=self.view.bounds.size.height - bannerHeightIAd - keyboardDistanceMinusBars;
                result=bannerHeightIAd;
                bannerOriginIAd.y -= self.tabBarController.tabBar.frame.size.height + (self.navigationController.toolbarHidden ? 0 : self.navigationController.toolbar.frame.size.height);
            }
            else
                bannerOriginIAd.y = self.view.bounds.size.height;
            
            
            // And finally animate the changes, running layout for the content view if required.
            //It is strange, although the notification is removed in viewWillDisappear, it seems that
            //the method is called anyway, so I make sure the banners are in self.view before doing anything.
            
            //Animate banners
            [UIView animateWithDuration:animationDuration animations:^{
                
                
                [AdModel sharedInstance].gadBannerView.frame = CGRectMake(bannerOriginGad.x, bannerOriginGad.y, [AdModel sharedInstance].gadBannerView.frame.size.width, [AdModel sharedInstance].gadBannerView.frame.size.height);
                [AdModel sharedInstance].iadBannerView.frame = CGRectMake(bannerOriginIAd.x, bannerOriginIAd.y, [AdModel sharedInstance].iadBannerView.frame.size.width, [AdModel sharedInstance].iadBannerView.frame.size.height);
            }];
            
            //Debug
            /*
             NSLog(@"------------------ADController----------------");
             NSLog(@"Bounds width: %f, height: %f", self.view.bounds.size.width, self.view.bounds.size.height);
             NSLog(@"Frame width: %f, height: %f", self.view.frame.size.width, self.view.frame.size.height);
             NSLog(@"Frame x: %f, y: %f", self.view.frame.origin.x, self.view.frame.origin.y);
             NSLog(@"Dimension: %f, %f, %f, %f:", bannerOriginGad.x, bannerOriginGad.y, gadBannerView.frame.size.width, gadBannerView.frame.size.height);
             NSLog(@"------------------FIN ADController----------------");
             */
            
            
            
            //Así evito el vuelo del botón la primera vez que se muestra un banner
            CGFloat buttonAnimationDuration = animationDuration;
            if (self.removeAdButton.frame.origin.y < 1.0)
                buttonAnimationDuration = 0;
            [UIView animateWithDuration:buttonAnimationDuration animations:^{
                //Botón
                if (result> 0.0)
                {
                    CGFloat xButton;
                    if (! self.alignRemoveButtonToLeft)
                    {
                        if (bannerOriginGad.y < bannerOriginIAd.y)
                            xButton = bannerOriginGad.x + [AdModel sharedInstance].gadBannerView.frame.size.width - self.removeAdButton.frame.size.width;
                        else
                            xButton = bannerOriginIAd.x + [AdModel sharedInstance].iadBannerView.frame.size.width - self.removeAdButton.frame.size.width;
                    }
                    else
                    {
                        if (bannerOriginGad.y < bannerOriginIAd.y)
                            xButton = bannerOriginGad.x;
                        else
                            xButton = bannerOriginIAd.x;
                    }
                    
                    self.removeAdButton.frame = CGRectMake(xButton,
                                                           self.view.bounds.size.height - result - self.removeAdButton.frame.size.height -  self.tabBarController.tabBar.frame.size.height -
                                                           (self.navigationController.toolbarHidden ? 0 : self.navigationController.toolbar.frame.size.height) - keyboardDistanceMinusBars,
                                                           self.removeAdButton.frame.size.width,
                                                           self.removeAdButton.frame.size.height);
                    
                    if (self.hideRemoveButtonWhenKeyboardUp)
                    {
                        if (keyboardDistanceMinusBars > 0.1)
                            self.removeAdButton.alpha = 0.0;
                        else
                            self.removeAdButton.alpha = 1.0;
                    }
                    
                    if (![self.removeAdButton isDescendantOfView:self.view])
                    {
                        [self.view addSubview:self.removeAdButton];
                    }
                    
                }
                else
                {
                    [self.removeAdButton removeFromSuperview];
                    self.removeAdButton.frame = CGRectMake(0, 0, self.removeAdButton.frame.size.width, self.removeAdButton.frame.size.height);
                }
            }];
            
            
            
            
        }
        else
        {
            [self.removeAdButton removeFromSuperview];
            self.removeAdButton.frame = CGRectMake(0, 0, self.removeAdButton.frame.size.width, self.removeAdButton.frame.size.height);
        }
    }
    
#endif
    if ( ! self.layoutDisabled)
    {
        CGFloat statusBarY = 20.0;
        if ([self prefersStatusBarHidden])
            statusBarY = 0.0;
        
        BOOL navigationBarHidden = self.navigationController.navigationBarHidden;
        if (self.navigationController == nil)
            navigationBarHidden = YES;
        
        //Animate Views
        [UIView animateWithDuration:animationDuration animations:^{
            
            //ScrollView
            if (self.scrollViewToLayout != nil)
            {
                UIEdgeInsets insets =
                UIEdgeInsetsMake(self.extraTopInset + (navigationBarHidden ? statusBarY : (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height)),
                                 0,
                                 self.tabBarController.tabBar.frame.size.height + (self.navigationController.toolbarHidden ? 0 : self.navigationController.toolbar.frame.size.height) + result + keyboardDistanceMinusBars + self.extraBottomInset,
                                 0);
                
                CGFloat offsetY = self.scrollViewToLayout.contentOffset.y;
                CGFloat offset = 0.0;
                if ( fabs( self.scrollViewToLayout.contentInset.top - insets.top) > 0.001 )
                    offset =insets.top - self.scrollViewToLayout.contentInset.top;
                
                
                self.scrollViewToLayout.contentInset = insets;
                self.scrollViewToLayout.scrollIndicatorInsets = insets;
                self.scrollViewToLayout.contentOffset = CGPointMake(0.0, offsetY - offset);
                
                
                if (self.searchDisplayController.isActive)
                {
                    insets = self.searchDisplayController.searchResultsTableView.contentInset;
                    //insets.top += self.extraTopInset;
                    insets.bottom = self.tabBarController.tabBar.frame.size.height + (self.navigationController.toolbarHidden ? 0 : self.navigationController.toolbar.frame.size.height) + result + keyboardDistanceMinusBars + self.extraBottomInset;
                    self.searchDisplayController.searchResultsTableView.contentInset = insets;
                    self.searchDisplayController.searchResultsTableView.scrollIndicatorInsets = insets;
                }
            }
            
        }];
        
        //StandardView
        if (self.viewToLayout != nil)
        {
            CGRect frame = CGRectMake(0,
                                      self.extraTopInset + (navigationBarHidden ? statusBarY : (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height)),
                                      
                                      self.view.bounds.size.width,
                                      
                                      self.view.bounds.size.height -
                                      (navigationBarHidden ? statusBarY : (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height)) -
                                      self.tabBarController.tabBar.frame.size.height -
                                      (self.navigationController.toolbarHidden ? 0 : self.navigationController.toolbar.frame.size.height) -
                                      result -
                                      keyboardDistanceMinusBars - self.extraBottomInset - self.extraTopInset);
            self.viewToLayout.frame = frame;
        }
    }
    
    self.lastAdHeight = result;
    
    return result;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self layoutBanners:YES];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size
          withTransitionCoordinator:coordinator];
    
    //Dentro de este bloque las vistas ya tienen al tamaño al que transitan, así que no es necesario arrastrar size
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         //update views here, e.g. calculate your view
         [self layoutBanners:YES];
     }
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
     }];
}

#pragma mark - AdViewController methods

- (void) keyboardWillShow:(NSNotification *) notif
{
    NSDictionary *userInfo = [notif userInfo];
    
    CGRect kbRect = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    //CGRect kbRect2= [self.view.window convertRect:kbRect toView:self.view];
    CGRect kbRect2 = [self.view convertRect:kbRect fromView:nil];
    
    self.keyboardDistance = kbRect2.size.height;
    
    [self layoutBanners:YES];
}

- (void) keyboardWillHide:(NSNotification *) notif
{
    self.keyboardDistance = 0;
    
    if (self.visible)
        [self layoutBanners:YES];
}

- (void) bringBannersToFront
{
#ifdef HASADS
    [self.view bringSubviewToFront:[AdModel sharedInstance].iadBannerView];
    [self.view bringSubviewToFront:[AdModel sharedInstance].gadBannerView];
    [self.view bringSubviewToFront:self.removeAdButton];
#endif
}

- (void) removeAds
{
#ifdef HASADS
    [AdModel sharedInstance].presentFromController = self;
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[AdModel sharedInstance].title
                                                     message:[AdModel sharedInstance].message
                                                    delegate:[AdModel sharedInstance]
                                           cancelButtonTitle:[AdModel sharedInstance].noText
                                           otherButtonTitles:[AdModel sharedInstance].yesText, nil];
    [alert show];
#endif
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
