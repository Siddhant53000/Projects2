//
//  ChatRoomListViewController.h
//  LextTalk
//
//  Created by Yo on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTDataDelegate.h"
#import "CreateChatRoomViewController.h"

@interface ChatRoomListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate, LTDataDelegate, UISearchBarDelegate, UISearchDisplayDelegate, CreateChatRoomViewControllerDelegate, UIAlertViewDelegate>
{
    UITableView * myTableView;
    UIPopoverController * popoverController;
    
    NSArray * chatrooms;
    BOOL isSearch;
    
    NSMutableArray * searchArray;
    NSString * savedSearchTerm;
    BOOL searchWasActive;
    NSInteger savedScopeButtonIndex;
    
	BOOL reloading;
    
    //In case it is used as search result
    NSString * lang;
    NSString * searchText;
    
    BOOL checkNewMessagesInChatrooms;
}

@property (nonatomic, strong) NSArray *chatrooms;
@property (nonatomic) BOOL isSearch;
@property (nonatomic, strong) NSString * lang;
@property (nonatomic, strong) NSString * searchText;

- (void) updateChatRooms;
- (void) newMessagesInChatroom:(NSInteger) chatroomId;
- (void) reloadController:(BOOL) checkNewMessagesInChatrooms2;
- (void) markAsReadChatroom:(NSInteger) chatroomId;


@end
