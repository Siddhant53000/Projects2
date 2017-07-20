//
// LTChat.h
// LextTalk
//
//  Created by David on 11/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LTObject.h"
#import "LTTableObjectProtocol.h"

@interface LTChat : LTObject <LTTableObjectProtocol,UIAlertViewDelegate>{
	NSInteger       _userId;
	NSString        *_userName;
    NSString * speakingLang;
    NSString * learningLang;
    NSInteger speakingFlag;
    NSInteger learningFlag;
	
	NSMutableArray  *_messages;
    NSInteger       _unreadMessages;
}

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, assign) NSInteger unreadMessages;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) NSString * speakingLang;
@property (nonatomic, strong) NSString * learningLang;
@property (nonatomic, assign) NSInteger speakingFlag;
@property (nonatomic, assign) NSInteger learningFlag;

@property (nonatomic, strong) NSString * url;//user image
@property (nonatomic, strong) NSDate * urlUpdateDate;
@property (nonatomic, strong) NSDate * activityUpdateDate;
@property (nonatomic, strong) NSDate * lastUpdateDate;
@property (nonatomic, assign) BOOL userDeleted;
@property (nonatomic, assign) NSInteger totalNumber;
@property (nonatomic, strong) NSDate * lastDate;

+ (LTChat*) newChat;

- (NSString*) newestMessage;
- (NSString*) oldestMessage;

@end
