//
//  LTChatroom.h
//  LextTalk
//
//  Created by Héctor on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LTObject.h"

@interface LTChatroom : LTObject

@property (nonatomic, assign) NSInteger chatroomId;
@property (nonatomic, strong) NSString *chatroomName;
@property (nonatomic, strong) NSString *lang;
@property (nonatomic, assign, getter = isUserIn) BOOL userIn;
@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, assign) NSInteger userNumber;
// Compatibility with chat object:
@property (nonatomic, assign) NSInteger messageNumber;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *learningLang;
@property (nonatomic, strong) NSString *speakingLang;
@property (nonatomic, assign) NSInteger unreadMessages;
@property (nonatomic, strong) NSMutableArray *messages;

+ (LTChatroom*) newChatroomWithDict: (NSDictionary*) d;

- (BOOL) shouldAppearInContentForSearchText:(NSString *) searchText scope:(NSString *) scope;

@end
