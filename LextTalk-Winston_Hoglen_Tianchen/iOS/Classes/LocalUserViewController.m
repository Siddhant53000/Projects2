//
//  LocalUserViewController.m
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 4/28/13.
//
//

#import "LocalUserViewController.h"
#import "LTDataSource.h"
#import "MBProgressHUD.h"
#import "IconGeneration.h"
#import <QuartzCore/QuartzCore.h>
#import "BallView.h"
#import "LanguageReference.h"
#import "LextTalkAppDelegate.h"
#import "UIColor+ColorFromImage.h"
#import "GeneralHelper.h"
#import "ConfigurationViewController.h"
#import "IQImagePicker.h"
#import "UIImage+Resize.h"
#import "ImageViewerViewController.h"

@interface LocalUserViewController ()

@property (nonatomic, strong) UIScrollView * scrollView;

@property (nonatomic, strong) UIImageView * backgroundImageView;
@property (nonatomic, strong) UIImageView * learningImageView;
@property (nonatomic, strong) UIImageView * speakingImageView;
@property (nonatomic, strong) UIButton * userImageButton;
@property (nonatomic, strong) UIImageView * activityImageView;
@property (nonatomic, strong) UIView * userImageShadow;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * activityLabel;
@property (nonatomic, strong) UIActivityIndicatorView * indicatorView;

@property (nonatomic, strong) UILabel * userLabel;
@property (nonatomic, strong) UIView * userTextViewShadow;
@property (nonatomic, strong) UITextField * userTextView;
@property (nonatomic, strong) UILabel * statusLabel;

@property (nonatomic, strong) UIView * statusTextViewShadow;
@property (nonatomic, strong) UITextView * statusTextView;
@property (nonatomic, strong) UILabel * speakingLabel1;
@property (nonatomic, strong) UILabel * speakingLabel2;
@property (nonatomic, strong) UILabel * learningLabel1;
@property (nonatomic, strong) UILabel * learningLabel2;
@property (nonatomic, strong) BallView * ballView;

//LextTalkCatalan
@property (nonatomic, strong) UILabel * firstLabel;
@property (nonatomic, strong) UILabel * secondLabel;
@property (nonatomic, strong) UISegmentedControl * learnOrSpeakSeg;
@property (nonatomic, strong) LangView * brandedLangView;



@property (nonatomic, strong) LangView * learningLangView;
@property (nonatomic, strong) LangView * speakingLangView;

@property (nonatomic, strong) UILabel * locationLabel;
@property (nonatomic, strong) UILabel * locationExplanationLabel;
@property (nonatomic, strong) UISwitch * locationSwitch;
@property (nonatomic, strong) MKMapView * mapView;


@property (nonatomic, strong) UIView * buttonView;
@property (nonatomic, strong) UIButton * editButton;
@property (nonatomic, strong) UIButton * deleteButton;
@property (nonatomic, strong) UIButton * saveButton;

//Views for remote user
@property (nonatomic, strong) UIButton * messageButton;
@property (nonatomic, strong) UIButton * locateButton;
@property (nonatomic, strong) UIButton * blockButton;

@property (nonatomic, strong) MBProgressHUD * HUD;
@property (nonatomic, strong) UIPopoverController * myPopoverController;


@property (nonatomic, assign) BOOL editingUser;
@property (nonatomic, strong) NSString * learningLang;
@property (nonatomic, strong) NSString * speakingLang;
@property (nonatomic, assign) NSInteger learningFlag;
@property (nonatomic, assign) NSInteger speakingFlag;

@property (nonatomic, assign) NSInteger backgroundImageIndex;

@property (nonatomic, strong) TutViewController *tut;
@property (nonatomic,strong) UIButton *removeTutBtn;


@end

@implementation LocalUserViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.backgroundImageIndex = ((NSInteger)[[NSDate date] timeIntervalSince1970])%9;
    }
    return self;
}

- (void)dealloc {
    self.scrollView.delegate = nil;
    self.scrollView=nil;
    self.backgroundImageView=nil;
    self.learningImageView=nil;
    self.speakingImageView=nil;
    self.userImageButton=nil;
    self.activityImageView=nil;
    self.userImageShadow=nil;
    self.nameLabel=nil;
    self.activityLabel=nil;
    self.indicatorView=nil;
    
    self.userLabel=nil;
    self.userTextView=nil;
    self.userTextViewShadow=nil;
    self.statusLabel=nil;
    
    self.statusTextViewShadow=nil;
    self.statusTextView=nil;
    self.speakingLabel1=nil;
    self.speakingLabel2=nil;
    self.learningLabel1=nil;
    self.learningLabel2=nil;
    self.ballView=nil;
    
    self.learningLangView=nil;
    self.speakingLangView=nil;
    
    //LTC
    self.firstLabel = nil;
    self.secondLabel = nil;
    self.learnOrSpeakSeg = nil;
    self.brandedLangView = nil;
    
    
    self.locationLabel=nil;
    self.locationExplanationLabel=nil;
    self.locationSwitch=nil;
    self.mapView=nil;
    
    self.editButton=nil;
    self.buttonView=nil;
    self.deleteButton=nil;
    self.saveButton=nil;
    
    self.messageButton=nil;
    self.locateButton=nil;
    self.blockButton=nil;
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    UIImage * image=[UIImage imageNamed:@"profile-background"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    //Scrollview
    self.scrollView=[[UIScrollView alloc] init];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.scrollView];
    
    //Background imageView
    NSString * imageName=[NSString stringWithFormat:@"profile-0%ld-iph-por.jpg", (long)self.backgroundImageIndex];
    self.backgroundImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [self.scrollView addSubview:self.backgroundImageView];
    
    //Learning imageView
    self.learningImageView=[[UIImageView alloc] init];
    [self.scrollView addSubview:self.learningImageView];
    
    //Speaking imageView
    self.speakingImageView=[[UIImageView alloc] init];
    [self.scrollView addSubview:self.speakingImageView];
    
    //User imageView
    self.userImageShadow=[[UIView alloc] init];
    self.userImageShadow.backgroundColor=[UIColor clearColor];
    self.userImageShadow.layer.cornerRadius = 32.5;
    self.userImageShadow.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.userImageShadow.layer.shadowOpacity = 1.0;
    self.userImageShadow.layer.shadowRadius = 5;
    self.userImageShadow.layer.shadowOffset = CGSizeMake(0, 0);
    [self.scrollView addSubview:self.userImageShadow];
    
    self.userImageButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.userImageButton.adjustsImageWhenDisabled=NO;
    self.userImageButton.frame=CGRectMake(0, 0, 65, 65);
    self.userImageButton.layer.masksToBounds=YES;
    self.userImageButton.layer.cornerRadius = 32.5;
    [self.userImageButton setBackgroundImage:[UIImage imageNamed:@"BigWhite"] forState:UIControlStateNormal];
    [self.userImageButton setTitle:NSLocalizedString(@"Select photo", nil) forState:UIControlStateNormal];
    [self.userImageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.userImageButton.titleLabel.font=[UIFont fontWithName:@"Ubuntu-Light" size:9];
    self.userImageButton.titleLabel.alpha=0.0;
    if (self.user == nil)
        [self.userImageButton addTarget:self action:@selector(selectPhoto) forControlEvents:UIControlEventTouchUpInside];
    else
        [self.userImageButton addTarget:self action:@selector(showPicture) forControlEvents:UIControlEventTouchUpInside];
    [self.userImageShadow addSubview:self.userImageButton];
    
    self.activityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(65 - 13, 0, 13, 13)];
    [self.userImageShadow addSubview:self.activityImageView];
    
    //User labels
    self.nameLabel=[[UILabel alloc] init];
    self.nameLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:17];
    self.nameLabel.backgroundColor=[UIColor clearColor];
    self.nameLabel.textColor=[UIColor whiteColor];
    self.nameLabel.textAlignment=NSTextAlignmentCenter;
    [self.scrollView addSubview:self.nameLabel];
    
    self.activityLabel=[[UILabel alloc] init];
    self.activityLabel.font=[UIFont fontWithName:@"Ubuntu-Light" size:9];
    self.activityLabel.backgroundColor=[UIColor clearColor];
    self.activityLabel.textColor=[UIColor whiteColor];
    self.activityLabel.textAlignment=NSTextAlignmentCenter;
    [self.scrollView addSubview:self.activityLabel];
    
    //Indicator view
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.userImageButton addSubview:self.indicatorView];
    
    
    //Fields for editing
    //Userlabel
    self.userLabel=[[UILabel alloc] init];
    self.userLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:13];
    self.userLabel.backgroundColor=[UIColor clearColor];
    self.userLabel.textColor=[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    self.userLabel.textAlignment=NSTextAlignmentLeft;
    self.userLabel.text=NSLocalizedString(@"Username & Photo", nil);
    [self.scrollView addSubview:self.userLabel];
    //User text view
    self.userTextViewShadow=[[UIView alloc] init];
    self.userTextViewShadow.layer.shadowColor=[[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
    self.userTextViewShadow.layer.shadowOpacity = 1.0;
    self.userTextViewShadow.layer.shadowRadius = 2;
    self.userTextViewShadow.layer.shadowOffset = CGSizeMake(1, 3);
    self.userTextViewShadow.clipsToBounds=NO;
    [self.scrollView addSubview:self.userTextViewShadow];
    
    self.userTextView=[[UITextField alloc] init];
    self.userTextView.backgroundColor = [UIColor whiteColor];
    self.userTextView.font=[UIFont fontWithName:@"Ubuntu-Medium" size:11];
    self.userTextView.textColor=[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    self.userTextView.layer.cornerRadius=8.0;
    self.userTextView.layer.borderWidth=1.0;
    self.userTextView.layer.borderColor=[[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
    self.userTextView.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0); // left margin
    self.userTextView.delegate=self;
    [self.userTextViewShadow addSubview:self.userTextView];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Hide keyboard", nil) style:UIBarButtonItemStyleDone target:self action:@selector(resignAllFirstResponders)];
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    NSDictionary * dic;
    dic = [NSDictionary dictionaryWithObjectsAndKeys:
           [UIFont fontWithName:@"Ubuntu-Bold" size:12], NSFontAttributeName,
           [UIColor whiteColor], NSForegroundColorAttributeName,
           shadow, NSShadowAttributeName, nil];
    [barButton setTitleTextAttributes:dic forState:UIControlStateNormal];
    barButton.tintColor=[UIColor darkGrayColor];
    UIToolbar * toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    toolbar.barStyle=UIBarStyleBlack;
    toolbar.translucent=YES;
    toolbar.items = [NSArray arrayWithObject:barButton];
    self.userTextView.inputAccessoryView = toolbar;
    //Status label
    self.statusLabel=[[UILabel alloc] init];
    self.statusLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:13];
    self.statusLabel.backgroundColor=[UIColor clearColor];
    self.statusLabel.textColor=[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    self.statusLabel.textAlignment=NSTextAlignmentLeft;
    self.statusLabel.text=NSLocalizedString(@"Status", nil);
    [self.scrollView addSubview:self.statusLabel];
    
    
    //Line with balls
    self.ballView=[[BallView alloc] init];
    [self.scrollView addSubview:self.ballView];
    self.ballView.frame=CGRectMake(10, 0, 5, 400);
    //Fake values so that I have five balls and in "rotateToInterface..." I only update the coors
    [self.ballView setYCoor:[NSArray arrayWithObjects:[NSNumber numberWithFloat:120.0], [NSNumber numberWithFloat:120.0], [NSNumber numberWithFloat:185 + 15],[NSNumber numberWithFloat:235 + 15.0], [NSNumber numberWithFloat:270 + 7.0], nil]];
    //Must be on top of the BallView
    [self.scrollView bringSubviewToFront:self.userTextViewShadow];
    
    
    //Status textView
    self.statusTextViewShadow=[[UIView alloc] init];
    self.statusTextViewShadow.layer.shadowColor=[[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
    self.statusTextViewShadow.layer.shadowOpacity = 1.0;
    self.statusTextViewShadow.layer.shadowRadius = 2;
    self.statusTextViewShadow.layer.shadowOffset = CGSizeMake(1, 3);
    self.statusTextViewShadow.clipsToBounds=NO;
    [self.scrollView addSubview:self.statusTextViewShadow];
    
    self.statusTextView=[[UITextView alloc] init];
    self.statusTextView.font=[UIFont fontWithName:@"Ubuntu-Medium" size:11];
    self.statusTextView.textColor=[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    self.statusTextView.layer.cornerRadius=8.0;
    self.statusTextView.layer.borderWidth=1.0;
    self.statusTextView.layer.borderColor=[[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
    self.statusTextView.delegate=self;
    [self.statusTextViewShadow addSubview:self.statusTextView];
    self.statusTextView.inputAccessoryView = toolbar;
    
    //Speaking & Learning labels
    self.speakingLabel1=[[UILabel alloc] init];
    self.speakingLabel1.font=[UIFont fontWithName:@"Ubuntu-Bold" size:13];
    self.speakingLabel1.backgroundColor=[UIColor clearColor];
    self.speakingLabel1.textColor=[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    self.speakingLabel1.textAlignment=NSTextAlignmentLeft;
    self.speakingLabel1.numberOfLines=0;
    [self.scrollView addSubview:self.speakingLabel1];
    self.speakingLabel2=[[UILabel alloc] init];
    self.speakingLabel2.font=[UIFont fontWithName:@"Ubuntu-Bold" size:13];
    self.speakingLabel2.backgroundColor=[UIColor clearColor];
    self.speakingLabel2.textColor=[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    self.speakingLabel2.textAlignment=NSTextAlignmentLeft;
    self.speakingLabel2.numberOfLines=0;
    [self.scrollView addSubview:self.speakingLabel2];
    self.speakingLabel1.text=NSLocalizedString(@"Speaking", @"Label Speaking Languagues as a whole");
    self.speakingLabel2.text=NSLocalizedString(@"Languages", @"Label Speaking Languagues as a whole");
    CGSize adjustedSize = [self.speakingLabel1.text sizeWithAttributes:@{NSFontAttributeName:self.speakingLabel1.font}];
    CGSize size = CGSizeMake(ceilf(adjustedSize.width), ceilf(adjustedSize.height));
    self.speakingLabel1.frame=CGRectMake(0, 0, size.width, size.height);
    adjustedSize = [self.speakingLabel2.text sizeWithAttributes:@{NSFontAttributeName:self.speakingLabel2.font}];
    size = CGSizeMake(ceilf(adjustedSize.width), ceilf(adjustedSize.height));
    self.speakingLabel2.frame=CGRectMake(0, 0, size.width, size.height);
    
    self.learningLabel1=[[UILabel alloc] init];
    self.learningLabel1.font=[UIFont fontWithName:@"Ubuntu-Bold" size:13];
    self.learningLabel1.backgroundColor=[UIColor clearColor];
    self.learningLabel1.textColor=[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    self.learningLabel1.textAlignment=NSTextAlignmentLeft;
    self.learningLabel1.numberOfLines=0;
    [self.scrollView addSubview:self.learningLabel1];
    self.learningLabel2=[[UILabel alloc] init];
    self.learningLabel2.font=[UIFont fontWithName:@"Ubuntu-Bold" size:13];
    self.learningLabel2.backgroundColor=[UIColor clearColor];
    self.learningLabel2.textColor=[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    self.learningLabel2.textAlignment=NSTextAlignmentLeft;
    self.learningLabel2.numberOfLines=0;
    [self.scrollView addSubview:self.learningLabel2];
    self.learningLabel1.text=NSLocalizedString(@"Learning", @"Label Learning Languagues as a whole");
    self.learningLabel2.text=NSLocalizedString(@"Languages", @"Label Learning Languagues as a whole");
    adjustedSize = [self.learningLabel1.text sizeWithAttributes:@{NSFontAttributeName:self.learningLabel1.font}];
    size = CGSizeMake(ceilf(adjustedSize.width), ceilf(adjustedSize.height));
    self.learningLabel1.frame=CGRectMake(0, 0, size.width, size.height);
    adjustedSize = [self.learningLabel2.text sizeWithAttributes:@{NSFontAttributeName:self.learningLabel2.font}];
    size = CGSizeMake(ceilf(adjustedSize.width), ceilf(adjustedSize.height));
    self.learningLabel2.frame=CGRectMake(0, 0, size.width, size.height);
    
    //Lang Views
    self.speakingLangView=[[LangView alloc] init];
    self.speakingLangView.delegate=self;
    [self.scrollView addSubview:self.speakingLangView];
    //Fake frame with the right height
    self.speakingLangView.frame=CGRectMake(0, 0, 100, 43);
    
    self.learningLangView=[[LangView alloc] init];
    self.learningLangView.delegate=self;
    [self.scrollView addSubview:self.learningLangView];
    //Fake frame with the right height
    self.learningLangView.frame=CGRectMake(0, 0, 100, 35);
    
    
    //LTC
    if ([LTDataSource isLextTalkCatalan])
    {
        //First label
        self.firstLabel=[[UILabel alloc] init];
        self.firstLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:13];
        self.firstLabel.backgroundColor=[UIColor clearColor];
        self.firstLabel.textColor=[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
        self.firstLabel.textAlignment=NSTextAlignmentLeft;
        self.firstLabel.numberOfLines=1;
        [self.scrollView addSubview:self.firstLabel];
        self.firstLabel.alpha = 0.0;
        
        //Second label
        self.secondLabel=[[UILabel alloc] init];
        self.secondLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:13];
        self.secondLabel.backgroundColor=[UIColor clearColor];
        self.secondLabel.textColor=[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
        self.secondLabel.textAlignment=NSTextAlignmentLeft;
        self.secondLabel.numberOfLines=0;
        [self.scrollView addSubview:self.secondLabel];
        self.secondLabel.alpha = 0.0;
        
        self.firstLabel.text=NSLocalizedString(@"Are you learning or do you speak Catalan?", nil);
        //self.secondLabel.text=NSLocalizedString(@"Languages", nil);
        adjustedSize = [self.firstLabel.text sizeWithAttributes:@{NSFontAttributeName:self.firstLabel.font}];
        size = CGSizeMake(ceilf(adjustedSize.width), ceilf(adjustedSize.height));
        self.firstLabel.frame=CGRectMake(0, 0, size.width, size.height);
        //size = [self.secondLabel.text sizeWithFont:self.secondLabel.font];
        //self.secondLabel.frame=CGRectMake(0, 0, size.width, size.height);
        
        //learnOrSpeakSeg
        self.learnOrSpeakSeg = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Learning", nil), NSLocalizedString(@"Speaking", nil), nil]];
        [self.scrollView addSubview:self.learnOrSpeakSeg];
        self.learnOrSpeakSeg.alpha = 0.0;
        [self.learnOrSpeakSeg addTarget:self action:@selector(languageChanged:) forControlEvents:UIControlEventValueChanged];
        if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 7)
            self.learnOrSpeakSeg.tintColor = [UIColor colorFromImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]];
        [self.learnOrSpeakSeg setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:self.firstLabel.font, NSFontAttributeName, self.firstLabel.textColor, NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        [self.learnOrSpeakSeg setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:self.firstLabel.font, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
        
        //brandedLangView
        self.brandedLangView=[[LangView alloc] init];
        self.brandedLangView.delegate=self;
        [self.scrollView addSubview:self.brandedLangView];
        //Fake frame with the right height
        self.brandedLangView.frame=CGRectMake(0, 0, 100, 43);
    }
    
    
    
    
    //Button View
    if (self.user==nil)
    {
        //LocationLabel
        self.locationLabel=[[UILabel alloc] init];
        self.locationLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:13];
        self.locationLabel.backgroundColor=[UIColor clearColor];
        self.locationLabel.textColor=[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
        self.locationLabel.textAlignment=NSTextAlignmentLeft;
        [self.scrollView addSubview:self.locationLabel];
        //locationExplanationLabel
        self.locationExplanationLabel=[[UILabel alloc] init];
        self.locationExplanationLabel.font=[UIFont fontWithName:@"Ubuntu-Light" size:13];
        self.locationExplanationLabel.backgroundColor=[UIColor clearColor];
        self.locationExplanationLabel.textColor=[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
        self.locationExplanationLabel.textAlignment=NSTextAlignmentLeft;
        [self.scrollView addSubview:self.locationExplanationLabel];
        self.locationExplanationLabel.numberOfLines=2;
        self.locationExplanationLabel.text=NSLocalizedString(@"Use GPS? (off: center the map \nwhere you wish to be shown)", nil);
        //locationSwitch
        self.locationSwitch=[[UISwitch alloc] init];
        if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 6)
            self.locationSwitch.tintColor = [UIColor colorFromImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]];
        self.locationSwitch.onTintColor = [UIColor colorFromImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]];
        [self.locationSwitch addTarget:self action:@selector(locationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        [self.scrollView addSubview:self.locationSwitch];
        //mapView
        self.mapView=[[MKMapView alloc] init];
        [self.scrollView addSubview:self.mapView];
        
        
        
        self.buttonView=[[UIView alloc] init];
        [self.view addSubview:self.buttonView];
        self.buttonView.layer.shadowColor=[[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        self.buttonView.layer.shadowOpacity = 1.0;
        self.buttonView.layer.shadowRadius = 2;
        self.buttonView.layer.shadowOffset = CGSizeMake(0, -2);
        self.buttonView.clipsToBounds=NO;
        
        self.editButton=[UIButton buttonWithType:UIButtonTypeCustom];
        UIImage * editButtonImage=[UIImage imageNamed:@"button-profile-yellow"];
        editButtonImage = [editButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
        //[self.editButton setImage:editButtonImage forState:UIControlStateNormal];
        [self.editButton setBackgroundImage:editButtonImage forState:UIControlStateNormal];
        [self.editButton setTitle:NSLocalizedString(@"EDIT PROFILE", @"Profile") forState:UIControlStateNormal];
        self.editButton.titleLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:15];
        self.editButton.titleLabel.textColor=[UIColor whiteColor];
        [self.editButton addTarget:self action:@selector(editButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonView addSubview:self.editButton];
        
        self.deleteButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [self.deleteButton setBackgroundImage:editButtonImage forState:UIControlStateNormal];
        [self.deleteButton setTitle:NSLocalizedString(@"DELETE PROFILE", @"Profile") forState:UIControlStateNormal];
        self.deleteButton.titleLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:15];
        self.deleteButton.titleLabel.textColor=[UIColor whiteColor];
        [self.deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonView addSubview:self.deleteButton];
        
        self.saveButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [self.saveButton setBackgroundImage:editButtonImage forState:UIControlStateNormal];
        [self.saveButton setTitle:NSLocalizedString(@"SAVE PROFILE", @"Profile") forState:UIControlStateNormal];
        self.saveButton.titleLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:15];
        self.saveButton.titleLabel.textColor=[UIColor whiteColor];
        [self.saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonView addSubview:self.saveButton];
    }
    else
    {
        self.messageButton=[UIButton buttonWithType:UIButtonTypeCustom];
        UIImage * messageButtonImage=[UIImage imageNamed:@"button-profile-yellow"];
        messageButtonImage = [messageButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
        [self.messageButton setBackgroundImage:messageButtonImage forState:UIControlStateNormal];
        [self.messageButton setTitle:NSLocalizedString(@"Send message", @"Profile") forState:UIControlStateNormal];
        self.messageButton.titleLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:13];
        [self.messageButton setTitleColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.messageButton addTarget:self action:@selector(messageButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:self.messageButton];
        
        self.messageButton.layer.shadowColor=[[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        self.messageButton.layer.shadowOpacity = 1.0;
        self.messageButton.layer.shadowRadius = 2;
        self.messageButton.layer.shadowOffset = CGSizeMake(0, 2);
        self.messageButton.clipsToBounds=NO;
        
        self.locateButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [self.locateButton setBackgroundImage:messageButtonImage forState:UIControlStateNormal];
        [self.locateButton setTitle:NSLocalizedString(@"Locate", @"Profile") forState:UIControlStateNormal];
        self.locateButton.titleLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:13];
        [self.locateButton setTitleColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.locateButton addTarget:self action:@selector(locateButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:self.locateButton];
        
        self.locateButton.layer.shadowColor=[[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        self.locateButton.layer.shadowOpacity = 1.0;
        self.locateButton.layer.shadowRadius = 2;
        self.locateButton.layer.shadowOffset = CGSizeMake(0, 2);
        self.locateButton.clipsToBounds=NO;
        
        self.blockButton=[UIButton buttonWithType:UIButtonTypeCustom];
        UIImage * blockButtonImage=[UIImage imageNamed:@"button-profile-darkgray"];
        blockButtonImage = [blockButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
        [self.blockButton setBackgroundImage:blockButtonImage forState:UIControlStateNormal];
        [self.blockButton setTitle:NSLocalizedString(@"Block user", @"Profile") forState:UIControlStateNormal];
        self.blockButton.titleLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:13];
        [self.blockButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.blockButton addTarget:self action:@selector(blockButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:self.blockButton];
        
        self.blockButton.layer.shadowColor=[[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        self.blockButton.layer.shadowOpacity = 1.0;
        self.blockButton.layer.shadowRadius = 2;
        self.blockButton.layer.shadowOffset = CGSizeMake(0, 2);
        self.blockButton.clipsToBounds=NO;
    }
    
    self.scrollViewToLayout = self.scrollView;
    self.extraBottomInset = 35.0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.title=NSLocalizedString(@"Profile", nil);
    
    
    
    [self customizeForUser];
    
    if (self.user == nil) //only for local user
    {
        self.navigationItem.leftBarButtonItem = [GeneralHelper plainBarButtonItemWithText:@"Log out" image:nil target:self selector:@selector(logout)];
        self.navigationItem.rightBarButtonItem = [GeneralHelper plainBarButtonItemWithText:nil image:[UIImage imageNamed:@"button-conf"] target:self selector:@selector(confButtonPressed)];
        
        self.editButton.enabled=YES;
    }
    else
        self.navigationItem.leftBarButtonItem = [GeneralHelper plainBarButtonItemWithText:nil image:[UIImage imageNamed:@"arrow-back"] target:self selector:@selector(popViewController)];
    
//<<<<<<< HEAD

//=======
    //winstojl
    
    self.tut = [[TutViewController alloc] init];
    [self.view addSubview:self.tut.view];
    
    //Set up remove view button
    self.removeTutBtn = [[UIButton alloc] init];
    self.removeTutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.removeTutBtn addTarget:self
                          action:@selector(dismissTut)
                forControlEvents:UIControlEventTouchUpInside];
    [self.removeTutBtn setTitle:@"Got it!" forState:UIControlStateNormal];
    self.removeTutBtn.frame = CGRectMake(80.0, self.view.frame.size.height-(200.0), 160.0, 40.0);
    [self.view addSubview:self.removeTutBtn];
    
    [self.tut changeTutImage:[UIImage imageNamed:@"profileedit"]];
    [self.tut changeTutText:@"Edit your profile settings to add a little color to your profile."];
}

-(void)dismissTut{
    NSLog(@"Dismissed");
    [self.tut.view removeFromSuperview];
    [self.removeTutBtn removeFromSuperview];
//>>>>>>> Winston_Hoglen
}

- (void) popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) rotateToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation
{
    CGSize size = self.view.bounds.size;
    BOOL iphone5 = NO;
    if (size.height > size.width)
    {
        if (size.height > 481.0)
            iphone5 = YES;
    }
    else
    {
        if (size.width > 481.0)
            iphone5 = YES;
    }
    
    NSString * backgroundImageName = nil;
    CGFloat backgroundWidth = 0;
    CGFloat yOffset=0;
    CGFloat backgroundHeight = 110;
    CGFloat iPadYOffset=0;
    CGFloat mapHeight = 0;
    CGFloat mapWidth = 0;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        //offset to separate items in iPhone 5
        if (iphone5) //iphone 5
        {
            if (self.user==nil)
                yOffset=13.0;
            else
                yOffset=7.0;
            
            if ((toInterfaceOrientation==UIInterfaceOrientationPortrait) || (toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown))
            {
                backgroundImageName = [NSString stringWithFormat:@"profile-0%ld-iph-por.jpg", (long)self.backgroundImageIndex];
                backgroundWidth = 320;
            }
            else
            {
                backgroundImageName = [NSString stringWithFormat:@"profile-0%ld-iph5-lan.jpg", (long)self.backgroundImageIndex];
                backgroundWidth = 568;
                yOffset=0.0;
            }
        }
        else
        {
            if ((toInterfaceOrientation==UIInterfaceOrientationPortrait) || (toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown))
            {
                backgroundImageName = [NSString stringWithFormat:@"profile-0%ld-iph-por.jpg", (long)self.backgroundImageIndex];
                backgroundWidth = 320;
            }
            else
            {
                backgroundImageName = [NSString stringWithFormat:@"profile-0%ld-ipad.jpg", (long)self.backgroundImageIndex];
                backgroundWidth = 480;
            }
        }
        
        mapWidth = 290;
        mapHeight = 220;
    }
    else
    {
        //profile takes all screen
        if (self.user==nil)
        {
            backgroundImageName = [NSString stringWithFormat:@"profile-0%ld-ipad.jpg", (long)self.backgroundImageIndex];
            if ((toInterfaceOrientation==UIInterfaceOrientationPortrait) || (toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown))
            {
                backgroundWidth = 768;
                backgroundHeight = 175.5;
                yOffset = 20;
                iPadYOffset = 85;
            }
            else
            {
                backgroundWidth = 1024;
                backgroundHeight = 234;
                yOffset = 20;
                iPadYOffset = 135;
            }
            
            if ((toInterfaceOrientation==UIInterfaceOrientationPortrait) || (toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown))
            {
                mapWidth = 728;
                mapHeight = 460;
            }
            else
            {
                mapWidth = 984;
                mapHeight = 400;
            }
        }
        else //as in iPhone 4, it is shown in a popover
        {
            backgroundImageName = [NSString stringWithFormat:@"profile-0%ld-iph-por.jpg", (long)self.backgroundImageIndex];
            backgroundWidth = 320;
            backgroundHeight = 110;
            yOffset = 0;
            iPadYOffset = 0;
        }
    }
    
    //Image, user name, flags, photo and activity
    self.backgroundImageView.image = [UIImage imageNamed:backgroundImageName];
    self.backgroundImageView.frame=CGRectMake(0, 0, backgroundWidth, backgroundHeight);
    if (self.editingUser)
    {
        self.learningImageView.frame=CGRectMake((backgroundWidth - 38 -38 -20 -65 -10), 29.5, 38, 32);
        self.speakingImageView.frame=CGRectMake((backgroundWidth - 38 -10), 29.5, 38, 46);
        self.userImageShadow.frame=CGRectMake((backgroundWidth - 38 -65 -20), 20, 65, 65);
        self.userImageButton.enabled=YES;
        self.userImageButton.titleLabel.alpha=1.0;
        
        self.activityImageView.alpha=0.0;
        self.backgroundImageView.alpha=0.0;
        self.nameLabel.alpha=0.0;
        self.activityLabel.alpha=0.0;
    }
    else
    {
        self.learningImageView.frame=CGRectMake((backgroundWidth - 38 -38 -20 -65) / 2.0, 14.5 + (backgroundHeight - 110)/2.0, 38, 32);
        self.speakingImageView.frame=CGRectMake((backgroundWidth - 38 -38 -20 -65) / 2.0 + 58 + 65, 14.5 + (backgroundHeight - 110)/2.0, 38, 46);
        self.userImageShadow.frame=CGRectMake((backgroundWidth - 38 -38 -20 -65) / 2.0 + 48, 5 + (backgroundHeight - 110)/2.0, 65, 65);
        self.userImageButton.enabled=NO;
        self.userImageButton.titleLabel.alpha=0.0;
        
        self.activityImageView.alpha=1.0;
        self.backgroundImageView.alpha=1.0;
        self.nameLabel.alpha=1.0;
        self.activityLabel.alpha=1.0;
    }
    
    //Button enabled if it is not the local user. That way I can show the picture by tapping on it
    //Disabled until the picture is shown right and size of the cached image is clear too
    
    if (self.user!=nil)
        self.userImageButton.enabled = YES;
     
    
    //self.activityImageView.frame=CGRectMake(65 - 13, 0, 13, 13);
    self.nameLabel.frame=CGRectMake(0, 5 + 65 + 5 + (backgroundHeight - 110)/2.0, backgroundWidth, 20);
    self.activityLabel.frame=CGRectMake(0, 5 + 65 + 5 + 20 + (backgroundHeight - 110)/2.0, backgroundWidth, 12);
    
    self.indicatorView.center=CGPointMake(65/2.0, 65/2.0);
    
    
    //Fields for editing
    self.userLabel.frame=CGRectMake(35, 10, 300, 16);
    self.userTextViewShadow.frame=CGRectMake(10, 30, 130, 30);
    self.userTextView.frame=CGRectMake(0, 0, self.userTextViewShadow.frame.size.width, self.userTextViewShadow.frame.size.height);
    self.statusLabel.frame=CGRectMake(35, 70, 300, 16);
    if (self.editingUser)
    {
        self.userLabel.alpha=1.0;
        self.userTextViewShadow.alpha=1.0;
        self.statusLabel.alpha=1.0;
    }
    else
    {
        self.userLabel.alpha=0.0;
        self.userTextViewShadow.alpha=0.0;
        self.statusLabel.alpha=0.0;
    }
    
    //Status TextView
    if (self.editingUser)
        self.statusTextViewShadow.frame=CGRectMake(10, 90, backgroundWidth - 20, 59);
    else
        self.statusTextViewShadow.frame=CGRectMake(25, 115 + yOffset*1 + iPadYOffset, backgroundWidth - 20 - 18, 59);
    self.statusTextView.frame=CGRectMake(0, 0, self.statusTextViewShadow.frame.size.width, self.statusTextViewShadow.frame.size.height);
    
    //Speaking and Learning labels
    CGSize speakingSize, learningSize;
    if (self.editingUser)
    {
        CGSize adjustedSize = [@" " sizeWithAttributes:@{NSFontAttributeName:self.speakingLabel1.font}];
        CGSize size = CGSizeMake(ceilf(adjustedSize.width), ceilf(adjustedSize.height));
        CGFloat spaceWidth = size.width;
        self.speakingLabel1.frame=CGRectMake(35, 160, self.speakingLabel1.bounds.size.width, self.speakingLabel1.bounds.size.height);
        self.speakingLabel2.frame=CGRectMake(35 + spaceWidth + self.speakingLabel1.bounds.size.width, 160, self.speakingLabel2.bounds.size.width, self.speakingLabel2.bounds.size.height);
        
        self.learningLabel1.frame=CGRectMake(35, 220, self.learningLabel1.bounds.size.width, self.learningLabel1.bounds.size.height);
        self.learningLabel2.frame=CGRectMake(35  + spaceWidth + self.learningLabel1.bounds.size.width, 220, self.learningLabel2.bounds.size.width, self.learningLabel2.bounds.size.height);
        
        if ([LTDataSource isLextTalkCatalan])
        {
            self.firstLabel.alpha = 1.0;
            self.secondLabel.alpha = 1.0;
            self.learnOrSpeakSeg.alpha = 1.0;
            
            self.firstLabel.frame = CGRectMake(35, 160, self.firstLabel.bounds.size.width, self.firstLabel.bounds.size.height);
            self.secondLabel.frame = CGRectMake(35, 220, self.secondLabel.bounds.size.width, self.secondLabel.bounds.size.height);
            
            self.speakingLabel1.alpha = 0.0;
            self.speakingLabel2.alpha = 0.0;
            self.learningLabel1.alpha = 0.0;
            self.learningLabel2.alpha = 0.0;
        }
    }
    else
    {
        speakingSize = CGSizeMake(fmaxf(self.speakingLabel1.bounds.size.width, self.speakingLabel2.bounds.size.width), self.speakingLabel1.bounds.size.height + self.speakingLabel2.bounds.size.height);
        self.speakingLabel1.frame=CGRectMake(25, 185 + yOffset*2 + iPadYOffset, self.speakingLabel1.bounds.size.width, self.speakingLabel1.bounds.size.height);
        self.speakingLabel2.frame=CGRectMake(25, 185 + yOffset*2 + iPadYOffset + self.speakingLabel1.bounds.size.height, self.speakingLabel2.bounds.size.width, self.speakingLabel2.bounds.size.height);
        
        learningSize = CGSizeMake(fmaxf(self.learningLabel1.bounds.size.width, self.learningLabel2.bounds.size.width), self.learningLabel1.bounds.size.height + self.learningLabel2.bounds.size.height);
        self.learningLabel1.frame=CGRectMake(25, 235 + yOffset*3 + iPadYOffset, self.learningLabel1.bounds.size.width, self.learningLabel1.bounds.size.height);
        self.learningLabel2.frame=CGRectMake(25, 235 + yOffset*3 + iPadYOffset + self.learningLabel1.bounds.size.height, self.learningLabel2.bounds.size.width, self.learningLabel2.bounds.size.height);
        
        if ([LTDataSource isLextTalkCatalan])
        {
            self.firstLabel.alpha = 0.0;
            self.secondLabel.alpha = 0.0;
            self.learnOrSpeakSeg.alpha = 0.0;
            
            self.firstLabel.frame = CGRectMake(25, 185 + yOffset*2 + iPadYOffset, self.firstLabel.bounds.size.width, self.firstLabel.bounds.size.height);
            self.secondLabel.frame = CGRectMake(25, 235 + yOffset*3 + iPadYOffset, self.secondLabel.bounds.size.width, self.secondLabel.bounds.size.height);
            
            self.speakingLabel1.alpha = 1.0;
            self.speakingLabel2.alpha = 1.0;
            self.learningLabel1.alpha = 1.0;
            self.learningLabel2.alpha = 1.0;
        }
    }
    
    
    
    self.ballView.frame=CGRectMake(10, 0, 5, 400);
    if (self.user!=nil)
    {
        self.ballView.frame=CGRectMake(10, 0, 5, 400);
        [self.ballView adjustExistingYCoor:[NSArray arrayWithObjects:[NSNumber numberWithFloat:120.0 + yOffset*1 + iPadYOffset], [NSNumber numberWithFloat:120.0 + yOffset*1 + iPadYOffset], [NSNumber numberWithFloat:185 + 8 + yOffset*2 + iPadYOffset],[NSNumber numberWithFloat:235 + 8 + yOffset*3 + iPadYOffset], [NSNumber numberWithFloat:235 + 8 + yOffset*3 + iPadYOffset], nil]];
    }
    else if (self.editingUser)
    {
        self.ballView.frame=CGRectMake(20, 0, 5, 400);
        [self.ballView adjustExistingYCoor:[NSArray arrayWithObjects:[NSNumber numberWithFloat:17.0], [NSNumber numberWithFloat:70 + 7], [NSNumber numberWithFloat:160 + 8],[NSNumber numberWithFloat:220 + 8], [NSNumber numberWithFloat:280 + 7], nil]];
    }
    else
    {
        self.ballView.frame=CGRectMake(10, 0, 5, 400);
        [self.ballView adjustExistingYCoor:[NSArray arrayWithObjects:[NSNumber numberWithFloat:120.0 + yOffset*1 + iPadYOffset], [NSNumber numberWithFloat:120.0 + yOffset*1 + iPadYOffset], [NSNumber numberWithFloat:185 + 8 + yOffset*2 + iPadYOffset],[NSNumber numberWithFloat:235 + 8 + yOffset*3 + iPadYOffset], [NSNumber numberWithFloat:280 + 7 + yOffset*4 + iPadYOffset], nil]];
    }
    
    CGFloat speakingWidth, learningWidth;
    if (self.editingUser)
    {
        speakingWidth = [self.speakingLangView enableButton:YES];
        learningWidth = [self.learningLangView enableButton:YES];
        
        self.speakingLangView.frame=CGRectMake(35, 175, speakingWidth, 43);
        speakingWidth += 35 + speakingSize.width;
        
        self.learningLangView.frame=CGRectMake(35, 235, learningWidth, 35);
        learningWidth += 35 + learningSize.width;
        
        if ([LTDataSource isLextTalkCatalan])
        {
            self.speakingLangView.alpha = 0.0;
            self.learningLangView.alpha = 0.0;
            
            //It is OK, learningLangView.apha = 0.0;
            self.brandedLangView.alpha = 1.0;
            learningWidth = [self.brandedLangView enableButton:YES];
            self.brandedLangView.frame=CGRectMake(35, 235, learningWidth, 43);
            learningWidth += 35 + learningSize.width;
            
            self.learnOrSpeakSeg.frame = CGRectMake(35, 182, self.learnOrSpeakSeg.bounds.size.width, self.learnOrSpeakSeg.bounds.size.height);
        }
    }
    else
    {
        speakingWidth = [self.speakingLangView enableButton:NO];
        learningWidth = [self.learningLangView enableButton:NO];
        
        self.speakingLangView.frame=CGRectMake(25 + speakingSize.width + 10, 185 + yOffset*2 + iPadYOffset, speakingWidth, 43);
        speakingWidth += 25 + speakingSize.width + 10;
        
        self.learningLangView.frame=CGRectMake(25 + learningSize.width + 10, 235 + yOffset*3 + iPadYOffset, learningWidth, 35);
        learningWidth += 25 + learningSize.width + 10;
        
        if ([LTDataSource isLextTalkCatalan])
        {
            self.speakingLangView.alpha = 1.0;
            self.learningLangView.alpha = 1.0;
            self.brandedLangView.alpha = 0.0;
            
            self.brandedLangView.frame = CGRectMake(25 + learningSize.width + 10, 235 + yOffset*3 + iPadYOffset, learningWidth, 43);
            
            self.learnOrSpeakSeg.frame = CGRectMake(35, 182, self.learnOrSpeakSeg.bounds.size.width, self.learnOrSpeakSeg.bounds.size.height);
        }
    }
    
    //Location
    self.locationExplanationLabel.frame=CGRectMake(20, 298, 260, 32);
    self.locationSwitch.frame=CGRectMake(230, 301, 0, 0);
    self.mapView.frame=CGRectMake(20, 335, mapWidth, mapHeight);
    if (self.editingUser)
    {
        self.locationLabel.frame=CGRectMake(35, 280, 275, 16);
        
        self.locationExplanationLabel.alpha=1.0;
        self.locationSwitch.alpha=1.0;
        self.mapView.alpha=1.0;
        
    }
    else
    {
        self.locationLabel.frame=CGRectMake(25, 280 + yOffset*4 + iPadYOffset, 275, 16);
        
        self.locationExplanationLabel.alpha=0.0;
        self.locationSwitch.alpha=0.0;
        self.mapView.alpha=0.0;
        
        //To avoid draining battery while not editting.
        self.mapView.showsUserLocation=NO;
    }
    
    
    
    if (self.user==nil)
    {
        //CGFloat adHeight = [super layoutBanners:NO];
        self.buttonView.frame=CGRectMake(0, self.view.bounds.size.height - 35, backgroundWidth, 35);
        self.editButton.frame=CGRectMake(0, 0, backgroundWidth, 35);
        self.deleteButton.frame=CGRectMake(0, 0, backgroundWidth / 2.0 - 1, 35);
        self.saveButton.frame=CGRectMake(backgroundWidth/2.0 + 1, 0, backgroundWidth /2.0 - 1, 35);
        
        if (self.editingUser)
        {
            self.editButton.alpha=0.0;
            self.deleteButton.alpha=1.0;
            self.saveButton.alpha=1.0;
        }
        else
        {
            self.editButton.alpha=1.0;
            self.deleteButton.alpha=0.0;
            self.saveButton.alpha=0.0;
        }
    }
    else
    {
        self.messageButton.frame=CGRectMake(12, 280 + yOffset*4 + iPadYOffset, (backgroundWidth - 24 -10) / 2.0, 35);
        self.locateButton.frame=CGRectMake(12 + 10 + (backgroundWidth - 24 -10) / 2.0, 280 + yOffset*4 + iPadYOffset, (backgroundWidth - 24 -10) / 2.0, 35);
        self.blockButton.frame=CGRectMake(12, 325 + yOffset*5 + iPadYOffset, backgroundWidth - 24, 35);
    }
    
    //Final size of the content of the scrollView
    CGFloat width=speakingWidth;
    if (learningWidth>speakingWidth)
        width=learningWidth;
    if (self.user==nil)
    {
        if (self.editingUser)
            self.scrollView.contentSize=CGSizeMake(width, 335 + mapHeight + 10);
        else
            self.scrollView.contentSize=CGSizeMake(width, 305 + yOffset*5 + iPadYOffset);
    }
    else
        self.scrollView.contentSize=CGSizeMake(width, 370 + yOffset*5 + iPadYOffset);
    
    //Flash scrollbars
    if (self.scrollView.contentSize.height>(self.scrollView.bounds.size.height - self.scrollView.contentInset.bottom))
        [self.scrollView flashScrollIndicators];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self rotateToInterfaceOrientation:self.interfaceOrientation];
    

    
    //Testing removal of ads
    /*
    LextTalkAppDelegate * del = (LextTalkAppDelegate *) [[UIApplication sharedApplication] delegate];
    [del performSelector:@selector(removeAds) withObject:nil afterDelay:5.0];
    [self performSelector:@selector(layoutBanners:) withObject:nil afterDelay:5.5];
     */
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

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.scrollView.contentSize.height>(self.scrollView.bounds.size.height - self.scrollView.contentInset.bottom))
        [self.scrollView flashScrollIndicators];

    //NSLog(@"content, height: %f, %f", self.scrollView.contentSize.height, self.scrollView.bounds.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark LTDataDelegate Delegate

- (void) didLogoutUser
{
    [self.HUD hide:YES];
    self.HUD = nil;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    //[self customizeForUser];
}

- (void) didUpdateUser
{
    [self.HUD hide:YES];
    self.HUD = nil;
    
    self.editingUser=NO;
    
    //It is going to be popped, by commenting this, I do not see white fields
    [self customizeForUser];
    
    [UIView animateWithDuration:1.0 animations:^{
        [self rotateToInterfaceOrientation:self.interfaceOrientation];
        [self layoutBanners:NO];
    }];
    
    self.navigationItem.leftBarButtonItem.enabled=YES;
}

- (void) didFailUpdatingUser
{
    // just for update view
    self.editingUser=NO;
    [UIView animateWithDuration:1.0 animations:^{
        [self rotateToInterfaceOrientation:self.interfaceOrientation];
        [self layoutBanners:NO];
    }];
    
    self.navigationItem.leftBarButtonItem.enabled=YES;
}

- (void) didBlockUser:(NSInteger)userId withBlockStatus:(BOOL)block
{
    [self.HUD hide:YES];
    self.HUD = nil;
    
    //Refresh block button
    [self customizeForUser];
}

- (void) didDeleteLocalUser
{
    [self.HUD hide:YES];
    self.HUD = nil;
    
    //It is going to be popped, by commenting this, I do not see white fields
    //[self customizeForUser];
    
    self.editingUser=NO;
    [UIView animateWithDuration:1.0 animations:^{
        [self rotateToInterfaceOrientation:self.interfaceOrientation];
        [self layoutBanners:NO];
    }];
    
    
    //If it was a facebook user
    [[LTDataSource sharedDataSource] handleFacebookLogout];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) didFail:(NSDictionary *)result
{
    [self.HUD hide:YES];
    self.HUD = nil;
    
    if (result == nil) return;
	
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
#pragma mark LocalUserViewController methods

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

- (void) logout
{
    self.HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.view];
    [self.tabBarController.view addSubview:self.HUD];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.labelText = NSLocalizedString(@"Logging out...", nil);
    [self.HUD show:YES];
    
    [[LTDataSource sharedDataSource] logoutWithDelegate:self];
}

- (void) customizeLocationForUser
{
    if ([LTDataSource sharedDataSource].localUser.fuzzyLocation)
        self.locationLabel.text=NSLocalizedString(@"Map does not show your real location", nil);
    else
        self.locationLabel.text=NSLocalizedString(@"Map shows your real location", nil);
    self.locationSwitch.on=![LTDataSource sharedDataSource].localUser.fuzzyLocation;
    
    if (self.editingUser)
    {
        BOOL authorized = YES;
        if ( NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 ) {
            if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
                authorized = NO;
            }
        } else {
            if ([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorized) {
                authorized = NO;
            }
        }
        if (!authorized)
        {
            self.locationSwitch.on=NO;
            self.locationLabel.text=NSLocalizedString(@"Map does not show your real location", nil);
            [LTDataSource sharedDataSource].localUser.fuzzyLocation=YES;
            
            UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GPS not available", nil)
                                                           message:NSLocalizedString(@"The GPS could not be used to center the map around your current position (GPS not found or Lext Talk is not authorised to use it). Please, center the map manually to the location where you will be shown to other users, or change your settings", nil)
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            if ([LTDataSource sharedDataSource].localUser.fuzzyLocation)
            {
                [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
                //Mirar que no esté en (0,0) y si no poner las coordenadas del usuario y una region pequeña alrededor
                if (([LTDataSource sharedDataSource].localUser.coordinate.latitude!=0) || ([LTDataSource sharedDataSource].localUser.coordinate.longitude!=0))
                {
                    MKCoordinateRegion region=MKCoordinateRegionMake([LTDataSource sharedDataSource].localUser.coordinate, MKCoordinateSpanMake(0.005, 0.005));
                    [self.mapView setRegion:region animated:YES];
                }
            }
            else
                [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        }
    }
    else //To avoid draining battery
        self.mapView.showsUserLocation=NO;
}

- (void) customizeForUser
{
    LTUser * tempUser;
    if (self.user==nil)
        tempUser=[LTDataSource sharedDataSource].localUser;
    else
        tempUser=self.user;
    
    //image and location
    if (self.user==nil) //local user, stored in the defaults, it is retrieved with the user
    {
        if (tempUser.image!=nil)
        {
            [self.userImageButton setBackgroundImage:[GeneralHelper centralSquareFromImage:tempUser.image] forState:UIControlStateNormal];
            [self.userImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            //Must be called. If it isn't, when the user image is downloaded when you log in, the background image is not updated in the previous 2 lines of code
            //Seems a bug in iOS 7, it didn't happen before.
            [self.userImageButton setNeedsLayout];
        }
        else
        {
            [self.userImageButton setBackgroundImage:[UIImage imageNamed:@"BigWhite"] forState:UIControlStateNormal];
            [self.userImageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        
        [self customizeLocationForUser];
    }
    else
    {
        //If I tap on myself on the map, I load the image from the data in the app, do not download it
        if (tempUser.userId == [LTDataSource sharedDataSource].localUser.userId)
        {
            if ([LTDataSource sharedDataSource].localUser.image!=nil)
            {
                [self.userImageButton setBackgroundImage:[GeneralHelper centralSquareFromImage:[LTDataSource sharedDataSource].localUser.image] forState:UIControlStateNormal];
                [self.userImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else
            {
                [self.userImageButton setBackgroundImage:[UIImage imageNamed:@"BigWhite"] forState:UIControlStateNormal];
                [self.userImageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
        }
        else if (tempUser.url!=nil) //download for other users, there is a caching mechanism to improve data usage and loading times
        {
            [self.indicatorView startAnimating];
            [[LTDataSource sharedDataSource] getImageForUrl:tempUser.url withUserId:tempUser.userId andExecuteBlockInMainQueue:^(UIImage *image, BOOL gotFromCache) {
                
                [self.indicatorView stopAnimating];
                if (image!=nil)
                {
                    [self.userImageButton setBackgroundImage:[GeneralHelper centralSquareFromImage:image] forState:UIControlStateNormal];
                    [self.userImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                
            }];
        }
        else
        {
            [self.userImageButton setBackgroundImage:[UIImage imageNamed:@"BigWhite"] forState:UIControlStateNormal];
            [self.userImageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    
    
    //Only used for the edition of the local user
    if (self.user==nil)
    {
        self.speakingLang=[LTDataSource sharedDataSource].localUser.activeSpeakingLan;
        self.speakingFlag=[LTDataSource sharedDataSource].localUser.activeSpeakingFlag;
        self.learningLang=[LTDataSource sharedDataSource].localUser.activeLearningLan;
        self.learningFlag=[LTDataSource sharedDataSource].localUser.activeLearningFlag;
    }
    else //when it is not the local user
    {
        //Label of block user
        if ([[LTDataSource sharedDataSource].localUser.blockedUsers containsObject:[NSNumber numberWithInteger:self.user.userId]])
            [self.blockButton setTitle:NSLocalizedString(@"Unblock user", @"Profile") forState:UIControlStateNormal];
        else
            [self.blockButton setTitle:NSLocalizedString(@"Block user", @"Profile") forState:UIControlStateNormal];
    }
    
    self.title=tempUser.screenName;
    self.nameLabel.text=tempUser.screenName;
    //NSLog(@"Last update: %@", tempUser.lastUpdate);
    NSDate * date=[LTUser dateForUtcTime:tempUser.lastUpdate];
    self.activityLabel.text=[LTUser stringForDate:date];
    self.activityImageView.image = [IconGeneration activityImageForDate:date];
    self.userTextView.text=tempUser.screenName;
    self.statusTextView.text=tempUser.status;
    
    self.learningImageView.image = [IconGeneration bigIconForLearningLan:tempUser.activeLearningLan withFlag:tempUser.activeLearningFlag];
    self.speakingImageView.image = [IconGeneration bigIconForSpeakingLan:tempUser.activeSpeakingLan withFlag:tempUser.activeSpeakingFlag];
    
    [self.speakingLangView setLanguages:tempUser.speakingLanguages withFlags:tempUser.speakingLanguagesFlags speaking:YES withButton:self.editingUser];
    [self.learningLangView setLanguages:tempUser.learningLanguages withFlags:tempUser.learningLanguagesFlags speaking:NO withButton:self.editingUser];
    [self.speakingLangView.selectButton addTarget:self action:@selector(selectLanguages:) forControlEvents:UIControlEventTouchUpInside];
    [self.learningLangView.selectButton addTarget:self action:@selector(selectLanguages:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([LTDataSource isLextTalkCatalan])
    {
        
        if ([tempUser.speakingLanguages containsObject:@"Catalan"])
        {
            self.learnOrSpeakSeg.selectedSegmentIndex = 1;
            [self.brandedLangView setLanguages:tempUser.learningLanguages withFlags:tempUser.learningLanguagesFlags speaking:NO withButton:self.editingUser];
            [self.brandedLangView.selectButton addTarget:self action:@selector(selectLanguages:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        else if ([tempUser.learningLanguages containsObject:@"Catalan"])
        {
            self.learnOrSpeakSeg.selectedSegmentIndex = 0;
            
            [self.brandedLangView setLanguages:tempUser.speakingLanguages withFlags:tempUser.speakingLanguagesFlags speaking:YES withButton:self.editingUser];
            [self.brandedLangView.selectButton addTarget:self action:@selector(selectLanguages:) forControlEvents:UIControlEventTouchUpInside];
        }
        else //None selected
        {
            //Don't have to do anything the brandedLangView is not shown if nothing is set
        }
        
        
        NSString * str;
        if (self.learnOrSpeakSeg.selectedSegmentIndex == 0)
            str = NSLocalizedString(@"Speaking Languages", nil);
        else if (self.learnOrSpeakSeg.selectedSegmentIndex == 1)
            str = NSLocalizedString(@"Learning Languages", nil);
        else
            str = nil;
        
        self.secondLabel.text = str;
        CGSize adjustedSize = [self.secondLabel.text sizeWithAttributes:@{NSFontAttributeName:self.secondLabel.font}];
        CGSize size = CGSizeMake(ceilf(adjustedSize.width), ceilf(adjustedSize.height));
        self.secondLabel.frame=CGRectMake(self.secondLabel.frame.origin.x, self.secondLabel.frame.origin.y, size.width, size.height);
    }
    
    
    //Sign in is not done from this controller anymore, so I reload the image if necessary, but only for the local user
    //This is called only if the app has been deleted or is being used in a different device from the one where I updated the image
    if (self.user==nil)
    {
        //In case I have deleted the app, I must download the image when I sign in
        if ([LTDataSource sharedDataSource].localUser.url!=nil && [LTDataSource sharedDataSource].localUser.image==nil)
        {
            [self.indicatorView startAnimating];
            [[LTDataSource sharedDataSource] getImageForUrl:[LTDataSource sharedDataSource].localUser.url withUserId:[LTDataSource sharedDataSource].localUser.userId
                                 andExecuteBlockInMainQueue:^(UIImage *image, BOOL gotFromCache)
             {
                 
                 [self.indicatorView stopAnimating];
                 
                 //Avoid infinite loop
                 if (image!=nil)
                 {
                     [LTDataSource sharedDataSource].localUser.image = image;
                     [[LTDataSource sharedDataSource] saveProfileImage:image];
                     
                     [self customizeForUser];
                 }
                 
             }];
        }
    }
}

- (void) locationSwitchChanged:(UISwitch *) swt
{
    [LTDataSource sharedDataSource].localUser.fuzzyLocation = !self.locationSwitch.on;
    
    //Add HUD to tell the user to center the map
    
    [UIView animateWithDuration:0.3 animations:^{
        self.locationLabel.alpha=0.0;
    } completion:^(BOOL finished) {
        [self customizeLocationForUser];
        [UIView animateWithDuration:0.3 animations:^{
            self.locationLabel.alpha=1.0;
        }];
    }];
}

- (void) editButtonPressed
{
    self.editingUser=YES;
    
    self.navigationItem.leftBarButtonItem.enabled=NO;
    
    [self customizeLocationForUser];
    
    [UIView animateWithDuration:1.0 animations:^{
        [self rotateToInterfaceOrientation:self.interfaceOrientation];
        [self layoutBanners:NO];
    }];
}

- (void) deleteButtonPressed
{
    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Do you really wish to delete your profile?", nil)
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                         otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
    alert.tag = 1;
    [alert show];
}

- (void) saveButtonPressed
{
    //If branded app, before doing any check set the standard learning and speaking LangViews
    if ([LTDataSource isLextTalkCatalan])
    {
        if (self.learnOrSpeakSeg.selectedSegmentIndex == 0) //Learning
        {
            [self.speakingLangView setLanguages:self.brandedLangView.langs withFlags:self.brandedLangView.flags speaking:YES withButton:self.editingUser];
            [self.learningLangView setLanguages:[NSArray arrayWithObject:@"Catalan"] withFlags:[NSArray arrayWithObject:[NSNumber numberWithInteger:0]] speaking:NO withButton:NO];
        }
        else if (self.learnOrSpeakSeg.selectedSegmentIndex == 1) //Speaking
        {
            [self.learningLangView setLanguages:self.brandedLangView.langs withFlags:self.brandedLangView.flags speaking:YES withButton:self.editingUser];
            [self.speakingLangView setLanguages:[NSArray arrayWithObject:@"Catalan"] withFlags:[NSArray arrayWithObject:[NSNumber numberWithInteger:0]] speaking:NO withButton:NO];
        }
    }
    
    
    if ([self.userTextView.text length]==0)
    {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Complete your profile!", nil)
                                                       message:NSLocalizedString(@"Please, write your username (the one other users will see).", nil)
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                             otherButtonTitles: nil];
        [alert show];
    }
    else if (([self.learningLangView.langs count]==0) || ([self.speakingLangView.langs count]==0) || (self.learningLang==nil) || (self.speakingLang==nil))
    {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Complete your profile!", nil)
                                                       message:NSLocalizedString(@"Please, select the languages you speak and the ones you are learning", nil)
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                             otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        //Update the user
        [LTDataSource sharedDataSource].localUser.screenName=self.userTextView.text;
        [LTDataSource sharedDataSource].localUser.status=self.statusTextView.text;
        
        //Languages
        [[LTDataSource sharedDataSource] localUser].speakingLanguages=self.speakingLangView.langs;
        [[LTDataSource sharedDataSource] localUser].speakingLanguagesFlags=self.speakingLangView.flags;
        [[LTDataSource sharedDataSource] localUser].learningLanguages=self.learningLangView.langs;
        [[LTDataSource sharedDataSource] localUser].learningLanguagesFlags=self.learningLangView.flags;
        
        [[LTDataSource sharedDataSource] localUser].activeSpeakingLan=self.speakingLang;
        [[LTDataSource sharedDataSource] localUser].activeSpeakingFlag=self.speakingFlag;
        [[LTDataSource sharedDataSource] localUser].activeLearningLan=self.learningLang;
        [[LTDataSource sharedDataSource] localUser].activeLearningFlag=self.learningFlag;
        
        
        //FuzzyLocation
        [LTDataSource sharedDataSource].localUser.fuzzyLocation = !self.locationSwitch.on;
        if ([LTDataSource sharedDataSource].localUser.fuzzyLocation)
            [[LTDataSource sharedDataSource] localUser].coordinate=self.mapView.region.center;
        
        //In case I am saving a Facebook image in the server
        [LTDataSource sharedDataSource].localUser.image = [GeneralHelper centralSquareFromImage:[LTDataSource sharedDataSource].localUser.image];
        if ([LTDataSource sharedDataSource].localUser.image.size.width * [LTDataSource sharedDataSource].localUser.image.scale > 641.0)
            [LTDataSource sharedDataSource].localUser.image = [[LTDataSource sharedDataSource].localUser.image resizedImage:CGSizeMake(640, 640) interpolationQuality:kCGInterpolationHigh];
        
        //Call the data source to update the user, and also update the current user.
        [[LTDataSource sharedDataSource] updateUser:[[LTDataSource sharedDataSource] localUser].userId withEditKey:[[LTDataSource sharedDataSource] localUser].editKey saveImage:YES delegate:self];
        
     
        self.HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.view];
        [self.tabBarController.view addSubview:self.HUD];
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        self.HUD.labelText = NSLocalizedString(@"Saving profile...", nil);
        [self.HUD show:YES];
    }
}

- (void) messageButtonPressed
{
    if([[LTDataSource sharedDataSource] localUser].userId == self.user.userId) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"You cannot send a message to yourself!", @"You cannot send a message to yourself!")
                                                        message: nil
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if(![[LTDataSource sharedDataSource] isUserLogged]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"You are not signed in", @"You are not signed in")
														message: NSLocalizedString(@"You must be signed in in order to send messages to other users.", @"You must be signed in in order to send messages to other users.")
													   delegate: nil
											  cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
											  otherButtonTitles: nil];
		[alert show];
		return;
	}
    
    //Check if the user is blocked
	
	if ([[LTDataSource sharedDataSource].localUser.blockedUsers containsObject:[NSNumber numberWithInteger:self.user.userId]])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"User blocked!", nil)
														message: NSLocalizedString(@"You have blocked this user, he won't be able to answer you. Are you sure you want to send him a message?", nil)
													   delegate: self
											  cancelButtonTitle: NSLocalizedString(@"No", nil)
											  otherButtonTitles: NSLocalizedString(@"Yes", nil), nil];
		[alert show];
    }
    else
        [self sendMessage];
    
}

- (void) sendMessage
{
    ChatViewController *chatViewController = [[ChatViewController alloc] init];
    
    LTChat *chat = nil;
    NSMutableArray *chats = [[LTDataSource sharedDataSource] chatList];
    
    for (LTChat *aCFChat in chats){
        if (aCFChat.userId == self.user.userId){
            chat = aCFChat;
            break;
        }
    }
    if(!chat) {
        chat = [LTChat newChat];
        [chat setUserId: self.user.userId];
        
        if (self.user.screenName!=nil)
            chat.userName = self.user.screenName;
        else
            chat.userName = self.user.name;
        
        chat.learningLang=self.user.activeLearningLan;
        chat.speakingLang=self.user.activeSpeakingLan;
        chat.learningFlag=self.user.activeLearningFlag;
        chat.speakingFlag=self.user.activeSpeakingFlag;
        [[[LTDataSource sharedDataSource] chatList] addObject: chat];
    }
    [chatViewController setUserId: [chat userId]];
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        [self.navigationController pushViewController:chatViewController animated:YES];
    else
    {
        [self.delegate pushController:chatViewController];
    }
}

- (void) locateButtonPressed
{
    if(![self.user userIsInMap]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Location unknown", @"Location unknown")
														message: [NSString stringWithFormat: NSLocalizedString(@"%@ did not make its location available to LextTalk yet.", @"%@ did not make its location available to LextTalk yet."),self.user.name]
													   delegate: nil
											  cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
											  otherButtonTitles: nil];
		[alert show];
		return;
	}
	
    LextTalkAppDelegate *del = (LextTalkAppDelegate*)[[UIApplication sharedApplication] delegate];
    [del goToUserAtLongitude: self.user.coordinate.longitude andLatitude: self.user.coordinate.latitude];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate pushController:nil];
}

- (void) blockButtonPressed
{
    //NSLog(@"Blocked users: %@, %d", [LTDataSource sharedDataSource].localUser.blockedUsers, self.user.userId);
    if ([LTDataSource sharedDataSource].localUser == nil) //not logged
    {
        LextTalkAppDelegate * del = (LextTalkAppDelegate *) [UIApplication sharedApplication].delegate;
        [del tellUserToSignIn];
        
        return;
    }
    
    if ([LTDataSource sharedDataSource].localUser.userId == self.user.userId)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"You cannot block your own user!", nil)
                                                         message:NSLocalizedString(@"You are trying to block yourself.", nil)
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                               otherButtonTitles: nil];
        [alert show];
        
        return;
    }
    
    NSString * message;
    if ([[LTDataSource sharedDataSource].localUser.blockedUsers containsObject:[NSNumber numberWithInteger:self.user.userId]])
    {
        [[LTDataSource sharedDataSource] blockUser:self.user.userId withBlockStatus:NO delegate:self];
        message = NSLocalizedString(@"Unblocking user...", nil);
    }
    else
    {
        [[LTDataSource sharedDataSource] blockUser:self.user.userId withBlockStatus:YES delegate:self];
        message = NSLocalizedString(@"Blocking user...", nil);
    }
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.labelText = message;
    [self.HUD show:YES];
}

- (void) selectLanguages:(UIButton *) button
{
    LanguageSelectorViewController * controller=[[LanguageSelectorViewController alloc] init];
    controller.delegate=self;
    
    controller.textArray=[LanguageReference availableLangsForAppLan:@"English"];
    controller.multiple=YES;
    controller.showFlags=NO;
    controller.preferredFlagForLan=nil;
    if (button==self.learningLangView.selectButton)
    {
        controller.textTag=@"Learning";
        controller.selectedItems=self.learningLangView.langs;
        controller.flagIndexForSelectedItems=self.learningLangView.flags;
    }
    else if (button==self.speakingLangView.selectButton)
    {
        controller.textTag=@"Speaking";
        controller.selectedItems=self.speakingLangView.langs;
        controller.flagIndexForSelectedItems=self.speakingLangView.flags;
    }
    else if (button==self.brandedLangView.selectButton)
    {
        controller.textTag=@"Branded";
        controller.selectedItems=self.brandedLangView.langs;
        controller.flagIndexForSelectedItems=self.brandedLangView.flags;
    }
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) selectPhoto
{
    /*
    UIImagePickerController * picker=[[[UIImagePickerController alloc] init] autorelease];
    picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing=YES;
    picker.delegate=self;
    
    picker.modalTransitionStyle=UIModalPresentationFullScreen;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        [self presentViewController:picker animated:YES completion:^(void) {}];
    else
    {
        self.myPopoverController=[[[UIPopoverController alloc] initWithContentViewController:picker] autorelease];
        self.myPopoverController.delegate=self;
        [self.myPopoverController presentPopoverFromRect:self.userImageShadow.frame inView:self.scrollView permittedArrowDirections:UIPopoverArrowDirectionAny  animated:YES];
    }
*/
    
    void (^completionBlock)(UIImage *img, NSDictionary *info, NSError *error);
    completionBlock = ^(UIImage *img, NSDictionary *info, NSError *error)
    {
        if (error==nil)
        {
            UIImage * imageFromPicker=[info objectForKey:UIImagePickerControllerEditedImage];
            if (imageFromPicker != nil)
            {
                //Reduction of the image. The button is 65x65, so the image should be 130x130 at least
                //It is possible that we might like to be able to show the image in fullscreen when tapping on the a photo, such as whatsapp does
                //So resize to 640x640
                UIImage * image = [GeneralHelper centralSquareFromImage:imageFromPicker];
                if (image.size.width*image.scale > 641.0)
                    image = [image resizedImage:CGSizeMake(640, 640) interpolationQuality:kCGInterpolationHigh];
                
                [self.userImageButton setBackgroundImage:image forState:UIControlStateNormal];
                [self.userImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
                [LTDataSource sharedDataSource].localUser.image=image;
            }
        }
    };
    
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        [IQImagePicker selectPictureFromView:self.userImageShadow presentingViewController:self source:IQImagePickerSourceAll fullScreen:YES withCompletion:completionBlock];
    else
        [IQImagePicker selectPictureFromView:self.userImageShadow presentingViewController:self source:IQImagePickerSourceAll fullScreen:NO withCompletion:completionBlock];
     
}

- (void) showPicture
{
    UIImage * image = [[LTDataSource sharedDataSource] imageFromCacheForUserId:self.user.userId];
    if (image!=nil)
    {
        ImageViewerViewController * controller = [[ImageViewerViewController alloc] init];
        controller.image = image;
        if (self.user.screenName!=nil)
            controller.title = self.user.screenName;
        else
            controller.title = self.user.name;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            controller.disableAds = YES;
            //self.navigationController.navigationBarHidden = NO;
        }
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void) resignAllFirstResponders
{
    [self.userTextView resignFirstResponder];
    [self.statusTextView resignFirstResponder];
}

//For branded apps
- (void) languageChanged:(UISegmentedControl *) seg
{
    NSString * str;
    if (seg.selectedSegmentIndex == 0)
    {
        str = NSLocalizedString(@"Speaking Languages", nil);
        [LTDataSource sharedDataSource].localUser.learningLanguages = [NSArray arrayWithObject:@"Catalan"];
        [LTDataSource sharedDataSource].localUser.learningLanguagesFlags = [NSArray arrayWithObject:[NSNumber numberWithInteger:0]];
        [LTDataSource sharedDataSource].localUser.activeLearningLan = @"Catalan";
        [LTDataSource sharedDataSource].localUser.activeLearningFlag = 0;
        [LTDataSource sharedDataSource].localUser.speakingLanguages = nil;
        [LTDataSource sharedDataSource].localUser.speakingLanguagesFlags = nil;
        [LTDataSource sharedDataSource].localUser.activeSpeakingLan = nil;
        [LTDataSource sharedDataSource].localUser.activeSpeakingFlag = 0;
        /*
        self.learningLang=@"Catalan";
        self.learningFlag=0;
        self.learningImageView.image = [IconGeneration bigIconForLearningLan:self.learningLang withFlag:self.learningFlag];
         */
    }
    else if (seg.selectedSegmentIndex == 1)
    {
        str = NSLocalizedString(@"Learning Languages", nil);
        [LTDataSource sharedDataSource].localUser.speakingLanguages = [NSArray arrayWithObject:@"Catalan"];
        [LTDataSource sharedDataSource].localUser.speakingLanguagesFlags = [NSArray arrayWithObject:[NSNumber numberWithInteger:0]];
        [LTDataSource sharedDataSource].localUser.activeSpeakingLan = @"Catalan";
        [LTDataSource sharedDataSource].localUser.activeSpeakingFlag = 0;
        [LTDataSource sharedDataSource].localUser.learningLanguages = nil;
        [LTDataSource sharedDataSource].localUser.learningLanguagesFlags = nil;
        [LTDataSource sharedDataSource].localUser.activeLearningLan = nil;
        [LTDataSource sharedDataSource].localUser.activeLearningFlag = 0;
        
        /*
        self.speakingLang=@"Catalan";
        self.speakingFlag=0;
        self.speakingImageView.image = [IconGeneration bigIconForSpeakingLan:self.speakingLang withFlag:self.speakingFlag];
         */
    }
    else
        str = nil;
    
    
    [UIView animateWithDuration:0.2 animations:^{
        self.secondLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        
        self.secondLabel.text = str;
        CGSize adjustedSize = [self.secondLabel.text sizeWithAttributes:@{NSFontAttributeName:self.secondLabel.font}];
        CGSize size = CGSizeMake(ceilf(adjustedSize.width), ceilf(adjustedSize.height));
        self.secondLabel.frame=CGRectMake(self.secondLabel.frame.origin.x, self.secondLabel.frame.origin.y, size.width, size.height);
        
        [UIView animateWithDuration:0.2 animations:^{
            self.secondLabel.alpha = 1.0;
            [self customizeForUser];
            
        } completion:^(BOOL finished) {
            
        }];
    }];
}


#pragma mark - UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==0)
    {
        if (buttonIndex==1)
            [self sendMessage];
    }
    else if (alertView.tag==1)
    {
        if (buttonIndex==1)
        {
            [[LTDataSource sharedDataSource] deleteLocalUserWithDelegate:self];
            
            self.HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.view];
            [self.view addSubview:self.HUD];
            self.HUD.mode = MBProgressHUDModeIndeterminate;
            self.HUD.labelText = NSLocalizedString(@"Deleting user...", nil);
            [self.HUD show:YES];
        }
    }
    else if ((buttonIndex==0) && (alertView.tag==404))
    {
        LextTalkAppDelegate * del = (LextTalkAppDelegate *) [[UIApplication sharedApplication] delegate];
        del.showingError = NO;
    }
}

#pragma mark - LanguageSelectorViewControllerDelegate

- (void) selectedItems:(NSArray *)selectedItems withFlags:(NSArray *)flags withTextTag:(NSString *)textTag
{
    if ([textTag isEqualToString:@"Learning"])
    {
        [self.learningLangView setLanguages:selectedItems withFlags:flags speaking:NO withButton:YES];
        if (![selectedItems containsObject:self.learningLang])
        {
            self.learningLang=[selectedItems lastObject];
            self.learningFlag=[[flags lastObject] integerValue];
        }
        self.learningImageView.image = [IconGeneration bigIconForLearningLan:self.learningLang withFlag:self.learningFlag];
    }
    else if ([textTag isEqualToString:@"Speaking"])
    {
        [self.speakingLangView setLanguages:selectedItems withFlags:flags speaking:YES withButton:YES];
        if (![selectedItems containsObject:self.speakingLang])
        {
            self.speakingLang=[selectedItems lastObject];
            self.speakingFlag=[[flags lastObject] integerValue];
        }
        self.speakingImageView.image = [IconGeneration bigIconForSpeakingLan:self.speakingLang withFlag:self.speakingFlag];
    }
    else if ([textTag isEqualToString:@"Branded"])
    {
        if (self.learnOrSpeakSeg.selectedSegmentIndex == 0)
        {
            [self.brandedLangView setLanguages:selectedItems withFlags:flags speaking:YES withButton:YES];
            if (![selectedItems containsObject:self.speakingLang])
            {
                self.speakingLang=[selectedItems lastObject];
                self.speakingFlag=[[flags lastObject] integerValue];
            }
            self.speakingImageView.image = [IconGeneration bigIconForSpeakingLan:self.speakingLang withFlag:self.speakingFlag];
        }
        else if (self.learnOrSpeakSeg.selectedSegmentIndex == 1)
        {
            [self.brandedLangView setLanguages:selectedItems withFlags:flags speaking:NO withButton:YES];
            if (![selectedItems containsObject:self.learningLang])
            {
                self.learningLang=[selectedItems lastObject];
                self.learningFlag=[[flags lastObject] integerValue];
            }
            self.learningImageView.image = [IconGeneration bigIconForLearningLan:self.learningLang withFlag:self.learningFlag];
        }
        
    }
    
    [self rotateToInterfaceOrientation:self.interfaceOrientation];
}

/*
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * imageFromPicker=[info objectForKey:UIImagePickerControllerEditedImage];
    [self.userImageButton setBackgroundImage:[GeneralHelper centralSquareFromImage:imageFromPicker] forState:UIControlStateNormal];
    [self.userImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [LTDataSource sharedDataSource].localUser.image=imageFromPicker;

    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}
 */

#pragma mark -
#pragma mark - LangView Delegate

- (void) langView:(LangView *)langView selectedLang:(NSString *)lang withFlag:(NSInteger)flag
{
    if (self.speakingLangView==langView)
    {
        self.speakingLang=lang;
        self.speakingFlag=flag;
        self.speakingImageView.image = [IconGeneration bigIconForSpeakingLan:lang withFlag:flag];
    }
    else if (self.learningLangView==langView)
    {
        self.learningLang=lang;
        self.learningFlag=flag;
        self.learningImageView.image = [IconGeneration bigIconForLearningLan:lang withFlag:flag];
    }
    else if (self.brandedLangView==langView)
    {
        if (self.learnOrSpeakSeg.selectedSegmentIndex == 0)
        {
            self.speakingLang=lang;
            self.speakingFlag=flag;
            self.speakingImageView.image = [IconGeneration bigIconForSpeakingLan:lang withFlag:flag];
        }
        else if (self.learnOrSpeakSeg.selectedSegmentIndex == 1)
        {
            self.learningLang=lang;
            self.learningFlag=flag;
            self.learningImageView.image = [IconGeneration bigIconForLearningLan:lang withFlag:flag];
        }
    }
}

#pragma mark -
#pragma mark UITextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return self.editingUser;
}

#pragma mark -
#pragma mark UITextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return self.editingUser;
}

#pragma mark -
#pragma mark Popover

- (CGSize) contentSizeForViewInPopover
{
    CGSize size=CGSizeMake(320, 375);
    return size;
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
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    
    CGFloat adHeight=[super layoutBanners:animated];
    
    CGRect buttonRect=self.buttonView.frame;
    buttonRect.origin.y=self.view.frame.size.height - adHeight - 35.0 - self.tabBarController.tabBar.frame.size.height;
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.buttonView.frame=buttonRect;
                     }];
    return 0.0;
}

@end
