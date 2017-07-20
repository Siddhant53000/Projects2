//
//  SearchViewController.m
// LextTalk
//
//  Created by nacho on 12/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "LanguageReference.h"
#import "UserListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ColorFromImage.h"
#import "GeneralHelper.h"

@interface SearchViewController ()


@end

@implementation SearchViewController
@synthesize speakingTable, learningTable, nameLabel, nameTextField, searchButton, textLabel;
@synthesize learningLan, speakingLan;
@synthesize learningController, speakingController;
@synthesize speakingLabel, learningLabel, learningBackgroundView, speakingBackgroundView;
@synthesize searchTypeControl, searchTypeBackgroundView;
@synthesize region;


#pragma mark -
#pragma mark IQLocalizableProtocol methods

- (void) localize {
    self.textLabel.text = NSLocalizedString(@"Use at least one of the search options in order to look for for other users", nil);
}

#pragma mark -
#pragma mark GFDataDelegate methods

- (void) didUpdateSearchResultsUsers: (NSArray*) results {
	//[indicatorView stopAnimating];
    //IQVerbose(VERBOSE_DEBUG,@"result is %@", [results class]);
    //[self setSearchResults: results];
    [HUD hide:YES];
    
    //iPhone xib is enough, it is the same as the iPad one but for the size, and it is resized when loaded
    UserListViewController *userList = [[UserListViewController alloc] init];
	
	[userList setObjects: results];
	[userList setTitle: NSLocalizedString(@"Search Result", @"Search Result")];
	[self.navigationController pushViewController: userList animated: YES];
	//[self setChild: userList];
}

- (void) didFail:(NSDictionary *)result {
	//[indicatorView stopAnimating];
	
	// handle error
	[HUD hide:YES];
	
    // handle error
	if(result == nil) return;
	
    //	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"LextTalk server error", @"LextTalk server error")
    //													message: [result objectForKey: @"message"]
    //												   delegate: self
    //										  cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
    //										  otherButtonTitles: nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: [result objectForKey: @"error_title"]
													message: [result objectForKey: @"error_message"]
												   delegate: self
										  cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
										  otherButtonTitles: nil];
    
	[alert show];
}





#pragma mark -
#pragma mark UIViewController methods
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    
    //Tables
    self.learningTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.speakingTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.learningTable];
    [self.view addSubview:self.speakingTable];
    self.learningTable.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    self.speakingTable.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    NSArray * array;
    if (self.learningLan==nil)
        array=nil;
    else
        array=[NSArray arrayWithObject:self.learningLan];
    self.learningController=
    [[LanguageSelectorController alloc] initWithSingleSelectionTableView:self.learningTable
                                                                textArray:[LanguageReference availableLangsForAppLan:@"English"]
                                                            selectedItems:array
                                                      preferredFlagForLan:[[[LTDataSource sharedDataSource] localUser] preferredFlagForLangs]
                                                                showFlags:YES
                                                                  textTag:@"Learning"
                                                                 delegate:self];
    if (self.speakingLan==nil)
        array=nil;
    else
        array=[NSArray arrayWithObject:self.speakingLan];
    self.speakingController=
    [[LanguageSelectorController alloc] initWithSingleSelectionTableView:self.speakingTable
                                                                textArray:[LanguageReference availableLangsForAppLan:@"English"]
                                                            selectedItems:array
                                                      preferredFlagForLan:[[[LTDataSource sharedDataSource] localUser] preferredFlagForLangs]
                                                                showFlags:YES
                                                                  textTag:@"Speaking"
                                                                 delegate:self];
    //Button
    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.searchButton.titleLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:16];
    self.searchButton.titleLabel.textColor = [UIColor whiteColor];
    [self.searchButton setTitle:NSLocalizedString(@"Search", nil) forState:UIControlStateNormal];
    self.searchButton.backgroundColor = [UIColor colorFromImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]];
    self.searchButton.frame = CGRectMake(240, 65, 70, 30);
    [self.searchButton addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    
    self.searchButton.layer.shadowColor=[[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
    self.searchButton.layer.shadowOpacity = 1.0;
    self.searchButton.layer.shadowRadius = 2;
    self.searchButton.layer.shadowOffset = CGSizeMake(0, 2);
    self.searchButton.clipsToBounds=NO;
    [self.view addSubview:self.searchButton];
    
    //nameTextField
    self.nameTextField = [[UITextField alloc] init];
    self.nameTextField.delegate=self;
    self.nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.nameTextField.background = [UIColor whiteColor];
    self.nameTextField.font = [UIFont fontWithName:@"Ubuntu-Bold" size:16];
    [self.view addSubview:self.nameTextField];
    
    //nameLabel
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textColor=[UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
    self.nameLabel.text=NSLocalizedString(@"Name", @"Name");
    self.nameLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:16];
    [self.view addSubview:self.nameLabel];
    
    //textLabel
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.font = [UIFont fontWithName:@"Ubuntu-Light" size:14];
    self.textLabel.textColor=[UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
    self.textLabel.numberOfLines = 0;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.textLabel];
    
    //learning & speaking background
    self.learningBackgroundView = [[UIView alloc] init];
    self.speakingBackgroundView = [[UIView alloc] init];
    self.learningBackgroundView.backgroundColor = [UIColor colorFromImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]];
    self.speakingBackgroundView.backgroundColor = [UIColor colorFromImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]];
    [self.view addSubview:self.learningBackgroundView];
    [self.view addSubview:self.speakingBackgroundView];
    
    //learning & speaking Labels
    self.learningLabel = [[UILabel alloc] init];
    self.speakingLabel = [[UILabel alloc] init];
    self.learningLabel.text=NSLocalizedString(@"Learning", @"Learning");
    self.speakingLabel.text=NSLocalizedString(@"Native", @"Native");
    self.learningLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:16];
    self.speakingLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:16];
    self.speakingLabel.backgroundColor=[UIColor clearColor];
    self.learningLabel.backgroundColor=[UIColor clearColor];
    self.learningLabel.textColor = [UIColor whiteColor];
    self.speakingLabel.textColor = [UIColor whiteColor];
    self.learningLabel.textAlignment = NSTextAlignmentCenter;
    self.speakingLabel.textAlignment = NSTextAlignmentCenter;
    [self.learningBackgroundView addSubview:self.learningLabel];
    [self.speakingBackgroundView addSubview:self.speakingLabel];
    
    //Search
    self.searchTypeBackgroundView = [[UIView alloc] init];
    self.searchTypeBackgroundView.backgroundColor = [UIColor colorFromImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]];
    [self.view addSubview:self.searchTypeBackgroundView];
    
    self.searchTypeControl = [[UISegmentedControl alloc] init];
    [self.searchTypeControl removeAllSegments];
    [self.searchTypeControl insertSegmentWithTitle: NSLocalizedString(@"Whole world", @"Whole world") atIndex: 0 animated: NO];
    [self.searchTypeControl insertSegmentWithTitle: NSLocalizedString(@"Just the map", @"Just the map") atIndex:1 animated:NO];
    

    self.searchTypeControl.tintColor=[UIColor whiteColor];
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIFont fontWithName:@"Ubuntu-Bold" size:12], NSFontAttributeName,
                          [UIColor grayColor], NSForegroundColorAttributeName,
                          shadow, NSShadowAttributeName, nil];
    
    [self.searchTypeControl setTitleTextAttributes:dic forState:UIControlStateSelected];
    [self.searchTypeControl setTitleTextAttributes:dic forState:UIControlStateHighlighted];
    [self.searchTypeControl setTitleTextAttributes:dic forState:UIControlStateNormal];
    [self.searchTypeControl setTitleTextAttributes:dic forState:UIControlStateDisabled];

    self.searchTypeControl.selectedSegmentIndex=0;
    [self.view addSubview:self.searchTypeControl];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	[self localize];

    self.navigationItem.leftBarButtonItem = [GeneralHelper plainBarButtonItemWithText:nil image:[UIImage imageNamed:@"arrow-back"] target:self selector:@selector(popViewController)];
}

- (void) popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

- (void) rotateToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation
{
    CGSize size = self.view.bounds.size;
    
    CGFloat statusBarY = 20.0;
    if ([self prefersStatusBarHidden])
        statusBarY = 0.0;
    BOOL navigationBarHidden = self.navigationController.navigationBarHidden;
    CGFloat extraY = (navigationBarHidden ? statusBarY : (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height));
    
    self.searchTypeControl.frame=CGRectMake(10, extraY + 5, size.width - 20, 30);
    self.searchTypeBackgroundView.frame=CGRectMake(0, extraY + 0, size.width, 40);
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        if (toInterfaceOrientation==UIInterfaceOrientationPortrait || toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
        {
            self.textLabel.frame=CGRectMake(10, extraY + 45, size.width - 20, 52);
            
            self.nameLabel.frame=CGRectMake(10, extraY + 105, 70, 20);
            self.nameTextField.frame=CGRectMake(90, extraY + 100, size.width - 90 - 90, 30);
            self.searchButton.frame=CGRectMake(size.width - 80, extraY + 100, 70, 30);
            
            self.learningBackgroundView.frame=CGRectMake(0, extraY + 140, size.width/2.0, 20);
            self.speakingBackgroundView.frame=CGRectMake(size.width/2.0, extraY + 140, size.width/2.0, 20);
            
            self.learningTable.frame=CGRectMake(0, extraY + 160, size.width/2.0, size.height - 160.0 - extraY);
            self.speakingTable.frame=CGRectMake(size.width/2.0, extraY + 160, size.width/2.0, size.height - 160.0 - extraY);
        }
        else 
        {
            self.textLabel.frame=CGRectMake(5, extraY + 40, size.width - 10, 26);
            
            self.nameLabel.frame=CGRectMake(10, extraY + 75, 70, 20);
            self.nameTextField.frame=CGRectMake(90, extraY + 70, size.width - 90 - 90, 30);
            self.searchButton.frame=CGRectMake(size.width - 80, extraY + 70, 70, 30);
            
            self.learningBackgroundView.frame=CGRectMake(0, extraY + 105, size.width/2.0, 20);
            self.speakingBackgroundView.frame=CGRectMake(size.width/2.0, extraY + 105, size.width/2.0, 20);
            
            self.learningTable.frame=CGRectMake(0, extraY + 125, size.width/2.0, size.height - 160.0 - extraY);
            self.speakingTable.frame=CGRectMake(size.width/2.0, extraY + 125, size.width/2.0, size.height - 160.0 - extraY);
        }
    }
    else
    {
        self.textLabel.frame=CGRectMake(20, extraY + 55, size.width - 40, 52);
        
        self.nameLabel.frame=CGRectMake(20, extraY + 125, 70, 20);
        self.nameTextField.frame=CGRectMake(100, extraY + 120, size.width - 100 - 100 - 10, 30);
        self.searchButton.frame=CGRectMake(size.width - 90, extraY + 120, 70, 30);
        
        self.learningBackgroundView.frame=CGRectMake(0, extraY + 170, size.width/2.0, 30);
        self.speakingBackgroundView.frame=CGRectMake(size.width/2.0, extraY + 170, size.width/2.0, 30);
        
        self.learningTable.frame=CGRectMake(0, extraY + 200, size.width/2.0, size.height - 160.0 -extraY);
        self.speakingTable.frame=CGRectMake(size.width/2.0, extraY + 200, size.width/2.0, size.height - 160.0 - extraY);
    }
    
    self.learningLabel.frame=self.learningBackgroundView.bounds;
    self.speakingLabel.frame=self.learningBackgroundView.bounds;
}

//Rotate methods
// parent implementation of willAnimateRotationToInterfaceOrientation is OK, since layoutbanners calls rotateToInterfaceOrientation
//viewWillTransitionToSize just calls layoutBanners, rotateToInterfaceOrientation is called there, no reason to call super

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    //[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    UIInterfaceOrientation interfaceOrientation = UIInterfaceOrientationPortrait;
    if (size.width > size.height)
        interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
    
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

- (void) viewWillAppear:(BOOL)animated {
    [self setTitle: NSLocalizedString(@"Search", @"Search")];
	[self.navigationController setNavigationBarHidden: NO animated: NO];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.learningTable=nil;
    self.speakingTable=nil;
    self.nameTextField=nil;
    self.nameLabel=nil;
    self.textLabel=nil;
    self.searchButton=nil;
    self.speakingLabel=nil;
    self.learningLabel=nil;
    self.learningBackgroundView=nil;
    self.speakingBackgroundView=nil;
    self.searchTypeControl=nil;
    self.searchTypeBackgroundView=nil;
}


- (void)dealloc {
	[[LTDataSource sharedDataSource] removeFromRequestDelegates: self];	
    self.learningTable=nil;
    self.speakingTable=nil;
    self.nameTextField=nil;
    self.nameLabel=nil;
    self.textLabel=nil;
    self.searchButton=nil;
    self.speakingLabel=nil;
    self.learningLabel=nil;
    self.learningBackgroundView=nil;
    self.speakingBackgroundView=nil;
    self.searchTypeControl=nil;
    self.searchTypeBackgroundView=nil;
}


#pragma mark - LanguageSelectorViewControllerDelegate 

- (void) selectedItem:(NSString *)selected withTextTag:(NSString *)textTag
{
    if ([textTag isEqualToString:@"Learning"])
    {
        self.learningLan=selected;
        
        if ([LTDataSource isLextTalkCatalan])
        {
            if (self.speakingLan != nil)
            {
                if (![self.speakingLan isEqualToString:@"Catalan"])
                {
                    [self.speakingController selectAndScrollToItem:@"Catalan"];
                    self.speakingLan = @"Catalan";
                }
            }
        }
    }
    else if ([textTag isEqualToString:@"Speaking"])
    {
        self.speakingLan=selected;
        
        if ([LTDataSource isLextTalkCatalan])
        {
            if (self.learningLan != nil)
            {
                if (![self.learningLan isEqualToString:@"Catalan"])
                {
                    [self.learningController selectAndScrollToItem:@"Catalan"];
                    self.learningLan = @"Catalan";
                }
            }
        }
    }

    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        [self.learningTable reloadData];
        [self.speakingTable reloadData];
    }
    
    NSLog(@"Learing: %@, Speaking: %@", self.learningLan, self.speakingLan);
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.nameTextField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.nameTextField isFirstResponder] && [touch view] != self.nameTextField) {
        [self.nameTextField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}


#pragma mark -
#pragma mark MBProgressHUD Delegate
- (void) hudWasHidden:(MBProgressHUD *)hud
{
    [HUD removeFromSuperview];
    HUD = nil;
}

#pragma mark - SearchViewController Methods 
- (void) search
{
    if ((self.learningLan==nil) && (self.speakingLan==nil) && ([self.nameTextField.text length]==0))
    {
        UIAlertView * alert=[[UIAlertView alloc] 
                             initWithTitle:NSLocalizedString(@"Use at least one search option!", @"Use at least one search option!") 
                             message:NSLocalizedString(@"You must select at least a language and / or write a name", @"You must select at least a language and / or write a name") 
                             delegate:nil 
                             cancelButtonTitle:NSLocalizedString(@"OK", @"OK") 
                             otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        MKCoordinateRegion region2;
        if (self.searchTypeControl.selectedSegmentIndex==0)
            region2=MKCoordinateRegionMake(CLLocationCoordinate2DMake(0, 0), MKCoordinateSpanMake(360, 360));
        else
            region2=self.region;
        /*
        NSLog(@"selected segment: %d", self.searchTypeControl.selectedSegmentIndex);
        NSLog(@"Center lat: %f", region.center.latitude);
        NSLog(@"Center lng: %f", region.center.longitude);
        NSLog(@"Center lat delta: %f", region.span.latitudeDelta);
        NSLog(@"Center lng delta: %f", region.span.longitudeDelta);
         */
        
        //I can search
        if ([LTDataSource isLextTalkCatalan])
        {
            //3 cases
            //1) No langs set, just searching by name
            if ((self.learningLan) == nil  && (self.speakingLan == nil))
            {
                [[LTDataSource sharedDataSource] searchUsers:self.nameTextField.text
                                                 learningLan: @"Catalan"
                                                 speakingLan: @"Catalan"
                                                    inRegion:region2
                                                    withBothLangs:YES
                                                    delegate:self];
            }
            //2) Search with or without name, one of the languages is Catalan, the other is not set
            else if ((([self.learningLan isEqualToString:@"Catalan"]) && (self.speakingLan == nil)) ||
                     ((self.learningLan ==nil) && ([self.speakingLan isEqualToString:@"Catalan"])))
            {
                [[LTDataSource sharedDataSource] searchUsers: self.nameTextField.text
                                                 learningLan: self.learningLan
                                                 speakingLan: self.speakingLan
                                                    inRegion: region2
                                               withBothLangs: NO
                                                    delegate: self];
            }
            //3) Search with or without name, one of the languages is differetn from Catalan, the other is not set
            else if (((![self.learningLan isEqualToString:@"Catalan"]) && (self.speakingLan == nil)) ||
                     ((self.learningLan ==nil) && (![self.speakingLan isEqualToString:@"Catalan"])))
            {
                if (self.learningLan == nil)
                {
                    [[LTDataSource sharedDataSource] searchUsers: self.nameTextField.text
                                                     learningLan: @"Catalan"
                                                     speakingLan: self.speakingLan
                                                        inRegion: region2
                                                   withBothLangs: NO
                                                        delegate: self];
                }
                else
                {
                    [[LTDataSource sharedDataSource] searchUsers: self.nameTextField.text
                                                     learningLan: self.learningLan
                                                     speakingLan: @"Catalan"
                                                        inRegion: region2
                                                   withBothLangs: NO
                                                        delegate: self];
                }
            }
            //4) Search with or without name, both languages are set. The UI forces that one of them is Catalan
            else
            {
                [[LTDataSource sharedDataSource] searchUsers: self.nameTextField.text
                                                 learningLan: self.learningLan
                                                 speakingLan: self.speakingLan
                                                    inRegion: region2
                                               withBothLangs: NO
                                                    delegate: self];
            }
        }
        else
        {
            [[LTDataSource sharedDataSource] searchUsers:self.nameTextField.text
                                             learningLan:self.learningLan
                                             speakingLan:self.speakingLan
                                                inRegion:region2
                                           withBothLangs:NO
                                                delegate:self];
        }
        
        HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.view];
        [self.tabBarController.view addSubview:HUD];
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.delegate = self;
        HUD.labelText = NSLocalizedString(@"Searching...", @"Searching...");
        [HUD show:YES];
    }
}

#pragma mark -
#pragma mark Ad Reimplementation
- (CGFloat) layoutBanners:(BOOL) animated
{
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    
    CGFloat adHeight=[super layoutBanners:animated];
    
    UIEdgeInsets insets =
    UIEdgeInsetsMake(0,
                     0,
                     self.tabBarController.tabBar.frame.size.height + (self.navigationController.toolbarHidden ? 0 : self.navigationController.toolbar.frame.size.height) + adHeight,
                     0);
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         
                         [self rotateToInterfaceOrientation:self.interfaceOrientation];
                         
                         self.learningTable.contentInset = insets;
                         self.learningTable.scrollIndicatorInsets = insets;
                         self.speakingTable.contentInset = insets;
                         self.speakingTable.scrollIndicatorInsets = insets;
                         
                     }];
    return 0.0;
}

@end
