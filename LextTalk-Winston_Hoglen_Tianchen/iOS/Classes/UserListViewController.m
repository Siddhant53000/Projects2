//
//  UserListViewController.m
// LextTalk
//
//  Created by David on 11/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserListViewController.h"


#import "LTUser.h"
#import "LocalUserViewController.h"
#import "LTDataSource.h"
#import "UIColor+ColorFromImage.h"
#import "GeneralHelper.h"

@interface UserListViewController ()

@property (nonatomic, strong) UISearchDisplayController * mysearchdisplaycontroller;

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
- (void)showObjectDetail: (id) object withIndexPath:(NSIndexPath *) indexPath;

@end


@implementation UserListViewController
@synthesize objectList = _objectList;
@synthesize filteredListContent = _filteredListContent;
@synthesize savedSearchTerm = _savedSearchTerm;
@synthesize savedScopeButtonIndex = _savedScopeButtonIndex;
@synthesize searchWasActive = _searchWasActive;
@synthesize popoverController;
@synthesize mysearchdisplaycontroller = _mysearchdisplaycontroller;

#pragma mark -
#pragma mark IQLocalizableProtocol methods

- (void) localize {
	_mysearchdisplaycontroller.searchBar.placeholder = NSLocalizedString(@"Filter", nil);
}

#pragma mark -
#pragma mark GFDataDelegate methods

- (void) didGetListOfAttendants: (NSArray*) attendants {
	[self setObjects: attendants];
}

- (void) didFail:(NSDictionary *)result {
	
	// handle error
	if(result == nil) return;
	

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: [result objectForKey: @"error_title"]
													message: [result objectForKey: @"error_message"]
												   delegate: self
										  cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
										  otherButtonTitles: nil];
	
	[alert show];
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

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    if (self.automaticallyAdjustsScrollViewInsets == NO)
    {
        UIEdgeInsets insets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.origin.y, 0, 0, 0);
        self.objectTableView.contentInset = insets;
        self.objectTableView.scrollIndicatorInsets = insets;
        self.objectTableView.contentOffset = CGPointMake(0.0, -64.0);
    }
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    self.layoutDisabled = YES;
    UIEdgeInsets insets =
    UIEdgeInsetsMake(64,
                     0,
                     self.tabBarController.tabBar.frame.size.height + (self.navigationController.toolbarHidden ? 0 : self.navigationController.toolbar.frame.size.height) + 0.0 ,
                     0);
    
    
    self.objectTableView.contentInset = insets;
    self.objectTableView.scrollIndicatorInsets = insets;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.searchDisplayController.searchBar.alpha = 0.0;
    }];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //If I do not do this, and the AD has been reloaded when the search is activ3
    //The AD is not placed correctly when I come back from the search.
    self.layoutDisabled = NO;
    [self layoutBanners:YES];
    self.searchDisplayController.searchBar.alpha = 1.0;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    //Si no se crean los banners sin necesidad al llamar a sharedInstance
    if (!self.disableAds)
    {
        [self bringBannersToFront];
        
        [self layoutBanners:NO];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate methds


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	if (tableView == _mysearchdisplaycontroller.searchResultsTableView) { // filtered results (no ADs)
		if( [[self.filteredListContent objectAtIndex: indexPath.row] class] == [LTUser class]) {
			LTUser *user = (LTUser*) [self.filteredListContent objectAtIndex: indexPath.row];
            return [user cellHeightInTableView:tableView];
		}
		
    }
    else if( [[self.objectList objectAtIndex: indexPath.row] class] == [LTUser class]) {
		LTUser *user = (LTUser*) [self.objectList objectAtIndex: indexPath.row];
		return [user cellHeightInTableView:tableView];
    }
    
    return 60;
}
 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	if (tableView == _mysearchdisplaycontroller.searchResultsTableView) {
		[self showObjectDetail: [self.filteredListContent objectAtIndex: indexPath.row] withIndexPath:indexPath];
    }
    else
        [self showObjectDetail: [self.objectList objectAtIndex: indexPath.row] withIndexPath:indexPath];
}

- (void)tableView: (UITableView *)tableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *)indexPath {
	[self tableView: tableView didSelectRowAtIndexPath: indexPath];
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
    else
        return [self.objectList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell * cell=nil;
    
	if (tableView == _mysearchdisplaycontroller.searchResultsTableView) { // filtered results (no ADs)
		if( [[self.filteredListContent objectAtIndex: indexPath.row] class] == [LTUser class]) { 
			LTUser *user = (LTUser*) [self.filteredListContent objectAtIndex: indexPath.row];
			cell= [user cellInTableView: tableView withIndexPath:indexPath searchResult: YES];
		}
		
    }
    else if( [[self.objectList objectAtIndex: indexPath.row] class] == [LTUser class]) { 
		LTUser *user = (LTUser*) [self.objectList objectAtIndex: indexPath.row];
		cell= [user cellInTableView: tableView withIndexPath:indexPath searchResult: NO];
    }
    return cell;
}

#pragma mark -
#pragma mark UserListViewController methods

- (void)showObjectDetail: (id) object withIndexPath:(NSIndexPath *) indexPath
{
    if( [object class] == [LTUser class]) {
        LTUser *user = (LTUser*) object;
        
        
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
                cellRect=[self.objectTableView rectForRowAtIndexPath:indexPath];
            
            CGRect showRect=CGRectMake(cellRect.origin.x + cellRect.size.width - 40,
                                       cellRect.origin.y + cellRect.size.height/2,
                                       1, 1);
            
            self.popoverController=[[UIPopoverController alloc] initWithContentViewController:nav];
            self.popoverController.delegate=self;
            if ([_mysearchdisplaycontroller isActive])
                [self.popoverController presentPopoverFromRect:showRect inView:_mysearchdisplaycontroller.searchResultsTableView permittedArrowDirections:UIPopoverArrowDirectionAny  animated:YES];
            else
                [self.popoverController presentPopoverFromRect:showRect inView:self.objectTableView permittedArrowDirections:UIPopoverArrowDirectionAny  animated:YES];
        }
        return;
    } 
}

- (void) setObjects:(NSArray *) objects {
    
	NSArray * array = [objects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 respondsToSelector:@selector(lastUpdate)] && [obj2 respondsToSelector:@selector(lastUpdate)])
        {
            return [[obj2 lastUpdate] compare: [obj1 lastUpdate]];
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
	self.objectList = array;
	[self.objectTableView reloadData];
}

- (void) hideSearchBar {
    CGFloat searchBarHeight = 44;
    if ([self.objectTableView contentOffset].y < searchBarHeight)
        [self.objectTableView setContentOffset:CGPointMake(0, searchBarHeight)];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [self.filteredListContent removeAllObjects]; // First clear the filtered array.

    for(LTObject<LTTableObjectProtocol> *object in self.objectList) {
		if( [object shouldAppearInContentForSearchText: searchText scope: scope] ) {
			[self.filteredListContent addObject: object];
        }
    }
}

#pragma mark -
#pragma mark UIViewController methods

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization.
    }
    return self;
}
 
- (void) viewWillAppear:(BOOL)animated {
    CGRect frame = self.view.frame;
    frame.origin = CGPointMake(0, 0);
    self.objectTableView.frame=frame;
    
    [super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden: NO animated: NO];
	[self.objectTableView reloadData];
    
    
}

- (void) loadView
{
    self.view=[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.objectTableView=[[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStylePlain];
    self.objectTableView.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.objectTableView];
    
    
    self.objectTableView.delegate=self;
    self.objectTableView.dataSource=self;
    
    self.scrollViewToLayout = self.objectTableView;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Background color
    UIImage * image=[UIImage imageNamed:@"profile-background"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    self.objectTableView.backgroundColor = [UIColor colorWithPatternImage:image];
    
    //Title bar
	[self localize];
    
    
    
    //Search Display Controller stuff
    self.filteredListContent=[NSMutableArray arrayWithCapacity:5];
    CGRect rect=[[UIScreen mainScreen] applicationFrame];
    UISearchBar * theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,rect.size.width,44)];
    
    self.objectTableView.tableHeaderView=theSearchBar;
    _mysearchdisplaycontroller = [[UISearchDisplayController alloc] initWithSearchBar:theSearchBar contentsController:self ];
    
    _mysearchdisplaycontroller.delegate = self;
    _mysearchdisplaycontroller.searchResultsDataSource = self;
    _mysearchdisplaycontroller.searchResultsDelegate = self;
    _mysearchdisplaycontroller.searchResultsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    
    _mysearchdisplaycontroller.searchBar.scopeButtonTitles=[NSArray arrayWithObjects:
                                                              NSLocalizedString(@"Name", @"Name"),
                                                              NSLocalizedString(@"Learning", @"Learning"),
                                                              NSLocalizedString(@"Native", @"Native"),
                                                              NSLocalizedString(@"All", @"All"),
                                                              nil];
    
    if (self.savedSearchTerm) {
        [_mysearchdisplaycontroller setActive:self.searchWasActive];
        [_mysearchdisplaycontroller.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [_mysearchdisplaycontroller.searchBar setText:self.savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
    
    _mysearchdisplaycontroller.searchBar.backgroundImage = [[UIImage imageNamed:@"search-orange"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    _mysearchdisplaycontroller.searchBar.tintColor = [UIColor colorFromImage:[UIImage imageNamed:@"search-orange"]];
    _mysearchdisplaycontroller.searchResultsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    
    self.navigationItem.leftBarButtonItem = [GeneralHelper plainBarButtonItemWithText:nil image:[UIImage imageNamed:@"arrow-back"] target:self selector:@selector(popViewController)];
    
    /*  Disable AdInheritanceViewController   */
    //self.disableAds = YES;
}

- (void) popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [_mysearchdisplaycontroller isActive];
    self.savedSearchTerm = [_mysearchdisplaycontroller.searchBar text];
    self.savedScopeButtonIndex = [_mysearchdisplaycontroller.searchBar selectedScopeButtonIndex];
}

- (void)dealloc {
	[[LTDataSource sharedDataSource] removeFromRequestDelegates: self];	

    self.filteredListContent = nil;
    
    self.objectTableView.delegate = nil;
    self.objectTableView.dataSource = nil;
    self.objectTableView=nil;
    
    
    //Usual problems with search display controller
    _mysearchdisplaycontroller.delegate = nil;
    _mysearchdisplaycontroller.searchResultsDataSource = nil;
    _mysearchdisplaycontroller.searchResultsDelegate = nil;
    
    
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


@end
