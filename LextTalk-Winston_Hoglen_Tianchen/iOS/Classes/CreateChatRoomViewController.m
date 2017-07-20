//
//  CreateChatRoomViewController.m
//  LextTalk
//
//  Created by Yo on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CreateChatRoomViewController.h"
#import "LanguageReference.h"
#import "LTDataSource.h"
#import "LextTalkAppDelegate.h"
#import "MBProgressHUD.h"
#import "LTDataSource.h"
#import "UIColor+ColorFromImage.h"
#import "GeneralHelper.h"

@interface CreateChatRoomViewController ()

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) UIView * headerView;

@end

@implementation CreateChatRoomViewController
@synthesize languageSelectorController, lang, textField, HUD;
@synthesize delegate;

- (void) loadView
{
    self.myTableView=[[UITableView alloc] init];
    self.view=[[UIView alloc] init];
    
    self.myTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.myTableView];
    self.myTableView.frame=self.view.frame;
    self.myTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    
    //Header View to write the name of the chat room
    self.headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    self.headerView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    
    UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(15, 15, 70, 20)];
    label.font=[UIFont fontWithName:@"Ubuntu-Bold" size:16];
    label.backgroundColor=[UIColor colorFromImage:[UIImage imageNamed:@"search-blue"]];
    label.textColor=[UIColor whiteColor];
    label.textAlignment=NSTextAlignmentLeft;
    label.text=NSLocalizedString(@"Name", @"Name");
    label.backgroundColor=[UIColor clearColor];
    
    self.textField=[[UITextField alloc] initWithFrame:CGRectMake(95, 10, 320 - 95 - 15, 30)];
    self.textField.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    self.textField.borderStyle=UITextBorderStyleRoundedRect;
    self.textField.delegate=self;
    
    [self.headerView addSubview:label];
    [self.headerView addSubview:self.textField];
    self.headerView.backgroundColor=[UIColor colorFromImage:[UIImage imageNamed:@"search-blue"]];
    
    [self.view addSubview:self.headerView];
    
    self.scrollViewToLayout = self.myTableView;
    self.extraTopInset = 50.0;
    self.moveUpWhenKeyboardShown = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title=NSLocalizedString(@"Choose name, lang", @"Choose name, lang");
    
    if(![[LTDataSource sharedDataSource] isUserLogged]) {
        LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
        [del tellUserToSignIn];
    }
    else 
    {
        NSArray * learningArray=[[LTDataSource sharedDataSource] localUser].learningLanguages;
        NSArray * speakingArray=[[LTDataSource sharedDataSource] localUser].speakingLanguages;
        NSArray * learningFlagArray=[[LTDataSource sharedDataSource] localUser].learningLanguagesFlags;
        NSArray * speakingFlagArray=[[LTDataSource sharedDataSource] localUser].speakingLanguagesFlags;
        
        NSArray * langArray=[learningArray arrayByAddingObjectsFromArray:speakingArray];
        NSArray * flagArray=[learningFlagArray arrayByAddingObjectsFromArray:speakingFlagArray];
        
        NSDictionary * preferredFlagForLang=nil;
        if (([langArray count] == [flagArray count]) && ([langArray count]>0))
            preferredFlagForLang=[NSDictionary dictionaryWithObjects:flagArray forKeys:langArray];
        
        self.languageSelectorController=[[LanguageSelectorController alloc] 
                                          initWithSingleSelectionTableView:self.myTableView 
                                          textArray:[LanguageReference availableLangsForAppLan:@"English"] 
                                          selectedItems:nil 
                                          preferredFlagForLan:preferredFlagForLang 
                                          showFlags:YES 
                                          textTag:@"From"
                                          delegate:self];
        
        self.myTableView.delegate=self.languageSelectorController;
        self.myTableView.dataSource=self.languageSelectorController;
        
        //Button to create the Chat Room
        self.navigationItem.rightBarButtonItem = [GeneralHelper plainBarButtonItemWithText:NSLocalizedString(@"Done!", @"Done!") image:nil target:self selector:@selector(createChatRoom)];
        
        //only if I am not the root controller in the navigation
        if ([self.navigationController.viewControllers objectAtIndex:0] != self)
            self.navigationItem.leftBarButtonItem = [GeneralHelper plainBarButtonItemWithText:nil image:[UIImage imageNamed:@"arrow-back"] target:self selector:@selector(popViewController)];
    }
    
    /*  Disable AdInheritanceViewController   */
    self.disableAds = YES;

}

- (void) popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) dealloc
{
    [[LTDataSource sharedDataSource] removeFromRequestDelegates:self];
    self.myTableView = nil;
    languageSelectorController = nil;
    lang = nil;
    textField = nil;
    self.myTableView.delegate = nil;
    self.myTableView.dataSource = nil;
    self.myTableView=nil;
    self.textField=nil;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.myTableView flashScrollIndicators];
}

#pragma mark CreateChatRoomViewController method
- (void) createChatRoom
{
    //Check that the user has provided a name for the chat room and has selected a language
    if (self.lang==nil || [self.textField.text length]==0)
    {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"More info needed!", @"More info needed!") 
                                                       message:NSLocalizedString(@"You must write a name and select a language in order to create the chat room", @"You must write a name and select a language in order to create the chat room") 
                                                      delegate:nil 
                                             cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                             otherButtonTitles:nil];
        [alert show];
    }
    else 
    {
        //Create the chat room
        [self.textField resignFirstResponder];
        self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.tabBarController.view addSubview:HUD];
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.labelText = NSLocalizedString(@"Creating...", @"Creating...");
        [HUD show:YES];
        [[LTDataSource sharedDataSource] createChatroom:self.textField.text
                                            withUserId:[[LTDataSource sharedDataSource] localUser].userId
                                                  lang:self.lang
                                               editKey:[[LTDataSource sharedDataSource] localUser].editKey
                                              delegate:self];
    }
}

- (void) didCreateChatroom: (NSInteger) chatroom_id
{
    [self.HUD hide:YES];
    self.HUD = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JoinedChatroomsChanged" object:nil];
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        [self.navigationController popViewControllerAnimated:YES];
    else 
    {
        if ([delegate respondsToSelector:@selector(chatroomCreated)])
            [delegate chatroomCreated];
    }
    
}

- (void) didFail: (NSDictionary*) dict
{
    [self.HUD hide:YES];
    self.HUD = nil;
//    NSString *title = [dict objectForKey:@"error_title"];
//    NSString *message = [dict objectForKey:@"error_message"];
//    
//    UIAlertView * alert=[[UIAlertView alloc] initWithTitle: title
//                                                   message: message
//                                                  delegate: nil 
//                                         cancelButtonTitle: NSLocalizedString(@"OK", @"OK")
//                                         otherButtonTitles: nil];
    
    // handle error
	if(dict == nil) return;
	
    //	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"LextTalk server error", @"LextTalk server error")
    //													message: [result objectForKey: @"message"]
    //												   delegate: self
    //										  cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
    //										  otherButtonTitles: nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: [dict objectForKey: @"error_title"]
													message: [dict objectForKey: @"error_message"]
												   delegate: self
										  cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
										  otherButtonTitles: nil];
    [alert show];
}

#pragma mark LanguageSelectorControllerDelegate methods

- (void) selectedItem:(NSString *) selected withTextTag:(NSString *) textTag
{
    self.lang=selected;
}

#pragma mark UITextFieldDelegate methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.textField isFirstResponder] && [touch view] != self.textField) {
        [self.textField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

#pragma mark UIViewController

- (CGSize) contentSizeForViewInPopover
{
    CGSize size=CGSizeMake(320, 480);
    return size;
}

#pragma mark Ad Reimplementation
- (CGFloat) layoutBanners:(BOOL) animated
{
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    
    [super layoutBanners:animated];
    
    CGRect frame = CGRectMake(0,
                              self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                              self.myTableView.bounds.size.width,
                              50.0);
    
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         
                         self.headerView.frame = frame;
                         self.textField.frame = CGRectMake(95, 10, self.view.bounds.size.width - 95 - 15, 30);
                         
                     }];
    
    return 0.0;
}

@end
