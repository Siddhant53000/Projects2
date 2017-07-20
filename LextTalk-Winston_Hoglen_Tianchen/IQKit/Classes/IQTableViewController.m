//
//  IQTableViewController.m
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import "IQObject.h"
#import "IQTableObject.h"
#import "IQTableViewProtocol.h"
#import "IQTableViewController.h"
#import "IQNavigationProtocol.h"

@implementation IQTableViewController
@synthesize objectList = _objectList;

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	
	if (theTableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredList count];
    } else {
		return [self.objectList count];
	}
}

#pragma mark -
#pragma mark IQTableViewController methods

- (id) objectInTableView: (UITableView*) theTableView atIndexPath: (NSIndexPath *)indexPath {
	if (theTableView == self.searchDisplayController.searchResultsTableView) { // filtered results (no ADs)
		return [self.filteredList objectAtIndex: indexPath.row];
    } else {
		return [self.objectList objectAtIndex: indexPath.row];		
	}
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [self.filteredList removeAllObjects]; // First clear the filtered array.
    
    for(IQObject<IQTableViewProtocol> *object in self.objectList) {
        if([object shouldAppearInContentForSearchText: searchText scope: scope]) {
            [self.filteredList addObject: object];
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

	for(IQTableObject *o in self.objectList) {
		if( [o respondsToSelector: @selector(cancelUpdateDelegates)] ) {
			[o cancelUpdateDelegates];
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
