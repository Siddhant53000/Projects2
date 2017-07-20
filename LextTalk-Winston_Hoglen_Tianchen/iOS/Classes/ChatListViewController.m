//
//  ChatListViewController.m
// LextTalk
//
//  Created by David on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ChatListViewController.h"
#import "ChatViewController.h"
#import "LTChat.h"
#import "LTMessage.h"
#import "LextTalkAppDelegate.h"
#import "UIColor+ColorFromImage.h"
#import "GeneralHelper.h"
#import "ChatListCell.h"
#import "MBProgressHUD.h"
#import "LocalUserViewController.h"
#import "GeneralHelper.h"
#import <Google/Analytics.h>
//AO for Google Analytics
#import "GAITrackedViewController.h"
#import "GAIDictionaryBuilder.h"
//ad
#import "AdCell.h"

@interface ChatListViewController ()

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
- (void)startUpdateProcess;

@property (nonatomic, strong) NSIndexPath * indexPath;
@property (nonatomic, strong) MBProgressHUD * HUD;
@property (nonatomic, strong) UIPopoverController * popoverController;
@property (nonatomic, strong) UISearchDisplayController * mysearchdisplaycontroller;
@property (nonatomic, strong) UIRefreshControl * refreshControl;

//for addCell
@property (nonatomic) int freequencyOfAdCell;

@end


@implementation ChatListViewController
@synthesize popoverController;
@synthesize filteredListContent = _filteredListContent;
@synthesize chatList = _chatList;
@synthesize savedSearchTerm = _savedSearchTerm;
@synthesize savedScopeButtonIndex = _savedScopeButtonIndex;
@synthesize searchWasActive = _searchWasActive;
@synthesize chatTableView, indicatorView;
@synthesize mysearchdisplaycontroller = _mysearchdisplaycontroller;

#pragma mark -
#pragma mark IQLocalizableProtocol methods

- (void) localize {
	[self setTitle: NSLocalizedString(@"Chats", @"Chats")];	
	_mysearchdisplaycontroller.searchBar.placeholder = NSLocalizedString(@"Search chat by name", @"Search chat by name");
}



#pragma mark -
#pragma mark LTDataDelegate methods

- (void) didGetListOfMessages {
    
	[indicatorView stopAnimating];	
	self.chatList = [[LTDataSource sharedDataSource] chatList];	
	_reloading = NO;
    [self.refreshControl endRefreshing];

	// force reload of chatViewController whever new chats are received	
	//[self.currentChatViewController viewWillAppear: NO];
    //if (self.currentChatViewController)
    //    [self.currentChatViewController updateChatViewController];
    
    NSArray * array=[[LextTalkAppDelegate sharedDelegate].tabBarController viewControllers];
    if ([array count]>=2)
    {
        UINavigationController * nav=[array objectAtIndex:0];
        if ([nav.visibleViewController isMemberOfClass:[ChatViewController class]])
        {
            ChatViewController * chatController = (ChatViewController *) nav.visibleViewController;
            [chatController updateChatViewController];
        }
        nav=[array objectAtIndex:1];
        if ([nav.visibleViewController isMemberOfClass:[ChatViewController class]])
        {
            ChatViewController * chatController = (ChatViewController *) nav.visibleViewController;
            [chatController updateChatViewController];
        }
    }
    
	[chatTableView reloadData];
	
}

- (void) didFail:(NSDictionary *)result {
	[indicatorView stopAnimating];
	_reloading = NO;
    [self.refreshControl endRefreshing];
	
	// handle error
	
	if(result == nil) return;
	
    //	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: [result objectForKey: @"error_title"]
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

        alert.tag=404;
        [alert show];
    }
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	[self filterContentForSearchText: searchString 
							   scope: [[_mysearchdisplaycontroller.searchBar scopeButtonTitles] objectAtIndex:[_mysearchdisplaycontroller.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText: [_mysearchdisplaycontroller.searchBar text]
							   scope: [[_mysearchdisplaycontroller.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag==0)
    {
        if(buttonIndex != 0) {
            // delete chat
            IQVerbose(VERBOSE_DEBUG,@"[%@] Will delete chat with user %d", [self class], _chatWithUserId);
            [[LTDataSource sharedDataSource] deleteChatWithUserId: _chatWithUserId];
            self.chatList = [[LTDataSource sharedDataSource] chatList];
            [chatTableView reloadData];
        }
    }
    else if (alertView.tag==1)
    {
        if (buttonIndex==1)
            [self pushChatViewControllerForIndexPath:self.indexPath];
    }
    else if ((buttonIndex==0) && (alertView.tag==404))
    {
        LextTalkAppDelegate * del = (LextTalkAppDelegate *) [[UIApplication sharedApplication] delegate];
        del.showingError = NO;
    }
}

#pragma mark -
#pragma mark UITableViewDelegate methds


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *list;
	if( tableView == _mysearchdisplaycontroller.searchResultsTableView ) {
		list = self.filteredListContent;
	} else {
		list = self.chatList;
	}
	
	LTObject <LTTableObjectProtocol> *object = [list objectAtIndex: indexPath.row];
	if( [object respondsToSelector: @selector(cellHeightInTableView:)] ) 
		return [object cellHeightInTableView: tableView];
	
	return 60;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
	LTChat *chat = [[[LTDataSource sharedDataSource] chatList] objectAtIndex: indexPath.row];
    self.indexPath = indexPath;
    if ([[LTDataSource sharedDataSource].localUser.blockedUsers containsObject:[NSNumber numberWithInteger:chat.userId]])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"User blocked!", nil)
														message: NSLocalizedString(@"You have blocked this user, he won't be able to answer you. Are you sure you want to send him a message?", nil)
													   delegate: self
											  cancelButtonTitle: NSLocalizedString(@"No", nil)
											  otherButtonTitles: NSLocalizedString(@"Yes", nil), nil];
        alert.tag=1;
		[alert show];
    }
    else
        [self pushChatViewControllerForIndexPath:indexPath];
}

- (void)tableView: (UITableView *)tableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *)indexPath {
	[self tableView: tableView didSelectRowAtIndexPath: indexPath];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;	
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	LTChat *chat;
	
	if (tableView == _mysearchdisplaycontroller.searchResultsTableView) { // filtered results (no ADs)
        chat = [self.filteredListContent objectAtIndex: indexPath.row];
    } else {
		chat = [self.chatList objectAtIndex: indexPath.row];	
	}

	_chatWithUserId = chat.userId;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: [NSString stringWithFormat: NSLocalizedString(@"Delete chat with %@", @"Delete chat with %@"), chat.userName]
													message: NSLocalizedString(@"Are you sure ?", @"Are you sure ?")
												   delegate: self
										  cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
										  otherButtonTitles: NSLocalizedString(@"Delete", @"Delete"),nil];
	
	[alert show];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == _mysearchdisplaycontroller.searchResultsTableView) { // filtered results (no ADs)
        return NO;
	}
	
	return YES;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor=[UIColor clearColor];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (tableView == _mysearchdisplaycontroller.searchResultsTableView) {
        return [self.filteredListContent count];
    }
	
    return [self.chatList count] ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier1 = @"adCell";
    
    if (indexPath.row % 5 ==0)
    {
        AdCell* adcell = [[AdCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier1];
        [[adcell contentView] addSubview:adcell.nativeAdView];
        NSLog(@"adcell %ld", (long)indexPath.row);
        return adcell;
    }
    
    ChatListCell * cell;
	if (tableView == _mysearchdisplaycontroller.searchResultsTableView) { // filtered results (no ADs)
        LTChat * chat = [self.filteredListContent objectAtIndex: indexPath.row];
        cell = (ChatListCell *) [chat cellInTableView: tableView withIndexPath:indexPath searchResult: YES];
    }
//    else if (indexPath.row == 0)
//    {
//        AdCell* adcell = [[AdCell alloc] init];
//        NSLog(@"adcell");
//        return adcell;
//    }
    else
    {
        LTChat * chat = [self.chatList objectAtIndex: indexPath.row];
        cell = (ChatListCell *) [chat cellInTableView: tableView withIndexPath:indexPath searchResult: NO];
    }
     
    
    //Button to see the user profile from the chat list
    [cell.button addTarget:self action:@selector(loadUserProfile:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return cell;
}

#pragma mark -
#pragma mark UIPopoverController Delegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverController=nil;//Lo libero así
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

#pragma mark -
#pragma mark PUshControllerProtocol Delegate Methods

- (void) pushController:(UIViewController *) controller
{
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController=nil;
    if (controller!=nil)
        [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -
#pragma mark ChatListViewController methods

- (void) loadUserProfile: (UIButton *) button
{
    UIView * view = button;
    while (![view isMemberOfClass:[ChatListCell class]])
    {
        view = [view superview];
        //NSLog(@"View class: %@", [view class]);
    }
    
    UITableViewCell * cell = (UITableViewCell *) view;
    NSIndexPath * indexPath;
    if ([cell isDescendantOfView:_mysearchdisplaycontroller.searchResultsTableView])
        indexPath = [_mysearchdisplaycontroller.searchResultsTableView indexPathForCell: cell];
    else
        indexPath = [self.chatTableView indexPathForCell: cell];
    //NSLog(@"Chat seleccionado con boton :%d", indexPath.row);
    
    LTChat * chat;
    if ([cell isDescendantOfView:_mysearchdisplaycontroller.searchResultsTableView])
        chat = [self.filteredListContent objectAtIndex: indexPath.row];
    else
        chat = [self.chatList objectAtIndex: indexPath.row];
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.view];
    [self.tabBarController.view addSubview:self.HUD];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.labelText = NSLocalizedString(@"Getting user profile...", nil);
    [self.HUD show:YES];
    
    [[LTDataSource sharedDataSource] getUserWithUserId:chat.userId andExecuteBlockInMainQueue:^(LTUser *user, NSError *error) {
        
        [self.HUD hide:YES];
        self.HUD = nil;
        
        if (error!=nil)
        {
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network error!", nil)
                                                             message:NSLocalizedString(@"The user information could not be downloaded", nil)
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles: nil];
            [alert show];
        }
        else if (user==nil) //No error but user==nil, which means that the user has been deleted
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"User deleted!", nil)
                                                             message:NSLocalizedString(@"The user's profile, whose information you are trying to retrieve, has been deleted.", nil)
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles: nil];
            [alert show];
        }
        else
        {
            LocalUserViewController * userViewController = [[LocalUserViewController alloc] init];
            userViewController.user = user;
            
            if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
            {
                [self.navigationController pushViewController:userViewController animated: YES];
            }
            else
            {
                UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:userViewController];
                nav.navigationBarHidden = YES;
                
                userViewController.delegate=self;
                userViewController.disableAds=YES;
                
                CGRect cellRect;
                if ([_mysearchdisplaycontroller isActive])
                    cellRect=[_mysearchdisplaycontroller.searchResultsTableView rectForRowAtIndexPath:indexPath];
                else
                    cellRect=[self.chatTableView rectForRowAtIndexPath:indexPath];
                
                CGRect showRect=CGRectMake(cellRect.origin.x + cellRect.size.width - 40,
                                           cellRect.origin.y + cellRect.size.height/2,
                                           1, 1);
                
                self.popoverController=[[UIPopoverController alloc] initWithContentViewController:nav];
                self.popoverController.delegate=self;
                if ([_mysearchdisplaycontroller isActive])
                    [self.popoverController presentPopoverFromRect:showRect inView:_mysearchdisplaycontroller.searchResultsTableView permittedArrowDirections:UIPopoverArrowDirectionAny  animated:YES];
                else
                    [self.popoverController presentPopoverFromRect:showRect inView:self.chatTableView permittedArrowDirections:UIPopoverArrowDirectionAny  animated:YES];
            }
        }
    }];
}

- (void) pushChatViewControllerForIndexPath:(NSIndexPath *) indexPath
{
    ChatViewController *chatViewController = [[ChatViewController alloc] init];
	
	LTChat *chat = [[[LTDataSource sharedDataSource] chatList] objectAtIndex: indexPath.row];
	[chatViewController setUserId: [chat userId]];
	[self.navigationController pushViewController:chatViewController animated: YES];
}

- (void) hideSearchBar {
    CGFloat searchBarHeight = 44;
    if ([chatTableView contentOffset].y < searchBarHeight)
        [chatTableView setContentOffset:CGPointMake(0, searchBarHeight)];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [self.filteredListContent removeAllObjects]; // First clear the filtered array.
    
    for(LTChat *chat in self.chatList) {
        if([chat shouldAppearInContentForSearchText: searchText scope: scope]) {
            [self.filteredListContent addObject: chat];
        }
    }
}

- (void) startUpdateProcess {
    
    for (LTChat * chat in self.chatList)
    {
        chat.url = nil;
        chat.urlUpdateDate = nil;
        chat.activityUpdateDate = nil;
        chat.lastUpdateDate = nil;
    }
    [self.refreshControl beginRefreshing];
    
	// is user logged?
	if(![[LTDataSource sharedDataSource] isUserLogged]) {
        [self.refreshControl endRefreshing];
		return;
	}
    
	//[self setChatList: [NSArray array]];
    //[chatTableView reloadData];
    
	[[LTDataSource sharedDataSource] getMessagesForUser: [[LTDataSource sharedDataSource] localUser].userId
											  withEditKey: [[LTDataSource sharedDataSource] localUser].editKey 
												 delegate: self];
	[indicatorView startAnimating];
	_reloading = NO;
	
    
}

#pragma mark -
#pragma mark UIViewController


- (id)init
{
    if ((self = [super init])) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetListOfMessages) name:@"ReloadChatList" object:nil];
    }
    return self;
}


- (void) awakeFromNib
{
    //Notificacion

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetListOfMessages) name:@"ReloadChatList" object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    CGRect frame = self.view.frame;
    frame.origin = CGPointMake(0, 0);
    self.chatTableView.frame=frame;
    
    [super viewWillAppear:animated];
    
	if(![[LTDataSource sharedDataSource] isUserLogged]) {
        LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
        //Update when the user has logged out
        self.chatList = [[LTDataSource sharedDataSource] chatList];
        [chatTableView reloadData];
        [del tellUserToSignIn];
		return;
	}
    
	[chatTableView reloadData];
	//[self hideSearchBar];
	//[self startUpdateProcess];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"chat"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
- (void) loadView
{
    self.view=[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.chatTableView=[[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStylePlain];
    self.chatTableView.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.chatTableView];
    //self.chatTableView.frame=self.view.frame;
    
    
    self.chatTableView.delegate=self;
    self.chatTableView.dataSource=self;
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:self.indicatorView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Navigation bar color
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"bar-blue"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] forBarMetrics:UIBarMetricsDefault];
    
	// create a filtered list that will contain products for the search results table.
	self.filteredListContent = [NSMutableArray array];
    
    CGRect rect=[[UIScreen mainScreen] applicationFrame];
    UISearchBar * theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,rect.size.width,44)];
    self.chatTableView.tableHeaderView=theSearchBar;
    
    
    _mysearchdisplaycontroller = [[UISearchDisplayController alloc] initWithSearchBar:theSearchBar contentsController:self ];
    
    _mysearchdisplaycontroller.delegate = self;
    _mysearchdisplaycontroller.searchResultsDataSource = self;
    _mysearchdisplaycontroller.searchResultsDelegate = self;
    _mysearchdisplaycontroller.searchResultsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
	
	// restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm) {
        [_mysearchdisplaycontroller setActive:self.searchWasActive];
        [_mysearchdisplaycontroller.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [_mysearchdisplaycontroller.searchBar setText:self.savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
    
    // just relocate activity indicator on iPad
	// relocate activity indicator
	CGRect newFrame = CGRectMake(0, 0, 37, 37);
	newFrame.origin.x = self.view.frame.size.width/2.0 - newFrame.size.width/2.0;
	newFrame.origin.y = self.view.frame.size.height/2.0 - newFrame.size.height/2.0;	
	[indicatorView setFrame: newFrame]; 
	
		
	
    
    
    //Color de la barra
    _mysearchdisplaycontroller.searchBar.backgroundImage = [[UIImage imageNamed:@"search-blue"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    _mysearchdisplaycontroller.searchBar.tintColor = [UIColor colorFromImage:[UIImage imageNamed:@"search-blue"]];
    
    
    //Color de fondo
    self.chatTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    
    [GeneralHelper setTitleTextAttributesForController:self];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    
    
    
    //Refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(startUpdateProcess) forControlEvents:UIControlEventValueChanged];
    [self.chatTableView addSubview:self.refreshControl];
	
    //Update
	[self startUpdateProcess];
    
    //search bar text
    [self localize];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGRect frame = self.view.frame;
    frame.origin = CGPointMake(0, 0);
    self.chatTableView.frame=frame;
    
    self.tut = [[TutViewController alloc] init];
    [self.tut changeTutImage:[UIImage imageNamed:@"chattut"]];
    [self.tut changeTutText:@"Chat with friends in multiple languages, and cross-check language competency."];
    [self.view addSubview:self.tut.view];
    

    self.removeTutBtn = [[UIButton alloc] init];
    self.removeTutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.removeTutBtn addTarget:self
                          action:@selector(dismissTut)
                forControlEvents:UIControlEventTouchUpInside];
    [self.removeTutBtn setTitle:@"Get Started" forState:UIControlStateNormal];
    self.removeTutBtn.frame = CGRectMake(80.0, self.view.frame.size.height-(200.0), 160.0, 40.0);
    [self.view addSubview:self.removeTutBtn];

    
}

-(void)dismissTut{
    NSLog(@"Dismissed");
    [self.tut.view removeFromSuperview];
    [self.removeTutBtn removeFromSuperview];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidDisappear:(BOOL)animated {
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [_mysearchdisplaycontroller isActive];
    self.savedSearchTerm = [_mysearchdisplaycontroller.searchBar text];
    self.savedScopeButtonIndex = [_mysearchdisplaycontroller.searchBar selectedScopeButtonIndex];
}

- (void)dealloc {
	[[LTDataSource sharedDataSource] removeFromRequestDelegates: self];
	self.chatList = nil;
    
    self.filteredListContent = nil;
    
    self.indicatorView=nil;
    self.chatTableView.delegate = nil;
    self.chatTableView.dataSource = nil;
    self.chatTableView=nil;
    
    [self.HUD hide:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark Ad Reimplementation
/*
- (CGFloat) layoutBanners:(BOOL) animated
{
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    
    CGFloat adHeight=[super layoutBanners:animated];
    CGRect newFrame=self.view.frame;//If I do it with the table, it reduces itself everytime an ad is refreshed
    newFrame.size.height=newFrame.size.height - adHeight;
    
    //Needed in iOS 7
    newFrame.origin = CGPointMake(0, 0);
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.chatTableView.frame=newFrame;
                     }];
    
    return 0.0;
}
 */

#pragma mark -
#pragma mark Adcell methods

- (BOOL) frequencyForAdCell: (NSIndexPath *)indexPath
{
    return (indexPath.row % (self.freequencyOfAdCell) == 0 );
}

//only called when Ads needed to show up
- (int) tableViewIndexToDatasourceIndex: (int)table_index
{
    return table_index - table_index/self.freequencyOfAdCell -1;
}

- (int) totalNumOfCellWhenAdsShown: (int)datasourceCount
{
    return datasourceCount + datasourceCount / (self.freequencyOfAdCell-1) + 1;
}

@end
