//
//  ModalSignInViewController.m
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 4/26/13.
//
//

#import "ModalSignInViewController.h"
#import "MBProgressHUD.h"
#import "LextTalkAppDelegate.h"

#define PortraitOffset 40.0
#define LandscapeOffset 40.0
#define PortraitOffset5 40.0
#define LandscapeOffset5 40.0

@interface ModalSignInViewController ()

@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIImageView * fieldsImageView;
@property (nonatomic, strong) UITextField * emailField;
@property (nonatomic, strong) UITextField * usernameField;
@property (nonatomic, strong) UITextField * passwordField;
@property (nonatomic, strong) UIButton * getStartedButton;
@property (nonatomic, strong) UIButton * facebookButton;
@property (nonatomic, strong) UIButton * accountButton;
@property (nonatomic, strong) UILabel * accountLabel1;
@property (nonatomic, strong) UILabel * accountLabel2;
@property (nonatomic, strong) UIButton * skipButton;
@property (nonatomic, assign) BOOL editingFields;
@property (nonatomic, assign) BOOL alreadySubscribed;
@property (nonatomic, strong) MBProgressHUD * HUD;

@property (nonatomic, strong) UIButton * rememberButton;
@property (nonatomic, weak) UIAlertView * rememberAlertView;
@property (nonatomic, strong) TutViewController *tut;
@property (nonatomic,strong) UIButton *removeTutBtn;



@end

@implementation ModalSignInViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.imageView=nil;
    self.logoImageView=nil;
    self.titleLabel=nil;
    self.fieldsImageView=nil;
    self.emailField=nil;
    self.usernameField=nil;
    self.passwordField=nil;
    self.getStartedButton=nil;
    self.facebookButton=nil;
    self.accountButton=nil;
    self.accountLabel1=nil;
    self.accountLabel2=nil;
    self.skipButton=nil;
    
    self.rememberButton = nil;
}

- (void) loadView
{
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    self.view=[[UIView alloc] initWithFrame:rect];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    //Background
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"EmpireNight-iphone4-Portrait.jpg"]];
    self.imageView.userInteractionEnabled=YES;
    [self.view addSubview:self.imageView];
    
    //logo
    self.logoImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LextTalkLogo"]];
    [self.imageView addSubview:self.logoImageView];
    
    //titleLabel
    self.titleLabel=[[UILabel alloc] init];
    self.titleLabel.font=[UIFont fontWithName:@"Ubuntu-Medium" size:11];
    self.titleLabel.backgroundColor=[UIColor clearColor];
    self.titleLabel.text=NSLocalizedString(@"Talk to the world", @"slogan");
    self.titleLabel.textAlignment=NSTextAlignmentCenter;
    self.titleLabel.textColor=[UIColor whiteColor];
    [self.imageView addSubview:self.titleLabel];
    
    //Fields on top of the image
    self.fieldsImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ImageSignUpFields"]];
    self.fieldsImageView.userInteractionEnabled=YES;
    [self.imageView addSubview:self.fieldsImageView];
    
    //E-mail, los campos tienen una anchura de 38, y van separados por 39 pixels
    self.emailField=[[UITextField alloc] initWithFrame:CGRectMake(10, 0 + 7, 240 - 20, 38 - 14)];
    self.emailField.borderStyle=UITextBorderStyleNone;
    self.emailField.font=[UIFont fontWithName:@"Ubuntu-Medium" size:15];
    self.emailField.placeholder=NSLocalizedString(@"E-Mail", @"email for sign up");
    self.emailField.delegate=self;
    self.emailField.keyboardType=UIKeyboardTypeEmailAddress;
    self.emailField.autocapitalizationType=UITextAutocapitalizationTypeNone;
    self.emailField.autocorrectionType=UITextAutocorrectionTypeNo;
    self.emailField.returnKeyType=UIReturnKeyNext;
    [self.fieldsImageView addSubview:self.emailField];
    
    //Username
    self.usernameField=[[UITextField alloc] initWithFrame:CGRectMake(10, 39 + 7, 240 - 20, 38 - 14)];
    self.usernameField.borderStyle=UITextBorderStyleNone;
    self.usernameField.font=[UIFont fontWithName:@"Ubuntu-Medium" size:15];
    self.usernameField.placeholder=NSLocalizedString(@"Username", @"username for sign up");
    self.usernameField.delegate=self;
    self.usernameField.keyboardType=UIKeyboardTypeDefault;
    self.usernameField.autocapitalizationType=UITextAutocapitalizationTypeNone;
    self.usernameField.autocorrectionType=UITextAutocorrectionTypeNo;
    self.usernameField.returnKeyType=UIReturnKeyNext;
    [self.fieldsImageView addSubview:self.usernameField];
    
    //Password
    self.passwordField=[[UITextField alloc] initWithFrame:CGRectMake(10, 78 + 7, 240 - 20, 38 - 14)];
    self.passwordField.borderStyle=UITextBorderStyleNone;
    self.passwordField.font=[UIFont fontWithName:@"Ubuntu-Medium" size:15];
    self.passwordField.placeholder=NSLocalizedString(@"Password", @"password for sign up");
    self.passwordField.delegate=self;
    self.passwordField.keyboardType=UIKeyboardTypeDefault;
    self.passwordField.autocapitalizationType=UITextAutocapitalizationTypeNone;
    self.passwordField.autocorrectionType=UITextAutocorrectionTypeNo;
    self.passwordField.secureTextEntry=YES;
    self.passwordField.returnKeyType=UIReturnKeyJoin;
    [self.fieldsImageView addSubview:self.passwordField];
    
    
    //get started button
    self.getStartedButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.getStartedButton setImage:[UIImage imageNamed:@"ButtonGetStarted"] forState:UIControlStateNormal];
    [self.getStartedButton addTarget:self action:@selector(getStartedButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 38)];
    label.font=[UIFont fontWithName:@"Ubuntu-Medium" size:15];
    label.backgroundColor=[UIColor clearColor];
    label.textColor=[UIColor whiteColor];
    label.textAlignment=NSTextAlignmentCenter;
    label.text=NSLocalizedString(@"Get Started", @"Sign up");
    [self.getStartedButton addSubview:label];
    [self.imageView addSubview:self.getStartedButton];
    
    //Remember
    self.rememberButton=[UIButton buttonWithType:UIButtonTypeCustom];
    //[self.rememberButton setImage:[UIImage imageNamed:@"EmpireNight-iphone4-Portrait.jpg"] forState:UIControlStateNormal];
    [self.rememberButton addTarget:self action:@selector(rememberButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    //self.rememberButton.frame = CGRectMake(0, 0, 15, 115.5 + 38.5 + 38.5);
    self.rememberButton.frame = CGRectMake(0, 0, 240, 30);
    //label=[[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 115.5 + 38.5 + 38.5, 15)] autorelease];
    label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 15)];
    label.font=[UIFont fontWithName:@"Ubuntu-Medium" size:13];
    label.backgroundColor=[UIColor clearColor];
    label.textColor=[UIColor whiteColor];
    label.textAlignment=NSTextAlignmentCenter;
    label.text=NSLocalizedString(@"Remember password", nil);
    //label.transform = CGAffineTransformMakeRotation(3*M_PI_2);
    [self.rememberButton addSubview:label];
    label.center = self.rememberButton.center;
    [self.imageView addSubview:self.rememberButton];
    
    //Facebook
    self.facebookButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.facebookButton setImage:[UIImage imageNamed:@"ButtonFacebook"] forState:UIControlStateNormal];
    [self.facebookButton addTarget:self action:@selector(facebookButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 38)];
    label.font=[UIFont fontWithName:@"Ubuntu-Medium" size:15];
    label.backgroundColor=[UIColor clearColor];
    label.textColor=[UIColor whiteColor];
    label.textAlignment=NSTextAlignmentCenter;
    label.text=NSLocalizedString(@"Get Started with Facebook", @"Sign up");
    [self.facebookButton addSubview:label];
    [self.imageView addSubview:self.facebookButton];
    
    //Account
    self.accountButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.accountButton setImage:[UIImage imageNamed:@"ButtonAccount"] forState:UIControlStateNormal];
    [self.accountButton addTarget:self action:@selector(accountButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    CGSize size=CGSizeMake(160, 60.5);
    UIFont * font1=[UIFont fontWithName:@"Ubuntu-Bold" size:14];
    UIFont * font2=[UIFont fontWithName:@"Ubuntu" size:14];
    NSString * text1 = NSLocalizedString(@"Have an account?", @"Sign up");
    NSString * text2 = NSLocalizedString(@"Sign in", @"Sign up");
    
    CGSize size1 = [text1 sizeWithAttributes:@{NSFontAttributeName: font1}];
    CGSize text1Size = CGSizeMake(ceilf(size1.width), ceilf(size1.height));
    CGSize size2 = [text2 sizeWithAttributes:@{NSFontAttributeName: font2}];
    CGSize text2Size = CGSizeMake(ceilf(size2.width), ceilf(size2.height));
    
    self.accountLabel1=[[UILabel alloc] initWithFrame:CGRectMake((size.width - text1Size.width)/2.0, (size.height - text1Size.height - text2Size.height - 0.0)/2.0, text1Size.width, text1Size.height)];
    self.accountLabel1.font=font1;
    self.accountLabel1.backgroundColor=[UIColor clearColor];
    self.accountLabel1.textColor=[UIColor colorWithRed:1.0 green:200.0/255.0 blue:27.0/255.0 alpha:1.0];
    self.accountLabel1.textAlignment=NSTextAlignmentCenter;
    self.accountLabel1.text=text1;
    [self.accountButton addSubview:self.accountLabel1];
    
    self.accountLabel2=[[UILabel alloc] initWithFrame:CGRectMake((size.width - text1Size.width)/2.0, (size.height - text1Size.height - text2Size.height - 0.0)/2.0 + text1Size.height + 0.0, text2Size.width, text2Size.height)];
    self.accountLabel2.font=font2;
    self.accountLabel2.backgroundColor=[UIColor clearColor];
    self.accountLabel2.textColor=[UIColor whiteColor];
    self.accountLabel2.textAlignment=NSTextAlignmentCenter;
    self.accountLabel2.text=text2;
    [self.accountButton addSubview:self.accountLabel2];
    
    [self.imageView addSubview:self.accountButton];
    
    
    //Skip Button
    self.skipButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.skipButton setImage:[UIImage imageNamed:@"ButtonAccount"] forState:UIControlStateNormal];
    [self.skipButton addTarget:self action:@selector(skipButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    text1 = NSLocalizedString(@"Skip", @"Sign up");
    text2 = NSLocalizedString(@"Connect Later", @"Sign up");
    
    size1 = [text1 sizeWithAttributes:@{NSFontAttributeName: font1}];
    text1Size = CGSizeMake(ceilf(size1.width), ceilf(size1.height));
    size2 = [text2 sizeWithAttributes:@{NSFontAttributeName: font2}];
    text2Size = CGSizeMake(ceilf(size2.width), ceilf(size2.height));
    
    label=[[UILabel alloc] initWithFrame:CGRectMake((size.width - text2Size.width)/2.0, (size.height - text1Size.height - text2Size.height - 0.0)/2.0, text1Size.width, text1Size.height)];
    label.font=font1;
    label.backgroundColor=[UIColor clearColor];
    label.textColor=[UIColor colorWithRed:26.0/255.0 green:167.0/255.0 blue:191.0/255.0 alpha:1.0];
    label.textAlignment=NSTextAlignmentCenter;
    label.text=text1;
    [self.skipButton addSubview:label];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake((size.width - text2Size.width)/2.0, (size.height - text1Size.height - text2Size.height - 0.0)/2.0 + text1Size.height + 0.0, text2Size.width, text2Size.height)];
    label.font=font2;
    label.backgroundColor=[UIColor clearColor];
    label.textColor=[UIColor whiteColor];
    label.textAlignment=NSTextAlignmentCenter;
    label.text=text2;
    [self.skipButton addSubview:label];
    
    [self.imageView addSubview:self.skipButton];
}

- (void) rotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation
{
    BOOL iphone5 = NO;
    if (self.view.bounds.size.height > self.view.bounds.size.width)
    {
        if (self.view.bounds.size.height > 481.0)
            iphone5 = YES;
    }
    else
    {
        if (self.view.bounds.size.width > 481.0)
            iphone5 = YES;
    }
    
    
    if ((interfaceOrientation==UIInterfaceOrientationPortrait) || (interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown))
    {
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        {
            if (iphone5) //iphone 5
            {
                //NSLog(@"iPhone 5");
                self.imageView.frame=CGRectMake(0, self.view.bounds.size.height - 568 + self.view.frame.origin.y, 320, 568); //Corregir cuando esté la pantalla para el iPhone 5 a 568 el 480
                self.logoImageView.frame=CGRectMake(118.5, 50, 83, 60);
                self.titleLabel.frame=CGRectMake(0, 120, 320, 15);
                self.imageView.image=[UIImage imageNamed:@"EmpireNight-iphone4-Portrait.jpg"];
                if (self.editingFields)
                    self.fieldsImageView.frame=CGRectMake(40, 35 + 177 - PortraitOffset5 - 30, 240, 115.5);
                else
                    self.fieldsImageView.frame=CGRectMake(40, 35 + 177 - 30, 240, 115.5);
                if (self.editingFields)
                    self.getStartedButton.frame=CGRectMake(40, 35 +  292.5 - PortraitOffset5 - 30, 240, 38);
                else
                    self.getStartedButton.frame=CGRectMake(40, 35 + 292.5 - 30, 240, 38);
                self.facebookButton.frame=CGRectMake(40, 35 + 350, 240, 38);
                self.accountButton.frame=CGRectMake(0, self.imageView.frame.size.height - 60.5, 160, 60.5);
                self.skipButton.frame=CGRectMake(160, self.imageView.frame.size.height - 60.5, 160, 60.5);
            }
            else
            {
                //NSLog(@"iPhone 4");
                self.imageView.frame=CGRectMake(0, self.view.bounds.size.height - 480 + self.view.frame.origin.y, 320, 480);
                self.logoImageView.frame=CGRectMake(118.5, 50, 83, 60);
                self.titleLabel.frame=CGRectMake(0, 120, 320, 15);
                self.imageView.image=[UIImage imageNamed:@"EmpireNight-iphone4-Portrait.jpg"];
                if (self.editingFields)
                    self.fieldsImageView.frame=CGRectMake(40, 177 - PortraitOffset - 30, 240, 115.5);
                else
                    self.fieldsImageView.frame=CGRectMake(40, 177 - 30, 240, 115.5);
                if (self.editingFields)
                    self.getStartedButton.frame=CGRectMake(40, 292.5 - PortraitOffset - 30, 240, 38);
                else
                    self.getStartedButton.frame=CGRectMake(40, 292.5 - 30, 240, 38);
                self.facebookButton.frame=CGRectMake(40, 350, 240, 38);
                self.accountButton.frame=CGRectMake(0, self.imageView.frame.size.height - 60.5, 160, 60.5);
                self.skipButton.frame=CGRectMake(160, self.imageView.frame.size.height - 60.5, 160, 60.5);
            }
        }
    }
    else //Landscape
    {
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        {
            if (iphone5) //iphone 5
            {
                //NSLog(@"iPhone 5");
                self.imageView.frame=CGRectMake(0, self.view.bounds.size.height - 320 + self.view.frame.origin.y, 568, 320); //Corregir cuando esté la pantalla para el iPhone 5 a 568 el 480
                self.imageView.image=[UIImage imageNamed:@"EmpireNight-iphone4-Landscape.jpg"];
                self.logoImageView.frame=CGRectMake(391.5, 50, 83, 60);
                self.titleLabel.frame=CGRectMake(296, 120, 272, 15);
                if (self.editingFields)
                    self.fieldsImageView.frame=CGRectMake(56, 56 - LandscapeOffset - 20, 240, 115.5);
                else
                    self.fieldsImageView.frame=CGRectMake(56, 56 - 20, 240, 115.5);
                if (self.editingFields)
                    self.getStartedButton.frame=CGRectMake(56, 171.5 - LandscapeOffset - 20, 240, 38);
                else
                    self.getStartedButton.frame=CGRectMake(56, 171.5 -20, 240, 38);
                self.facebookButton.frame=CGRectMake(56, 245.5, 240, 38);
                self.accountButton.frame=CGRectMake(352, 160, 160, 60.5);
                self.skipButton.frame=CGRectMake(352, 220.5, 160, 60.5);
            }
            else
            {
                //NSLog(@"iPhone 4");
                self.imageView.frame=CGRectMake(0, self.view.bounds.size.height - 320 + self.view.frame.origin.y, 480, 320);
                self.imageView.image=[UIImage imageNamed:@"EmpireNight-iphone4-Landscape.jpg"];
                self.logoImageView.frame=CGRectMake(331.5, 50, 83, 60);
                self.titleLabel.frame=CGRectMake(266, 120, 214, 15);
                if (self.editingFields)
                    self.fieldsImageView.frame=CGRectMake(26, 56 - LandscapeOffset - 20, 240, 115.5);
                else
                    self.fieldsImageView.frame=CGRectMake(26, 56 - 20, 240, 115.5);
                if (self.editingFields)
                    self.getStartedButton.frame=CGRectMake(26, 171.5 - LandscapeOffset - 20, 240, 38);
                else
                    self.getStartedButton.frame=CGRectMake(26, 171.5 - 20, 240, 38);
                self.facebookButton.frame=CGRectMake(26, 245.5, 240, 38);
                self.accountButton.frame=CGRectMake(292, 160, 160, 60.5);
                self.skipButton.frame=CGRectMake(292, 220.5, 160, 60.5);
            }
        }
    }
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        self.imageView.frame=CGRectMake(0, 0, 540, 620);
        self.imageView.image=[UIImage imageNamed:@"EmpireNight-ipad.jpg"];
        
        self.logoImageView.frame=CGRectMake((540.0 - 83.0)/2.0, 50, 83, 60);
        self.titleLabel.frame=CGRectMake(0, 120, 540, 15);
        self.fieldsImageView.frame=CGRectMake((540 - 240)/2.0, 35 + 177, 240, 115.5);
        self.getStartedButton.frame=CGRectMake((540 - 240)/2.0, 35 + 292.5, 240, 38);
        self.facebookButton.frame=CGRectMake((540 - 240)/2.0, 35 + 350 + 30, 240, 38);
        self.accountButton.frame=CGRectMake(0, self.imageView.frame.size.height - 60.5, 160, 60.5);
        self.skipButton.frame=CGRectMake(540 - 160, self.imageView.frame.size.height - 60.5, 160, 60.5);
    }
    
    //RememberButton
    /*
    CGRect frame = self.fieldsImageView.frame;
    frame.size.height += 38.5 + 38.5;
    frame.size.width = 15;
    frame.origin.x -= 25;
    frame.origin.y = frame.origin.y;
     */
    CGRect frame = self.rememberButton.frame;
    frame.origin.x = self.fieldsImageView.frame.origin.x;
    frame.origin.y = self.fieldsImageView.frame.origin.y + self.fieldsImageView.frame.size.height + self.getStartedButton.frame.size.height + 0.0;
    self.rememberButton.frame = frame;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self rotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //NSLog(@"w: %f, h: %f", self.view.bounds.size.width, self.view.bounds.size.height);
    
    [self rotateToInterfaceOrientation:self.interfaceOrientation];
    
    if (!self.alreadySubscribed)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        self.alreadySubscribed=YES;
    }
    
    //To force redraw if signIn has been changed from outside
    [self layoutFieldsAndLabel:NO];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    self.alreadySubscribed=NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITextField delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.emailField isFirstResponder] && [touch view] != self.emailField) {
        [self.emailField resignFirstResponder];
    }
    if ([self.usernameField isFirstResponder] && [touch view] != self.usernameField) {
        [self.usernameField resignFirstResponder];
    }
    if ([self.passwordField isFirstResponder] && [touch view] != self.passwordField) {
        [self.passwordField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (self.emailField==textField)
    {
        //[self.emailField resignFirstResponder];
        [self.usernameField becomeFirstResponder];
    }
    else if (self.usernameField==textField)
    {
        //[self.usernameField resignFirstResponder];
        [self.passwordField becomeFirstResponder];
    }
    else if (self.passwordField==textField)
    {
        //[self.passwordField resignFirstResponder];
        //Sign in
        [self getStartedButtonPressed:self.getStartedButton];
    }
    else //textField from UIAlertView (remember password)
    {
        [self.rememberAlertView dismissWithClickedButtonIndex:1 animated:YES];
        [self alertView:self.rememberAlertView clickedButtonAtIndex:1];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //[self adjustFieldsWithEditing:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //if ((![self.emailField isFirstResponder]) && (![self.usernameField isFirstResponder]) && (![self.passwordField isFirstResponder]))
    //    [self adjustFieldsWithEditing:NO];
}

#pragma mark -
#pragma mark ModalSignInViewController methods

- (void) adjustFieldsWithEditing:(BOOL) editingFields2
{
    if (self.editingFields!=editingFields2)
    {
        self.editingFields=editingFields2;
        
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        {
            CGRect frame=[UIScreen mainScreen].applicationFrame;
            
            CGFloat offset=0;
            if (self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
            {
                if (frame.size.height>481.0)
                    offset=PortraitOffset5;
                else
                    offset=PortraitOffset;
            }
            else
            {
                if (frame.size.height>481.0)
                    offset=LandscapeOffset5;
                else
                    offset=LandscapeOffset;
            }
            
            if (self.editingFields)
            {
                [UIView animateWithDuration:0.2 animations:^{
                    CGRect fieldsImageViewFrame=self.fieldsImageView.frame;
                    CGRect getStartedButtonFrame=self.getStartedButton.frame;
                    CGRect rememberButtonFrame = self.rememberButton.frame;
                    fieldsImageViewFrame.origin.y -= offset;
                    getStartedButtonFrame.origin.y -= offset;
                    rememberButtonFrame.origin.y -= offset;
                    self.fieldsImageView.frame=fieldsImageViewFrame;
                    self.getStartedButton.frame=getStartedButtonFrame;
                    self.rememberButton.frame = rememberButtonFrame;
                }];
            }
            else
            {
                [UIView animateWithDuration:0.2 animations:^{
                    CGRect fieldsImageViewFrame=self.fieldsImageView.frame;
                    CGRect getStartedButtonFrame=self.getStartedButton.frame;
                    CGRect rememberButtonFrame = self.rememberButton.frame;
                    fieldsImageViewFrame.origin.y += offset;
                    getStartedButtonFrame.origin.y += offset;
                    rememberButtonFrame.origin.y += offset;
                    self.fieldsImageView.frame=fieldsImageViewFrame;
                    self.getStartedButton.frame=getStartedButtonFrame;
                    self.rememberButton.frame = rememberButtonFrame;
                }];
            }
        }
    }
}

- (void) keyboardWillShow:(NSNotification *)nsNotification
{
    //NSLog(@"teclado dentro");
    if (self.rememberAlertView == nil)
        [self adjustFieldsWithEditing:YES];
}

- (void) keyboardWillHide:(NSNotification *)nsNotification
{
    //NSLog(@"teclado fuera");
    if (self.rememberAlertView == nil);
        [self adjustFieldsWithEditing:NO];
}

- (void) getStartedButtonPressed:(UIButton *) button
{
    if (self.signIn)
    {
        if ([self.usernameField.text length]>0 && [self.passwordField.text length]>0)
        {
            self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:self.HUD];
            self.HUD.mode = MBProgressHUDModeIndeterminate;
            self.HUD.labelText = NSLocalizedString(@"Logging...", nil);
            [self.HUD show:YES];
            
            [[LTDataSource sharedDataSource] loginUser:self.usernameField.text withPassword:self.passwordField.text delegate:self];
        }
        else
        {
            UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                           message:NSLocalizedString(@"You have to fill in both the username and password", nil)
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
            [alert show];
        }
    }
    else
    {
        if ([self.usernameField.text length]>0 && [self.passwordField.text length]>0 && [self.emailField.text length]>0)
        {
            self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:self.HUD];
            self.HUD.mode = MBProgressHUDModeIndeterminate;
            self.HUD.labelText = NSLocalizedString(@"Creating...", nil);
            [self.HUD show:YES];

            [[LTDataSource sharedDataSource] createUser:self.usernameField.text withPassword:self.passwordField.text withEmail:self.emailField.text delegate:self];
        }
        else
        {
            UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                           message:NSLocalizedString(@"You have to fill the e-mail, username and password", nil)
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
            [alert show];
        }
    }
}

- (void) facebookButtonPressed:(UIButton *) button
{
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.labelText = NSLocalizedString(@"Logging with Facebook...", nil);
    [self.HUD show:YES];
    
    [[LTDataSource sharedDataSource] handleFacebookLogout];
    [[LTDataSource sharedDataSource] openSessionWithAllowLoginUI:YES withDelegate:self withFacebokAction:LTFacebookActionLogin];
}

- (void) layoutFieldsAndLabel:(BOOL) animated
{
    NSTimeInterval timeInterval = animated ? 0.3 : 0.0;
    
    [UIView animateWithDuration:timeInterval animations:^{
        
        self.fieldsImageView.alpha=0.0;
        self.accountLabel1.alpha=0.0;
        self.accountLabel2.alpha=0.0;
        
        if (!self.signIn)
            self.rememberButton.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        NSString * text1, * text2;
        if (self.signIn)
        {
            self.fieldsImageView.image=[UIImage imageNamed:@"ImageSignInFields"];
            self.emailField.hidden=YES;
            text1 = NSLocalizedString(@"Get Started?", @"Sign in");
            text2 = NSLocalizedString(@"Sign up", @"Sign in");
        }
        else
        {
            self.emailField.hidden=NO;
            self.fieldsImageView.image=[UIImage imageNamed:@"ImageSignUpFields"];
            text1 = NSLocalizedString(@"Have an account?", @"Sign up");
            text2 = NSLocalizedString(@"Sign in", @"Sign up");
        }
        
        CGSize size=CGSizeMake(160, 60.5);
        UIFont * font1=[UIFont fontWithName:@"Ubuntu-Bold" size:14];
        UIFont * font2=[UIFont fontWithName:@"Ubuntu" size:14];
        CGSize size1 = [text1 sizeWithAttributes:@{NSFontAttributeName: font1}];
        CGSize text1Size = CGSizeMake(ceilf(size1.width), ceilf(size1.height));
        CGSize size2 = [text2 sizeWithAttributes:@{NSFontAttributeName: font2}];
        CGSize text2Size = CGSizeMake(ceilf(size2.width), ceilf(size2.height));
        
        self.accountLabel1.text=text1;
        self.accountLabel1.frame=CGRectMake((size.width - text1Size.width)/2.0, (size.height - text1Size.height - text2Size.height - 0.0)/2.0, text1Size.width, text1Size.height);
        self.accountLabel2.text=text2;
        self.accountLabel2.frame=CGRectMake((size.width - text1Size.width)/2.0, (size.height - text1Size.height - text2Size.height - 0.0)/2.0 + text1Size.height + 0.0, text2Size.width, text2Size.height);
        
        [UIView animateWithDuration:timeInterval animations:^{
            self.fieldsImageView.alpha=1.0;
            self.accountLabel1.alpha=1.0;
            self.accountLabel2.alpha=1.0;
            
            if (self.signIn)
                self.rememberButton.alpha = 1.0;
        }];
        
    }];
}

- (void) accountButtonPressed:(UIButton *) button
{
    self.signIn=!self.signIn;
    
    [self layoutFieldsAndLabel:YES];
}

- (void) skipButtonPressed:(UIButton *) button
{
    if ([self.delegate respondsToSelector:@selector(didCancelSignIn)])
        [self.delegate didCancelSignIn];
}

- (void) rememberButtonPressed:(UIButton *) button
{
    //NSLog(@"remember");
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Fill in your e-mail", nil)
                                                      message:NSLocalizedString(@"Fill in the e-mail you used to sign up. An e-mail with a new password will be sent to that e-mail", nil)
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                            otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].delegate = self;
    [alert textFieldAtIndex:0].returnKeyType = UIReturnKeyDone;
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeEmailAddress;
    alert.tag = 1;
    self.rememberAlertView = alert;
    [alert show];
}

- (void) rememberPasswordForEmail:(NSString *) email
{
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    [self.HUD show:YES];
    
    [[LTDataSource sharedDataSource] rememberPasswordForEmail:email withDelegate:self];
}

#pragma mark -
#pragma mark LTDataDelegate methods

- (void) didLoginUser
{
    [self.HUD hide:YES];
    self.HUD = nil;
    
    if ([self.delegate respondsToSelector:@selector(didSignIn)])
        [self.delegate didSignIn];
}

- (void) didCreateUser
{
    [self.HUD hide:YES];
    self.HUD = nil;
    
    if ([self.delegate respondsToSelector:@selector(didSignIn)])
        [self.delegate didSignIn];
}

- (void) didRememberPassword
{
    [self.HUD hide:YES];
    self.HUD = nil;
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password reset", nil)
                                                      message:NSLocalizedString(@"An e-mail with a new password has been sent to you. You should receive it in a few moments", nil)
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                            otherButtonTitles: nil];
    [alert show];
}

- (void) didFail:(NSDictionary *)result
{
    [self.HUD hide:YES];
    self.HUD = nil;
    
    // handle error
	if(result == nil) return;
	
    //	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"LextTalk server error", @"LextTalk server error")
    //													message: [result objectForKey: @"message"]
    //												   delegate: self
    //										  cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
    //										  otherButtonTitles: nil];
    
    LextTalkAppDelegate * del = (LextTalkAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!del.showingError)
    {
        del.showingError=YES;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: [result objectForKey: @"error_title"]
                                                        message: [result objectForKey: @"error_message"]
                                                       delegate: self
                                              cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
                                              otherButtonTitles: nil];
        alert.tag = 404;
        [alert show];
    }
}

#pragma mark -
#pragma mark UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((buttonIndex==0) && (alertView.tag==404))
    {
        LextTalkAppDelegate * del = (LextTalkAppDelegate *) [[UIApplication sharedApplication] delegate];
        del.showingError = NO;
    }
    
    if (alertView.tag == 1) //Remember password
    {
        if (buttonIndex == 1)
        {
            [self rememberPasswordForEmail:[[alertView textFieldAtIndex:0] text]];
        }
        
        self.rememberAlertView = nil;
    }
}


@end
