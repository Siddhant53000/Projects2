//
//  ListsViewController.h
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 16/03/14.
//
//

#import <UIKit/UIKit.h>
#import "ChatListViewController.h"
#import "ChatRoomListViewController.h"
#import "AdInheritanceViewController.h"

@interface ListsViewController : AdInheritanceViewController

@property (nonatomic, strong) ChatListViewController * chatListViewController;
@property (nonatomic, strong) ChatRoomListViewController * chatRoomListViewController;
@property (nonatomic) BOOL chatSelected;

@end
