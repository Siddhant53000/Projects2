//
//  TranslatorViewController2.m
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 6/20/13.
//
//

#import "TranslatorViewController2.h"

#import "LanguageSelectorViewController.h"
#import "LanguageReference.h"
#import "LTDataSource.h"
#import "LextTalkAppDelegate.h"
#import "DictionaryHandler.h"
#import "DictionaryViewController.h"
#import "UIColor+ColorFromImage.h"
#import "Flurry.h"
#import "GeneralHelper.h"
#import "SCLAlertView.h"

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#define timeForAddedToDic 0.8

@interface TranslatorViewController2 ()

@property (nonatomic, strong) UIView * blindView;

@property (nonatomic, strong) UIView * navShadowView;

@property (nonatomic, strong) UIButton * fromButton;
@property (nonatomic, strong) UIButton * toButton;
@property (nonatomic, strong) UIView * toButtonView;

@property (nonatomic, strong) UITableView * fromTableView;
@property (nonatomic, strong) UITableView * toTableView;

@property (nonatomic, strong) LanguageSelectorController * fromController;
@property (nonatomic, strong) LanguageSelectorController * toController;

@property (nonatomic, strong) TranslatorItemView * fromTranslatorItemView;
@property (nonatomic, strong) TranslatorItemView * toTranslatorItemView;
@property (nonatomic, strong) UIView * fromShadowView;
@property (nonatomic, strong) UIView * toShadowView;

@property (nonatomic, strong) UIView * containterView;
@property (nonatomic, strong) UIButton * swapButton;
@property (nonatomic, strong) UIButton * translateButton;
@property (nonatomic, strong) UIButton * dicButton;

@property (nonatomic, strong) AVAudioPlayer * player;

@property (nonatomic, strong) MBProgressHUD * HUD;


@property (nonatomic, assign) CGRect fromTableCollapsedFrame;
@property (nonatomic, assign) CGRect fromTableExpandedFrame;
@property (nonatomic, assign) CGRect toTableCollapsedFrame;
@property (nonatomic, assign) CGRect toTableExpandedFrame;

@property (nonatomic, strong) NSDictionary * textFromChatDic;

@end

@implementation TranslatorViewController2

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.bingTranslator=[[BingTranslator alloc] init];
        [self.bingTranslator downloadToken];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFromChat:) name:@"GoToTranslator" object:nil];
        
        //Inicializaciones para usar el AVAudioPlayer
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:NULL];
        [[AVAudioSession sharedInstance] setActive: YES error: NULL];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    }
    return self;
}

//The init does not seem to be called from the xib
- (void) awakeFromNib
{
    //Notificacion
    self.bingTranslator=[[BingTranslator alloc] init];
    [self.bingTranslator downloadToken];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFromChat:) name:@"GoToTranslator" object:nil];
    
    
    //Inicializaciones para usar el AVAudioPlayer
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:NULL];
    [[AVAudioSession sharedInstance] setActive: YES error: NULL];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.blindView = nil;
    
    self.navShadowView = nil;
    
    self.fromButton = nil;
    self.toButton = nil;
    self.toButtonView = nil;
    
    self.fromTableView = nil;
    self.toTableView = nil;
    
    self.fromTranslatorItemView = nil;
    self.toTranslatorItemView = nil;
    self.fromShadowView = nil;
    self.toShadowView = nil;
    
    self.containterView = nil;
    self.swapButton = nil;
    self.translateButton = nil;
    self.dicButton = nil;
}

- (void) loadView
{
    UIView * view=[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view=view;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    
    self.blindView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.blindView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.blindView];
    
    self.fromButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fromButton.titleLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:20];
    [self.fromButton setBackgroundImage:[UIImage imageNamed:@"button-green"] forState:UIControlStateNormal];
    [self.fromButton setImage:[UIImage imageNamed:@"arrow-down"] forState:UIControlStateNormal];
    //In case the notification to load a text with the chat languagues in the translator has been sent before the view has loaded
    if (self.fromLang == nil)
        [self.fromButton setTitle:NSLocalizedString(@"Select language", nil) forState:UIControlStateNormal];
    else
        [self.fromButton setTitle:[LanguageReference getLanForAppLan:[LanguageReference appLan] andMasterLan:self.fromLang] forState:UIControlStateNormal];
    [self.fromButton addTarget:self action:@selector(fromButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = self.fromButton;
    
    self.navShadowView = [[UIView alloc] init];
    self.navShadowView.layer.shadowColor=[[UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0] CGColor];
    self.navShadowView.layer.shadowOpacity = 1.0;
    self.navShadowView.layer.shadowRadius = 2;
    self.navShadowView.layer.shadowOffset = CGSizeMake(2, 2);
    self.navShadowView.backgroundColor = [UIColor whiteColor];
    [self.blindView addSubview:self.navShadowView];
    //self.navShadowView.clipsToBounds=NO;
    
    //From tableView and Controller
    self.fromTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.fromTableView.layer.cornerRadius = 8.0;
    self.fromTableView.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
    self.fromTableView.layer.borderWidth = 1.0;
    self.fromTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    [self.blindView addSubview:self.fromTableView];
    
    NSArray * array=nil;
    if (self.fromLang)
        array=[NSArray arrayWithObject:self.fromLang];
    self.fromController=[[LanguageSelectorController alloc]
                          initWithSingleSelectionTableView:self.fromTableView
                          textArray:[LanguageReference availableLangsForAppLan:@"English"]
                          selectedItems:array
                          preferredFlagForLan:[[LTDataSource sharedDataSource].localUser preferredFlagForLangs]
                          showFlags:YES
                          textTag:@"From"
                          delegate:self];
    
    //fromTranslatorItemView
    self.fromShadowView = [[UIView alloc] init];
    self.fromShadowView.layer.shadowColor=[[UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0] CGColor];
    self.fromShadowView.layer.shadowOpacity = 1.0;
    self.fromShadowView.layer.shadowRadius = 2;
    self.fromShadowView.layer.shadowOffset = CGSizeMake(4, 4);
    self.fromShadowView.clipsToBounds=NO;
    [self.blindView addSubview:self.fromShadowView];
    
    self.fromTranslatorItemView = [[TranslatorItemView alloc] init];
    self.fromTranslatorItemView.delegate = self;
    self.fromTranslatorItemView.layer.cornerRadius=8.0;
    self.fromTranslatorItemView.layer.masksToBounds=YES;
    self.fromTranslatorItemView.showsDic = YES;
    self.fromTranslatorItemView.buttonVisible = NO;
    self.fromTranslatorItemView.textView.delegate = self;
    self.fromTranslatorItemView.textView.text=self.textToTranslate; //In case the view has not loaded yet.
    [self.fromShadowView addSubview:self.fromTranslatorItemView];

    //toView & toButton
    self.toButtonView = [[UIView alloc] init];
    self.toButtonView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"button-green"]];
    [self.blindView addSubview:self.toButtonView];
    
    self.toButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.toButton.titleLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:20];
    [self.toButton setBackgroundImage:[UIImage imageNamed:@"button-green"] forState:UIControlStateNormal];
    [self.toButton setImage:[UIImage imageNamed:@"arrow-down"] forState:UIControlStateNormal];
    //In case the notification to load a text with the chat languagues in the translator has been sent before the view has loaded
    if (self.toLang == nil)
        [self.toButton setTitle:NSLocalizedString(@"Select language", nil) forState:UIControlStateNormal];
    else
        [self.toButton setTitle:[LanguageReference getLanForAppLan:[LanguageReference appLan] andMasterLan:self.toLang] forState:UIControlStateNormal];
    [self.toButton addTarget:self action:@selector(toButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.toButtonView addSubview:self.toButton];
    
    
    self.toButton.layer.shadowColor=[[UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0] CGColor];
    self.toButton.layer.shadowOpacity = 1.0;
    self.toButton.layer.shadowRadius = 2;
    self.toButton.layer.shadowOffset = CGSizeMake(2, 2);
    //self.toButton.clipsToBounds=NO;
     

    
    //To tableView and Controller
    self.toTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.toTableView.layer.cornerRadius = 8.0;
    self.toTableView.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
    self.toTableView.layer.borderWidth = 1.0;
    self.toTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    [self.blindView addSubview:self.toTableView];
    
    if (self.toLang)
        array=[NSArray arrayWithObject:self.toLang];
    self.toController=[[LanguageSelectorController alloc]
                        initWithSingleSelectionTableView:self.toTableView
                        textArray:[LanguageReference availableLangsForAppLan:@"English"]
                        selectedItems:array
                        preferredFlagForLan:[[LTDataSource sharedDataSource].localUser preferredFlagForLangs]
                        showFlags:YES
                        textTag:@"To"
                        delegate:self];
    
    
    //toranslatorItemView
    self.toShadowView = [[UIView alloc] init];
    self.toShadowView.layer.shadowColor=[[UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0] CGColor];
    self.toShadowView.layer.shadowOpacity = 1.0;
    self.toShadowView.layer.shadowRadius = 2;
    self.toShadowView.layer.shadowOffset = CGSizeMake(2, 2);
    self.toShadowView.clipsToBounds=NO;
    [self.blindView addSubview:self.toShadowView];
    
    self.toTranslatorItemView = [[TranslatorItemView alloc] init];
    self.toTranslatorItemView.delegate = self;
    self.toTranslatorItemView.layer.cornerRadius=8.0;
    self.toTranslatorItemView.layer.masksToBounds=YES;
    self.toTranslatorItemView.showsDic = NO;
    self.toTranslatorItemView.buttonVisible = YES;
    self.toTranslatorItemView.textView.editable=NO;
    [self.toShadowView addSubview:self.toTranslatorItemView];
    
    //ContainerView
    self.containterView = [[UIView alloc] init];
    [self.blindView addSubview: self.containterView];
    
    self.swapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.swapButton setBackgroundImage:[UIImage imageNamed:@"button-green"] forState:UIControlStateNormal];
    [self.swapButton setImage:[UIImage imageNamed:@"translator-swap"] forState:UIControlStateNormal];
    [self.swapButton addTarget:self action:@selector(swapButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.containterView addSubview:self.swapButton];
    
    self.translateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.translateButton setBackgroundImage:[UIImage imageNamed:@"button-green"] forState:UIControlStateNormal];
    self.translateButton.titleLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:20];
    [self.translateButton setTitle:NSLocalizedString(@"Translate", nil) forState:UIControlStateNormal];
    [self.translateButton addTarget:self action:@selector(translateButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.containterView addSubview:self.translateButton];
    
    self.translateButton.layer.shadowColor=[[UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0] CGColor];
    self.translateButton.layer.shadowOpacity = 1.0;
    self.translateButton.layer.shadowRadius = 10.0;
    self.translateButton.layer.shadowOffset = CGSizeMake(2, -2);
    //self.translateButton.clipsToBounds=NO;
    
    self.dicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dicButton setBackgroundImage:[UIImage imageNamed:@"button-green"] forState:UIControlStateNormal];
    [self.dicButton setImage:[UIImage imageNamed:@"translator-dic"] forState:UIControlStateNormal];
    [self.dicButton addTarget:self action:@selector(dicButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.containterView addSubview:self.dicButton];
    
    [self centerTextAndImageInButtons];
    [self.blindView bringSubviewToFront:self.fromTableView];
    [self.blindView bringSubviewToFront:self.toTableView];
    
    self.viewToLayout = self.blindView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    //self.navigationController.navigationBar.tintColor=[UIColor colorWithRed:0.0/255.0 green:183.0/255.0 blue:135.0/255.0 alpha:1.0];
    //self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:183.0/255.0 blue:135.0/255.0 alpha:1.0];
    
    if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 7)
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"bar-green-ios7"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] forBarMetrics:UIBarMetricsDefault];
    else
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"bar-green"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] forBarMetrics:UIBarMetricsDefault];
    
    
    self.title = NSLocalizedString(@"Translator", nil);
    
    [GeneralHelper setTitleTextAttributesForController:self];
    
    self.tut = [[TutViewController alloc] init];
    [self.view addSubview:self.tut.view];
    
    self.removeTutBtn = [[UIButton alloc] init];
    self.removeTutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.removeTutBtn addTarget:self
                          action:@selector(dismissTut)
                forControlEvents:UIControlEventTouchUpInside];
    [self.removeTutBtn setTitle:@"Got it!" forState:UIControlStateNormal];
    self.removeTutBtn.frame = CGRectMake(80.0, self.view.frame.size.height-(200.0), 160.0, 40.0);
    [self.tut changeTutImage:[UIImage imageNamed:@"translator"]];
    [self.view addSubview:self.removeTutBtn];
}

-(void)dismissTut{
    NSLog(@"Dismissed");
    [self.tut.view removeFromSuperview];
    [self.removeTutBtn removeFromSuperview];
}

- (void) rotateToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation
{
    CGSize size = self.blindView.bounds.size;
    //NSLog(@"Width: %f, Height: %f", size.width, size.height);
    
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
    
    CGFloat cellNumber=0;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        if ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown))
        {
            if (iphone5) //iphone 5
                cellNumber = 9;
            else
                cellNumber = 7;
        }
        else
            cellNumber = 5;
        
        //offset to separate items in iPhone 5
        
    }
    else
    {
        if ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown))
            cellNumber = 17;
        else
            cellNumber = 11;
    }
    
    //Could be optimized more, iPhone layout in portrait and iPad layout is almost the same
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        
        if ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown))
        {
            CGFloat translatorItemHeight = (size.height - 10 - 10 - 44 - 10 - 10 - 44 )/2.0;
            
            self.fromTableCollapsedFrame = CGRectMake((size.width - 240)/2.0, 0, 240, 0);
            self.fromTableExpandedFrame =  CGRectMake((size.width - 240)/2.0, 0, 240, 44.0 * cellNumber);
            self.toTableCollapsedFrame =   CGRectMake((size.width - 240)/2.0, 10 + translatorItemHeight + 10 + 44, 240, 0);
            self.toTableExpandedFrame =    CGRectMake((size.width - 240)/2.0, 22.0 + 10 + translatorItemHeight + 10 + 44/2.0 - 44 * cellNumber/2.0, 240, 44.0 * cellNumber);
            
            //fromButton
            self.navShadowView.frame = CGRectMake(0, -44, size.width, 44);
            
            self.navigationItem.titleView=self.fromButton;
            self.fromButton.frame = CGRectMake(0, 0, size.width, 44);
            if (self.fromTableView.frame.size.height>1.0)
                self.fromTableView.frame = self.fromTableExpandedFrame;
            else
                self.fromTableView.frame = self.fromTableCollapsedFrame;
            self.fromShadowView.frame = CGRectMake(15, 10, size.width - 15 - 15, translatorItemHeight);
            self.fromTranslatorItemView.frame = CGRectMake(0, 0, size.width -15 -15 , translatorItemHeight);
            
            //toButton
            [self.blindView addSubview:self.toButtonView];
            [self.toButtonView addSubview:self.toButton];
            self.toButtonView.frame = CGRectMake(0, 10 + translatorItemHeight + 10, size.width, 44);
            self.toButton.frame = CGRectMake(0, 0, size.width, 44);
            if (self.toTableView.frame.size.height>1.0)
                self.toTableView.frame = self.toTableExpandedFrame;
            else
                self.toTableView.frame = self.toTableCollapsedFrame;
            self.toShadowView.frame = CGRectMake(15, 10 + translatorItemHeight + 10 + 44 + 10, size.width - 15 - 15, translatorItemHeight);
            self.toTranslatorItemView.frame = CGRectMake(0, 0, size.width - 15 - 15, translatorItemHeight);
            
            //ContainerView
            self.containterView.frame = CGRectMake(0, 10 + translatorItemHeight + 10 + 44 + 10 + translatorItemHeight + 10, size.width, 44);
            self.swapButton.frame = CGRectMake(0, 0, 56, 44);
            self.translateButton.frame = CGRectMake(58, 0, size.width - 58 - 58, 44);
            self.dicButton.frame = CGRectMake(size.width - 56, 0, 56, 44);
            
        }
        else //Landscape
        {
            CGFloat translatorItemHeight = (size.height - 10 - 10 - 10 - 32 )/2.0;
            
            self.fromTableCollapsedFrame = CGRectMake(0, 0, size.width/2.0, 0);
            self.fromTableExpandedFrame = CGRectMake(0, 0, size.width/2.0, 44.0 * cellNumber);
            self.toTableCollapsedFrame = CGRectMake(size.width/2.0, 0, size.width/2.0, 0);
            self.toTableExpandedFrame = CGRectMake(size.width/2.0, 0, size.width/2.0, 44.0 * cellNumber);
            
            //Buttons
            self.navShadowView.frame = CGRectMake(0, -32, size.width, 32);
            
            self.toButtonView.frame = CGRectMake(0, 80, size.width, 32);
            [self.toButtonView addSubview:self.fromButton];
            self.fromButton.frame = CGRectMake(0, 0, size.width/2.0, 32);
            [self.toButtonView addSubview:self.toButton];
            self.toButton.frame = CGRectMake(size.width/2.0, 0, size.width/2.0, 32);
            self.navigationItem.titleView=self.toButtonView;
            
            //fromButton
            if (self.fromTableView.frame.size.height>1.0)
                self.fromTableView.frame = self.fromTableExpandedFrame;
            else
                self.fromTableView.frame = self.fromTableCollapsedFrame;
            self.fromShadowView.frame = CGRectMake(15, 10, size.width - 15 - 15, translatorItemHeight);
            self.fromTranslatorItemView.frame = CGRectMake(0, 0, size.width - 15 - 15, translatorItemHeight);
            
            //toButton
            if (self.toTableView.frame.size.height>1.0)
                self.toTableView.frame = self.toTableExpandedFrame;
            else
                self.toTableView.frame = self.toTableCollapsedFrame;
            self.toShadowView.frame = CGRectMake(15, 10 + translatorItemHeight + 10, size.width - 15 - 15, translatorItemHeight);
            self.toTranslatorItemView.frame = CGRectMake(0, 0, size.width - 15 - 15, translatorItemHeight);
            
            //ContainerView
            self.containterView.frame = CGRectMake(0, 10 + translatorItemHeight + 10 + translatorItemHeight + 10, size.width, 32);
            self.swapButton.frame = CGRectMake(0, 0, 56, 32);
            self.translateButton.frame = CGRectMake(58, 0, size.width - 58 - 58, 32);
            self.dicButton.frame = CGRectMake(size.width - 56, 0, 56, 32);
        }
    }
    else //iPad
    {
        CGFloat translatorItemHeight = (size.height - 20 - 20 - 44 - 20 - 20 - 44)/2.0;
        
        self.fromTableCollapsedFrame = CGRectMake((size.width - 300)/2.0, 0, 300, 0);
        self.fromTableExpandedFrame =  CGRectMake((size.width - 300)/2.0, 0, 300, 44.0 * cellNumber);
        self.toTableCollapsedFrame =   CGRectMake((size.width - 300)/2.0, 20 + translatorItemHeight + 20 + 44, 300, 0);
        self.toTableExpandedFrame =    CGRectMake((size.width - 300)/2.0, 20 + translatorItemHeight + 20 + 44/2.0 - 44 * cellNumber/2.0, 300, 44.0 * cellNumber);
        
        //fromButton
        self.navShadowView.frame = CGRectMake(0, -44, size.width, 44);
        
        self.navigationItem.titleView=self.fromButton;
        self.fromButton.frame = CGRectMake(0, 0, size.width, 44);
        if (self.fromTableView.frame.size.height>1.0)
            self.fromTableView.frame = self.fromTableExpandedFrame;
        else
            self.fromTableView.frame = self.fromTableCollapsedFrame;
        self.fromShadowView.frame = CGRectMake(30, 20, size.width - 30 - 30, translatorItemHeight);
        self.fromTranslatorItemView.frame = CGRectMake(0, 0, size.width -30 -30, translatorItemHeight);
        
        //toButton
        [self.blindView addSubview:self.toButtonView];
        [self.toButtonView addSubview:self.toButton];
        self.toButtonView.frame = CGRectMake(0, 20 + translatorItemHeight + 20, size.width, 44);
        self.toButton.frame = CGRectMake(0, 0, size.width, 44);
        if (self.toTableView.frame.size.height>1.0)
            self.toTableView.frame = self.toTableExpandedFrame;
        else
            self.toTableView.frame = self.toTableCollapsedFrame;
        self.toShadowView.frame = CGRectMake(30, 20 + translatorItemHeight + 20 + 44 + 20, size.width - 30 - 30, translatorItemHeight);
        self.toTranslatorItemView.frame = CGRectMake(0, 0, size.width - 30 - 30, translatorItemHeight);
        
        //ContainerView
        self.containterView.frame = CGRectMake(0, 20 + translatorItemHeight + 20 + 44 + 20 + translatorItemHeight + 20, size.width, 44);
        self.swapButton.frame = CGRectMake(0, 0, 56, 44);
        self.translateButton.frame = CGRectMake(58, 0, size.width - 58 - 58, 44);
        self.dicButton.frame = CGRectMake(size.width - 56, 0, 56, 44);
    }
    
    [self.blindView bringSubviewToFront:self.fromTableView];
    [self.blindView bringSubviewToFront:self.toTableView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    [self rotateToInterfaceOrientation:self.interfaceOrientation];
    
    //In case I have logged in, or changed the user while in other views
    self.fromController.preferredFlagForLan = [[LTDataSource sharedDataSource].localUser preferredFlagForLangs];
    self.toController.preferredFlagForLan = [[LTDataSource sharedDataSource].localUser preferredFlagForLangs];
    
    if (self.textFromChatDic != nil)
    {
        [self processTextFromChat:self.textFromChatDic];
        self.textFromChatDic = nil;
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //I don't undrestand why it has to be multiplied by 2.
    //Centering of text and 
    
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self rotateToInterfaceOrientation:toInterfaceOrientation];
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
#pragma mark TranslatorViewController methods
- (void) centerTextAndImageInButtons
{
    
    CGSize adjustedSize = [self.fromButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.fromButton.titleLabel.font}];
    CGSize size = CGSizeMake(ceilf(adjustedSize.width), ceilf(adjustedSize.height));
    [self.fromButton setTitleEdgeInsets:UIEdgeInsetsMake(0, ( -15 -5)*2, 0, 0)];
    [self.fromButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, (- size.width -5)*2)];
    
    adjustedSize = [self.toButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.toButton.titleLabel.font}];
    size = CGSizeMake(ceilf(adjustedSize.width), ceilf(adjustedSize.height));
    [self.toButton setTitleEdgeInsets:UIEdgeInsetsMake(0, ( -15 -5)*2, 0, 0)];
    [self.toButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, (- size.width -5)*2)];
}

- (void) fromButtonPressed
{
    [self.fromTranslatorItemView.textView resignFirstResponder];
    [self.view bringSubviewToFront:self.fromTableView];
    
    if (self.fromTableView.frame.size.height<1.0)
        [self expandFromTableView:YES withAnimationDuration:0.3];
    else
        [self expandFromTableView:NO withAnimationDuration:0.3];
}

- (void) toButtonPressed
{
    [self.fromTranslatorItemView.textView resignFirstResponder];
    
    [self.view bringSubviewToFront:self.toTableView];
    
    if (self.toTableView.frame.size.height<1.0)
        [self expandToTableView:YES withAnimationDuration:0.3];
    else
        [self expandToTableView:NO withAnimationDuration:0.3];
}

- (void) expandFromTableView:(BOOL) expand withAnimationDuration:(NSTimeInterval) duration
{
    
    if (expand)
    {
        [self.fromButton setImage:[UIImage imageNamed:@"arrow-up"] forState:UIControlStateNormal];
        [UIView animateWithDuration:duration animations:^{
            self.fromTableView.frame = self.fromTableExpandedFrame;
        } completion:^(BOOL finished) {
            [self.fromTableView flashScrollIndicators];
        }];
        
        [self expandToTableView:NO withAnimationDuration:duration];
    }
    else
    {
        [self.fromButton setImage:[UIImage imageNamed:@"arrow-down"] forState:UIControlStateNormal];
        [UIView animateWithDuration:duration animations:^{
            self.fromTableView.frame = self.fromTableCollapsedFrame;
        }];
        
    }
    [self centerTextAndImageInButtons];
}

- (void) expandToTableView:(BOOL) expand withAnimationDuration:(NSTimeInterval) duration
{
    
    if (expand)
    {
        [self.toButton setImage:[UIImage imageNamed:@"arrow-up"] forState:UIControlStateNormal];
        [UIView animateWithDuration:duration animations:^{
            self.toTableView.frame = self.toTableExpandedFrame;
        } completion:^(BOOL finished) {
            [self.toTableView flashScrollIndicators];
        }];
        
        [self expandFromTableView:NO withAnimationDuration:duration];
    }
    else
    {
        [self.toButton setImage:[UIImage imageNamed:@"arrow-down"] forState:UIControlStateNormal];
        [UIView animateWithDuration:duration animations:^{
            self.toTableView.frame = self.toTableCollapsedFrame;
        }];
        
    }
    [self centerTextAndImageInButtons];
}

- (void) swapButtonPressed
{
    NSString * aux=self.fromLang;
    self.fromLang=self.toLang;
    self.toLang=aux;
    
    [self selectedItem:self.fromLang withTextTag:@"From"];
    
    [self selectedItem:self.toLang withTextTag:@"To"];
    
    //I must remove the dic button, it is not longer in sync
    self.fromTranslatorItemView.buttonVisible = NO;

    //and also remove the translation, since it cannot be in sync
    self.toTranslatorItemView.textView.text=nil;
}

- (void) translateButtonPressed
{
    NSLog(@"entered translate \n \n \n \n \n \n \n \n \n \n \n");
    //[self.bingTranslator getLanguagesForSpeak];
    [self.fromTranslatorItemView.textView resignFirstResponder];
    
    if (self.fromLang && self.toLang)
    {
        if ([self.fromTranslatorItemView.textView.text length]>0)
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
            self.HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.view];
            [self.tabBarController.view addSubview:self.HUD];
            self.HUD.mode = MBProgressHUDModeIndeterminate;
            self.HUD.labelText=NSLocalizedString(@"Translating...", @"Translating...");
            [self.HUD show:YES];
            
            [self.bingTranslator translateText:self.fromTranslatorItemView.textView.text
                                    fromLocale:[LanguageReference getLocaleForMasterLan:[LanguageReference getMasterLanForAppLan:@"English" andLanName:self.fromLang]]
                                            to:[LanguageReference getLocaleForMasterLan:[LanguageReference getMasterLanForAppLan:@"English" andLanName:self.toLang]]
                                  withDelegate:self];

            NSDictionary * dic =
            [NSDictionary dictionaryWithObjectsAndKeys:
             [LanguageReference getLocaleForMasterLan:[LanguageReference getMasterLanForAppLan:@"English" andLanName:self.fromLang]], @"fromLocale",
             [LanguageReference getLocaleForMasterLan:[LanguageReference getMasterLanForAppLan:@"English" andLanName:self.toLang]], @"toLocale",
             [NSNumber numberWithInteger:[self.fromTranslatorItemView.textView.text length]], @"charNumber", nil];
            [Flurry logEvent:@"TRANSLATE_IN_TRANSLATOR_ACTION" withParameters:dic];
            
            
            // Added in: winstojl - support/feedback alertview
            /*SCLAlertView *alert = [[SCLAlertView alloc] init];
            
            //Using Block
            [alert addButton:@"Second Button" actionBlock:^(void) {
                NSLog(@"Second button tapped");
            }];
            
            [alert showSuccess:self title:@"Button View" subTitle:@"This alert view has buttons" closeButtonTitle:@"Done" duration:0.0f];*/
            
            /*UIColor *greenColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bar-green"]];
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            
            SCLSwitchView *switchView = [alert addSwitchViewWithLabel:@"Don't show again".uppercaseString];
            switchView.tintColor = greenColor;
            
            
            
            UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 215.0f, 80.0f)];
            customView.backgroundColor = greenColor;
            
            UIButton *thumbsUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            thumbsUpBtn.backgroundColor = [UIColor whiteColor];
            //[button setImage:[UIImage imageNamed:@"TimoonPumba.png"] forState:UIControlStateNormal];
            [thumbsUpBtn addTarget:self action:@selector(thumbsUpPressed:) forControlEvents:UIControlEventTouchUpInside];
            //width and height should be same value
            thumbsUpBtn.frame = CGRectMake(0, 0, customView.frame.size.height, customView.frame.size.height);
            //Clip/Clear the other pieces whichever outside the rounded corner
            thumbsUpBtn.clipsToBounds = YES;
            //half of the width
            thumbsUpBtn.layer.cornerRadius = customView.frame.size.height/2.0f;
            //button.layer.borderColor=[UIColor redColor].CGColor;
            //thumbsUpBtn.layer.borderWidth=2.0f;
            [customView addSubview:thumbsUpBtn];
            
            UIButton *thumbsDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            thumbsDownBtn.backgroundColor = [UIColor whiteColor];
            //[button setImage:[UIImage imageNamed:@"TimoonPumba.png"] forState:UIControlStateNormal];
            [thumbsDownBtn addTarget:self action:@selector(thumbsUpPressed:) forControlEvents:UIControlEventTouchUpInside];
            //width and height should be same value
            thumbsDownBtn.frame = CGRectMake(thumbsUpBtn.frame.size.width+20.0, 0, customView.frame.size.height, customView.frame.size.height);
            //Clip/Clear the other pieces whichever outside the rounded corner
            thumbsDownBtn.clipsToBounds = YES;
            //half of the width
            thumbsDownBtn.layer.cornerRadius = customView.frame.size.height/2.0f;
            [customView addSubview:thumbsDownBtn];
            
            
            [alert addCustomView:customView];
            [alert addButton:@"Done" actionBlock:^(void) {
                NSLog(@"Show again? %@", switchView.isSelected ? @"-No": @"-Yes");
            }];
            
            [alert showCustom:self image:[UIImage imageNamed:@"switch"] color:greenColor title:@"kInfoTitle" subTitle:@"some subtitle" closeButtonTitle:nil duration:0.0f];*/
            
        }
        else
        {
            UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Write something to translate!", @"Write something to translate!")
                                                           message:NSLocalizedString(@"Please, fill in the box with the text you wish to translate", @"Please, fill in the box with the text you wish to translate")
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                 otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Select the languages!", @"Select the languages!")
                                                       message:NSLocalizedString(@"Please, select both the laguage you are translating from, and the one you are translating to.", @"Please, select both the laguage you are translating from, and the one you are translating to.")
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                             otherButtonTitles:nil];
        [alert show];
    }
}

//new f(x) - winstojl
- (void) thumbsUpPressed:(UIButton*)sender{
    sender.backgroundColor = [UIColor redColor];
}

- (void) dicButtonPressed
{
    //Flurry
    [Flurry logEvent:@"DIC_OPEN_DICS_ACTION"];
    
    DictionaryViewController * controller=[[DictionaryViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) textFromChat:(NSNotification *) not
{
    NSDictionary * dic=[not userInfo];
    [self processTextFromChat:dic];
}

- (void) processTextFromChat:(NSDictionary *) dic
{
    if (self.view != nil)
    {
        NSString * str=[dic objectForKey:@"textToTranslate"];
        self.fromTranslatorItemView.textView.text=str;
        self.textToTranslate=str;//In case the view has not loaded yet
        if (self.fromLang==nil)
        {
            [self selectedItem:[dic objectForKey:@"fromLang"] withTextTag:@"From"];
        }
        if (self.toLang==nil)
        {
            [self selectedItem:[dic objectForKey:@"toLang"] withTextTag:@"To"];
        }
        
        
        //I must remove the dic button, it is not longer in sync
        self.fromTranslatorItemView.buttonVisible = NO;
        
        //Remove the translated text?: no at the moment
        //Make this controller selected
        LextTalkAppDelegate * del=[LextTalkAppDelegate sharedDelegate];
        [del.tabBarController selectTab:4];
    }
    else
        self.textFromChatDic = dic;
}

#pragma mark -
#pragma mark TranslatorItemViewDelegate methods

- (void) speakButtonPressedIn:(TranslatorItemView *)trans withId:(NSInteger)index
{
    BOOL begin=YES;
    NSString * alertTitle=nil;
    NSString * alertMessage=nil;
    if (trans==self.fromTranslatorItemView)
    {
        if ([self.fromTranslatorItemView.textView.text length]==0)
        {
            begin=NO;
            alertTitle=NSLocalizedString(@"Write something to be read!", @"Write something to be read!");
            alertMessage=NSLocalizedString(@"Please, fill in the box with the text you wish to be read", @"Please, fill in the box with the text you wish to be read");
        }
    }
    if (trans==self.toTranslatorItemView)
    {
        if ([self.toTranslatorItemView.textView.text length]==0)
        {
            begin=NO;
            alertTitle=NSLocalizedString(@"Translate something to be read!", @"Translate something to be read!");
            alertMessage=NSLocalizedString(@"Please, translate something before you try to read it", @"Please, translate something before you try to read it");
        }
    }
    
    if (begin)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
        self.HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.view];
        [self.tabBarController.view addSubview:self.HUD];
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        self.HUD.labelText=NSLocalizedString(@"Getting audio file...", @"Getting audio file...");
        [self.HUD show:YES];
        
        //NO need to check fromLang and toLang. If the seg control is shown, they are set.
        NSString * locale;
        NSString * text;
        if (trans==self.fromTranslatorItemView)
        {
            text=self.fromTranslatorItemView.textView.text;
            locale=[LanguageReference getSpeakLocaleForMasterLan:self.fromLang withId:index];
        }
        else if (trans==self.toTranslatorItemView)
        {
            locale=[LanguageReference getSpeakLocaleForMasterLan:self.toLang withId:index];
            text=self.toTranslatorItemView.textView.text;
        }
        
        [self.bingTranslator speakText: text
                            inLanguage: locale
                          withDelegate: self];
    }
    else
    {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle: alertTitle
                                                       message: alertMessage
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                             otherButtonTitles:nil];
        [alert show];
    }
}

- (void) dicOrChatButtonPressedIn:(TranslatorItemView *)trans
{
    if (trans==self.fromTranslatorItemView)
    {
        //Security Measure, although has the button is hidden, it shouldn't be necessary
        if (self.fromLang && self.toLang && ([self.fromTranslatorItemView.textView.text length]>0) && ([self.toTranslatorItemView.textView.text length]>0))
        {
            //Get the master lans
            NSString * fromMasterLan=[LanguageReference getMasterLanForAppLan:@"English" andLanName:self.fromLang];
            NSString * toMasterLan=[LanguageReference getMasterLanForAppLan:@"English" andLanName:self.toLang];
            
            [DictionaryHandler addEntry:self.fromTranslatorItemView.textView.text
                        withTranslation:self.toTranslatorItemView.textView.text
                                fromLan:fromMasterLan
                                  toLan:toMasterLan];
            
            //Flurry
            NSDictionary * dic =
            [NSDictionary dictionaryWithObjectsAndKeys:
             fromMasterLan, @"fromLang",
             toMasterLan, @"toLang", nil];
            [Flurry logEvent:@"DIC_ADD_TO_ACTION" withParameters:dic];
            
            self.HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.view];
            [self.tabBarController.view addSubview:self.HUD];
            self.HUD.customView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckWhite"]];
            self.HUD.mode = MBProgressHUDModeCustomView;
            self.HUD.delegate = self;
            self.HUD.labelText=NSLocalizedString(@"Added!", @"Added!");
            [self.HUD show:YES];
            [self.HUD hide:YES afterDelay:timeForAddedToDic];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DictionaryWasModified" object:self];
        }
    }
    else if (trans==self.toTranslatorItemView)
    {
        LextTalkAppDelegate * del=[LextTalkAppDelegate sharedDelegate];
        if ([self.toTranslatorItemView.textView.text length]!=0)
        {
            if ([del numberOfChatControllers]==0)
            {
                UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No active chat!", @"No active chat!")
                                                               message:NSLocalizedString(@"You do are not chatting with anyone, so the text could not be moved to the chat window", @"You do are not chatting with anyone, so the text could not be moved to the chat window")
                                                              delegate:nil
                                                     cancelButtonTitle: NSLocalizedString(@"OK", @"OK")
                                                     otherButtonTitles: nil];
                [alert show];
            }
            else
            {
                //Launch Notification
                NSString *str= self.toTranslatorItemView.textView.text;
                NSDictionary * dic=[NSDictionary dictionaryWithObject:str forKey:@"textToChat"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GoToChat" object:self userInfo:dic];
            }
        }
        else
        {
            UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No text!", @"No text!")
                                                           message:NSLocalizedString(@"When you have translated something, by tapping this button, you can copy that text to the chat windows.", @"When you have translated something, by tapping this button, you can copy that text to the chat windows.")
                                                          delegate:nil
                                                 cancelButtonTitle: NSLocalizedString(@"OK", @"OK")
                                                 otherButtonTitles: nil];
            [alert show];
        }
    }
}

#pragma mark -
#pragma mark BingTranslatorProtocol methods

- (void) translatedText:(NSString *) text
{
    self.toTranslatorItemView.textView.text=text;
    [self.HUD hide:YES];
    self.HUD = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    
    if (text!=nil)
    {
        //Now that it has been translated, I show the dictionary control
        self.fromTranslatorItemView.buttonVisible = YES;
        
        LextTalkAppDelegate * del=[LextTalkAppDelegate sharedDelegate];
        [del countBingUses];
    }
    else
    {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Translation Error!", @"Translation Error!")
                                                       message: NSLocalizedString(@"The text could not be translated. Try again in a few minutes. The translation servide might be down", @"The text could not be translated. Try again in a few minutes. The translation servide might be down")
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                             otherButtonTitles:nil];
        [alert show];
    }
}

- (void) spokenText:(NSData *) wav
{
    if (wav!=nil)
    {
        self.player = [[AVAudioPlayer alloc] initWithData:wav error:NULL];
        [self.player play];
        
        LextTalkAppDelegate * del=[LextTalkAppDelegate sharedDelegate];
        [del countBingUses];
    }
    else
    {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Error!", @"Network Error!")
                                                       message: NSLocalizedString(@"The text could not be read. Try again in a few minutes. The translation servide might be down", @"The text could not be read. Try again in a few minutes. The translation servide might be down")
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                             otherButtonTitles:nil];
        [alert show];
    }
    
    [self.HUD hide:YES];
    self.HUD = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
}

- (void) connectionFailedWithError:(NSError *) error
{
    [self.HUD hide:YES];
    self.HUD = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    
    NSString * str=[NSString stringWithString:NSLocalizedString(@"The operation could not be performed: ", @"The operation could not be performed: ")];
    NSString * message=[str stringByAppendingString: [error localizedDescription]];
    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Error", @"Network Error")
                                                   message: message
                                                  delegate:nil
                                         cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                         otherButtonTitles:nil];
    [alert show];
}

#pragma mark -
#pragma mark UITextViewDelegate methods

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.fromTranslatorItemView.textView resignFirstResponder];
    
    //Launch Translation
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]){
        //[textView resignFirstResponder];
        [self translateButtonPressed];
        return NO;
    }
    else
    {
        //If the text changes, I remove the dictionary button. Additions to the dic are only possible if the traslation matches the input text
        self.fromTranslatorItemView.buttonVisible = NO;
        
        return YES;
    }
}

#pragma mark - UIViewController reimplementation

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([touch view] != self.fromTableView) {
        if (self.fromTableView.frame.size.height>1.0)
            [self expandFromTableView:NO withAnimationDuration:0.3];
    }
    if ([touch view] != self.toTableView) {
        if (self.toTableView.frame.size.height>1.0)
            [self expandToTableView:NO withAnimationDuration:0.3];
    }
    if ([self.fromTranslatorItemView.textView isFirstResponder] && [touch view] != self.fromTranslatorItemView.textView) {
        [self.fromTranslatorItemView.textView resignFirstResponder];
    }
    if ([self.toTranslatorItemView.textView isFirstResponder] && [touch view] != self.toTranslatorItemView.textView) {
        [self.toTranslatorItemView.textView resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - LanguageSelectorViewControllerDelegate

- (void) selectedItem:(NSString *)selected withTextTag:(NSString *)textTag
{
    if ([textTag isEqualToString:@"From"])
    {
        if (![self.fromLang isEqualToString:selected])
        {
            self.fromTranslatorItemView.buttonVisible = NO;
            self.toTranslatorItemView.textView.text = nil;
        }
        self.fromLang=selected;
        if (self.fromLang!=nil)
            [self.fromButton setTitle:[LanguageReference getLanForAppLan:[LanguageReference appLan] andMasterLan:self.fromLang] forState:UIControlStateNormal];
        else
            [self.fromButton setTitle:NSLocalizedString(@"Select language", nil) forState:UIControlStateNormal];
        [self centerTextAndImageInButtons];
        [self expandFromTableView:NO withAnimationDuration:0.3];
        
        self.fromTranslatorItemView.speakArray = [LanguageReference availableSpeakLangsForAppLan:[LanguageReference appLan] andMasterLan:self.fromLang];
    }
    else if ([textTag isEqualToString:@"To"])
    {
        if (![self.toLang isEqualToString:selected])
        {
            self.fromTranslatorItemView.buttonVisible = NO;
            self.toTranslatorItemView.textView.text = nil;
        }
        self.toLang=selected;
        if (self.toLang != nil)
            [self.toButton setTitle:[LanguageReference getLanForAppLan:[LanguageReference appLan] andMasterLan:self.toLang] forState:UIControlStateNormal];
        else
            [self.toButton setTitle:NSLocalizedString(@"Select language", nil) forState:UIControlStateNormal];
        [self centerTextAndImageInButtons];
        [self expandToTableView:NO withAnimationDuration:0.3];
        
        self.toTranslatorItemView.speakArray = [LanguageReference availableSpeakLangsForAppLan:[LanguageReference appLan] andMasterLan:self.toLang];
    }
}

#pragma mark -
#pragma mark MBProgressHUD Delegate
- (void) hudWasHidden:(MBProgressHUD *)hud
{
    [self.HUD removeFromSuperview];
    self.HUD = nil;
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
