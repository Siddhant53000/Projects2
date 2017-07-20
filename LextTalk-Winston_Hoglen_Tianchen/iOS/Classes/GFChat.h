//
//  GFChat.h
// LextTalk
//
//  Created by David on 11/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GFObject.h"
#import "GFTableObjectProtocol.h"

@interface GFChat : GFObject <GFTableObjectProtocol>{
	NSInteger       _userId;
	NSString        *_userName;
    NSInteger       _teamId;
	
	NSMutableArray  *_messages;
    NSInteger       _unreadMessages;
}

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, assign) NSInteger teamId;
@property (nonatomic, assign) NSInteger unreadMessages;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSMutableArray *messages;

+ (GFChat*) newChat;

- (NSString*) newestMessage;
- (NSString*) oldestMessage;

@end
