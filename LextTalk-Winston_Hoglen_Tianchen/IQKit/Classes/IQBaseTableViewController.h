//
//  IQBaseTableViewController.h
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "IQSkin.h"

@interface IQBaseTableViewController : UIViewController < UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate, IQSkinProtocol>{
	IBOutlet UITableView				*tableView;
	IBOutlet UIActivityIndicatorView	*indicatorView;
	
    NSMutableArray						*_filteredList;
    
	// The saved state of the search UI if a memory warning removed the view.
    NSString                            *_savedSearchTerm;
    NSInteger                           _savedScopeButtonIndex;
    BOOL                                _searchWasActive;    
	
	// EGO refresh table stuff
	BOOL								_showRefreshView;
	EGORefreshTableHeaderView			*_refreshHeaderView;	
	BOOL								_reloading;
	
	// editing stuff
	BOOL								_allowEditing;
}

@property (nonatomic, strong) NSMutableArray *filteredList;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshHeaderView; 
@property (nonatomic) BOOL searchWasActive;
@property (nonatomic) BOOL showRefreshView;
@property (nonatomic) BOOL allowEditing;

- (void) startUpdateProcess;
- (void) updateDone;
- (id) objectInTableView: (UITableView*) theTableView atIndexPath: (NSIndexPath *)indexPath;

@end
