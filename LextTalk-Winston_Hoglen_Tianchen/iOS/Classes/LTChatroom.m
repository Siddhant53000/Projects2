//
//  LTChatroom.m
//  LextTalk
//
//  Created by Héctor on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LTChatroom.h"
#import "LTChat.h"
#import "LanguageReference.h"

@interface LTChatroom ()
@end

@implementation LTChatroom
@synthesize chatroomId, chatroomName, lang, messageNumber;
@synthesize messages = _messages;
@synthesize unreadMessages = _unreadMessages;
@synthesize userId = _userId;
@synthesize speakingLang;
@synthesize userIn;
@synthesize timestamp;
@synthesize userNumber;

+ (LTChatroom*) newChatroomWithDict: (NSDictionary*) d {
    //NSLog(@"Dic: %@", d);
    LTChatroom *result = [[LTChatroom alloc] init];
    result.chatroomId = [result integerForKey: @"chatroom_id" inDict: d];
    result.chatroomName = [result stringForKey: @"chatroom_name" inDict: d];
    result.lang = [result stringForKey: @"lang" inDict: d];
    result.messageNumber = [result integerForKey: @"message_number" inDict: d];
    result.userIn = [result boolForKey: @"user_in" inDict: d];
    result.userNumber = [result integerForKey: @"users_number" inDict: d];
    
    NSString * str=[result stringForKey:@"timestamp" inDict:d];
    if (![str isKindOfClass:[NSString class]])
        result.timestamp=@"2010-01-01 00:00:00";
    else 
        result.timestamp = str;
     
    result.messages = [NSMutableArray array];
	return result;	
}

- (BOOL) shouldAppearInContentForSearchText:(NSString *) searchText scope:(NSString *) scope
{
    NSString * translatedLang=[LanguageReference getLanForAppLan:[LanguageReference appLan] andMasterLan:self.lang];
    
    BOOL result=NO;
    if ([scope isEqualToString:NSLocalizedString(@"Name", @"Name")] || [scope isEqualToString:NSLocalizedString(@"All", @"All")])
    {
        if([self.chatroomName rangeOfString: searchText options: NSCaseInsensitiveSearch].location != NSNotFound)
            result=YES;
    }
    if ([scope isEqualToString:NSLocalizedString(@"Language", @"Language")] || [scope isEqualToString:NSLocalizedString(@"All", @"All")])
    {
        if([translatedLang rangeOfString: searchText options: NSCaseInsensitiveSearch].location != NSNotFound)
            result=YES;
    }
    return result;
}

- (NSString *)learningLang
{
    return self.lang;
}

- (void)setLearningLang:(NSString *)learningLang
{
    self.lang = learningLang;
}

#pragma mark -
#pragma mark NSObject methods

- (void) dealloc {
    chatroomName = nil;
    lang = nil;
    _messages = nil;
    timestamp = nil;
    
}

@end
