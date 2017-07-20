//
//  LoginUserViewController.m
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 7/13/13.
//
//

#import "LoginUserViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "GeneralHelper.h"
#import "LocalUserViewController.h"
#import "LTDataSource.h"
#import "LextTalkAppDelegate.h"

@interface LoginUserViewController ()

@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UILabel * label;
@property (nonatomic, strong) UIButton * alreadyUserButton;
@property (nonatomic, strong) UIButton * notUserButton;
@property (nonatomic, strong) UIPopoverController * myPopoverController;
@property (nonatomic, strong) UIView * blindView;

@end

@implementation LoginUserViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.imageView = nil;
    self.label = nil;
    self.alreadyUserButton = nil;
    self.notUserButton = nil;
}

- (void) loadView
{
    UIView * view=[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view=view;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.blindView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.blindView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.blindView];
    
    //imageView
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image-not-logged"]];
    [self.blindView addSubview:self.imageView];
    
    
    //label
    self.label = [[UILabel alloc] init];
    self.label.font = [UIFont fontWithName:@"Ubuntu-Bold" size:18];
    self.label.textColor =  [UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:1.0];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.text = NSLocalizedString(@"You are not logged in", nil);
    self.label.backgroundColor = [UIColor clearColor];
    [self.blindView addSubview:self.label];
    
    //alreadyUserButton
    self.alreadyUserButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.alreadyUserButton setBackgroundImage:[UIImage imageNamed:@"button-login"] forState:UIControlStateNormal];
    [self.alreadyUserButton setTitle:NSLocalizedString(@"Already have\nan account", nil) forState:UIControlStateNormal];
    [self.alreadyUserButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.alreadyUserButton.titleLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:14];
    self.alreadyUserButton.titleLabel.numberOfLines = 0;
    self.alreadyUserButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.alreadyUserButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    /*
    self.alreadyUserButton.layer.shadowColor=[[UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0] CGColor];
    self.alreadyUserButton.layer.shadowOpacity = 1.0;
    self.alreadyUserButton.layer.shadowRadius = 1;
    self.alreadyUserButton.layer.shadowOffset = CGSizeMake(0, 1);
    self.alreadyUserButton.clipsToBounds=YES;
    
    self.alreadyUserButton.layer.borderColor = [[UIColor colorWithRed:205.0/255.0 green:191.0/255.0 blue:69.0/255.0 alpha:1.0] CGColor];
    self.alreadyUserButton.layer.cornerRadius = 6.0;
    self.alreadyUserButton.layer.borderWidth = 1.0f;
    */
    [self.blindView addSubview:self.alreadyUserButton];
    
    //notUserButton
    self.notUserButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.notUserButton setBackgroundImage:[UIImage imageNamed:@"button-login"]  forState:UIControlStateNormal];
    [self.notUserButton setTitle:NSLocalizedString(@"I'd like to create\nan account", nil) forState:UIControlStateNormal];
    [self.notUserButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.notUserButton.titleLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:14];
    self.notUserButton.titleLabel.numberOfLines = 0;
    self.notUserButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.notUserButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    /*
    self.notUserButton.layer.shadowColor=[[UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0] CGColor];
    self.notUserButton.layer.shadowOpacity = 1.0;
    self.notUserButton.layer.shadowRadius = 2;
    self.notUserButton.layer.shadowOffset = CGSizeMake(0, -2);
    self.notUserButton.clipsToBounds=YES;
    
    self.notUserButton.layer.borderColor = [[UIColor colorWithRed:205.0/255.0 green:191.0/255.0 blue:69.0/255.0 alpha:1.0] CGColor];
    self.notUserButton.layer.cornerRadius = 6.0;
    self.notUserButton.layer.borderWidth = 1.0f;
    */
    [self.blindView addSubview:self.notUserButton];
    
    self.viewToLayout = self.blindView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title=NSLocalizedString(@"Profile", nil);
    
    if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 7)
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"bar-yellow-ios7"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] forBarMetrics:UIBarMetricsDefault];
    else
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"bar-yellow"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] forBarMetrics:UIBarMetricsDefault];
    
    [GeneralHelper setTitleTextAttributesForController:self];
    
    //ConfButton
    self.navigationItem.rightBarButtonItem = [GeneralHelper plainBarButtonItemWithText:nil image:[UIImage imageNamed:@"button-conf"] target:self selector:@selector(confButtonPressed)];
    
    
    //Push the user controller if already logged
    //if done in view will appear, the LocalUserViewController is pushed twice, becaue the sign in controller is presented modally
    if ([LTDataSource sharedDataSource].localUser!=nil)
    {
        LocalUserViewController * controller = [[LocalUserViewController alloc] init];
        [self.navigationController pushViewController:controller animated:NO];
    }
    

}

- (void) rotateToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation
{
    CGSize size = self.blindView.bounds.size;
    
    if (toInterfaceOrientation==UIInterfaceOrientationPortrait || toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
    {
        static CGFloat sepBetweenRows = 20.0;
        CGFloat upDownSep = (size.height - sepBetweenRows*2.0 - 283.0/2.0 - 20.0 - 87/2.0) / 2.0;
        
        self.imageView.frame = CGRectMake((size.width - 438.0/2.0)/2.0, upDownSep, 438.0/2.0, 283.0/2.0);
        self.label.frame = CGRectMake(0, upDownSep + 283.0/2.0 + sepBetweenRows, size.width, 20.0);
        self.alreadyUserButton.frame = CGRectMake((size.width - 272.0*2/2.0 - 20)/2.0, upDownSep + 283.0/2.0 + sepBetweenRows + 20.0 + sepBetweenRows, 272.0/2.0, 87.0/2.0);
        self.notUserButton.frame = CGRectMake((size.width - 272.0*2/2.0 - 20)/2.0 + 272.0/2.0 + 20, upDownSep + 283.0/2.0 + sepBetweenRows + 20.0 + sepBetweenRows, 272.0/2.0, 87.0/2.0);
    }
    else
    {
        static CGFloat sepBetweenRows = 2.0;
        CGFloat upDownSep = (size.height - sepBetweenRows - 283.0/2.0 - 20.0) / 2.0;
        
        self.imageView.frame = CGRectMake((size.width - 438.0/2.0)/2.0, upDownSep, 438.0/2.0, 283.0/2.0);
        self.label.frame = CGRectMake(0, upDownSep + 283.0/2.0 + sepBetweenRows, size.width, 20.0);
        self.alreadyUserButton.frame =  CGRectMake((size.width - 438.0/2.0 - 2*272.0/2.0 + 2*20)/2.0, upDownSep + 90, 272.0/2.0, 87.0/2.0);
        self.notUserButton.frame =      CGRectMake((size.width - 438.0/2.0 - 2*272.0/2.0 + 2*20)/2.0 - 2*20 + 272.0/2.0 + 438.0/2.0, upDownSep + 90, 272.0/2.0, 87.0/2.0);
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    [self rotateToInterfaceOrientation:self.interfaceOrientation];
    //It is called in willAnimateRotationToInterfaceOrientation
    //[self layoutBanners:YES];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
    
    [self rotateToInterfaceOrientation:interfaceOrientation];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size
          withTransitionCoordinator:coordinator];
    
    UIInterfaceOrientation interfaceOrientation = UIInterfaceOrientationPortrait;
    if (size.width > size.height)
        interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
    
    //Dentro de este bloque las vistas ya tienen al tamaño al que transitan, así que no es necesario arrastrar size
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         //update views here, e.g. calculate your view
         [self rotateToInterfaceOrientation:interfaceOrientation];
     }
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark LoginUserViewController methods

- (void) buttonPressed:(UIButton *) button
{
    ModalSignInViewController * controller=[[ModalSignInViewController alloc] init];
    controller.modalPresentationStyle=UIModalPresentationFormSheet;
    controller.delegate=self;
    
    
    if (button == self.alreadyUserButton)
    {
        controller.signIn = YES;
    }
    else if (button == self.notUserButton)
    {
        controller.signIn = NO;
    }
    
    [self presentViewController:controller  animated:YES completion:NULL];
}

- (void) confButtonPressed
{
    ConfigurationViewController * controller=[[ConfigurationViewController alloc] init];
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        [self.navigationController pushViewController:controller animated:YES];
    }
    else
    {
        controller.disableAds=YES;
        
        [self.myPopoverController dismissPopoverAnimated:NO];//In case the user presses the button twice
        self.myPopoverController=nil;
        self.myPopoverController=[[UIPopoverController alloc] initWithContentViewController:controller];
        self.myPopoverController.delegate=self;
        [self.myPopoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

#pragma mark -
#pragma mark ModalSignInViewController Delegate

- (void) didCancelSignIn
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) didSignIn
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    
    LocalUserViewController * controller = [[LocalUserViewController alloc] init];
    //do not set the user, it takes the localUser from the dataSource
    [self.navigationController pushViewController:controller animated:NO];
    
    
    LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
    [del updateChatList];
    [del.chatRoomListViewController reloadController:YES];
    [del closeSignInView];
}

#pragma mark -
#pragma mark UIPopoverController Delegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.myPopoverController=nil;//Lo libero así
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

#pragma mark -
#pragma mark Ad Reimplementation

- (CGFloat) layoutBanners:(BOOL) animated
{
    [super layoutBanners:animated];
    
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         [self rotateToInterfaceOrientation:self.interfaceOrientation];
                     }];
    return 0.0;
}

@end
