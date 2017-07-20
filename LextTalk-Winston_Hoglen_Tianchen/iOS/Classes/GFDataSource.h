//
//  GFDataSource.h
//  LextTalk
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "IQKit.h"
#import "GFUser.h"
#import "GFChat.h"
#import "GFDataDelegate.h"
#import "GFNotLoggedUser.h"

typedef enum {
	STATS_TEAM  = 0,
	STATS_DISTANCE,
	STATS_USER
} GFStatsType;

@class ASIFormDataRequest;

@interface GFDataSource : IQDataSource <CLLocationManagerDelegate, GFDataDelegate>{
	GFUser					*_localUser;
	GFNotLoggedUser			*_noUser;	
	NSMutableArray			*_userList;
    NSMutableArray			*_eventList;
    NSMutableArray			*_userEventList;	
	NSInteger				_completeResults;
	
    NSMutableArray			*_chatList;
	NSString				*_chatListTimestamp;

	// location stuff
    BOOL                    _usingLocation;
    CLLocationManager       *_locationManager;
    CLLocationCoordinate2D  latestLocation;
	
	//Apple Push Notification Service token
	NSString                *_apnsToken;
	NSMutableArray			*_unreadedMessages;
	
}

@property(nonatomic, retain) GFUser *localUser;
@property(nonatomic, retain) GFNotLoggedUser *noUser;
@property(nonatomic, retain) NSMutableArray *userList;
@property(nonatomic, retain) NSMutableArray *eventList;
@property(nonatomic, assign) NSInteger completeResults;
@property(nonatomic, retain) NSMutableArray *chatList;
@property(nonatomic, retain) NSString *chatListTimestamp;
@property(nonatomic, retain) NSMutableArray *unreadedMessages;
@property(nonatomic, retain) NSMutableArray *userEventList;
@property (nonatomic, assign) BOOL usingLocation;
@property (nonatomic, retain) CLLocationManager   *gfLocationManager;
@property (nonatomic, retain) NSString *apnsToken;

- (void) setAndSaveApnsToken: (NSString*) token;
- (void) restoreApnsToken;

+ (id) sharedDataSource;

- (void) createUser: (NSString*) name
	   withPassword: (NSString*) pwd 
		   delegate: (id <GFDataDelegate>) del;

- (void) loginUser: (NSString*) name
	  withPassword: (NSString*) pwd 
		  delegate: (id <GFDataDelegate>) del;

- (void) restoreLoginWithDelegate: (id <GFDataDelegate>) del;

- (void) logoutWithDelegate: (id <GFDataDelegate>) del;

- (void) updateUser: (NSInteger) userId
		withEditKey: (NSString*) editKey
			 status: (NSString*) status
			 teamId: (NSInteger) teamId
		   delegate: (id <GFDataDelegate>) del;

- (void) searchInRegion: (MKCoordinateRegion) region
			   forUsers: (BOOL) users
			  andEvents: (BOOL) events
               delegate: (id <GFDataDelegate>) del;

- (void) searchByName: (NSString*) name
             forUsers: (BOOL) users
            andEvents: (BOOL) events
             delegate: (id <GFDataDelegate>) del;

- (void) sendMessage: (NSString*) msg
			  toUser: (NSInteger) receiverId
			fromUser: (NSInteger) userId
		 withEditKey: (NSString*) editKey
			delegate: (id <GFDataDelegate>) del;

- (void) getMessagesForUser: (NSInteger) userId
				withEditKey: (NSString*) editKey
				   delegate: (id <GFDataDelegate>) del;

- (void) getStats: (GFStatsType) type 
	 withDelegate: (id <GFDataDelegate>) del;

- (void) getUser: (NSInteger) userId
	withDelegate: (id <GFDataDelegate>) del;

- (BOOL) isUserLogged;

- (void) startLocation;
- (void) stopLocation;
- (void) updateLatestLocation: (CLLocationCoordinate2D) loc;
- (CLLocationCoordinate2D) latestLocation;

// chat management
- (GFChat*) chatForUserId: (NSInteger) userId;
- (void) deleteChatWithUserId: (NSInteger) userId;
- (void) updateChatList;

- (NSString*) infoURLForEvent: (NSInteger) eventId;
@end
