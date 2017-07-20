//
//  MasterChatViewController.h
//  LextTalk
//
//  Created by Yo on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdInheritanceViewController.h"
#import "ChatListViewController.h"
#import "ChatRoomListViewController.h"
#import <Google/Analytics.h>

@interface MasterChatViewController : AdInheritanceViewController <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate>
{
    ChatListViewController * chatListViewController;
    ChatRoomListViewController * chatRoomListViewController;
    UIPopoverController * popoverController;
    
    NSInteger chatsNotRead;
}

@property (nonatomic, strong) UITableView * myTableView;
@property (nonatomic, strong) ChatListViewController * chatListViewController;
@property (nonatomic, strong) ChatRoomListViewController * chatRoomListViewController;
@property (nonatomic, strong) UIPopoverController * popoverController;
@property (nonatomic) NSInteger chatsNotRead;

@end
