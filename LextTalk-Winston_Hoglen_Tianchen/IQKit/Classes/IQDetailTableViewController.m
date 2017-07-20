//
//  IQDetailTableViewController.m
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import "IQDetailTableViewController.h"
#import "IQNavigationProtocol.h"
#import "IQTableObject.h"

@implementation IQDetailTableViewController
@synthesize mainObject = _mainObject;
@synthesize sectionList = _sectionList;
@synthesize sectionTitleList = _sectionTitleList;

#pragma mark -
#pragma mark UITableViewDelegate methds

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(indexPath.section == 0) {
		return [self.mainObject detailCellHeightInTableView: theTableView];
	}
	
	NSArray *array = [self.sectionList objectAtIndex: indexPath.section-1];
	IQObject <IQTableViewProtocol> *object = [array objectAtIndex: indexPath.row];

	if( [object respondsToSelector: @selector(cellHeightInTableView:)] ) {
		return [object cellHeightInTableView: theTableView];
	}
	return 44;	
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];

	if(indexPath.section == 0) {
		return;
	}
		
	NSArray *array = [self.sectionList objectAtIndex: indexPath.section-1];
	IQObject <IQNavigationProtocol> *object = [array objectAtIndex: indexPath.row];
	
	if( [object respondsToSelector: @selector(selectedInViewController:)] ) 
		return [object selectedInViewController: self];
}

- (BOOL)tableView:(UITableView *)theTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSString *)tableView:(UITableView *) theTableView titleForHeaderInSection:(NSInteger)section {

	if(section == 0 ) return nil;
	
	NSString *result = [self.sectionTitleList objectAtIndex: section-1];
	return result;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	if (theTableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
		return [self.sectionList count] + 1;
	}
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	
	if(section == 0) return 1;
	
	NSArray *array = [self.sectionList objectAtIndex: section-1];	
	return [array count];
}

- (UITableViewCell *)tableView:(UITableView *) theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	IQObject <IQTableViewProtocol> *object = [self objectInTableView: theTableView atIndexPath: indexPath];
	
	if(object == self.mainObject) {
		return [self.mainObject detailCellInTableView: theTableView];
	}
	
	return [object cellInTableView: theTableView searchResult: NO];
}

#pragma mark -
#pragma mark IQDetailTableViewController methods

- (id) objectInTableView:(UITableView *)theTableView atIndexPath:(NSIndexPath *)indexPath {
	if (theTableView == self.searchDisplayController.searchResultsTableView) { // filtered results (no ADs)
		return [self.filteredList objectAtIndex: indexPath.row];
    } else {
		if(indexPath.section == 0) return self.mainObject;
	
		NSArray *list = [self.sectionList objectAtIndex: (indexPath.section-1)];
		return [list objectAtIndex: indexPath.row];
	}
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [self.filteredList removeAllObjects]; // First clear the filtered array.
    
	for(NSArray *objects in self.sectionList) {
		for(IQObject<IQTableViewProtocol> *object in objects) {
			if([object shouldAppearInContentForSearchText: searchText scope: scope]) {
				[self.filteredList addObject: object];
			}
		}
	}
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

- (void) viewWillDisappear:(BOOL)animated {

	IQTableObject *object = (IQTableObject*) self.mainObject;
	if( [object respondsToSelector: @selector(cancelUpdateDelegates)] ) {
		[object cancelUpdateDelegates];
	}
	
	for(NSArray *a in self.sectionList) {
		for(IQTableObject *o in a) {
			if( [o respondsToSelector: @selector(cancelUpdateDelegates)] ) {
				[o cancelUpdateDelegates];
			}			
		}
	}
	[super viewWillDisappear: animated];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


@end
