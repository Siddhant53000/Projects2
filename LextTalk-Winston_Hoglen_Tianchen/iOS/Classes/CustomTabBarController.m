//
//  CustomTabBarController.m
//  LextTalk
//
//  Created by Yo on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomTabBarController.h"
#import "LTDataSource.h"
#import "LocalUserViewController.h"
#import "Flurry.h"
#import "SettingsTableViewController.h"

#define ICON_WIDTH   40.0
#define ICON_HEIGHT  40.0

@implementation CustomTabBarController
    @synthesize mapButton, chatButton, profileButton, translatorButton, chatRoomButton, settingsButton;
    
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
    {
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        if (self) {
            // Custom initialization
        }
        return self;
    }
    
- (void)didReceiveMemoryWarning
    {
        // Releases the view if it doesn't have a superview.
        [super didReceiveMemoryWarning];
        
        // Release any cached data, images, etc that aren't in use.
    }
    
#pragma mark - View lifecycle
    
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
        [Flurry logAllPageViewsForTarget:self];
        
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
- (void)dealloc {
    self.mapButton=nil;
    self.chatButton=nil;
    self.profileButton=nil;
    self.translatorButton=nil;
    self.chatRoomButton=nil;
    self.settingsButton = nil;
}
    
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
    {
        // Return YES for supported orientations
        //return (interfaceOrientation == UIInterfaceOrientationPortrait);
        return YES;
    }
    
    
- (void) rotateToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation
{
    CGFloat width=self.view.bounds.size.width;
    CGFloat height=self.view.bounds.size.height;
    
    // winstojl: changed 5 to 4 below
    CGFloat space=width/4;//I have 5 buttons
    
    self.mapButton.frame  = CGRectMake(space * 0 + (space - ICON_WIDTH)/2, height-45, ICON_WIDTH, ICON_HEIGHT);
    self.chatButton.frame = CGRectMake(space * 1 + (space - ICON_WIDTH)/2, height-45, ICON_WIDTH, ICON_HEIGHT);
    self.chatRoomButton.frame = CGRectMake(space * 2 + (space - ICON_WIDTH)/2, height-45, ICON_WIDTH, ICON_HEIGHT);
    self.profileButton.frame = CGRectMake(space * 3 + (space - ICON_WIDTH)/2, height-45, ICON_WIDTH, ICON_HEIGHT);
    self.translatorButton.frame = CGRectMake(space * 3 + (space - ICON_WIDTH)/2, height-45, ICON_WIDTH, ICON_HEIGHT);
}
 


/*
    {
        CGFloat width=self.view.bounds.size.width;
        CGFloat height=self.view.bounds.size.height;
        CGFloat space=width/6;//I have 5 buttons
        
        self.mapButton.frame  = CGRectMake(space * 0 + (space - ICON_WIDTH)/2, height-50, ICON_WIDTH, ICON_HEIGHT);
        self.chatButton.frame = CGRectMake(space * 1 + (space - ICON_WIDTH)/2, height-50, ICON_WIDTH, ICON_HEIGHT);
        self.chatRoomButton.frame = CGRectMake(space * 2 + (space - ICON_WIDTH)/2, height-50, ICON_WIDTH, ICON_HEIGHT);
        self.profileButton.frame = CGRectMake(space * 3 + (space - ICON_WIDTH)/2, height-50, ICON_WIDTH, ICON_HEIGHT);
        self.translatorButton.frame = CGRectMake(space * 4 + (space - ICON_WIDTH)/2, height-50, ICON_WIDTH, ICON_HEIGHT);
 
    }*/
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
    
    
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!notFirstTime)
    {
        notFirstTime=YES;
        
        [self hideExistingTabBar];
        [self addCustomElements];
        
        [self selectTab:0];
    }
    
    [self rotateToInterfaceOrientation:self.interfaceOrientation];
    
    //Prueba badges
    /*
     [self setBadgeValue:@"3" atPosition:0];
     [self setBadgeValue:@"28" atPosition:1];
     [self setBadgeValue:@"new" atPosition:2];
     [self setBadgeValue:@"1" atPosition:3];
     [self removeAllBadges];
     */
}
    
- (void) viewDidAppear:(BOOL)animated
    {
        [super viewDidAppear:animated];
        
        [self rotateToInterfaceOrientation:self.interfaceOrientation];
    }
    
    
#pragma mark - CustomTabBar methods
    
- (void)hideExistingTabBar
    {
        for(UIView *view in self.view.subviews)
        {
            if([view isKindOfClass:[UITabBar class]])
            {
                view.hidden = YES;
                break;
            }
        }
    }
    
-(void)addCustomElements
{
    CGFloat width=self.view.bounds.size.width;
    CGFloat height=self.view.bounds.size.height;
    
    //Bar background
    UIImage * backgroungImage=[UIImage imageNamed:@"Bar"];
    UIImageView * imageView=[[UIImageView alloc] initWithImage:backgroungImage];
    imageView.frame=CGRectMake(0, height-50, width, 50);
    imageView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:imageView];
    
	// Icons
	UIImage *btnImage, * btnImageSelected;
    
    
    // Winstojl: Changing it from 5 to 4 (denominator)
    CGFloat space=width/4;//I have 5 buttons
    
	btnImage = [UIImage imageNamed:@"map-icon-new-unselected"];
	btnImageSelected = [UIImage imageNamed:@"map-icon-new-selected"];
	self.mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.mapButton.frame = CGRectMake(space * 0 + (space - ICON_WIDTH)/2, height-50, ICON_WIDTH, ICON_HEIGHT);
	[self.mapButton setBackgroundImage:btnImage forState:UIControlStateNormal];
	[self.mapButton setBackgroundImage:btnImageSelected forState:UIControlStateSelected];
	[self.mapButton setTag:0];
    //self.mapButton.autoresizingMask= UIViewAutoresizingFlexibleTopMargin;
    
    // Now we repeat the process for the other buttons
	btnImage = [UIImage imageNamed:@"chat-icon-new-unselected"];
	btnImageSelected = [UIImage imageNamed:@"chat-icon-new-selected"];
	self.chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.chatButton.frame = CGRectMake(space * 1 + (space - ICON_WIDTH)/2, height-50, ICON_WIDTH, ICON_HEIGHT);
	[self.chatButton setBackgroundImage:btnImage forState:UIControlStateNormal];
	[self.chatButton setBackgroundImage:btnImageSelected forState:UIControlStateSelected];
	[self.chatButton setTag:1];
    //self.chatButton.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    btnImage = [UIImage imageNamed:@"profile-icon-new-unselected"];
	btnImageSelected = [UIImage imageNamed:@"profile-icon-new-selected"];
	self.chatRoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.chatRoomButton.frame = CGRectMake(space * 2 + (space - ICON_WIDTH)/2, height-50, ICON_WIDTH, ICON_HEIGHT);
	[self.chatRoomButton setBackgroundImage:btnImage forState:UIControlStateNormal];
	[self.chatRoomButton setBackgroundImage:btnImageSelected forState:UIControlStateSelected];
	[self.chatRoomButton setTag:2];
    //self.chatRoomButton.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
	/*btnImage = [UIImage imageNamed:@"ProfileIcon"];
	btnImageSelected = [UIImage imageNamed:@"ProfileIconSelected"];
	self.profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.profileButton.frame = CGRectMake(space * 3 + (space - ICON_WIDTH)/2, height-50, ICON_WIDTH, ICON_HEIGHT);
	[self.profileButton setBackgroundImage:btnImage forState:UIControlStateNormal];
	[self.profileButton setBackgroundImage:btnImageSelected forState:UIControlStateSelected];
	[self.profileButton setTag:3];
    //self.profileButton.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
     Winstojl: removed buttons for transitioned key experiences*/
    
	btnImage = [UIImage imageNamed:@"translate-icon-new-unselected"];
	btnImageSelected = [UIImage imageNamed:@"translate-icon-new-selected"];
	self.translatorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.translatorButton.frame = CGRectMake(space * 3 + (space - ICON_WIDTH)/2, height-50, ICON_WIDTH, ICON_HEIGHT);
	[self.translatorButton setBackgroundImage:btnImage forState:UIControlStateNormal];
	[self.translatorButton setBackgroundImage:btnImageSelected forState:UIControlStateSelected];
	[self.translatorButton setTag:3];
    //self.translatorButton.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    /*btnImage = [UIImage imageNamed:@"SettingsIconLT"];
    btnImageSelected = [UIImage imageNamed:@"TranslatorIconSelected"];
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.settingsButton.frame = CGRectMake(space * 5 + (space - ICON_WIDTH)/2, height-50, ICON_WIDTH, ICON_HEIGHT);
    [self.settingsButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [self.settingsButton setBackgroundImage:btnImageSelected forState:UIControlStateSelected];
    [self.settingsButton setTag:5];*/

    
    // Setup event handlers so that the buttonClicked method will respond to the touch up inside event.
	[self.mapButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[self.chatButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[self.profileButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[self.translatorButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.chatRoomButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // Add my new buttons to the view
	[self.view addSubview:self.mapButton];
	[self.view addSubview:self.chatButton];
    [self.view addSubview:self.chatRoomButton];
	[self.view addSubview:self.profileButton];
	[self.view addSubview:self.translatorButton];
}

/*
    {
        CGFloat width=self.view.bounds.size.width;
        CGFloat height=self.view.bounds.size.height;
        
        //Bar background
        UIImage * backgroungImage=[UIImage imageNamed:@"BarImage"];
        UIImageView * imageView=[[UIImageView alloc] initWithImage:backgroungImage];
        imageView.frame=CGRectMake(0, height-50, width, 50);
        imageView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:imageView];
        
        // Icons
        UIImage *btnImage, * btnImageSelected;
        
        
        CGFloat space=width/5;//I have 5 buttons
        
        btnImage = [UIImage imageNamed:@"MapIcon"];
        btnImageSelected = [UIImage imageNamed:@"MapIconSelected"];
        self.mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.mapButton.frame = CGRectMake(space * 0 + (space - ICON_WIDTH)/2, height-50, ICON_WIDTH, ICON_HEIGHT);
        [self.mapButton setBackgroundImage:btnImage forState:UIControlStateNormal];
        [self.mapButton setBackgroundImage:btnImageSelected forState:UIControlStateSelected];
        [self.mapButton setTag:0];
        //self.mapButton.autoresizingMask= UIViewAutoresizingFlexibleTopMargin;
        
        // Now we repeat the process for the other buttons
        btnImage = [UIImage imageNamed:@"ChatIcon"];
        btnImageSelected = [UIImage imageNamed:@"ChatIconSelected"];
        self.chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.chatButton.frame = CGRectMake(space * 1 + (space - ICON_WIDTH)/2, height-50, ICON_WIDTH, ICON_HEIGHT);
        [self.chatButton setBackgroundImage:btnImage forState:UIControlStateNormal];
        [self.chatButton setBackgroundImage:btnImageSelected forState:UIControlStateSelected];
        [self.chatButton setTag:1];
        //self.chatButton.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        
        btnImage = [UIImage imageNamed:@"ContactIcon"];
        btnImageSelected = [UIImage imageNamed:@"ContactIconSelected"];
        self.chatRoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.chatRoomButton.frame = CGRectMake(space * 2 + (space - ICON_WIDTH)/2, height-50, ICON_WIDTH, ICON_HEIGHT);
        [self.chatRoomButton setBackgroundImage:btnImage forState:UIControlStateNormal];
        [self.chatRoomButton setBackgroundImage:btnImageSelected forState:UIControlStateSelected];
        [self.chatRoomButton setTag:2];
        //self.chatRoomButton.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        
        btnImage = [UIImage imageNamed:@"ProfileIcon"];
        btnImageSelected = [UIImage imageNamed:@"ProfileIconSelected"];
        self.profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.profileButton.frame = CGRectMake(space * 3 + (space - ICON_WIDTH)/2, height-50, ICON_WIDTH, ICON_HEIGHT);
        [self.profileButton setBackgroundImage:btnImage forState:UIControlStateNormal];
        [self.profileButton setBackgroundImage:btnImageSelected forState:UIControlStateSelected];
        [self.profileButton setTag:3];
        //self.profileButton.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        
        btnImage = [UIImage imageNamed:@"TranslatorIcon"];
        btnImageSelected = [UIImage imageNamed:@"TranslatorIconSelected"];
        self.translatorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.translatorButton.frame = CGRectMake(space * 4 + (space - ICON_WIDTH)/2, height-50, ICON_WIDTH, ICON_HEIGHT);
        [self.translatorButton setBackgroundImage:btnImage forState:UIControlStateNormal];
        [self.translatorButton setBackgroundImage:btnImageSelected forState:UIControlStateSelected];
        [self.translatorButton setTag:4];
        //self.translatorButton.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
 
        
        // Setup event handlers so that the buttonClicked method will respond to the touch up inside event.
        [self.mapButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.chatButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.profileButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.translatorButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.chatRoomButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.settingsButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        // Add my new buttons to the view
        [self.view addSubview:self.mapButton];
        [self.view addSubview:self.chatButton];
        [self.view addSubview:self.chatRoomButton];
        [self.view addSubview:self.profileButton];
        [self.view addSubview:self.translatorButton];
        [self.view addSubview:self.settingsButton];
    }*/
- (void)selectTab:(NSInteger)tabID
    {
        switch(tabID)
        {
            case 0:
            [self.mapButton setSelected:true];
            [self.chatButton setSelected:false];
            [self.chatRoomButton setSelected:false];
            [self.profileButton setSelected:false];
            [self.translatorButton setSelected:false];
            [self.settingsButton setSelected:false];
            break;
            case 1:
            [self.mapButton setSelected:false];
            [self.chatButton setSelected:true];
            [self.chatRoomButton setSelected:false];
            [self.profileButton setSelected:false];
            [self.translatorButton setSelected:false];
            [self.settingsButton setSelected:false];
            break;
            case 2:
            [self.mapButton setSelected:false];
            [self.chatButton setSelected:false];
            [self.chatRoomButton setSelected:true];
            //[self.profileButton setSelected:false]; // Winstojl,11/2
            [self.profileButton setSelected:true]; // Winstojl,11/2
            [self.translatorButton setSelected:false];
            //[self.settingsButton setSelected:false];  // Winstojl,11/2
            break;
            case 3:
            [self.mapButton setSelected:false];
            [self.chatButton setSelected:false];
            [self.chatRoomButton setSelected:false];
            [self.profileButton setSelected:false];
            [self.translatorButton setSelected:true];
            break;
    }	
    
    //Changing a button can hide the imageViews with badge
    UIView * view=[self.mapButton viewWithTag:111];
    if (view!=nil) [self.mapButton bringSubviewToFront:view];
    view=[self.mapButton viewWithTag:222];
    if (view!=nil) [self.mapButton bringSubviewToFront:view];
    
    view=[self.chatButton viewWithTag:111];
    if (view!=nil) [self.chatButton bringSubviewToFront:view];
    view=[self.chatButton viewWithTag:222];
    if (view!=nil) [self.chatButton bringSubviewToFront:view];
    
    view=[self.chatRoomButton viewWithTag:111];
    if (view!=nil) [self.chatRoomButton bringSubviewToFront:view];
    view=[self.chatRoomButton viewWithTag:222];
    if (view!=nil) [self.chatRoomButton bringSubviewToFront:view];
    
    view=[self.profileButton viewWithTag:111];
    if (view!=nil) [self.profileButton bringSubviewToFront:view];
    view=[self.profileButton viewWithTag:222];
    if (view!=nil) [self.profileButton bringSubviewToFront:view];
    
    view=[self.translatorButton viewWithTag:111];
    if (view!=nil) [self.translatorButton bringSubviewToFront:view];
    view=[self.translatorButton viewWithTag:222];
    if (view!=nil) [self.translatorButton bringSubviewToFront:view];
    
    if (self.selectedIndex == tabID)
    {
        UINavigationController *navController = (UINavigationController *)[self selectedViewController];

            if (tabID == 3)//Login controller
            {
                if ([LTDataSource sharedDataSource].localUser != nil)//User is logged in
                {
                    for (UIViewController * controller in navController.viewControllers)
                    {
                        if ([controller isMemberOfClass:[LocalUserViewController class]])
                        {
                            if (navController.topViewController != controller)
                            [navController popToViewController:controller animated:YES];
                            break;
                        }
                    }
                }
            }
            else
            [navController popToRootViewControllerAnimated:YES];
        }
        else
        {
            self.selectedIndex = tabID;
        }
        
        
        //self.selectedIndex = tabID;
        
    }


- (void)buttonClicked:(id)sender
    {
        NSInteger tagNum = [sender tag];
        [self selectTab:tagNum];
    }
    
-(void) setBadgeValue:(NSString *) str atPosition:(NSInteger) position
    {
        [self removeBadgeAtPosition:position];
        //NSLog(@"setBadgeValue: \"%@\" at position: %d", str, position);
        
        //CGRect buttonFrame = CGRectMake(space * position + (space - ICON_WIDTH)/2, height-50, ICON_WIDTH, ICON_HEIGHT);
        CGRect badgeRect;
        //I adapt it to the
        
        UIImage * badgeImage=[UIImage imageNamed:@"Badge"];
        badgeImage = [badgeImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8.5, 0, 9.5)];
        
        UIFont * font=[UIFont systemFontOfSize:12];
        CGSize constraintSize = CGSizeMake(50, 12);
        
        CGRect textRect = [str boundingRectWithSize:constraintSize
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:font}
                                            context:nil];
        CGSize labelSize = textRect.size;
        CGFloat stretch=labelSize.width;
        if (stretch<=9)
        stretch=0;
        else
        stretch=stretch-10;
        
        
        badgeRect.origin.x=ICON_WIDTH - 18 - stretch;
        badgeRect.origin.y=2;
        badgeRect.size.width = 18 + stretch;
        badgeRect.size.height = 18;
        
        UILabel * label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = font;
        label.text = str;
        label.frame = CGRectMake((badgeRect.size.width - labelSize.width)/2.0, (badgeRect.size.height - labelSize.height)/2.0 -0.5, labelSize.width, labelSize.height);
        label.tag = 222;
        
        
        UIImageView * imageView=[[UIImageView alloc] initWithImage:badgeImage];
        imageView.frame=badgeRect;
        imageView.tag=111;
        
        [imageView addSubview:label];
        
        
        switch (position)
        {
            case 0:
            [self.mapButton addSubview:imageView];
            [self.mapButton bringSubviewToFront:imageView];
            break;
            case 1:
            [self.chatButton addSubview:imageView];
            [self.chatButton bringSubviewToFront:imageView];
            break;
        /*case 2:
=======
            case 2:
>>>>>>> CSCI401_Hoglen_Dev
            [self.chatRoomButton addSubview:imageView];
            [self.chatRoomButton bringSubviewToFront:imageView];
            break;
            case 3:
            [self.profileButton addSubview:imageView];
            [self.profileButton bringSubviewToFront:imageView];
            break;
            case 4:
            [self.translatorButton addSubview:imageView];
            [self.translatorButton bringSubviewToFront:imageView];
<<<<<<< HEAD
            break;*/
/*=======
            break;
            case 5:
            [self.settingsButton addSubview:imageView];
            [self.settingsButton bringSubviewToFront:imageView];
            break;
        }
        
>>>>>>> CSCI401_Hoglen_Dev*/
    }
    }

-(void) setSecondBadgeAtPosition:(NSInteger) position
    {
        [self removeSecondBadgeAtPosition:position];
        
        //CGRect buttonFrame = CGRectMake(space * position + (space - ICON_WIDTH)/2, height-50, ICON_WIDTH, ICON_HEIGHT);
        CGRect badgeRect;
        //I adapt it to the
        
        UIImage * badgeImage=[UIImage imageNamed:@"BadgeBlue"];
        badgeRect.origin.x=ICON_WIDTH - 18;
        badgeRect.origin.y=50 - 18 - 2;
        badgeRect.size.width = 18;
        badgeRect.size.height = 18;
        
        UIImageView * imageView=[[UIImageView alloc] initWithImage:badgeImage];
        imageView.frame=badgeRect;
        imageView.tag=333;
        
        switch (position)
        {
            case 0:
            [self.mapButton addSubview:imageView];
            [self.mapButton bringSubviewToFront:imageView];
            break;
            case 1:
            [self.chatButton addSubview:imageView];
            [self.chatButton bringSubviewToFront:imageView];
            break;
            case 2:
            [self.chatRoomButton addSubview:imageView];
            [self.chatRoomButton bringSubviewToFront:imageView];
            break;
            case 3:
            [self.profileButton addSubview:imageView];
            [self.profileButton bringSubviewToFront:imageView];
            break;
            case 4:
            [self.translatorButton addSubview:imageView];
            [self.translatorButton bringSubviewToFront:imageView];
            break;
            case 5:
            [self.settingsButton addSubview:imageView];
            [self.settingsButton bringSubviewToFront:imageView];
            break;
        }
    }
    
- (void) removeAllBadges
    {
        [self removeBadgeAtPosition:0];
        [self removeBadgeAtPosition:1];
        [self removeBadgeAtPosition:2];
        [self removeBadgeAtPosition:3];
        [self removeBadgeAtPosition:4];
        [self removeBadgeAtPosition:5];
    }
    
- (void) removeAllSecondBadges
    {
        [self removeSecondBadgeAtPosition:0];
        [self removeSecondBadgeAtPosition:1];
        [self removeSecondBadgeAtPosition:2];
        [self removeSecondBadgeAtPosition:3];
        [self removeSecondBadgeAtPosition:4];
        [self removeSecondBadgeAtPosition:5];
    }
    
-(void) removeBadgeAtPosition:(NSInteger) pos
    {
        //NSLog(@"remoremoveBadgeAtPosition: %d", pos);
        
        if (pos==0)
        {
            UIView * view=[self.mapButton viewWithTag:111];
            [view removeFromSuperview];
            view=[self.mapButton viewWithTag:222];
            [view removeFromSuperview];
        }
        else if (pos==1)
        {
            UIView * view=[self.chatButton viewWithTag:111];
            [view removeFromSuperview];
            view=[self.chatButton viewWithTag:222];
            [view removeFromSuperview];
        }
        else if (pos==2)
        {
            UIView * view=[self.chatRoomButton viewWithTag:111];
            [view removeFromSuperview];
            view=[self.chatRoomButton viewWithTag:222];
            [view removeFromSuperview];
        }
        else if (pos==3)
        {
            UIView * view=[self.profileButton viewWithTag:111];
            [view removeFromSuperview];
            view=[self.profileButton viewWithTag:222];
            [view removeFromSuperview];
        }
        else if (pos==4)
        {
            UIView * view=[self.translatorButton viewWithTag:111];
            [view removeFromSuperview];
            view=[self.translatorButton viewWithTag:222];
            [view removeFromSuperview];
        }
        else if (pos == 5) {
            UIView * view = [self.settingsButton viewWithTag:111];
            [view removeFromSuperview];
            view=[self.settingsButton viewWithTag:222];
            [view removeFromSuperview];
        }
    }
    
-(void) removeSecondBadgeAtPosition:(NSInteger) pos
    {
        //NSLog(@"remoremoveBadgeAtPosition: %d", pos);
        
        if (pos==0)
        {
            UIView * view=[self.mapButton viewWithTag:333];
            [view removeFromSuperview];
        }
        else if (pos==1)
        {
            UIView * view=[self.chatButton viewWithTag:333];
            [view removeFromSuperview];
        }
        else if (pos==2)
        {
            UIView * view=[self.chatRoomButton viewWithTag:333];
            [view removeFromSuperview];
        }
        else if (pos==3)
        {
            UIView * view=[self.profileButton viewWithTag:333];
            [view removeFromSuperview];
        }
        else if (pos==4)
        {
            UIView * view=[self.translatorButton viewWithTag:333];
            [view removeFromSuperview];
        }
        else if (pos==5){
            UIView * view = [self.settingsButton viewWithTag:333];
            [view removeFromSuperview];
        }
    }
    
    @end
