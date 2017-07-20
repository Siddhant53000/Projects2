//
//  SearchChatRoomViewController.m
//  LextTalk
//
//  Created by Yo on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchChatRoomViewController.h"
#import "LanguageReference.h"
#import <QuartzCore/QuartzCore.h>
#import "LTDataSource.h"
#import "ChatRoomListViewController.h"
#import "UIColor+ColorFromImage.h"
#import "GeneralHelper.h"

@interface SearchChatRoomViewController ()

@property (nonatomic, strong) UILabel * insLabel;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UITextField * textField;
@property (nonatomic, strong) UIView * backgroundView;
@property (nonatomic, strong) UILabel * langLabel;
@property (nonatomic, strong) UITableView * myTableView;
@property (nonatomic, strong) UIButton * button;

@property (nonatomic, strong) LanguageSelectorController * languageSelectorController;
@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, strong) UIView * blindView;

@end

@implementation SearchChatRoomViewController
@synthesize insLabel, nameLabel, textField, backgroundView, langLabel, button;
@synthesize lang, languageSelectorController, HUD;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadView
{
    self.view=[[UIView alloc] init];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    
    //TableView
    self.myTableView=[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.myTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.myTableView.delegate=self;
    self.myTableView.dataSource=self;
    self.myTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    [self.view addSubview:self.myTableView];
    
    //BlindView
    self.blindView = [[UIView alloc] init];
    self.blindView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.blindView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    [self.view addSubview:self.blindView];
    
    //insLabel
    self.insLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 10, 280, 40)];
    self.insLabel.font=[UIFont fontWithName:@"Ubuntu-Light" size:14];
    self.insLabel.backgroundColor = [UIColor clearColor];
    self.insLabel.textColor=[UIColor grayColor];
    self.insLabel.textAlignment= NSTextAlignmentCenter;
    self.insLabel.lineBreakMode= NSLineBreakByWordWrapping;
    self.insLabel.numberOfLines=2;
    self.insLabel.text=NSLocalizedString(@"Use a name, language or both in order to look for available chatrooms", nil);
    [self.blindView addSubview:self.insLabel];
    
    //nameLabel
    self.nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 70, 70, 20)];
    self.nameLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:16];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.textColor=[UIColor grayColor];
    self.nameLabel.textAlignment= NSTextAlignmentLeft;
    self.nameLabel.lineBreakMode= NSLineBreakByWordWrapping;
    //self.nameLabel.numberOfLines=2;
    self.nameLabel.text=NSLocalizedString(@"Name", @"Name");
    [self.blindView addSubview:self.nameLabel];
    
    //textField
    self.textField=[[UITextField alloc] initWithFrame:CGRectMake(90, 65, 140, 30)];
    self.textField.font = [UIFont fontWithName:@"Ubuntu-Light" size:15];
    self.textField.borderStyle=UITextBorderStyleRoundedRect;
    self.textField.delegate=self;
    [self.blindView addSubview:self.textField];
    
    //Button
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setTitle:NSLocalizedString(@"Search", nil) forState:UIControlStateNormal];
    self.button.titleLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:16];
    [self.button setBackgroundImage:[[UIImage imageNamed:@"search-blue"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] forState:UIControlStateNormal];
    self.button.frame = CGRectMake(240, 65, 70, 30);
    [self.button addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [self.blindView addSubview:self.button];
    
    self.button.layer.shadowColor=[[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
    self.button.layer.shadowOpacity = 1.0;
    self.button.layer.shadowRadius = 2;
    self.button.layer.shadowOffset = CGSizeMake(0, 2);
    self.button.clipsToBounds=NO;
    
    //BackgroundView
    //self.backgroundView=[[[UIView alloc] initWithFrame:CGRectMake(0, 115, 320, 30)] autorelease];
    /*
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:0.612 green:0.459 blue:0.686 alpha:1.0] CGColor], 
                       (id)[[UIColor colorWithRed:0.310 green:0.102 blue:0.431 alpha:1.0] CGColor],
                       nil];
    gradient.frame=self.backgroundView.bounds;
    [self.backgroundView.layer insertSublayer:gradient atIndex:0];
     */
    //self.backgroundView.backgroundColor = [UIColor colorFromImage:[UIImage imageNamed:@"search-blue"]];
    //[self.view addSubview:self.backgroundView];
    
    //langLabel
    /*
    self.langLabel=[[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)] autorelease];
    self.langLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:16];
    self.langLabel.textColor=[UIColor whiteColor];
    self.langLabel.backgroundColor=[UIColor clearColor];
    self.langLabel.textAlignment=UITextAlignmentCenter;
    self.langLabel.lineBreakMode=UILineBreakModeWordWrap;
    self.langLabel.text=NSLocalizedString(@"Chatroom language", @"Chatroom language");
    [self.backgroundView addSubview:self.langLabel];
     */
    
    //Language Controller
    NSArray * array;
    if (self.lang==nil)
        array=nil;
    else
        array=[NSArray arrayWithObject:self.lang];

    self.languageSelectorController=
    [[LanguageSelectorController alloc] initWithSingleSelectionTableView:self.myTableView
                                                                textArray:[LanguageReference availableLangsForAppLan:@"English"]
                                                            selectedItems:array
                                                      preferredFlagForLan:[[LTDataSource sharedDataSource].localUser preferredFlagForLangs]
                                                                showFlags:YES
                                                                  textTag:@"From"
                                                                 delegate:self];
    
    self.scrollViewToLayout = self.myTableView;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        self.extraTopInset = 100.0;
    else
        self.extraTopInset = 110.0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title=NSLocalizedString(@"Search Chatrooms", @"Search Chatrooms");
    
    self.navigationItem.leftBarButtonItem = [GeneralHelper plainBarButtonItemWithText:nil image:[UIImage imageNamed:@"arrow-back"] target:self selector:@selector(popViewController)];
    
    /*  Disable AdInheritanceViewController   */
    self.disableAds = YES;

}

- (void) popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) dealloc
{
    [self.HUD hide:YES];
    self.insLabel=nil;
    self.nameLabel=nil;
    self.textField=nil;
    self.backgroundView=nil;
    self.langLabel=nil;
    self.myTableView.delegate = nil;
    self.myTableView.dataSource = nil;
    self.myTableView=nil;
    self.button=nil;
    
    self.languageSelectorController=nil;
    self.HUD=nil;
    
    self.blindView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        
        self.insLabel.frame=CGRectMake(10, extraY + 10, size.width - 20, 40);
        self.nameLabel.frame=CGRectMake(10, extraY + 60, 70, 20);
        self.textField.frame=CGRectMake(90, extraY + 55, size.width - 90 - 90, 30);
        self.button.frame=CGRectMake(size.width - 80, extraY + 55, 70, 30);
        //self.backgroundView.frame=CGRectMake(0, 95, size.width, 30);
        self.blindView.frame = CGRectMake(0, 0, size.width, extraY + 105);
    }
    else 
    {
        self.insLabel.frame=CGRectMake(20, extraY + 20, size.width - 40, 40);
        self.nameLabel.frame=CGRectMake(20, extraY + 70, 70, 20);
        self.textField.frame=CGRectMake(100, extraY + 65, size.width - 100 - 100, 30);
        self.button.frame=CGRectMake(size.width - 90, extraY + 65, 70, 30);
        //self.backgroundView.frame=CGRectMake(0, 95, size.width, 30);
        self.blindView.frame = CGRectMake(0, 0, size.width, extraY + 110);
    }
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


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView2 numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
     static NSString *CellIdentifier = @"AlarmViewControllerCell";
     
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     if (cell == nil) {
     cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
     }
     */
    
    UITableViewCell * cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    // Configure the cell...
    cell.textLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:16];
    
    if (self.lang==nil)
        cell.textLabel.text=NSLocalizedString(@"Choose one", @"Choose one");
    else
        cell.textLabel.text=self.lang;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
	
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
    
    LanguageSelectorViewController * controller=[[LanguageSelectorViewController alloc] init];
    controller.delegate=self;
    
    controller.textArray=[LanguageReference availableLangsForAppLan:@"English"];
    controller.multiple=NO;
    controller.showFlags=YES;
    controller.preferredFlagForLan=nil;
    

    controller.textTag=nil;
    if (self.lang!=nil)
        controller.selectedItems=[NSArray arrayWithObject:self.lang];
    
    LTUser * user=[[LTDataSource sharedDataSource] localUser];
    if ((user.learningLanguages!=nil) && (user.learningLanguagesFlags!=nil))
        controller.preferredFlagForLan=[NSDictionary dictionaryWithObjects:user.learningLanguagesFlags forKeys:user.learningLanguages];

    
    [self.navigationController pushViewController:controller animated:YES];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cell.backgroundColor=[UIColor colorWithRed:0 green:0.616 blue:0.878 alpha:1.0];
    cell.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BarImage"]];
    cell.textLabel.backgroundColor=[UIColor clearColor];
    cell.textLabel.textColor=[UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
}

#pragma mark - LanguageSelectorViewControllerDelegate 

- (void) selectedItem:(NSString *)selected withTextTag:(NSString *)textTag
{
    self.lang=selected;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        [self.myTableView reloadData];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.textField isFirstResponder] && [touch view] != self.textField) {
        [self.textField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - SearchChatRoomViewController methods

- (void) search
{
    if (([self.textField.text length]==0) && self.lang==nil)
    {
        UIAlertView * alert=[[UIAlertView alloc] 
                             initWithTitle:NSLocalizedString(@"Use at least one search option!", @"Use at least one search option!") 
                             message:NSLocalizedString(@"You must select at least the language and / or write a chatroom name", @"You must select at least the language and / or write a chatroom name") 
                             delegate:nil 
                             cancelButtonTitle:NSLocalizedString(@"OK", @"OK") 
                             otherButtonTitles:nil];
        [alert show];
    }
    else 
    {
        NSString * str=nil;
        if ([self.textField.text length]>0)
            str=self.textField.text;
        
        [self.textField resignFirstResponder];
        self.HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.view];
        [self.tabBarController.view addSubview:HUD];
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.labelText = NSLocalizedString(@"Searching...", nil);
        [HUD show:YES];
        [[LTDataSource sharedDataSource] searchChatroom:str
                                                   lang:self.lang
                                                 userId:[LTDataSource sharedDataSource].localUser.userId
                                               delegate:self];
    }
}

#pragma mark -
#pragma mark LTDataDelegate methods

- (void)didFail:(NSDictionary *)result
{
    //reloading=NO;
    //[self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading: self.myTableView];
    
    [self.HUD hide:YES];
    self.HUD = nil;
//    NSString *title = [result objectForKey:@"error_title"];
//    NSString *message = [result objectForKey:@"error_message"];
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: title
//                                                     message: message
//                                                    delegate: nil 
//                                           cancelButtonTitle: NSLocalizedString(@"OK", @"OK")
//                                           otherButtonTitles: nil];
    
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

- (void)didUpdateSearchResultsChatrooms:(NSArray *)results
{
    //reloading=NO;
    //[self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading: self.myTableView];
    [self.HUD hide:YES];
    self.HUD = nil;
    
    NSString * str=nil;
    if ([self.textField.text length]>0)
        str=self.textField.text;
    
    ChatRoomListViewController * controller=[[ChatRoomListViewController alloc] init];
    controller.isSearch=YES;
    controller.chatrooms=results;
    controller.lang=self.lang;
    controller.searchText=str;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -
#pragma mark Ad Reimplementation
- (CGFloat) layoutBanners:(BOOL) animated
{
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    
    [super layoutBanners:animated];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         
                         [self rotateToInterfaceOrientation:self.interfaceOrientation];
                         
                     }];
    return 0.0;
}

@end
