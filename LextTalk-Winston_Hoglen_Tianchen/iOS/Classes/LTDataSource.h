//
//  LTDataSource.h
//  LextTalk
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "IQKit.h"
#import "LTUser.h"
#import "LTChat.h"
#import "LTMessage.h"
#import "LTDataDelegate.h"
#import "LTNotLoggedUser.h"
#import "MessageHandler.h"

#import <FacebookSDK/FacebookSDK.h>
extern NSString *const FBSessionStateChangedNotification;


typedef enum {
	LT_STATS_LANG  = 0,
	LT_STATS_DISTANCE,
	LT_STATS_USER
} LTStatsType;

extern NSString *const LTBaseURL;
extern NSString *const LTLangURL;

@class ASIFormDataRequest;

@interface LTDataSource : IQDataSource <CLLocationManagerDelegate, LTDataDelegate, UIAlertViewDelegate>{
	LTUser					*_localUser;
	LTNotLoggedUser			*_noUser;	
	NSMutableArray			*_userList;
	NSInteger				_completeResults;
	
    NSMutableArray			*_chatList;
	NSString				*_chatListTimestamp;

	// location stuff
    BOOL                    _usingLocation;
    CLLocationCoordinate2D  latestLocation;
	
	//Apple Push Notification Service token
	NSString                *_apnsToken;
	NSMutableArray			*_unreadedMessages;
	
}

@property(nonatomic, strong) LTUser *localUser;
@property(nonatomic, strong) LTNotLoggedUser *noUser;
@property(nonatomic, strong) NSMutableArray *userList;
@property(nonatomic, assign) NSInteger completeResults;
@property(nonatomic, strong) NSMutableArray *chatList;
@property(nonatomic, strong) NSString *chatListTimestamp;
@property(nonatomic, strong) NSMutableArray *unreadedMessages;
@property (nonatomic, assign) BOOL usingLocation;
@property (nonatomic, strong) NSString *apnsToken;

+ (BOOL) isLextTalkCatalan;
- (void) setAndSaveApnsToken: (NSString*) token;
- (void) restoreApnsToken;

//Facebook
typedef NS_ENUM(NSInteger, LTFacebookAction) {
    LTFacebookActionLogin = 0,
    LTFacebookActionContacts = 1,
    LTFacebookActionTestContacts = 2
};
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI withDelegate:(id<LTDataDelegate>) delegate withFacebokAction:(LTFacebookAction) action;
- (BOOL) handleFacebookUrl:(NSURL *) url;
- (void) handleFacebookDidBecomeActive;
- (void) handleFacebookApplicatinWillTerminate;
- (void) handleFacebookLogout;
- (void) handleFacebookShare:(NSString *) text andImage:(UIImage *)image;

+ (LTDataSource*) sharedDataSource;

- (void) createUser: (NSString*) name
	   withPassword: (NSString*) pwd
          withEmail: (NSString *) email
		   delegate: (id <LTDataDelegate>) del;


- (void) loginUser: (NSString*) name
	  withPassword: (NSString*) pwd 
		  delegate: (id <LTDataDelegate>) del;

- (void) restoreLoginWithDelegate: (id <LTDataDelegate>) del;

- (void) logoutWithDelegate: (id <LTDataDelegate>) del;

- (void) updateUser: (NSInteger) userId
		withEditKey: (NSString*) editKey
          saveImage: (BOOL) saveImage
		   delegate: (id <LTDataDelegate>) del;

- (void) blockUser:(NSInteger) userId withBlockStatus:(BOOL) block delegate:(id<LTDataDelegate>) del;

- (void) deleteLocalUserWithDelegate:(id<LTDataDelegate>) del;

- (void) getUserWithUserId:(NSInteger) userId andExecuteBlockInMainQueue:(void(^)(LTUser * user, NSError *error)) block;

- (void) rememberPasswordForEmail:(NSString *) email withDelegate:(id<LTDataDelegate>) del;
- (void) searchUserContacts:(NSArray *) emails withDelegate:(id<LTDataDelegate>) del useFacebook:(BOOL) useFacebook;
- (NSArray *) getUserContacts;
- (void) saveUserContacts: (NSArray *) array;
- (void) deleteUserFromStoredUserContactsFromChats: (LTUser * ) user;

- (void) sendMessage: (NSString*) msg
			  toUser: (NSInteger) receiverId
		 withEditKey: (NSString*) editKey
andExecuteBlockInMainQueue:(void(^)(BOOL hasPendingMessages , NSError *error)) block;

/*
- (void) searchInRegion: (MKCoordinateRegion) region
			   forUsers: (BOOL) users
               delegate: (id <LTDataDelegate>) del;
 */

- (void) searchUsers: (NSString *) name
         learningLan: (NSString *) learningLan
         speakingLan: (NSString *) speakingLan
            inRegion: (MKCoordinateRegion) region
       withBothLangs: (BOOL) bothLangs
            delegate: (id <LTDataDelegate>) del;


- (void) getMessagesForUser: (NSInteger) userId
				withEditKey: (NSString*) editKey
				   delegate: (id <LTDataDelegate>) del;


//Chatroom badge management
- (void) setLastMessageRead:(NSInteger) messageId inChatroom: (NSInteger) chatroomId;
- (NSInteger) lastMessageReadInChatroom:(NSInteger) chatroomId;
- (void) addChatroomToUnread:(NSInteger) chatroomId;
- (void) removeChatroomFromUnread:(NSInteger) chatroomId;
- (NSArray *) unreadChatrooms;




- (void) getUser: (NSInteger) userId
	withDelegate: (id <LTDataDelegate>) del;

- (BOOL) isUserLogged;
- (void) updateLocation;
- (void) updateLatestLocation: (CLLocationCoordinate2D) loc;
- (CLLocationCoordinate2D) latestLocation;

// chat management
- (LTChat*) chatForUserId: (NSInteger) userId;
- (void) deleteChatWithUserId: (NSInteger) userId;
- (void) updateChatList;

-(void)newSessionWithDelegate: (id) delegate;

- (void) getAdOrder;

// chat room

/**
 Creates a chatroom.
 @required name userId editKey
 @optional del
 */
- (void) createChatroom: (NSString*) name
             withUserId: (NSInteger) userId
                   lang: (NSString*) lang
                editKey: (NSString*) editKey
               delegate: (id) del;

/**
 Creates a chatroom.
 @optional keyword lang user_id del
 */
- (void) searchChatroom: (NSString *) keyword
                   lang: (NSString *) lang
                userId: (NSInteger) user_id
               delegate: (id <LTDataDelegate>) del;

/**
 Joins the local user to a chat room.
 @required chatroom_id user_id editKey
 @optional del limit
 */
- (void) enterChatroom: (NSInteger) chatroom_id
                userId: (NSInteger) user_id
                 limit: (NSInteger) limit
           withEditKey: (NSString *) editKey
              delegate: (id <LTDataDelegate>) del;

/**
 Retrieve messages from a chat room.
 @required chatroom_id 
 @optional del limit time user_id editKey
 */
- (void) getMesssagesForChatroom:(NSInteger)chatroom_id
                            user:(NSInteger)user_id
                         editKey:(NSString*)edit_key
                            time:(NSString*)time
                           limit:(NSInteger)limit
                        delegate:(id <LTDataDelegate>) del;

/**
 Send a message to a chat room.
 @required msg chatroom_id user_id editKey
 @optional del
 */
- (void) sendMessage: (NSString*) msg
          toChatroom: (NSInteger) chatroom_id
			fromUser: (NSInteger) userId
		 withEditKey: (NSString*) editKey
			delegate: (id <LTDataDelegate>) del;

/**
 Send a message to a chat room.
 @required chatroom_id user_id editKey
 @optional del
 */
- (void) leaveChatroom: (NSInteger) chatroom_id
                  user: (NSInteger) user_id
               editKey: (NSString*) edit_key
              delegate: (id <LTDataDelegate>) del;

- (void) saveProfileImage:(UIImage *) image;
- (UIImage *) imageFromCacheForUserId:(NSInteger) userId;
- (void) getImageForUrl:(NSString *) url withUserId: (NSInteger) userId andExecuteBlockInMainQueue:(void(^)(UIImage * image, BOOL gotFromCache)) block;

@end
