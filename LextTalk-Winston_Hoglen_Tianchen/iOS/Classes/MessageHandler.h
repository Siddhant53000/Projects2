//
//  MessageHandler.h
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 08/02/14.
//
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "LTMessage.h"
#import "LTDataSource.h"
#import "LTChat.h"

@interface MessageHandler : NSObject
{
    sqlite3 * _messages;
}

+ (MessageHandler *) sharedInstance;
+ (void) installDatabase;
+ (void) deleteDatabase;

//Returns the userId of the Chat where the message was inserted
- (NSInteger) insertMessage:(LTMessage *) message;
- (void) insertMessages:(NSArray *) messages;

- (NSMutableArray *) chatLists;
- (LTChat *) chatListForUserId:(NSInteger) userId;

- (void) updateChatActivityVars:(LTChat *) chat;
- (void) updateUser:(LTChat *) chat withActivity:(NSDate *) date andUnread:(NSInteger) unread;

- (NSMutableArray *) last:(NSInteger) number messagesForUser:(NSInteger) userId moreAvailable:(BOOL *) moreAvailable;
- (void) markMessagesAsRead:(NSArray *) array;

- (void) deleteChatForUserId:(NSInteger) userId;
@end
