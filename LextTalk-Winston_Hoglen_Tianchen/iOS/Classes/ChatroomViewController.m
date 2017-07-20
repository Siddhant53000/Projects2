//
//  ChatroomViewController.m
//  LextTalk
//
//  Created by Héctor on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChatroomViewController.h"
#import "LTChatroom.h"
#import "LTDataSource.h"
#import "Flurry.h"
#import "LTMessage.h"
#import "LextTalkAppDelegate.h"
#import "UIColor+ColorFromImage.h"
#import "GeneralHelper.h"

@interface ChatroomViewController ()

@end

//Have to be exactly the same as parent class
#define MAX_MESSAGE_TEXT_LENGTH 249
#define TAB_BAR_HEIGHT 50
#define MAX_MESSAGES_IN_TABLE 25

@implementation ChatroomViewController

- (LTChatroom *)chatroom
{
    // In this class, chat is a chatroom indeed
    return (LTChatroom*)self.chat;
}

#pragma mark -
#pragma mark LTDataDelegate methods

- (void) didGetMessages:(NSArray *)messages withChatroomId:(NSInteger)chatroomId withTimestamp:(NSString *)timestamp
{
    // Store new messages and reload data
    
    //No vienen ordenados
    NSArray * messages2=[messages sortedArrayUsingSelector:@selector(compare:)];
    
    /*
    for (LTMessage * message in messages2)
    {
        NSLog(@"Message text: %@", message.body);
        NSLog(@"Time stamp: %@", message.timestamp);
    }
     */
     
    //Prevenir que el último mensaje llegue repetido: Puede ocurrir cuando se tiene la chatroom cargada, la app está en
    //segundo plano, llega un menaje, y se hace tap en la notificación para lanzar la app.
    if ([[messages2 lastObject] messageId]!=[[self.chatroom.messages lastObject] messageId])
    {
        [self.chatroom.messages addObjectsFromArray:messages2];
        self.chatroom.timestamp = timestamp;
        [self updateChatViewController];
        
        if (self.visible)
        {
            //I record the id of the last message of this chat room.
            //I will use this information to know if a chatroom must be marked with new messages when the app is open
            if ([self.chatroom.messages count]>0)
            {
                LTMessage * message=[self.chatroom.messages lastObject];
                [[LTDataSource sharedDataSource] setLastMessageRead:message.messageId inChatroom:self.chatroom.chatroomId];
            }
            
            LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
            [del.chatRoomListViewController markAsReadChatroom:self.chatroom.chatroomId];
        }
        messagesDownloaded=YES;
    }
}

- (void) didSendMessage
{
    // Update messages list to get the new message
	[[LTDataSource sharedDataSource] getMesssagesForChatroom:self.chatroom.chatroomId
                                                        user:[LTDataSource sharedDataSource].localUser.userId
                                                     editKey:[LTDataSource sharedDataSource].localUser.editKey
                                                        time:self.chatroom.timestamp
                                                       limit:0
                                                    delegate:self];
    // Reset UI
	[_indicatorView stopAnimating];
    self.sendButton.enabled = YES;
    [self.messageTextView setText:@""];
    
    //Fix for iOS 4.x
    CGSize contentSize=self.messageTextView.contentSize;
    contentSize.height=34;
    self.messageTextView.contentSize=contentSize;
    
    [self textViewDidChange:self.messageTextView];
}

- (void)didEnterChatroom
{
    self.chatroom.userIn = YES;
    self.navigationItem.rightBarButtonItem = [GeneralHelper plainBarButtonItemWithText:(self.chatroom.userIn)?NSLocalizedString(@"Leave", nil):NSLocalizedString(@"Join", nil) image:nil target:self selector:@selector(enterOrLeaveChatroom:)];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    // these properties are used for compatibility with regular chats code
    self.chatroom.userId = [LTDataSource sharedDataSource].localUser.userId;
    self.chatroom.speakingLang = [[LTDataSource sharedDataSource].localUser.speakingLanguages lastObject];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JoinedChatroomsChanged" object:self];
}

- (void)didLeaveChatroom
{
    self.chatroom.userIn = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JoinedChatroomsChanged" object:self];
    self.navigationItem.rightBarButtonItem = [GeneralHelper plainBarButtonItemWithText:(self.chatroom.userIn)?NSLocalizedString(@"Leave", nil):NSLocalizedString(@"Join", nil) image:nil target:self selector:@selector(enterOrLeaveChatroom:)];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    // these properties are used for compatibility with regular chats code
    self.chatroom.userId = NSIntegerMin;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didFail:(NSDictionary *)result
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [super didFail:result];
}

#pragma mark -
#pragma mark UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((buttonIndex==0) && (alertView.tag==404))
    {
        LextTalkAppDelegate * del = (LextTalkAppDelegate *) [[UIApplication sharedApplication] delegate];
        del.showingError = NO;
    }
}

#pragma mark -
#pragma mark IBAction methods

- (IBAction) sendMessage {
    [Flurry logEvent:@"SEND_MESSAGE_ACTION"];
    
    if(self.sendButton.enabled && (self.messageTextView.text.length > 0)){
        //[self.messageTextView resignFirstResponder];
        self.sendButton.enabled = NO;
        
        if (!self.chatroom.isUserIn) {
            // the user was not joined to the chat, so join now
            [[LTDataSource sharedDataSource] enterChatroom:self.chatroom.chatroomId
                                                    userId:[LTDataSource sharedDataSource].localUser.userId
                                                     limit:0
                                               withEditKey:[LTDataSource sharedDataSource].localUser.editKey
                                                  delegate:self];
        }
        
        [[LTDataSource sharedDataSource] sendMessage: self.messageTextView.text
                                          toChatroom: self.chatroom.chatroomId
                                            fromUser: [[LTDataSource sharedDataSource] localUser].userId
                                         withEditKey: [[LTDataSource sharedDataSource] localUser].editKey
                                            delegate: self];
        [_indicatorView startAnimating];
    }
}

- (IBAction)enterOrLeaveChatroom:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (self.chatroom.isUserIn) {
        // the user is already in, so he wants to leave the chatroom:
        [[LTDataSource sharedDataSource] leaveChatroom:self.chatroom.chatroomId
                                                  user:[LTDataSource sharedDataSource].localUser.userId
                                               editKey:[LTDataSource sharedDataSource].localUser.editKey
                                              delegate:self];
    } else {
        // the user wants to enter the chatroom:
        [[LTDataSource sharedDataSource] enterChatroom:self.chatroom.chatroomId
                                                userId:[LTDataSource sharedDataSource].localUser.userId
                                                 limit:0
                                           withEditKey:[LTDataSource sharedDataSource].localUser.editKey
                                              delegate:self];
    }
}

#pragma mark -
#pragma mark ChatViewController methods

- (void) updateChatViewController
{
	if( ![[LTDataSource sharedDataSource] isUserLogged] ) {
        // user is no longer logged in, leave this view
		[self.navigationController popViewControllerAnimated: NO];
		return;
	}
    
    self.title = self.chatroom.chatroomName;
    
    if(self.chat == nil) {
		IQVerbose(VERBOSE_DEBUG,@"No chatroom to display!!");
        //[chatTableView reloadData];        
        return; 
    }
    
    showLoadMoreButton=NO;
    if([self.chat.messages count] > 0)
    {
        
        NSIndexPath * indexPath=[NSIndexPath indexPathForRow:[self.chat.messages count] -1 inSection:1];
        [self.chatTableView reloadData];
        
        [self.chatTableView scrollToRowAtIndexPath: indexPath
                              atScrollPosition: UITableViewScrollPositionTop
                                      animated: NO];
	}
    
    
    IQVerbose(VERBOSE_DEBUG,@"[%@] updateChatViewController: marking all messages as read", [self class]);
    if (self.chat)
        [self messagesDelivered];
}

- (void) downloadMessagesFromServer
{
    NSString * time=nil;
    if ([self.chatroom.messages count]!=0)
        time=self.chatroom.timestamp;
    [[LTDataSource sharedDataSource] getMesssagesForChatroom:self.chatroom.chatroomId
                                                        user:[LTDataSource sharedDataSource].localUser.userId
                                                     editKey:[LTDataSource sharedDataSource].localUser.editKey
                                                        time:time
                                                       limit:NSIntegerMin
                                                    delegate:self];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [GeneralHelper plainBarButtonItemWithText:(self.chatroom.userIn)?NSLocalizedString(@"Leave", nil):NSLocalizedString(@"Join", nil) image:nil target:self selector:@selector(enterOrLeaveChatroom:)];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.chatroom.messages count]==0)
    {
        [[LTDataSource sharedDataSource] getMesssagesForChatroom:self.chatroom.chatroomId
                                                            user:[LTDataSource sharedDataSource].localUser.userId
                                                         editKey:[LTDataSource sharedDataSource].localUser.editKey
                                                            time: nil
                                                           limit:NSIntegerMin
                                                        delegate:self];
    }
    
    //I record the id of the last message of this chat room.
    //I will use this information to know if a chatroom must be marked with new messages when the app is opened
    if ([self.chatroom.messages count]>0)
    {
        LTMessage * message=[self.chatroom.messages lastObject];
        [[LTDataSource sharedDataSource] setLastMessageRead:message.messageId inChatroom:self.chatroom.chatroomId];
    }
    
    //Marcar todos como leídos
    if (messagesDownloaded)
    {
        LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
        [del.chatRoomListViewController markAsReadChatroom:self.chatroom.chatroomId];
        
        messagesDownloaded=NO;
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark NSObject methods

- (void)dealloc
{
    [[LTDataSource sharedDataSource] removeFromRequestDelegates:self];
    // chatroom is released in super's dealloc
}

@end
