//
//  LTMessage.h
// LextTalk
//

#import <Foundation/Foundation.h>
#import "LTObject.h"
#import "LTTableObjectProtocol.h"

typedef NS_ENUM(NSUInteger, DeliverStatus) {
	DELIVER_NEW = 0,
	DELIVER_STARTED,
	DELIVER_FINISHED,
	DELIVER_NONE,
	DELIVER_FAIL
};

@interface LTMessage : LTObject <LTTableMessageProtocol>{
	NSInteger		_messageId;
	NSInteger		_senderId;
	NSString		*_senderName;
	NSInteger		_destId;
	NSString		*_destName;
	NSString		*_timestamp;
    NSString		*_body;
	DeliverStatus	_deliverStatus;
    
    NSString * senderLearningLan;
    NSString * senderSpeakingLan;
    NSInteger senderLearningFlag;
    NSInteger senderSpeakingFlag;
    NSString * destLearningLan;
    NSString * destSpeakingLan;
    NSInteger destLearningFlag;
    NSInteger destSpeakingFlag;
}

@property (nonatomic, assign) NSInteger		messageId;
@property (nonatomic, assign) NSInteger		senderId;
@property (nonatomic, strong) NSString		*senderName;
@property (nonatomic, assign) NSInteger		destId;
@property (nonatomic, strong) NSString		*destName;
@property (nonatomic, strong) NSString		*timestamp;
//AO
//@property (nonatomic, strong) UITextView		*body;
//
@property (nonatomic, strong) NSString		*body;
//
@property (nonatomic, assign) DeliverStatus	deliverStatus;

@property (nonatomic, strong) NSString * senderLearningLan;
@property (nonatomic, strong) NSString * senderSpeakingLan;
@property (nonatomic, assign) NSInteger senderLearningFlag;
@property (nonatomic, assign) NSInteger senderSpeakingFlag;
@property (nonatomic, strong) NSString * destLearningLan;
@property (nonatomic, strong) NSString * destSpeakingLan;
@property (nonatomic, assign) NSInteger destLearningFlag;
@property (nonatomic, assign) NSInteger destSpeakingFlag;

//Not saved in defaults. Just used when a translation has been done inside the chat
@property (nonatomic, strong) NSString * translatedText;

+ (LTMessage*) newMessageWithDict: (NSDictionary*) d;
- (NSComparisonResult)compare:(LTMessage *)anotherMessage;

@end
