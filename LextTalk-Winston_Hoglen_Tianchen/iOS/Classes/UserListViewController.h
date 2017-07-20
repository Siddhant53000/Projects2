//
//  UserListViewController.h
// LextTalk
//
//  Created by David on 11/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdInheritanceViewController.h"
#import "LTDataSource.h"
#import "IQKit.h"
#import "LocalUserViewController.h"


@interface UserListViewController : AdInheritanceViewController <UISearchDisplayDelegate, UISearchBarDelegate, LTDataDelegate, IQLocalizableProtocol, UIPopoverControllerDelegate, PushControllerProtocol, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_filteredListContent;
    
	// The saved state of the search UI if a memory warning removed the view.
    NSString		*_savedSearchTerm;
    NSInteger		_savedScopeButtonIndex;
    BOOL			_searchWasActive;    
	
	NSArray			*_objectList;
    
    UIPopoverController * popoverController;
}


@property (nonatomic, strong) NSMutableArray *filteredListContent;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

@property (nonatomic, strong) UITableView * objectTableView;

@property (nonatomic, strong) NSArray *objectList;

- (void) setObjects:(NSArray *) objects;

@property (nonatomic, strong) UIPopoverController * popoverController;

@end
