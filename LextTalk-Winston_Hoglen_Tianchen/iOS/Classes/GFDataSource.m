//
//  GFDataSource.m
//  LextTalk


#import "GFDataSource.h"
#import "SHA1.h"
#import "JSON.h"
#import "GFMessage.h"
#import "GFChat.h"
#import "GFTeamStat.h"
#import "GFUserStat.h"
#import "GFDistanceStat.h"
#import "LextTalkAppDelegate.h"
#include <math.h>

#define APNS_TOKEN_KEY @"APNSToken"

#define GF_BASE_URL @"http://glocalfans.inqbarna.com/service/"

#define CREATE_USER             @"create_user"
#define LOGIN_USER				@"login_user"
#define LOGOUT_USER				@"logout"
#define UPDATE_USER             @"update_user"

#define SEND_MSG				@"send_msg"
#define GET_MSG					@"get_msg"

#define SEARCH_IN_ZONE			@"search_zone"
#define SEARCH_BY_NAME			@"search_name"
#define GET_USER				@"get_user"

#define USER_STATS				@"user_stats"
#define DISTANCE_STATS			@"distance_stats"
#define TEAM_STATS				@"team_stats"

@interface GFDataSource (PrivateMethods)
- (void) restoreLatestLocation;
- (void) updateChatListWithMessages: (NSArray*) messages;
- (void) updateUserLocation;
@end

@implementation GFDataSource
@synthesize localUser = _localUser;
@synthesize noUser = _noUser;
@synthesize userList = _userList;
@synthesize eventList = _eventList;
@synthesize completeResults = _completeResults;
@synthesize chatList = _chatList;
@synthesize chatListTimestamp = _chatListTimestamp;
@synthesize userEventList = _userEventList;
@synthesize unreadedMessages = _unreadedMessages;
@synthesize usingLocation = _usingLocation;
@synthesize gfLocationManager = _locationManager;
@synthesize apnsToken = _apnsToken;
//@synthesize latestLocation = _latestLocation;

#pragma mark -
#pragma mark GFDataSource methods
- (NSString*) infoURLForEvent: (NSInteger) eventId {
	NSString *result = [NSString stringWithFormat: @"%@event_info.php?id=%d", GF_BASE_URL, eventId];
	return result;
}

- (void) restoreApnsToken {
	NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey: APNS_TOKEN_KEY];
	if(token != nil) {
		self.apnsToken = token;
		IQVerbose(VERBOSE_DEBUG,@"[%@] Restored APNS token: %@", [self class], self.apnsToken);
	} else {
		IQVerbose(VERBOSE_DEBUG,@"[%@] No APNS token to restore", [self class]);		
	}
}

- (void) setAndSaveApnsToken: (NSString*) token {
	self.apnsToken = token;
	[[NSUserDefaults standardUserDefaults] setObject: token forKey: APNS_TOKEN_KEY];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Location stuff
- (CLLocationCoordinate2D) latestLocation {
	return latestLocation;
}

- (void) startLocation {
	
	self.usingLocation = YES;
	
	// Create the manager object 
	self.gfLocationManager = [[[CLLocationManager alloc] init]autorelease];
	self.gfLocationManager.delegate = self;
	
	// This is the most important property to set for the manager. It ultimately determines how the manager will
	// attempt to acquire location and thus, the amount of power that will be consumed.
	self.gfLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
	
	// When "tracking" the user, the distance filter can be used to control the frequency with which location measurements
	// are delivered by the manager. If the change in distance is less than the filter, a location will not be delivered.
	self.gfLocationManager.distanceFilter = 100;
	
	// Custom message to show to the user
	if ([self.gfLocationManager respondsToSelector:@selector(setPurpose:)]) {
	    self.gfLocationManager.purpose = NSLocalizedString(@"LextTalk would like to use your location to place you on the map", @"LextTalk would like to use your location to place you on the map");
	}
	
	// Once configured, the location manager must be "started".
	[self.gfLocationManager startUpdatingLocation];
	[self performSelector:@selector(stopLocation) withObject:nil afterDelay:120];
	IQVerbose(VERBOSE_DEBUG,@"[%@] Location Manager started...", [self class]);
}

- (void)stopLocation {
    IQVerbose(VERBOSE_DEBUG,@"[%@] Stoping location manager", [self class]);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopLocation) object:nil];
    [self.gfLocationManager stopUpdatingLocation];
    self.gfLocationManager.delegate = nil;
}

#pragma mark -
#pragma mark Manage messages and chats

- (void) removeDuplicatedMessages {
    IQVerbose(VERBOSE_DEBUG, @"[%@] Removing duplicated messages",[self class]);
    for(GFChat *c in self.chatList) {
        for(int i = 0;i<[c.messages count];i++) {
            GFMessage *m = [c.messages objectAtIndex: i];
            
            for(int j = i+1;j<[c.messages count];j++) {
                GFMessage *n = [c.messages objectAtIndex: j];
                if(m.messageId == n.messageId) {
                    [c.messages removeObjectAtIndex: j];
                }
            }            
        }
    }    
}

- (void) removeMessageListFromUserDefaults {
	[[NSUserDefaults standardUserDefaults] setObject: nil 
											  forKey: @"LocalUserMessages"];
    
	[[NSUserDefaults standardUserDefaults] synchronize];    
}

- (void) saveMessageListToUserDefaults {
    // check is user is logged
    if(![self isUserLogged]) {
        IQVerbose(VERBOSE_DEBUG,@"[%@] Will not save messages because user is not logged",[self class]);
        return;
    }

    [self removeDuplicatedMessages];    

    NSMutableArray *messages = [[NSMutableArray alloc] init];
    
    for(GFChat *c in self.chatList) {
        for(GFMessage *m in c.messages) {
            [messages addObject: m];
        }
    }
    
    NSString *userId = [NSString stringWithFormat: @"%d", self.localUser.userId];
    NSDictionary *toSave = [NSDictionary dictionaryWithObjectsAndKeys: messages, @"LocalMessageList", self.chatListTimestamp, @"LocalMessageListTimestamp", userId, @"LocalMessageListOwner", nil];
    
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject: toSave];
	[[NSUserDefaults standardUserDefaults] setObject: data 
											  forKey: @"LocalUserMessages"];
    	
	[[NSUserDefaults standardUserDefaults] synchronize];	
	
	IQVerbose(VERBOSE_DEBUG,@"[%@] Saved chat list (%d bytes)", [self class], [data length]);	
    IQVerbose(VERBOSE_DEBUG,@"       chats: %d", [messages count]);				
    IQVerbose(VERBOSE_DEBUG,@"   timestamp: %@", self.chatListTimestamp);	
    
    [messages release];
}

- (void) loadChatListFromUserDefaults {
    // check is user is logged
    if(![self isUserLogged]) {
        IQVerbose(VERBOSE_DEBUG,@"[%@] Will not load messages because user is not logged",[self class]);
        return;
    }
    
    // clear previous cache
    [self.chatList removeAllObjects];
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey: @"LocalUserMessages"];	
	NSDictionary *toLoad = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSArray *messages = [toLoad objectForKey: @"LocalMessageList"];
    NSString *ownerId = [toLoad objectForKey: @"LocalMessageListOwner"];
    
    if([ownerId intValue] != self.localUser.userId) {
        IQVerbose(VERBOSE_DEBUG,@"[%@] Will not load messages because user %@ is not the owner of the cached messages (%@)",[self class], self.localUser.name, ownerId);
        // should clear cache
        return;
    }
    
    [self setChatListTimestamp: [toLoad objectForKey: @"LocalMessageListTimestamp"]];
    
	IQVerbose(VERBOSE_DEBUG,@"[%@] Loaded chat list (%d bytes)", [self class], [data length]);	
    IQVerbose(VERBOSE_DEBUG,@"       chats: %d", [messages count]);				
    IQVerbose(VERBOSE_DEBUG,@"   timestamp: %@", self.chatListTimestamp);	
    
    [self updateChatListWithMessages: messages];
}

- (GFChat *) chatForUserId: (NSInteger) userId inList: (NSArray*) list{
	
	for(GFChat *c in list) {
		if(c.userId == userId) return c;
	}
	return nil;
}

- (GFChat*) chatForUserId: (NSInteger) userId {
	return [self chatForUserId: userId inList: self.chatList];
}

- (void) deleteChatWithUserId: (NSInteger) userId {
    if(![self isUserLogged]) {
        IQVerbose(VERBOSE_DEBUG,@"[%@] Will not delete messages because user is not logged",[self class]);
        return;
    }
	
	NSMutableArray *newMessages = [[NSMutableArray alloc] init];
	for(GFChat *c in self.chatList) {
		for(GFMessage *m in c.messages) {
			if( (m.senderId != userId) && (m.destId != userId) ) {
				[newMessages addObject: m];
			}
		}
	}
	
	[self.chatList removeAllObjects];
	[self updateChatListWithMessages: newMessages];
	[newMessages release];

}

- (void) updateChatList {
	
	NSInteger badge = 0;
	
	for(GFChat *chat in self.chatList) {
		chat.unreadMessages = 0;
		for(GFMessage *m in chat.messages) {
			if( ( (m.deliverStatus == DELIVER_STARTED) || (m.deliverStatus == DELIVER_NONE) ) && (m.senderId != self.localUser.userId)){
				chat.unreadMessages++;
				badge++;
			}
			
		}
		
		IQVerbose(VERBOSE_DEBUG,@"Chat %@:", chat.userName);
		IQVerbose(VERBOSE_DEBUG,@"   messages: %d", [chat.messages count]);
		IQVerbose(VERBOSE_DEBUG,@"     unread: %d", chat.unreadMessages);
	}	

	// update badge
	LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];	
	[del setBadgeValueTo: badge];
    [self saveMessageListToUserDefaults];
}

- (void) updateChatListWithMessages: (NSArray*) messages {
    
    //[chatList removeAllObjects];
	
	for(GFMessage *m in messages) {
		NSInteger userId;
		NSInteger teamId;
		NSString *userName;
		
		if(m.senderId != [[GFDataSource sharedDataSource] localUser].userId) {
			userId = m.senderId;
			teamId = m.senderTeamId;
			userName = m.senderName;
		} else {
			userId = m.destId;      
			teamId = m.destTeamId;
			userName = m.destName;
		}
		        
		GFChat *chat = [self chatForUserId: userId inList: self.chatList];
		if(chat == nil) {
			chat = [GFChat newChat];
			[chat setUserId: userId];
			[chat setTeamId: teamId];
			[chat setUserName: userName];
			[chat.messages addObject: m];
			[self.chatList addObject: chat];
			[chat release];
		} else {
			[chat.messages addObject: m];
		}
	}
	
    [self removeDuplicatedMessages];    
    
    for(GFChat *c in self.chatList) {
		// sort list of messages
		[c.messages sortUsingSelector: @selector(compare:)];
    }
	
	[self updateChatList];	
}

#pragma mark Manage local user

- (void) setLocalUser: (GFUser*) user
      andPasswordHash: (NSString*) hash {
	
	if(self.localUser != nil) {
		[self.localUser release];
	}
	
	self.localUser = [user retain];
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject: user];
	[[NSUserDefaults standardUserDefaults] setObject: data 
											  forKey: @"LocalUserDict"];
    
	[[NSUserDefaults standardUserDefaults] setObject: hash
											  forKey: @"LocalUserHash"];    
	
	[[NSUserDefaults standardUserDefaults] synchronize];	
	
	IQVerbose(VERBOSE_DEBUG,@"[%@] Saved local user (%d bytes)", [self class], [data length]);	
    IQVerbose(VERBOSE_DEBUG,@"    local user: %@", [user name]);				
    IQVerbose(VERBOSE_DEBUG,@"            id: %d", [user userId]);						
    //IQVerbose(VERBOSE_DEBUG,@"  edit key: %@", [user editKey]);						
    IQVerbose(VERBOSE_DEBUG,@"       team id: %d", [user teamId]);								
    IQVerbose(VERBOSE_DEBUG,@"      latitude: %f", user.coordinate.latitude);        
    IQVerbose(VERBOSE_DEBUG,@"     longitude: %f", user.coordinate.longitude);      
    IQVerbose(VERBOSE_DEBUG,@"          hash: %@", hash);       
}

- (BOOL) isUserLogged {
    if( self.localUser != nil) return YES;
    return NO;
}

#pragma mark -
#pragma mark POST CREATE_USER requests

- (void) createUser: (NSString*) name
       withPassword: (NSString*) pwd 
           delegate: (id <GFDataDelegate>) del
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@.php", GF_BASE_URL,CREATE_USER];
	
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = CREATE_USER;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue: name forKey: @"name"];
	[request setPostValue: [NSString sha1Digest: pwd] forKey: @"password"];    
	[request setPostValue: [UIDevice currentDevice].uniqueIdentifier forKey: @"udid"];
	
	if(self.apnsToken != nil) {
        IQVerbose(VERBOSE_DEBUG,@"[%@] Sending APNS token: %@", [self class], self.apnsToken);        
		[request setPostValue: self.apnsToken forKey: @"dev_id"];
	}
	
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];
	[self.requests addObject: dataRequest];
	IQVerbose(VERBOSE_DEBUG,@"[%@] Sent %@ request", [self class], dataRequest.note);        			
}

- (void) didCreateUserWithResult: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
    
    GFUser *user = [[GFUser alloc] initWithDict: result];
    [user setCoordinate: latestLocation];
    
    ASIFormDataRequest *req = (ASIFormDataRequest*) dataRequest.request;
    [self setLocalUser: user
       andPasswordHash: (NSString*) [req getPostValueForKey: @"password"]];
    [user release];		
    if([dataRequest.delegate respondsToSelector: @selector(didCreateUser)])
        [dataRequest.delegate didCreateUser];
}

#pragma mark -
#pragma mark POST LOGIN_USER request
- (void) restoreLoginWithDelegate: (id <GFDataDelegate>) del {
    
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey: @"LocalUserDict"];	
	GFUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
	if(user == nil) {
		IQVerbose(VERBOSE_DEBUG,@"[%@] No user is signed in", [self class]);				
		[self setLocalUser: nil
           andPasswordHash: nil];
        [del didFail: nil];
        return;
	}
      
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@.php", GF_BASE_URL,LOGIN_USER];
	
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = LOGIN_USER;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue: user.name
                   forKey: @"name"];
	
    [request setPostValue: [[NSUserDefaults standardUserDefaults] objectForKey: @"LocalUserHash"]
                   forKey: @"password"];    
    
	[request setPostValue: [UIDevice currentDevice].uniqueIdentifier 
                   forKey: @"udid"];
	
    IQVerbose(VERBOSE_DEBUG,@"[%@] Restoring login for:", [self class]);
    IQVerbose(VERBOSE_DEBUG,@"   User: %@", user.name);    
    IQVerbose(VERBOSE_DEBUG,@"   Hash: %@", [[NSUserDefaults standardUserDefaults] objectForKey: @"LocalUserHash"]);        
    
	if(self.apnsToken != nil) {
		IQVerbose(VERBOSE_DEBUG,@"[%@] Sending APNS token: %@", [self class], self.apnsToken);               
        [request setPostValue: self.apnsToken forKey: @"dev_id"];
	}
	
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];    
	[self.requests addObject: dataRequest];
	IQVerbose(VERBOSE_DEBUG,@"[%@] Sent %@ request", [self class], dataRequest.note);        		
}

- (void) loginUser: (NSString*) name
	  withPassword: (NSString*) pwd 
		  delegate: (id <GFDataDelegate>) del
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@.php", GF_BASE_URL,LOGIN_USER];
	
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = LOGIN_USER;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue: name forKey: @"name"];
	[request setPostValue: [NSString sha1Digest: pwd] forKey: @"password"];    
	[request setPostValue: [UIDevice currentDevice].uniqueIdentifier forKey: @"udid"];
	
	if(self.apnsToken != nil) {
        IQVerbose(VERBOSE_DEBUG,@"[%@] Sending APNS token: %@", [self class], self.apnsToken);        
        [request setPostValue: self.apnsToken forKey: @"dev_id"];
	}
	
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];    
	[self.requests addObject: dataRequest];
	IQVerbose(VERBOSE_DEBUG,@"[%@] Sent %@ request", [self class], dataRequest.note);        	
}

- (void) didLoginUserWithResult: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
	IQVerbose(VERBOSE_DEBUG, @"%@", [result description]);
    ASIFormDataRequest *req = (ASIFormDataRequest*) dataRequest.request;
    GFUser *user = [[GFUser alloc] initWithDict: result];
    
    double server_latitude = user.coordinate.latitude;
    double server_longitude = user.coordinate.longitude;        
    
    // override server location with latest valid location
    if( ([self latestLocation].longitude != 0) && ([self latestLocation].latitude != 0) ) {
        [user setCoordinate: [self latestLocation]];
    }        
    
    [self setLocalUser: user
       andPasswordHash: (NSString*) [req getPostValueForKey: @"password"]];
    [user release];
    
    [self loadChatListFromUserDefaults];
    
    if([dataRequest.delegate respondsToSelector: @selector(didLoginUser)])		
        [dataRequest.delegate didLoginUser];		
    
    // update user location after login if necessary
    if( ([self latestLocation].latitude == 0) && ([self latestLocation].longitude == 0) ) {
        IQVerbose(VERBOSE_DEBUG,@"[%@] Current location is (0,0), not updating location", [self class]);
    } else {
        
        IQVerbose(VERBOSE_DEBUG,@"[%@] User location:", [self class]);       
        IQVerbose(VERBOSE_DEBUG,@"   Server location: %f, %f", server_longitude, server_latitude);       
        IQVerbose(VERBOSE_DEBUG,@"    Local location: %f, %f", (double)latestLocation.longitude, (double)latestLocation.latitude);                 
        
        if( (server_latitude != latestLocation.latitude) || (server_longitude != latestLocation.longitude) ) {
            IQVerbose(VERBOSE_DEBUG,@"[%@] User location at server is outdated, updating location...", [self class]);
            [self updateUserLocation];
        }  else {
            IQVerbose(VERBOSE_DEBUG,@"[%@] User location at server is up-to-dated", [self class]);
        }
    }
}

#pragma mark -
#pragma mark POST LOGOUT_USER request

- (void) logoutWithDelegate: (id <GFDataDelegate>) del {
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@.php", GF_BASE_URL,LOGOUT_USER];
	
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = LOGOUT_USER;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue: [NSString stringWithFormat:@"%d", self.localUser.userId] forKey: @"user_id"];
	[request setPostValue: self.localUser.editKey forKey: @"edit_key"];
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];
	[self.requests addObject: dataRequest];
	
	// now, set localUser to nil
    [self setLocalUser: nil
       andPasswordHash: nil];
	
	// delete cached data
	//[eventList removeAllObjects];
	//[userList removeAllObjects];
	[self.chatList removeAllObjects];
	self.chatListTimestamp = @"";
	[self.userEventList removeAllObjects];
    [self removeMessageListFromUserDefaults];
    
    // bring all navigation view controllers to root view controller
    LextTalkAppDelegate *appDel = (LextTalkAppDelegate*) [UIApplication sharedApplication].delegate;
	[appDel setBadgeValueTo: 0];
    [appDel resetNavgationControllers];
	/*
	[appDel goToUserAtLongitude: latestLocation.longitude
					andLatitude: latestLocation.latitude];
	 */
}

#pragma mark -
#pragma mark POST UPDATE_USER request

- (void) updateUser: (NSInteger) userId
		withEditKey: (NSString*) editKey
			 status: (NSString*) status
			 teamId: (NSInteger) teamId
		   delegate: (id <GFDataDelegate>) del 
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@.php", GF_BASE_URL,UPDATE_USER];
	
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = UPDATE_USER;
	IQVerbose(VERBOSE_DEBUG,@"[%@] Updating with latest location: %f, %f", [self class], latestLocation.longitude, latestLocation.latitude);
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue: [NSString stringWithFormat:@"%d", userId] forKey: @"user_id"];
	[request setPostValue: editKey forKey: @"edit_key"];    
	[request setPostValue: status forKey: @"status"];
	[request setPostValue: [NSString stringWithFormat:@"%f", latestLocation.longitude] forKey: @"longitude"];    
	[request setPostValue: [NSString stringWithFormat:@"%f", latestLocation.latitude] forKey: @"latitude"];    
	[request setPostValue: [NSString stringWithFormat: @"%d", teamId] forKey: @"team_id"];
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];    
	[self.requests addObject: dataRequest];	
}

- (void) didUpdateUserWithResult: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary: result];
    [newDict setObject: [self localUser].editKey forKey: @"edit_key"];
    
    GFUser *user = [[GFUser alloc] initWithDict: newDict];
    
    // override server location with latest valid location
    if( ([self latestLocation].longitude != 0) && ([self latestLocation].latitude != 0) ) {
        [user setCoordinate: [self latestLocation]];
    }		
    
    // now set the user
    [self setLocalUser: user
       andPasswordHash: [[NSUserDefaults standardUserDefaults] objectForKey: @"LocalUserHash"]];
    [user release];
    
    if([dataRequest.delegate respondsToSelector: @selector(didUpdateUser)])		
        [dataRequest.delegate didUpdateUser];    
}

#pragma mark -
#pragma mark POST SEARCH_IN_ZONE request

- (void) searchInRegion: (MKCoordinateRegion) region
			   forUsers: (BOOL) users
			  andEvents: (BOOL) events
               delegate: (id <GFDataDelegate>) del
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@.php", GF_BASE_URL,SEARCH_IN_ZONE];

    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = SEARCH_IN_ZONE;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];         
	[request setPostValue: [NSString stringWithFormat: @"%f",region.center.latitude-region.span.latitudeDelta/2.0] forKey: @"lat_br"];
	[request setPostValue: [NSString stringWithFormat: @"%f",region.center.longitude-region.span.longitudeDelta/2.0] forKey: @"lon_tl"];
	[request setPostValue: [NSString stringWithFormat: @"%f",region.center.latitude+region.span.latitudeDelta/2.0] forKey: @"lat_tl"];
	[request setPostValue: [NSString stringWithFormat: @"%f",region.center.longitude+region.span.longitudeDelta/2.0] forKey: @"lon_br"];
    
	if(users && events) {
		[request setPostValue: @"3" forKey: @"s_type"];
	} else {
		if(users) [request setPostValue: @"1" forKey: @"s_type"];
		if(events) [request setPostValue: @"2" forKey: @"s_type"];
	}
 
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];    
	[self.requests addObject: dataRequest];        	
}

- (void) searchInZoneResult: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
    
    [self.userList removeAllObjects];
    [self.eventList removeAllObjects];
    
    NSArray *newUsers = [result objectForKey: @"users"];
    NSArray *newEvents = [result objectForKey: @"events"];
    NSString *flag = [result objectForKey: @"complete_results"];
    
    [self setCompleteResults: [flag intValue]];
    IQVerbose(VERBOSE_DEBUG,@"[%@] Got %d events and %d users (complete results %d)", [self class], [newEvents count], [newUsers count], self.completeResults);
    
    // now add old users that are not present in new users
    for(NSDictionary *d in newUsers) {
        GFUser *u = [[GFUser alloc] initWithDict: d];
        // do not include local userin resuts
        if(u.userId != self.localUser.userId)  [self.userList addObject: u];
        [u release];
    }
    
    if([dataRequest.delegate respondsToSelector: @selector(didUpdateSearchResults)])		
        [dataRequest.delegate didUpdateSearchResults];		
}

#pragma mark -
#pragma mark POST SEARCH_BY_NAME request

- (void) searchByName: (NSString*) name
             forUsers: (BOOL) users
            andEvents: (BOOL) events
             delegate: (id <GFDataDelegate>) del
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@.php", GF_BASE_URL,SEARCH_BY_NAME];
    
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = SEARCH_BY_NAME;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];         
    
    [request setPostValue: name forKey: @"name"];
    
	if(users && events) {
		[request setPostValue: @"3" forKey: @"s_type"];
	} else {
		if(users) [request setPostValue: @"1" forKey: @"s_type"];
		if(events) [request setPostValue: @"2" forKey: @"s_type"];
	}
    
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];    
	[self.requests addObject: dataRequest];        	    
}

- (void) searchByNameResult: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
    NSArray *newUsers = [result objectForKey: @"users"];
    NSArray *newEvents = [result objectForKey: @"events"];		
    
    NSMutableArray *searchResults = [[NSMutableArray alloc] initWithCapacity: [newUsers count] + [ newEvents count]];
    
    IQVerbose(VERBOSE_DEBUG,@"[%@] Got %d events and %d users", [self class], [newEvents count], [newUsers count]);
    
    for(NSDictionary *d in newUsers) {
        GFUser *u = [[GFUser alloc] initWithDict: d];
        // do not include local userin resuts
        if(u.userId != self.localUser.userId)  [searchResults addObject: u];
        [u release];
    }
    
    if([dataRequest.delegate respondsToSelector: @selector(didUpdateSearchResultsByName:)])		
        [dataRequest.delegate didUpdateSearchResultsByName: searchResults];
    
    [searchResults release];    
}

#pragma mark -
#pragma mark POST SEND_MSG request
- (void) sendMessage: (NSString*) msg
			  toUser: (NSInteger) receiverId
			fromUser: (NSInteger) userId
		 withEditKey: (NSString*) editKey
			delegate: (id <GFDataDelegate>) del
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@.php", GF_BASE_URL,SEND_MSG];
	
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = SEND_MSG;
	
	NSURL *url = [NSURL URLWithString: reqURL];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];         
	[request setPostValue: [NSString stringWithFormat: @"%d",[self localUser].userId] forKey: @"user_id"];
	[request setPostValue: [self localUser].editKey forKey: @"edit_key"];	
	[request setPostValue: [NSString stringWithFormat: @"%d",receiverId] forKey: @"dest_id"];	
	[request setPostValue: msg forKey: @"message"];	
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];
	[self.requests addObject: dataRequest];
}

#pragma mark -
#pragma mark POST GET_MSG request
- (void) getMessagesForUser: (NSInteger) userId
				withEditKey: (NSString*) editKey
				   delegate: (id <GFDataDelegate>) del 
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@.php", GF_BASE_URL,GET_MSG];
	
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = GET_MSG;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];         
	[request setPostValue: [NSString stringWithFormat: @"%d",[self localUser].userId] forKey: @"user_id"];
	[request setPostValue: [self localUser].editKey forKey: @"edit_key"];	
	
	IQVerbose(VERBOSE_DEBUG,@"[%@] Sending get_msg request with timestamp %@", [self class], self.chatListTimestamp);
	if(self.chatListTimestamp != nil) {
		[request setPostValue: self.chatListTimestamp forKey: @"time"];				
	}
	
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];    
	[self.requests addObject: dataRequest]; 		
}

- (void) gotMessagesWithResult: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
    NSArray *newMessages = [result objectForKey: @"messages"];
    NSMutableArray *messageList = [[NSMutableArray alloc] initWithCapacity: [newMessages count]];
    
    [self setChatListTimestamp:[result objectForKey: @"timestamp"]];
    
    IQVerbose(VERBOSE_DEBUG,@"[%@] Got %d new messages (timestamp is %@)", [self class], [newMessages count], self.chatListTimestamp);
    
    for(NSDictionary *d in newMessages) {
        GFMessage *msg = [GFMessage newMessageWithDict: d];
        [messageList addObject: msg];
        [msg release];
    }

    [self updateChatListWithMessages: messageList];
    [messageList release];
    
    if([dataRequest.delegate respondsToSelector: @selector(didGetListOfMessages)])
        [dataRequest.delegate didGetListOfMessages];
}

#pragma mark -
#pragma mark POST STATS request
- (void) getStats: (GFStatsType) type 
	 withDelegate: (id <GFDataDelegate>) del
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/stat.php", GF_BASE_URL];
	
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];         


	switch(type) {
		case STATS_TEAM: 
			dataRequest.note = TEAM_STATS;
			[request setPostValue: @"0" forKey: @"type"];
			[request setPostValue: @"21" forKey: @"limit"];				
			break;
		case STATS_DISTANCE: 
			dataRequest.note = DISTANCE_STATS;
			[request setPostValue: @"1" forKey: @"type"];
			[request setPostValue: @"20" forKey: @"limit"];				
			break;
		case STATS_USER: 
			dataRequest.note = USER_STATS;
			[request setPostValue: @"2" forKey: @"type"];
			[request setPostValue: @"20" forKey: @"limit"];				
			break;
	}
	
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];    
	[self.requests addObject: dataRequest]; 		
	
    IQVerbose(VERBOSE_DEBUG,@"[%@] Send request %@: %@", [self class], dataRequest.note, [request description]);
}

- (void) gotUserStatsWithResult: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
    NSMutableArray *userStats = [[NSMutableArray alloc] initWithCapacity: [result count]];
    
    for(NSDictionary *d in result) {
        GFUserStat *u = (GFUserStat*) [[GFUserStat alloc] initWithDict: d];
        [userStats addObject: u];
        [u release];
    }
    
    if([dataRequest.delegate respondsToSelector: @selector(didUpdateUserStatistics:)])
        [dataRequest.delegate didUpdateUserStatistics: userStats];
    
    [userStats release];    
}

- (void) gotTeamStatsWithResult: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
    
    NSMutableArray *teamStats = [[NSMutableArray alloc] initWithCapacity: [result count]];
    
    for(NSDictionary *d in result) {
        GFTeamStat *u = [GFTeamStat newTeamStatWithDict: d];
        [teamStats addObject: u];
        [u release];
    }
    
    if([dataRequest.delegate respondsToSelector: @selector(didUpdateTeamStatistics:)])
        [dataRequest.delegate didUpdateTeamStatistics: teamStats];
    
    [teamStats release];    
}

- (void) gotDistanceStatsWithResult: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
    NSMutableArray *distanceStats = [[NSMutableArray alloc] initWithCapacity: [result count]];
    
    for(NSDictionary *d in result) {
        GFDistanceStat *u = (GFDistanceStat*) [[GFDistanceStat alloc] initWithDict: d];
        [distanceStats addObject: u];
        [u release];
    }
    
    if([dataRequest.delegate respondsToSelector: @selector(didUpdateDistanceStatistics:)])
        [dataRequest.delegate didUpdateDistanceStatistics: distanceStats];
    
    [distanceStats release];    
}

#pragma mark -
#pragma mark POST GET_USER request

- (void) getUser: (NSInteger) userId
	withDelegate: (id <GFDataDelegate>) del
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@.php", GF_BASE_URL,GET_USER];
    
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = GET_USER;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];         
    
	[request setPostValue: [NSString stringWithFormat:@"%d", userId] forKey: @"user_id"];
	
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];    
	[self.requests addObject: dataRequest];        	    
}

- (void) gotUserWithResult: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
    GFUser *user = [[GFUser alloc] initWithDict: result];
    
    if([dataRequest.delegate respondsToSelector: @selector(didGetUser:)])
        [dataRequest.delegate didGetUser: user];
    
    [user release];    
}

#pragma mark -
#pragma mark Dispatch methods

- (void) dispatchError:(IQDataRequest *)dataRequest {
	
	ASIFormDataRequest *req = (ASIFormDataRequest*) dataRequest.request;	
	NSMutableDictionary *d = [[req responseString] JSONValue];
	NSString *status = [d objectForKey:@"status"];
	
	// handle error
	if([status isEqualToString: @"error"]) {
		[dataRequest.delegate didFail: [d objectForKey: @"result"]];
		return;
	}
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Network error", @"Network error")
													message: NSLocalizedString(@"Could not process the request", @"Could not process the request") 
												   delegate: nil
										  cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
										  otherButtonTitles: nil];
	
	[alert show];
	[alert release];
}


- (BOOL) dispatchNote:(IQDataRequest *)dataRequest {
	
	// process POST requests
	ASIFormDataRequest *req = (ASIFormDataRequest*) dataRequest.request;	
	NSMutableDictionary *d = [[req responseString] JSONValue];
	NSString *status = [d objectForKey:@"status"];
	NSDictionary *result = [d objectForKey:@"result"];	
	
	NSLog(@"%@", [d description]);
	
	// handle error
	if(![status isEqualToString: @"success"]) {
		[self dispatchError: dataRequest];
		return YES;
	}
	
	// process the succesfull request results according to NOTE
	if([dataRequest.note isEqualToString: CREATE_USER]) {
        [self didCreateUserWithResult: result withDataRequest: dataRequest];
		
	} else if([dataRequest.note isEqualToString: LOGIN_USER]) {
        
        [self didLoginUserWithResult: result withDataRequest: dataRequest];
        
	} else if([dataRequest.note isEqualToString: LOGOUT_USER]) {
		
		if([dataRequest.delegate respondsToSelector: @selector(didLogoutUser)])		
			[dataRequest.delegate didLogoutUser];		
		
	} else if([dataRequest.note isEqualToString: UPDATE_USER]) {
		
        [self didUpdateUserWithResult: result withDataRequest: dataRequest];
		
	} else if([dataRequest.note isEqualToString: SEARCH_IN_ZONE]) {
		
        [self searchInZoneResult: result withDataRequest: dataRequest];
        
	} else if([dataRequest.note isEqualToString: SEARCH_BY_NAME]) {
		
        [self searchByNameResult: result withDataRequest: dataRequest];        
		
    } else if([dataRequest.note isEqualToString: SEND_MSG]) {
		
		if([dataRequest.delegate respondsToSelector: @selector(didSendMessage)])
			[dataRequest.delegate didSendMessage];		
		
	} else if([dataRequest.note isEqualToString: GET_MSG]) {
        
        [self gotMessagesWithResult: result withDataRequest: dataRequest];
		
	} else if([dataRequest.note isEqualToString: USER_STATS]) {
        
        [self gotUserStatsWithResult: result withDataRequest: dataRequest];
		
	} else if([dataRequest.note isEqualToString: TEAM_STATS]) {
		
        [self gotTeamStatsWithResult: result withDataRequest: dataRequest];
		
	} else if([dataRequest.note isEqualToString: DISTANCE_STATS]) {
		
        [self gotDistanceStatsWithResult: result withDataRequest: dataRequest];        
		
	} else if([dataRequest.note isEqualToString: GET_USER]) {
		
        [self gotUserWithResult: result withDataRequest: dataRequest];
        
	} else {
        return NO;
    }
	
	return YES;
}

#pragma mark -
#pragma mark GFDataDelegate

- (void) didUpdateUser {
    IQVerbose(VERBOSE_DEBUG,@"[%@] New location set", [self class]);
}

- (void) didFail: (NSDictionary*) result {
    IQVerbose(VERBOSE_DEBUG,@"[%@] Could not store new location", [self class]);	
}

#pragma mark -
#pragma mark Manage latest location
- (void) updateLatestLocation: (CLLocationCoordinate2D) loc {
	// no user must always be updated
	self.noUser.coordinate = loc;	
	
	latestLocation = loc;
	IQVerbose(VERBOSE_DEBUG,@"[%@] Latest location set to %f, %f", [self class], latestLocation.longitude, latestLocation.latitude);
}

- (void) restoreLatestLocation {
    latestLocation.latitude = 0;
    latestLocation.longitude = 0;
}

#pragma mark -
#pragma mark CLLocationManagerDelegate methods

- (void) updateUserLocation {
    //if( (self.localUser.coordinate.longitude == latestLocation.longitude) && (self.localUser.coordinate.latitude == latestLocation.latitude) ) return;

    //localUser.coordinate = [self latestLocation];
    //IQVerbose(VERBOSE_DEBUG,@"Updating user location:");       
    //IQVerbose(VERBOSE_DEBUG,@"   Old location: %f, %f", (double)self.localUser.coordinate.longitude, (double)self.localUser.coordinate.latitude);       
    //IQVerbose(VERBOSE_DEBUG,@"   New location: %f, %f", (double)latestLocation.longitude, (double)latestLocation.latitude);           
    
    [self updateUser: self.localUser.userId 
         withEditKey: self.localUser.editKey 
              status: self.localUser.status 
              teamId: self.localUser.teamId 
            delegate: self];        
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
    BOOL updateLocation = NO;
    
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 60.0) {
        IQVerbose(VERBOSE_DEBUG,@"[%@] Got new location (%f, %f) ... but location is outdated (%f)", [self class], newLocation.coordinate.longitude, newLocation.coordinate.latitude, locationAge);		
        return;
    }
    
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) {
		IQVerbose(VERBOSE_DEBUG,@"[%@] Got new location...but it is invalid", [self class]);		
		return;
	}

    if ( (newLocation.coordinate.longitude == 0) && (newLocation.coordinate.latitude == 0) ) {
        IQVerbose(VERBOSE_DEBUG,@"[%@] Got new location ... but location is 0,0", [self class]);		
        return;
    }
    
	// test the measurement to see if it meets the desired accuracy
	//
	// IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue 
	// accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of 
	// acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
	//
    if (((latestLocation.longitude==0)&&(latestLocation.latitude==0))) {
        updateLocation = YES;
    }
	if (newLocation.horizontalAccuracy <= manager.desiredAccuracy) {
		// we have a measurement that meets our requirements, so we can stop updating the location
		// 
		// IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
		//
        [self stopLocation];// we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
        updateLocation = YES;
//		[manager stopUpdatingLocation];
//		manager.delegate = nil;
	}
    
    // store new location
    [self updateLatestLocation: newLocation.coordinate];
    
    if(updateLocation) {
        //LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
        //[del goToUserAtLongitude: newLocation.coordinate.longitude andLatitude: newLocation.coordinate.latitude];
        
        if ( [self isUserLogged] ) {
            // set new value
            [self updateUserLocation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a 
    // timeout that will stop the location manager to save power.
    if ([error code] == kCLErrorDenied) {
        self.usingLocation = NO;
    } else if ([error code] == kCLErrorLocationUnknown) {
        return;
    }
    
    [self stopLocation];
//    [manager stopUpdatingLocation];
//    manager.delegate = nil;
}

static GFDataSource *theGFDataSource = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (id) sharedDataSource {
    @synchronized(self) {
        if(theGFDataSource == nil)
            theGFDataSource = [[super allocWithZone:NULL] init];
    }
    return theGFDataSource;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedDataSource] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX; //denotes an object that cannot be released
}

- (oneway void)release {
    // never release
}

- (id)autorelease {
    return self;
}

- (id) init {
	if (self = [super init]) {
		self.requests = [NSMutableArray array];
		self.userList = [NSMutableArray array];
		self.eventList = [NSMutableArray array];        
		self.chatList = [NSMutableArray array];        		
		self.userEventList = [NSMutableArray array];     
		self.unreadedMessages = [NSMutableArray array];
		
		// create a no user just in case
		self.noUser = [[[GFNotLoggedUser alloc] init]autorelease];
		
		//[self startLocation];
        // restore last location
        [self restoreLatestLocation];
		[self restoreApnsToken];
	}
	return self;
}

- (void)dealloc {
    self.gfLocationManager.delegate = nil;
    [self.gfLocationManager release];
    // Should never be called, but just here for clarity really.
    [super dealloc];
}

@end
