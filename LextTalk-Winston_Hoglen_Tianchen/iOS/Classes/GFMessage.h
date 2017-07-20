//
//  GFMessage.h
// LextTalk
//
//  Created by David on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GFObject.h"
#import "GFTableObjectProtocol.h"

typedef enum {
	DELIVER_NEW = 0,
	DELIVER_STARTED,
	DELIVER_FINISHED,
	DELIVER_NONE,
	DELIVER_FAIL
} DeliverStatus;

@interface GFMessage : GFObject <GFTableObjectProtocol>{
	NSInteger		_messageId;
	NSInteger		_senderId;
	NSInteger		_senderTeamId;
	NSString		*_senderName;
	NSInteger		_destId;
	NSInteger		_destTeamId;
	NSString		*_destName;
	NSString		*_timestamp;
	NSInteger		_eventId;
	NSString		*_eventName;
	NSString		*_body;
	DeliverStatus	_deliverStatus;
}

@property (nonatomic, assign) NSInteger		messageId;
@property (nonatomic, assign) NSInteger		senderId;
@property (nonatomic, assign) NSInteger		senderTeamId;
@property (nonatomic, retain) NSString		*senderName;
@property (nonatomic, assign) NSInteger		destId;
@property (nonatomic, assign) NSInteger		destTeamId;
@property (nonatomic, retain) NSString		*destName;
@property (nonatomic, retain) NSString		*timestamp;
@property (nonatomic, assign) NSInteger		eventId;
@property (nonatomic, retain) NSString		*eventName;
@property (nonatomic, retain) NSString		*body;
@property (nonatomic, assign) DeliverStatus	deliverStatus;

+ (GFMessage*) newMessageWithDict: (NSDictionary*) d;
- (NSComparisonResult)compare:(GFMessage *)anotherMessage;

@end
