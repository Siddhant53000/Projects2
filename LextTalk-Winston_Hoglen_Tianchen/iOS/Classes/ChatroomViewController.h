//
//  ChatroomViewController.h
//  LextTalk
//
//  Created by Héctor on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChatViewController.h"
#import "LTChatroom.h"
#import "TutViewController.h"

@interface ChatroomViewController : ChatViewController
{
    BOOL messagesDownloaded;
}

@property (strong, nonatomic) TutViewController *tut;
@property (strong, nonatomic) UIButton *removeTutBtn;
@property (weak, nonatomic, readonly) LTChatroom *chatroom;

- (void) downloadMessagesFromServer;

@end

