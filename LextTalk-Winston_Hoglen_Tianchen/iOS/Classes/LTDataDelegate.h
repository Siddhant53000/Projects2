/*
 *  GFDataDelegate.h
 *  GlocalFans
 *
 *  Created by David on 11/30/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
#import "LTUser.h"

@protocol LTDataDelegate<NSObject>
@optional
- (void) didCreateUser;
- (void) didLoginUser;
- (void) didUpdateUser;
- (void) didFailUpdatingUser;
- (void) didLogoutUser;
- (void) didCheckIfUserExists:(BOOL) exists;

- (void) didBlockUser:(NSInteger) userId withBlockStatus:(BOOL) block;
- (void) didDeleteLocalUser;
- (void) didRememberPassword;

//- (void) didUpdateSearchResults;

- (void) didUpdateSearchResultsChatrooms: (NSArray*) results;

//- (void) didGetMessages:(NSArray*)messages withTimestamp:(NSString*)timestamp;

- (void) didUpdateSearchResultsUsers: (NSArray*) results;
- (void) didUpdateUserStatistics: (NSArray*) userStats;
- (void) didUpdateDistanceStatistics: (NSArray*) distanceStats;
- (void) didUpdateLangStatistics: (NSArray*) teamStats;

- (void) didUpdateListOfEvents;
- (void) didGetListOfUserEvents: (NSMutableArray*) userEvents;
- (void) didGetListOfAttUserEvents: (NSMutableArray*) attUserEvents;

- (void) didGetListOfAttendants: (NSArray*) attendants;

- (void) didSendMessage;
- (void) didSendMessageAndHasPendingMessages:(BOOL) hasMessages;
- (void) didGetListOfMessages;

- (void) didGetUser: (LTUser*) user;

- (void) didCreateChatroom:(NSInteger)chatroom_id;

- (void) didLeaveChatroom;

- (void) didEnterChatroom;

- (void) didGetMessages:(NSArray *)messages withChatroomId:(NSInteger) chatroomId withTimestamp:(NSString *)timestamp;

- (void) didConnectToFacebookForContacts;
- (void) didTestFacebookForContacts:(BOOL) fbAvailable;

@required
- (void) didFail: (NSDictionary*) result;

@end
