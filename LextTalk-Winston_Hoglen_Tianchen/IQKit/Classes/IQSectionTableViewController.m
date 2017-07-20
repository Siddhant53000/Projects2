//
//  IQSectionTableViewController.m
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import "IQObject.h"
#import "IQTableObject.h"
#import "IQTableViewProtocol.h"
#import "IQSectionTableViewController.h"
#import "IQNavigationProtocol.h"

@implementation IQSectionTableViewController
@synthesize sectionList = _sectionList;
@synthesize sectionTitleList = _sectionTitleList;

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSString *)tableView:(UITableView *) theTableView titleForHeaderInSection:(NSInteger)section {
	if (theTableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
		NSString *sectionTitle = [self.sectionTitleList objectAtIndex: section];
		return sectionTitle;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	if (theTableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
		return [self.sectionList count];
	}
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	
	if (theTableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredList count];
    } else {
		NSArray *objects = [self.sectionList objectAtIndex: section];
		return [objects count];
	}
}

#pragma mark -
#pragma mark IQSectionTableViewController methods

- (id) objectInTableView: (UITableView*) theTableView atIndexPath: (NSIndexPath *)indexPath {
	if (theTableView == self.searchDisplayController.searchResultsTableView) { // filtered results (no ADs)
		return [self.filteredList objectAtIndex: indexPath.row];
    } else {
		NSArray *list = [self.sectionList objectAtIndex: indexPath.section];
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
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/




@end
