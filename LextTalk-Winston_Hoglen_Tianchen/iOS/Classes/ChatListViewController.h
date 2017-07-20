//
//  ChatListViewController.h
// LextTalk
//
//  Created by David on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTDataSource.h"
#import "ChatViewController.h"
#import "IQKit.h"
#import "LocalUserViewController.h"
#import <Google/Analytics.h>
#import "TutViewController.h"

@interface ChatListViewController : UIViewController < UITableViewDelegate, UITableViewDataSource, LTDataDelegate, IQLocalizableProtocol, UIAlertViewDelegate, PushControllerProtocol, UIPopoverControllerDelegate, UISearchDisplayDelegate>{
	IBOutlet UITableView				*chatTableView;
	IBOutlet UIActivityIndicatorView	*indicatorView;
	
	NSMutableArray						*__weak _chatList;
    NSMutableArray						*_filteredListContent;
    
	// The saved state of the search UI if a memory warning removed the view.
    NSString                            *_savedSearchTerm;
    NSInteger                           _savedScopeButtonIndex;
    BOOL                                _searchWasActive;    
	
	NSInteger							_chatWithUserId;
	
	BOOL		_reloading;
}

@property (nonatomic, strong) IBOutlet UITableView				*chatTableView;

@property (nonatomic, strong) TutViewController *tut;
@property (nonatomic,strong) UIButton *removeTutBtn;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView	*indicatorView;

@property (nonatomic, weak) NSMutableArray *chatList;
@property (nonatomic, strong) NSMutableArray *filteredListContent;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;	

- (void) startUpdateProcess;

@end
