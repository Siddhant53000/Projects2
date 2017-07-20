//
//  IQBaseTableViewController.m
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import "IQObject.h"
#import "IQTableObject.h"
#import "IQBaseTableViewController.h"
#import "IQTableViewController.h"
#import "IQNavigationProtocol.h"

@interface IQBaseTableViewController (PrivateMethods)

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
- (id) objectInTableView: theTableView atIndexPath: indexPath;

@end

@implementation IQBaseTableViewController
@synthesize filteredList = _filteredList;
@synthesize savedSearchTerm = _savedSearchTerm;
@synthesize savedScopeButtonIndex = _savedScopeButtonIndex;
@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize searchWasActive = _searchWasActive;
@synthesize showRefreshView = _showRefreshView;
@synthesize allowEditing = _allowEditing;

#pragma mark -
#pragma mark IQSkinProtocol methods

- (void) applySkin: (IQSkin*) skin {
    if(!skin.active) return;
    
	[self.navigationController.navigationBar setTintColor: skin.navBarColor];
	[self.searchDisplayController.searchBar setTintColor: skin.navBarColor];
	[tableView setSeparatorColor: skin.cellSeparatorColor];
	
	[IQSkin setTitle: self.title ofColor: skin.navBarTextColor inViewController: self];	
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	[self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (BOOL)egoRefreshTableHeaderShouldTriggerRefresh:(EGORefreshTableHeaderView*) theView {
	return YES;
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*) theView{
	[self startUpdateProcess];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)theView{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)theView{
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	[self filterContentForSearchText: searchString 
							   scope: [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText: [self.searchDisplayController.searchBar text] 
							   scope: [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark -
#pragma mark UITableViewDelegate methds

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	IQObject <IQTableViewProtocol> *object = (IQObject<IQTableViewProtocol>*)[self objectInTableView: theTableView atIndexPath: indexPath];
	
	if( [object respondsToSelector: @selector(cellHeightInTableView:)] ) 
		return [object cellHeightInTableView: theTableView];
	
	return 44;	
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	IQObject <IQNavigationProtocol> *object = (IQObject<IQNavigationProtocol>*)[self objectInTableView: theTableView atIndexPath: indexPath];
	
	if( [object respondsToSelector: @selector(selectedInViewController:)] ) 
		return [object selectedInViewController: self];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *) theTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(!self.allowEditing) return UITableViewCellEditingStyleNone;
	
	IQObject <IQTableViewProtocol> *object = (IQObject<IQTableViewProtocol>*)[self objectInTableView: theTableView atIndexPath: indexPath];
	
	if([object respondsToSelector: @selector(editingStyleInTableView:)]) {
		return [object editingStyleInTableView: theTableView];
	}
	
	return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)theTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(!self.allowEditing) return;	
	
	IQObject <IQTableViewProtocol> *object = (IQObject<IQTableViewProtocol>*)[self objectInTableView: theTableView atIndexPath: indexPath];
	
	if( (editingStyle == UITableViewCellEditingStyleDelete) && [object respondsToSelector: @selector(deletedInTableView:andViewController:)] ) {
		return [object deletedInTableView: theTableView andViewController: self];
	}
}

- (BOOL)tableView:(UITableView *)theTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(!self.allowEditing) return NO;
	
	IQObject <IQTableViewProtocol> *object = (IQObject<IQTableViewProtocol>*)[self objectInTableView: theTableView atIndexPath: indexPath];
	
	if([object respondsToSelector: @selector(canBeEdited)]) {
		return [object canBeEdited];
	}
	
	return NO;
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	// override	
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	// override	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *) theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	IQObject<IQTableViewProtocol> *object = [self objectInTableView: theTableView atIndexPath: indexPath];
	
	if (theTableView == self.searchDisplayController.searchResultsTableView) { // filtered results (no ADs)
		return [object cellInTableView: theTableView searchResult: YES];
    } else {
		return [object cellInTableView: theTableView searchResult: NO];
	}
}

#pragma mark -
#pragma mark IQTableViewController methods

- (id) objectInTableView: (UITableView*) theTableView atIndexPath: (NSIndexPath *)indexPath {
	// overide in subclasses
	return nil;
}

- (void) hideSearchBar {
	if(self.searchDisplayController.searchBar == nil) return;
    CGFloat searchBarHeight = 44;
    if ([tableView contentOffset].y < searchBarHeight)
        [tableView setContentOffset:CGPointMake(0, searchBarHeight)];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	// override	
    [self.filteredList removeAllObjects]; // First clear the filtered array.
}

- (void) updateDone {
	_reloading = NO;
	[self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading: tableView];
	[indicatorView stopAnimating];
	[tableView reloadData];
}

- (void) startUpdateProcess {
	_reloading = YES;
	[indicatorView startAnimating];
	// Overload with appropriate update code
}

#pragma mark -
#pragma mark UIViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void) viewWillAppear:(BOOL)animated {
	[tableView reloadData];
	[self hideSearchBar];
	[self.navigationController setNavigationBarHidden: NO];	
	
	/*
	// relocate activity indicator
	CGFloat x = self.view.frame.size.width/2.0 - indicatorView.frame.size.width/2.0;
	CGFloat y = self.view.frame.size.height/2.0 - indicatorView.frame.size.height/2.0;
	if((indicatorView.frame.origin.x != x) || (indicatorView.frame.origin.y != y)) {
		CGRect newFrame = indicatorView.frame;
		newFrame.origin.x = x;
		newFrame.origin.y = y;
		[indicatorView setFrame: newFrame];	
	}
	*/
	[super viewWillAppear: animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	[self applySkin: [IQSkin defaultSkin]];
	
	self.filteredList = [[NSMutableArray alloc]  init];
	
	// restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm) {
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:self.savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
	
	if(!self.showRefreshView) return;
	
	self.refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, self.view.frame.size.width, tableView.bounds.size.height)];
	self.refreshHeaderView.delegate = self;
	[tableView addSubview:self.refreshHeaderView];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidDisappear:(BOOL)animated {
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

- (void)dealloc {
	self.searchDisplayController.delegate = nil;
    self.filteredList = nil;
    self.refreshHeaderView = nil;
}

@end
