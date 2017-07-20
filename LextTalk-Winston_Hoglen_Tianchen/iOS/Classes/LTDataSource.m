//
//  LTDataSource.m
//  LextTalk


#import "LTDataSource.h"
#import "LTMessage.h"
#import "LTChat.h"
#import "LextTalkAppDelegate.h"
#import "LTChatroom.h"
#include <math.h>
#import "UIDevice+IdentifierAddition.h"
#import "GeneralHelper.h"
#import <IQLocationManager/IQLocationManager.h>

#import "AFNetworking.h"

#define BUNDLE_ID_LTC @"com.inqbarna.lexttalkcatalan"

#define APNS_TOKEN_KEY @"APNSToken"
/*
#ifdef DEBUG
 #define LX_BASE_URL @"http://test.lexttalk.inqbarna.com/API/5/"
 #define LX_LANG_URL @"http://test.lexttalk.inqbarna.com/API/"
#else
 */
 #define LX_BASE_URL @"http://lexttalk.inqbarna.com/API/5"
 #define LX_LANG_URL @"http://lexttalk.inqbarna.com/API/"
//#endif

NSString *const LTBaseURL = LX_BASE_URL;
NSString *const LTLangURL = LX_LANG_URL;

#define CREATE_USER             @"create_user"
#define LOGIN_USER				@"login_user"
#define RESTORE_SESSION         @"restore_session"
#define LOGOUT_USER				@"logout"
#define UPDATE_USER             @"update_user"
#define BLOCK_USER              @"block_user"
#define FB_LOGIN_USER           @"fb_login_user"
#define DELETE_USER             @"delete_user"
#define REMEMBER_PASSWORD       @"remember_password"

#define SEND_MSG				@"send_msg"
#define GET_MSG					@"get_msg"

#define SEARCH_IN_ZONE			@"search_zone"
#define SEARCH_USERS			@"search_users"
#define GET_USER				@"get_user"
#define SEARCH_USER_EMAIL       @"search_user_email"

#define ADORDER                 @"adorder"

#define CREATE_CHATROOM         @"create_chatroom"
#define ENTER_CHATROOM          @"enter_chatroom"
#define LEAVE_CHATROOM          @"leave_chatroom"
#define SEND_MESSAGE_CHATROOM   @"send_msg_chatroom"
#define GET_MESSAGE_CHATROOM    @"get_msg_chatroom"
#define SEARCH_CHATROOM         @"search_chatrooms"

//Facebook stuff
NSString *const FBSessionStateChangedNotification = @"com.inqbarna.lexttalk:FBSessionStateChangedNotification";

@interface LTDataSource ()
- (void) restoreLatestLocation;
- (void) updateChatListWithMessages: (NSArray*) messages;
- (void) updateUserLocation;

@property (atomic, strong) NSMutableDictionary * userCache;
@property (atomic, strong) NSMutableSet * userIdsToDownload;

@end

@implementation LTDataSource
@synthesize localUser = _localUser;
@synthesize noUser = _noUser;
@synthesize userList = _userList;
@synthesize completeResults = _completeResults;
@synthesize chatList = _chatList;
@synthesize chatListTimestamp = _chatListTimestamp;
@synthesize unreadedMessages = _unreadedMessages;
@synthesize usingLocation = _usingLocation;
@synthesize apnsToken = _apnsToken;

#pragma mark -
#pragma mark LTDataSource methods

+ (BOOL) isLextTalkCatalan
{
    if ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] isEqualToString:BUNDLE_ID_LTC])
        return YES;
    else
        return NO;
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

#pragma mark -
#pragma mark Facebook

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
               withDelegate: (id<LTDataDelegate>) delegate
          withFacebokAction:(LTFacebookAction)action
{
    
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                //NSLog(@"User session found");
                //I login with the data source
                //NSLog(@"Token from facebook: %@", session.accessTokenData.accessToken);
                if (action == LTFacebookActionLogin)
                    [self loginWithFacebookToken:session.accessTokenData.accessToken delegate:delegate];
                else if (action ==LTFacebookActionContacts)
                {
                    if ([delegate respondsToSelector:@selector(didConnectToFacebookForContacts)])
                        [delegate didConnectToFacebookForContacts];
                }
                else if (action ==LTFacebookActionTestContacts)
                {
                    if ([delegate respondsToSelector:@selector(didTestFacebookForContacts:)])
                        [delegate didTestFacebookForContacts:YES];
                }
            }
            break;
            
            //Separated: FBSessionStateClosed is called when you logout and after that you log in again.
            //Then, the SDK tries by itself again and logs the user
        case FBSessionStateClosed:
            if (action ==LTFacebookActionTestContacts)
            {
                if ([delegate respondsToSelector:@selector(didTestFacebookForContacts:)])
                    [delegate didTestFacebookForContacts:NO];
            }
            //NSLog(@"User session closed");
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        case FBSessionStateClosedLoginFailed:
            //NSLog(@"User session failed");
            [FBSession.activeSession closeAndClearTokenInformation];
            
            if (action ==LTFacebookActionTestContacts)
            {
                if ([delegate respondsToSelector:@selector(didTestFacebookForContacts:)])
                    [delegate didTestFacebookForContacts:NO];
            }
            else
                //Call it with an ad hoc dic
                [delegate didFail:nil];
            break;
        default:
            if (action ==LTFacebookActionTestContacts)
            {
                if ([delegate respondsToSelector:@selector(didTestFacebookForContacts:)])
                    [delegate didTestFacebookForContacts:NO];
            }
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
    
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI withDelegate:(id<LTDataDelegate>) delegate withFacebokAction:(LTFacebookAction)action
{
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"email",
                            //@"user_likes",
                            nil];
    
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error
                                                          withDelegate:delegate
                                                     withFacebokAction:action];
                                             
                                         }];
    
}

//As I am doing everything in the dataSource, I create this methos to handle URLs which will be called from the App Delegate
- (BOOL) handleFacebookUrl:(NSURL *) url
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (void) handleFacebookDidBecomeActive
{
    [FBSession.activeSession handleDidBecomeActive];
}

- (void) handleFacebookApplicatinWillTerminate
{
    [FBSession.activeSession close];
}

- (void) handleFacebookLogout
{
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (void) handleFacebookShare:(NSString *) text andImage:(UIImage *)image
{
    NSURL* url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/lext-talk-language-exchange/id484851963?mt=8"];
    FBAppCall *appCall = [FBDialogs presentShareDialogWithLink:url
                                                       handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                           if(error) {
                                                               [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error or Facebook app  not installed!", nil)
                                                                                           message:NSLocalizedString(@"There has been an error or you don't have the Facebook app installed", nil)
                                                                                          delegate:nil
                                                                                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                                 otherButtonTitles: nil] show];
                                                           } else {
                                                               //NSLog(@"Success!");
                                                           }
                                                       }];
    
    if (!appCall) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error or Facebook app  not installed!", nil)
                                    message:NSLocalizedString(@"There has been an error or you don't have the Facebook app installed", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];
    }
    
    /*
    //if ([FBDialogs canPresentShareDialogWithParams:nil])
    if (YES)
    {
        NSArray* images = @[
                            @{@"url": image, @"user_generated" : @"true" }
                            ];
        
        id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
        [action setObject:@"https://itunes.apple.com/us/app/lext-talk-language-exchange/id484851963?mt=8" forKey:@"map"];
        [action setObject:images forKey:@"image"];
        
        [FBDialogs presentShareDialogWithOpenGraphAction:action
                                              actionType: @"lexttalk_app:share"
                                     previewPropertyName: @"map"
                                                 handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                     if(error) {
                                                         NSLog(@"Error: %@", error.description);
                                                     } else {
                                                         NSLog(@"Success!");
                                                     }
                                                 }];
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Facebook app  not installed!", nil)
                                                         message:NSLocalizedString(@"You can only share on Facebook if you have the Facebook app installed", nil)
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                               otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
     */
}

#pragma mark Location stuff
- (CLLocationCoordinate2D) latestLocation {
	return latestLocation;
}

- (void) updateLocation {
    
    [[IQLocationManager sharedManager] getCurrentLocationWithCompletion:^(CLLocation *location, IQLocationResult result) {
        if (result == kIQLocationResultFound) {
            self.usingLocation = YES;
            // store new location
            [self updateLatestLocation: location.coordinate];

            if ( [self isUserLogged] ) {
                // set new value
                [self updateUserLocation];
            }
        } else {
            if ([[IQLocationManager sharedManager] getLocationStatus] == kIQlocationResultAuthorized) {
                self. usingLocation = YES;
            } else {
                self.usingLocation = NO;
            }
        }
    }];
}

#pragma mark -
#pragma mark Manage messages and chats

- (void) loadChatListFromUserDefaults {
    // check is user is logged
    if(![self isUserLogged]) {
        IQVerbose(VERBOSE_DEBUG,@"[%@] Will not load messages because user is not logged",[self class]);
        return;
    }
    
    // clear previous cache
    [self.chatList removeAllObjects];
    
    //Parse data from old version
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey: @"LocalUserMessages"];
    if (data!=nil)//read data, save in new format and delete data
    {
        NSDictionary *toLoad = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSArray *messages = [toLoad objectForKey: @"LocalMessageList"];
        NSString *ownerId = [toLoad objectForKey: @"LocalMessageListOwner"];
        
        if ([ownerId intValue]== self.localUser.userId) //Convertir al nuevo formato y borrar
        {
            //[self setChatListTimestamp: [toLoad objectForKey: @"LocalMessageListTimestamp"]];
            //[self updateChatListWithMessages: messages];
            
            [[MessageHandler sharedInstance] insertMessages:messages];
        }
        
        //Always delete to stay in the new model from now on
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LocalUserMessages"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else //Import for the last version to use the defaults
    {
        //Read from current version
        NSString * key = [NSString stringWithFormat:@"LocalUserMessages-%.10ld", (long)self.localUser.userId];
        data = [[NSUserDefaults standardUserDefaults] objectForKey: key];
        if (data != nil)
        {
            NSDictionary *toLoad = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            NSArray *messages = [toLoad objectForKey: @"LocalMessageList"];
            //[self setChatListTimestamp: [toLoad objectForKey: @"LocalMessageListTimestamp"]];
            //[self updateChatListWithMessages: messages];
            
            //Poco a poco
            [[MessageHandler sharedInstance] insertMessages:messages];
            //Borrar todo los datos de los defaults
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            IQVerbose(VERBOSE_DEBUG,@"[%@] Loaded chat list (%d bytes)", [self class], [data length]);
            IQVerbose(VERBOSE_DEBUG,@"       chats: %d", [messages count]);
            IQVerbose(VERBOSE_DEBUG,@"   timestamp: %@", self.chatListTimestamp);
        }
    }
    
    self.chatList = [[MessageHandler sharedInstance] chatLists];
}

- (LTChat *) chatForUserId: (NSInteger) userId inList: (NSArray*) list{
	
	for(LTChat *c in list) {
		if(c.userId == userId) return c;
	}
	return nil;
}

- (LTChat*) chatForUserId: (NSInteger) userId {
	return [self chatForUserId: userId inList: self.chatList];
}

- (void) deleteChatWithUserId: (NSInteger) userId {
    if(![self isUserLogged]) {
        IQVerbose(VERBOSE_DEBUG,@"[%@] Will not delete messages because user is not logged",[self class]);
        return;
    }
    
    [[MessageHandler sharedInstance] deleteChatForUserId:userId];
	
	for (NSInteger i =0; i <[self.chatList count]; i++)
    {
        LTChat * chat = [self.chatList objectAtIndex:i];
        if (chat.userId == userId)
        {
            [self.chatList removeObjectAtIndex:i];
            break;
        }
    }
}

- (void) updateChatList {
	
	NSInteger badge = 0;
	
	for(LTChat *chat in self.chatList) {
		badge += chat.unreadMessages;
		
		IQVerbose(VERBOSE_DEBUG,@"Chat %@:", chat.userName);
		IQVerbose(VERBOSE_DEBUG,@"   messages: %d", chat.totalNumber);
		IQVerbose(VERBOSE_DEBUG,@"     unread: %d", chat.unreadMessages);
	}
	
    
    //Enough to order it here? It seems so
    [self.chatList sortUsingComparator:^NSComparisonResult(LTChat * chat1, LTChat * chat2) {

        if ((chat2.unreadMessages==0) && (chat1.unreadMessages==0))
            return [chat2.lastDate compare:chat1.lastDate];
        else if ((chat2.unreadMessages>0) && (chat1.unreadMessages==0))
            return NSOrderedDescending;
        else if ((chat2.unreadMessages==0) && (chat1.unreadMessages>0))
            return NSOrderedAscending;
        else if ((chat2.unreadMessages>0) && (chat1.unreadMessages>0))
            return [chat2.lastDate compare:chat1.lastDate];
        else 
            return NSOrderedAscending;
    }];
    
    

	// update badge
	LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];	
	[del setBadgeValueTo: badge];
}

- (void) updateChatListWithMessages: (NSArray*) messages {
    
	NSMutableSet * set = [[NSMutableSet alloc] init];
	for(LTMessage *m in messages) {
        
        //Insert message
        NSNumber * userId = [NSNumber numberWithInteger:[[MessageHandler sharedInstance] insertMessage:m]];
        [set addObject:userId];
	}
    
    //I get the LTChats which have been updated or created because of the messages received.
    //(I do it this way to avoid getting the LTChat several times for the same user
    for (NSNumber * userId in set)
    {
        LTChat * chat = [[MessageHandler sharedInstance] chatListForUserId: [userId integerValue]];
        
        if (chat != nil)
        {
            BOOL found = NO;
            for (NSInteger i = 0; i < [self.chatList count]; i++)
            {
                LTChat * c = [self.chatList objectAtIndex:i];
                if (c.userId == [userId integerValue])
                {
                    [self.chatList replaceObjectAtIndex:i withObject:chat];
                    found = YES;
                    break;
                }
            }
            if (!found)
                [self.chatList addObject:chat];
        }
    }
	
	[self updateChatList];
}

#pragma mark Manage local user

- (void) setLocalUser: (LTUser*) user
      andPasswordHash: (NSString*) hash {
	
	if(self.localUser != nil) {
        NSLog(@"setLocalUser :: %@", self.localUser);
	}
	
	self.localUser = user;
    
    self.localUser.image = [self getProfileImage];
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject: user];
	[[NSUserDefaults standardUserDefaults] setObject: data 
											  forKey: @"LocalUserDict"];
    
	[[NSUserDefaults standardUserDefaults] setObject: hash
											  forKey: @"LocalUserHash"];    
	
	[[NSUserDefaults standardUserDefaults] synchronize];	
	IQVerbose(VERBOSE_DEBUG,@"[%@] Saved local user (%d bytes)", [self class], [data length]);	
    IQVerbose(VERBOSE_DEBUG,@"    local user: %@", [user name]);				
    IQVerbose(VERBOSE_DEBUG,@"            id: %d", [user userId]);						
    IQVerbose(VERBOSE_DEBUG,@"  edit key: %@", [user editKey]);						
    IQVerbose(VERBOSE_DEBUG,@"      latitude: %f", user.coordinate.latitude);        
    IQVerbose(VERBOSE_DEBUG,@"     longitude: %f", user.coordinate.longitude);      
    IQVerbose(VERBOSE_DEBUG,@"          hash: %@", hash);       
}

- (BOOL) isUserLogged {
    if( self.localUser != nil) return YES;
    return NO;
}



//Chatroom badge management
- (void) setLastMessageRead:(NSInteger) messageId inChatroom: (NSInteger) chatroomId
{
    //It doesn't allow me to save to NSNumber in a dictionary in NSUserDefaults, so I use a NSString
    NSString * chatroomIdStr=[NSString stringWithFormat:@"%ld", (long)chatroomId];
    
    NSUserDefaults * defs=[NSUserDefaults standardUserDefaults];
    NSString * key=[NSString stringWithFormat:@"userChatroomBadgeDic-%ld", (long)self.localUser.userId];
    
    NSDictionary * userDic=[defs objectForKey:key];
    //NSLog(@"Save last message in chatroom: %@", userDic);
    NSMutableDictionary * userMutDic;
    if (userDic==nil)
        userMutDic=[NSMutableDictionary dictionary];
    else 
        userMutDic=[NSMutableDictionary dictionaryWithDictionary:userDic];
    
    NSDictionary * dic=[userMutDic objectForKey:@"chatroomsIdMessageIdDic"];
    NSMutableDictionary * mutDic;
    if (dic==nil)
        mutDic=[NSMutableDictionary dictionary];
    else 
        mutDic=[NSMutableDictionary dictionaryWithDictionary:dic];
    
    
    [mutDic setObject:[NSNumber numberWithInteger:messageId] forKey:chatroomIdStr];
    [userMutDic setObject:mutDic forKey:@"chatroomsIdMessageIdDic"];
    [defs setObject:userMutDic forKey:key];
    [defs synchronize];
}

- (NSInteger) lastMessageReadInChatroom:(NSInteger) chatroomId
{
    NSInteger result=-1;
    
    NSString * chatroomIdStr=[NSString stringWithFormat:@"%ld", (long)chatroomId];
    
    NSUserDefaults * defs=[NSUserDefaults standardUserDefaults];
    NSString * key=[NSString stringWithFormat:@"userChatroomBadgeDic-%ld", (long)self.localUser.userId];
    
    NSDictionary * userDic=[defs objectForKey:key];
    //NSLog(@"Read last message in chatroom: %@", userDic);
    NSDictionary * dic=[userDic objectForKey:@"chatroomsIdMessageIdDic"];
    if ([dic objectForKey:chatroomIdStr]!=nil)
        result=[[dic objectForKey:chatroomIdStr] intValue];
    
    return result;
}

- (void) addChatroomToUnread:(NSInteger) chatroomId
{
    NSUserDefaults * defs=[NSUserDefaults standardUserDefaults];
    NSString * key=[NSString stringWithFormat:@"userChatroomBadgeDic-%ld", (long)self.localUser.userId];
    
    NSDictionary * userDic=[defs objectForKey:key];
    NSMutableDictionary * userMutDic;
    if (userDic==nil)
        userMutDic=[NSMutableDictionary dictionary];
    else 
        userMutDic=[NSMutableDictionary dictionaryWithDictionary:userDic];
    
    NSArray * array=[userMutDic objectForKey:@"chatroomsIdsWithNewMessages"];
    NSMutableArray * mutArray;
    if (array==nil)
        mutArray=[NSMutableArray array];
    else 
        mutArray=[NSMutableArray arrayWithArray:array];
    
    if (![mutArray containsObject:[NSNumber numberWithInteger:chatroomId]])
        [mutArray addObject:[NSNumber numberWithInteger:chatroomId]];
    [userMutDic setObject:mutArray forKey:@"chatroomsIdsWithNewMessages"];
    [defs setObject:userMutDic forKey:key];
    [defs synchronize];
}

- (void) removeChatroomFromUnread:(NSInteger) chatroomId
{
    NSUserDefaults * defs=[NSUserDefaults standardUserDefaults];
    NSString * key=[NSString stringWithFormat:@"userChatroomBadgeDic-%ld", (long)self.localUser.userId];
    
    NSDictionary * userDic=[defs objectForKey:key];
    NSMutableDictionary * userMutDic;
    if (userDic==nil)
        userMutDic=[NSMutableDictionary dictionary];
    else 
        userMutDic=[NSMutableDictionary dictionaryWithDictionary:userDic];
    
    NSArray * array=[userMutDic objectForKey:@"chatroomsIdsWithNewMessages"];
    NSMutableArray * mutArray;
    if (array==nil)
        mutArray=[NSMutableArray array];
    else 
        mutArray=[NSMutableArray arrayWithArray:array];
    
    if ([mutArray containsObject:[NSNumber numberWithInteger:chatroomId]])
    {
        [mutArray removeObject:[NSNumber numberWithInteger:chatroomId]];
        [userMutDic setObject:mutArray forKey:@"chatroomsIdsWithNewMessages"];
        [defs setObject:userMutDic forKey:key];
        [defs synchronize];
    }
}

- (NSArray *) unreadChatrooms
{
    NSUserDefaults * defs=[NSUserDefaults standardUserDefaults];
    NSString * key=[NSString stringWithFormat:@"userChatroomBadgeDic-%ld", (long)self.localUser.userId];
    
    NSDictionary * userDic=[defs objectForKey:key];
    return [userDic objectForKey:@"chatroomsIdsWithNewMessages"];
}

- (void) saveProfileImage:(UIImage *) image
{
    NSUserDefaults * defs=[NSUserDefaults standardUserDefaults];
    NSString * key=[NSString stringWithFormat:@"profile-image-%ld", (long)self.localUser.userId];
    
    NSData * data = UIImageJPEGRepresentation(image, 0.7);
    [defs setObject:data forKey:key];
    
    [defs synchronize];
}

- (UIImage *) getProfileImage
{
    
    NSUserDefaults * defs=[NSUserDefaults standardUserDefaults];
    NSString * key=[NSString stringWithFormat:@"profile-image-%ld", (long)self.localUser.userId];
    
    NSData * data = [defs objectForKey:key];
    
    if (data!=nil)
        return [UIImage imageWithData:data];
    else
        return nil;
}


//2 levels of cache for the small images which appear en chat and users cells
//The first level in memory with 130x130 images, shouldn't take a lot of memory and speed up cells a lot after caching
//The second level has the big images in order to show them in another version
//it contains an array with the image and the date
static NSCache * imageCache = nil;

- (UIImage *) imageFromCacheForUserId:(NSInteger) userId
{
    UIImage * result=nil;
    
    NSString * fileName = [NSString stringWithFormat:@"user_%.10ld.jpg", (long)userId];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *filePath = [cacheDirectory stringByAppendingPathComponent:fileName];
    

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        result = [UIImage imageWithData:[[NSFileManager defaultManager] contentsAtPath:filePath]];
    
    return result;
}

- (void) getImageForUrl:(NSString *) url withUserId: (NSInteger) userId andExecuteBlockInMainQueue:(void(^)(UIImage * image, BOOL gotFromCache)) block
{
    //Fill in first level cache in first run in background
    if (imageCache == nil)
    {
        imageCache = [[NSCache alloc] init];
        
        dispatch_queue_t queue=dispatch_queue_create("First level cache first fill in", NULL);
        dispatch_async(queue, ^{
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cacheDirectory = [paths objectAtIndex:0];
            NSArray * fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cacheDirectory error:NULL];
            for (NSString * file in fileArray)
            {
                if (([file rangeOfString:@"user_"].location == 0) && ([file rangeOfString:@".jpg"].location != NSNotFound))
                {
                    NSString *filePath = [cacheDirectory stringByAppendingPathComponent:file];
                    
                    NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];
                    NSDate * date = [attributes fileModificationDate];
                    
                    //Proceso todas
                    //if ([date timeIntervalSinceNow] > -3600*24)
                    {
                        //Reduce and cache
                        UIImage * image = [UIImage imageWithData:[[NSFileManager defaultManager] contentsAtPath:filePath]];
                        image = [image resizedImage:CGSizeMake(130, 130) interpolationQuality:kCGInterpolationHigh];
                        [imageCache setObject:[NSArray arrayWithObjects:image, date, nil] forKey:file];
                    }
                }
            }
        });
    }
    
    NSString * fileName = [NSString stringWithFormat:@"user_%.10ld.jpg", (long)userId];
    BOOL download=NO;
    BOOL goon = YES;
    
    NSArray * array = [imageCache objectForKey:fileName];
    if (array!=nil)
    {
        UIImage * image = [array objectAtIndex:0];
        NSDate  * date =  [array objectAtIndex:1];
        if ([date timeIntervalSinceNow] < -3600*24)
            download = YES;
        else
            goon = NO;
        
        block (image, YES);
    }
    
    if (goon)
    {
        //Could do it better by not executing this if it was in the first level of cache but out of date. It is not worth it.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = [paths objectAtIndex:0];
        NSString *filePath = [cacheDirectory stringByAppendingPathComponent:fileName];
        
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            NSError * error=nil;
            NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
            NSDate * date = [attributes fileModificationDate];
            //NSLog(@"time interval: %f", [date timeIntervalSinceNow]);
            if ([date timeIntervalSinceNow] < -3600*24) //Cache invalid every day. NSTimeInterval is negative
                //Call the block with the old image? Chances are it has not been updated
                download = YES;
            
            __block UIImage * image = [UIImage imageWithData:[[NSFileManager defaultManager] contentsAtPath:filePath]];
            block(image, YES);
            
            if (!download)
            {
                dispatch_queue_t queue=dispatch_queue_create("First level cache of user images", NULL);
                dispatch_async(queue, ^{
                    
                    //CACHE
                    image = [image resizedImage:CGSizeMake(130, 130) interpolationQuality:kCGInterpolationHigh];
                    [imageCache setObject:[NSArray arrayWithObjects:image, date, nil] forKey:fileName];
                    
                });
            }
        }
        else //download file and cache it
            download=YES;
        
        if (download)
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
            dispatch_queue_t queue=dispatch_queue_create("Download Profile Image", NULL);
            dispatch_async(queue, ^{
                
                NSError * error=nil;
                NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:nil error: &error];
                
                
                //processing in the thread
                UIImage * image = nil;
                if (error==nil)
                {
                    image = [UIImage imageWithData:imageData];
                    //here? it seems to work well in the thread
                    image = [GeneralHelper centralSquareFromImage:image];
                    //cache image
                    //Second level
                    NSData * data = UIImageJPEGRepresentation(image, 0.7);
                    [data writeToFile:filePath atomically:YES];
                    
                    //CACHE
                    image = [image resizedImage:CGSizeMake(130, 130) interpolationQuality:kCGInterpolationHigh];
                    [imageCache setObject:[NSArray arrayWithObjects:image, [NSDate date], nil] forKey:fileName];
                }
                
                dispatch_queue_t mainQueue=dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    
                    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
                    
                    if (error != nil)
                    {
                        block(nil, NO);
                        
                        LextTalkAppDelegate * del = (LextTalkAppDelegate *) [[UIApplication sharedApplication] delegate];
                        if (!del.showingError)
                        {
                            del.showingError=YES;
                            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network error!", nil)
                                                                             message:NSLocalizedString(@"The user profile image could not be downloaded", nil)
                                                                            delegate:self
                                                                   cancelButtonTitle:@"OK"
                                                                   otherButtonTitles: nil];
                            alert.tag = 404;
                            [alert show];
                        }
                    }
                    else
                    {
                        block(image, NO);
                    }
                });
                
            });
        }
    }
}

#pragma mark -
#pragma mark UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((buttonIndex==0) && (alertView.tag==404))
    {
        LextTalkAppDelegate * del = (LextTalkAppDelegate *) [[UIApplication sharedApplication] delegate];
        del.showingError = NO;
    }
}


#pragma mark -
#pragma mark POST SEARCH_CHATROOM request

- (void) searchChatroom: (NSString *) name
                   lang: (NSString *) lang
                userId: (NSInteger) user_id
               delegate: (id <LTDataDelegate>) del
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@", LX_BASE_URL,SEARCH_CHATROOM];
    
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = SEARCH_CHATROOM;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];         
    
    if ([name length]>0)
        [request setPostValue: name forKey: @"keyword"];
    if (lang!=nil)
        [request setPostValue:lang forKey:@"lang"];
    if (user_id>0) {
        [request setPostValue: [self localUser].editKey forKey: @"edit_key"];
        [request setPostValue: [NSString stringWithFormat:@"%ld", (long)user_id] forKey: @"user_id"];
    }

	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];    
	[self.requests addObject: dataRequest];   
}

- (void) searchChatroomResult: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
    NSArray *chatrooms = nil;
    if ([result respondsToSelector:@selector(objectForKey:)]) {
        chatrooms = [result objectForKey: @"chatrooms"];
    } else {
        // assume that result is an array
        chatrooms = (NSArray *)result;
    }
    
    NSMutableArray *searchResults = [[NSMutableArray alloc] initWithCapacity: [chatrooms count]];
    
    IQVerbose(VERBOSE_DEBUG,@"[%@] Got %d chatrooms", [self class], [chatrooms count]);
    
    for(NSDictionary *d in chatrooms) {
        LTChatroom *u = [LTChatroom newChatroomWithDict: d];
        if (u) {
            [searchResults addObject:u];
        }
    }
    
    if([dataRequest.delegate respondsToSelector: @selector(didUpdateSearchResultsChatrooms:)])		
        [dataRequest.delegate didUpdateSearchResultsChatrooms: searchResults];
    
}  

#pragma mark -
#pragma mark POST SEND_MESSAGE_CHATROOM request

- (void) sendMessage: (NSString*) msg
          toChatroom: (NSInteger) receiverId
			fromUser: (NSInteger) userId
		 withEditKey: (NSString*) editKey
			delegate: (id <LTDataDelegate>) del
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@", LX_BASE_URL,SEND_MESSAGE_CHATROOM];
	
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = SEND_MESSAGE_CHATROOM;
	
	NSURL *url = [NSURL URLWithString: reqURL];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];         
	[request setPostValue: [NSString stringWithFormat: @"%ld",(long)[self localUser].userId] forKey: @"user_id"];
	[request setPostValue: [self localUser].editKey forKey: @"edit_key"];	
	[request setPostValue: [NSString stringWithFormat: @"%ld",(long)receiverId] forKey: @"chatroom_id"];
	[request setPostValue: msg forKey: @"message"];	
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];
	[self.requests addObject: dataRequest];
}

#pragma mark -
#pragma mark POST CREATE_CHATROOM request

- (void) createChatroom: (NSString*) name
             withUserId: (NSInteger) userId
                   lang: (NSString*) lang
                editKey: (NSString*) editKey
               delegate: (id) del
{
    NSString *reqURL = [NSString stringWithFormat: @"%@/%@", LX_BASE_URL,CREATE_CHATROOM];
    
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = CREATE_CHATROOM;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];         
    
	[request setPostValue: [NSString stringWithFormat:@"%ld", (long)userId] forKey: @"user_id"];
	[request setPostValue: name forKey: @"chatroom_name"];
    [request setPostValue: lang forKey: @"chatroom_lang"];
    [request setPostValue: editKey forKey: @"edit_key"];
    
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];    
	[self.requests addObject: dataRequest];   
}

- (void) didCreateChatroomResult: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
    NSString *chatroom_id = [result objectForKey:@"chatroom_id"];
    
    if([dataRequest.delegate respondsToSelector: @selector(didCreateChatroom:)])
        [dataRequest.delegate didCreateChatroom:chatroom_id.integerValue];
}

#pragma mark -
#pragma mark POST ENTER_CHATROOM request

- (void) enterChatroom: (NSInteger) chatroom_id
                userId: (NSInteger) user_id
                 limit: (NSInteger) limit
           withEditKey: (NSString *) editKey
               delegate: (id <LTDataDelegate>) del
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@", LX_BASE_URL,ENTER_CHATROOM];
    
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = ENTER_CHATROOM;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];         
    
    [request setPostValue: [NSString stringWithFormat:@"%ld", (long)chatroom_id] forKey: @"chatroom_id"];
    [request setPostValue: [NSString stringWithFormat:@"%ld", (long)user_id] forKey: @"user_id"];
    [request setPostValue: editKey forKey: @"edit_key"];

    if (limit>0)
        [request setPostValue: [NSString stringWithFormat:@"%ld", (long)limit] forKey: @"limit"];
        
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];    
	[self.requests addObject: dataRequest];   
}

//- (void) enterChatroomResult: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
//    NSArray *newMessages = [result objectForKey: @"messages"];
//    NSMutableArray *messageList = [[[NSMutableArray alloc] initWithCapacity: [newMessages count]] autorelease];
//    
//    NSString *timestamp = [result objectForKey: @"timestamp"];
//    
//    IQVerbose(VERBOSE_DEBUG,@"[%@] Got %d new messages (timestamp is %@)", [self class], [newMessages count], self.chatListTimestamp);
//    
//    for(NSDictionary *d in newMessages) {
//        LTMessage *msg = [LTMessage newMessageWithDict: d];
//        [messageList addObject: msg];
//        [msg release];
//    }
//    
//    if([dataRequest.delegate respondsToSelector: @selector(didGetMessages:withTimestamp:)])
//        [dataRequest.delegate didGetMessages:messageList withTimestamp:timestamp];
//}

#pragma mark -
#pragma mark POST LEAVE_CHATROOM request

- (void) leaveChatroom: (NSInteger) chatroom_id
                  user: (NSInteger) user_id
               editKey: (NSString*) edit_key
              delegate: (id <LTDataDelegate>) del
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@", LX_BASE_URL,LEAVE_CHATROOM];
    
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = LEAVE_CHATROOM;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];         
    
    [request setPostValue: [NSString stringWithFormat:@"%ld", (long)chatroom_id] forKey: @"chatroom_id"];
    [request setPostValue: [NSString stringWithFormat:@"%ld", (long)user_id] forKey: @"user_id"];
    [request setPostValue: edit_key forKey: @"edit_key"];
        
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];    
	[self.requests addObject: dataRequest];   
}

#pragma mark -
#pragma mark POST GET_MESSAGE_CHATROOM

- (void) getMesssagesForChatroom:(NSInteger)chatroom_id
                            user:(NSInteger)user_id
                         editKey:(NSString*)edit_key
                            time:(NSString*)time
                           limit:(NSInteger)limit
                        delegate:(id <LTDataDelegate>) del
{
    NSString *reqURL = [NSString stringWithFormat: @"%@/%@", LX_BASE_URL,GET_MESSAGE_CHATROOM];
    
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = GET_MESSAGE_CHATROOM;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];         
    
    [request setPostValue: [NSString stringWithFormat:@"%ld", (long)chatroom_id] forKey: @"chatroom_id"];
    [request setPostValue: [NSString stringWithFormat:@"%ld", (long)user_id] forKey: @"user_id"];
    [request setPostValue: edit_key forKey: @"edit_key"];
    
    if (time)
        [request setPostValue: time forKey: @"time"];

    if (limit>0)
        [request setPostValue: [NSString stringWithFormat:@"%ld", (long)limit] forKey: @"limit"];
    
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];    
	[self.requests addObject: dataRequest];   
}

- (void)getMessageChatroomResult:(NSDictionary*)result withDataRequest: (IQDataRequest*) dataRequest
{
    //NSLog(@"Whole chatroom result: %@", result);
    
    NSArray *newMessages = [result objectForKey: @"messages"];
    NSMutableArray *messageList = [[NSMutableArray alloc] initWithCapacity: [newMessages count]];
    
    NSString *timestamp = [result objectForKey: @"timestamp"];
    NSInteger chatroomId=[[result objectForKey:@"chatroom_id"] intValue];
    
    IQVerbose(VERBOSE_DEBUG,@"[%@] Got %d new messages (timestamp is %@)", [self class], [newMessages count], self.chatListTimestamp);
    
    for(NSDictionary *d in newMessages) {
        LTMessage *msg = [LTMessage newMessageWithDict: d];
        [messageList addObject: msg];
        
        //NSLog(@"Dictionary chat room message: %@", d);
    }
    
    
    if([dataRequest.delegate respondsToSelector: @selector(didGetMessages:withChatroomId:withTimestamp:)])
        [dataRequest.delegate didGetMessages:messageList withChatroomId:chatroomId withTimestamp:timestamp];
}

#pragma mark -
#pragma mark POST ADORDER

- (void) getAdOrder
{
    NSString *reqURL = [NSString stringWithFormat: @"%@/%@", LX_BASE_URL, ADORDER];
	
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = nil;
	dataRequest.url = reqURL;
	dataRequest.note = ADORDER;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    //Get country locale and name
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSString *countryName = [locale displayNameForKey: NSLocaleCountryCode value: countryCode];
    
	[request setPostValue: countryCode forKey: @"country_code"];
	[request setPostValue: countryName forKey: @"country_name"];    

	
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];
	[self.requests addObject: dataRequest];
	IQVerbose(VERBOSE_DEBUG,@"[%@] Sent %@ request", [self class], dataRequest.note);
}

- (void) didGetAdOrder: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
    IQVerbose(VERBOSE_DEBUG,@"[%@] didGetAdOrder: %@", [self class], result);

    
}


#pragma mark -
#pragma mark POST RESTORE_SESSION

-(void)newSessionWithDelegate:(id)delegate
{
    //Facebook account just present in iOS 6.0
    //Renew credentilas, should fix it
    if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 6)
    {
        ACAccountStore *accountStore;
        ACAccountType *accountTypeFB;
        if ((accountStore = [[ACAccountStore alloc] init]) &&
            (accountTypeFB = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook] ) ){
            
            NSArray *fbAccounts = [accountStore accountsWithAccountType:accountTypeFB];
            id account;
            if (fbAccounts && [fbAccounts count] > 0 &&
                (account = [fbAccounts objectAtIndex:0])){
                
                [accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
                    //we don't actually need to inspect renewResult or error.
                    if (error){
                        
                    }
                }];
            }
        }
    }
    
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey: @"LocalUserDict"];
    LTUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSString *reqURL = [NSString stringWithFormat: @"%@/%@", LX_BASE_URL,RESTORE_SESSION];
    
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
    dataRequest.url = reqURL;
    dataRequest.note = RESTORE_SESSION;
    dataRequest.delegate = delegate;
    
    NSURL *url = [NSURL URLWithString: dataRequest.url];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    if (user) {
        [request setPostValue: user.editKey
                       forKey: @"edit_key"];
        [request setPostValue: [NSString stringWithFormat:@"%ld",(long)user.userId]
                       forKey: @"user_id"];
    }
    
    NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *lang = @"";
    if ([languages count] >= 1) {
        lang = [languages objectAtIndex:0];
    }
    [request setPostValue: [UIDevice currentDevice].uniqueDeviceIdentifier
                   forKey: @"udid"];
    [request setPostValue: [UIDevice currentDevice].systemVersion
                   forKey: @"os_version"];
    [request setPostValue: [UIDevice currentDevice].model
                   forKey: @"device_type"];
    [request setPostValue: [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey]
                   forKey: @"app_version"];
    [request setPostValue: lang
                   forKey: @"lang_code"];
    
    if ([LTDataSource isLextTalkCatalan])
        [request setPostValue:@"2" forKey:@"app_id"];
    else
        [request setPostValue:@"1" forKey:@"app_id"];
    
    IQVerbose(VERBOSE_DEBUG,@"[%@] Restoring session.", [self class]);
    
    [request setDelegate: self];
    [request startAsynchronous];
    [dataRequest setRequest: request];
    [self.requests addObject: dataRequest];
    IQVerbose(VERBOSE_DEBUG,@"[%@] Sent %@ request", [self class], dataRequest.note);
}

#pragma mark -
#pragma mark POST CREATE_USER requests

- (void) createUser: (NSString*) name
       withPassword: (NSString*) pwd
          withEmail:(NSString *)email
           delegate: (id <LTDataDelegate>) del
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@", LX_BASE_URL, CREATE_USER];
	
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = CREATE_USER;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue: name forKey: @"name"];
	[request setPostValue: [NSString sha1Digest: pwd] forKey: @"password"];
    [request setPostValue: email forKey: @"email"];
    if ([LTDataSource isLextTalkCatalan])
        [request setPostValue:@"2" forKey:@"app_id"];
    else
        [request setPostValue:@"1" forKey:@"app_id"];
	//[request setPostValue: [UIDevice currentDevice].uniqueDeviceIdentifier forKey: @"udid"];
	
	if(self.apnsToken != nil) {
        IQVerbose(VERBOSE_DEBUG,@"[%@] Sending APNS token: %@", [self class], self.apnsToken);
        NSLog(@"[%@] Sending APNS token: %@", [self class], self.apnsToken);
		[request setPostValue: self.apnsToken forKey: @"dev_id"];
	}
	
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];
	[self.requests addObject: dataRequest];
	IQVerbose(VERBOSE_DEBUG,@"[%@] Sent %@ request", [self class], dataRequest.note);        			
}

- (void) didCreateUserWithResult: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
   IQVerbose(VERBOSE_DEBUG,@"[%@] didCreateUserWithResult: %@", [self class], result);
    
    LTUser *user = [[LTUser alloc] initWithDict: result];
    [user setCoordinate: latestLocation];
    
    ASIFormDataRequest *req = (ASIFormDataRequest*) dataRequest.request;
    [self setLocalUser: user
       andPasswordHash: (NSString*) [req getPostValueForKey: @"password"]];
    if([dataRequest.delegate respondsToSelector: @selector(didCreateUser)])
        [dataRequest.delegate didCreateUser];
}


#pragma mark -
#pragma mark POST LOGIN_USER request
- (void) restoreLoginWithDelegate: (id <LTDataDelegate>) del {
    
    //If I have stored in "LocalUserHash" the word "FacebookLogin" it means I try to restore the session from a cached Facebook token
    if ([[[NSUserDefaults standardUserDefaults] objectForKey: @"LocalUserHash"] isEqualToString:@"FacebookLogin"])
    {
        [self openSessionWithAllowLoginUI:NO withDelegate:del withFacebokAction:LTFacebookActionLogin];
    }
    else
    {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey: @"LocalUserDict"];
        LTUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if(user == nil) {
            IQVerbose(VERBOSE_DEBUG,@"[%@] No user is signed in", [self class]);
            [self setLocalUser: nil
               andPasswordHash: nil];
            [del didFail: nil];
            return;
        }
        
        NSString *reqURL = [NSString stringWithFormat: @"%@/%@", LX_BASE_URL,LOGIN_USER];
        
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
        
        [request setPostValue: [UIDevice currentDevice].uniqueDeviceIdentifier
                       forKey: @"udid"];
        
        if ([LTDataSource isLextTalkCatalan])
            [request setPostValue:@"2" forKey:@"app_id"];
        else
            [request setPostValue:@"1" forKey:@"app_id"];
        
        IQVerbose(VERBOSE_DEBUG,@"[%@] Restoring login for:", [self class]);
        IQVerbose(VERBOSE_DEBUG,@"   User: %@", user.name);
        IQVerbose(VERBOSE_DEBUG,@"   Hash: %@", [[NSUserDefaults standardUserDefaults] objectForKey: @"LocalUserHash"]);
        
        if(self.apnsToken != nil) {
            // IQVerbose(VERBOSE_ALL,@"[%@] Sending APNS token: %@", [self class], self.apnsToken);
            NSLog(@"[%@] Sending APNS token: %@", [self class], self.apnsToken);
            [request setPostValue: self.apnsToken forKey: @"dev_id"];
        } else {
            // IQVerbose(VERBOSE_ALL,@"[%@] No APNS token", [self class]);
            NSLog(@"[%@] No APNS token", [self class]);
        }
        
        [request setDelegate: self];
        [request startAsynchronous];
        [dataRequest setRequest: request];    
        [self.requests addObject: dataRequest];
        IQVerbose(VERBOSE_DEBUG,@"[%@] Sent %@ request", [self class], dataRequest.note);
    }
}

- (void) loginUser: (NSString*) name
	  withPassword: (NSString*) pwd 
		  delegate: (id <LTDataDelegate>) del
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@", LX_BASE_URL, LOGIN_USER];
	
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = LOGIN_USER;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue: name forKey: @"name"];
	[request setPostValue: [NSString sha1Digest: pwd] forKey: @"password"];    
	//[request setPostValue: [UIDevice currentDevice].uniqueDeviceIdentifier forKey: @"udid"];
    
    if ([LTDataSource isLextTalkCatalan])
        [request setPostValue:@"2" forKey:@"app_id"];
    else
        [request setPostValue:@"1" forKey:@"app_id"];
	
	if(self.apnsToken != nil) {
        IQVerbose(VERBOSE_DEBUG,@"[%@] Sending APNS token: %@", [self class], self.apnsToken);
        NSLog(@"[%@] Sending APNS token: %@", [self class], self.apnsToken);
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
    
    if (![result respondsToSelector:@selector(objectForKey:)]) {
        // it is an empty result
        [dataRequest.delegate didFail:result];
        return;
    }
    
    NSString * hash = (NSString *) [req getPostValueForKey: @"password"];
    [self didLoginUserWithResult:result withPasswordHash:hash andDelegate:dataRequest.delegate];
}

- (void) didLoginUserWithResult: (NSDictionary*) result withPasswordHash:(NSString *) hash andDelegate:(id<LTDataDelegate>) delegate
{
    //NSLog(@"Did login with user result: %@", result);
    LTUser *user = [[LTUser alloc] initWithDict: result];
    
    double server_latitude = user.coordinate.latitude;
    double server_longitude = user.coordinate.longitude;
    
    // override server location with latest valid location
    if (!user.fuzzyLocation)
    {
        if( ([self latestLocation].longitude != 0) && ([self latestLocation].latitude != 0) ) {
            [user setCoordinate: [self latestLocation]];
        }
    }
    
    [self setLocalUser: user
       andPasswordHash: hash];
    
    self.localUser.image=[self getProfileImage];
    
    [self loadChatListFromUserDefaults];
    
    if([delegate respondsToSelector: @selector(didLoginUser)])
    {
        [delegate didLoginUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LTDidLoginUser" object:self];
    }
    
    // update user location after login if necessary
    if (!user.fuzzyLocation)
    {
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
}


#pragma mark -
#pragma mark POST LOGOUT_USER request

- (void) logoutWithDelegate: (id <LTDataDelegate>) del {
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@", LX_BASE_URL,LOGOUT_USER];
	
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = LOGOUT_USER;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue: [NSString stringWithFormat:@"%ld", (long)self.localUser.userId] forKey: @"user_id"];
	[request setPostValue: self.localUser.editKey forKey: @"edit_key"];
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];
	[self.requests addObject: dataRequest];
	
	
}

- (void) didLogoutWithResult:(NSDictionary *) result withDataRequest: (IQDataRequest *) dataRequest
{
    // now, set localUser to nil
    [self setLocalUser: nil
       andPasswordHash: nil];
	
	// delete cached data
	//[userList removeAllObjects];
	[self.chatList removeAllObjects];
	self.chatListTimestamp = @"";
    
    
    // bring all navigation view controllers to root view controller
    LextTalkAppDelegate *appDel = (LextTalkAppDelegate*) [UIApplication sharedApplication].delegate;
	[appDel setBadgeValueTo: 0];
    [appDel resetNavgationControllers];
	/*
     [appDel goToUserAtLongitude: latestLocation.longitude
     andLatitude: latestLocation.latitude];
	 */
    
    if([dataRequest.delegate respondsToSelector: @selector(didLogoutUser)])
        [dataRequest.delegate didLogoutUser];
}

# pragma mark -
# pragma mark Vamos a liarla
- (void) updateUser: (NSInteger) userId
		withEditKey: (NSString*) editKey
          saveImage: (BOOL)saveImage
		   delegate: (id <LTDataDelegate>) del
{
    
    NSMutableDictionary *allParams = [NSMutableDictionary dictionary];
    
    if (!self.localUser.fuzzyLocation)
    {
        [allParams addEntriesFromDictionary:@{ @"longitude":@(latestLocation.longitude)
         , @"latitude":@(latestLocation.latitude)}];
    }
    else
    {
        
        [allParams addEntriesFromDictionary:@{ @"longitude":@(self.localUser.coordinate.longitude)
         , @"latitude":@(self.localUser.coordinate.latitude)}];
    }
    
    
    [allParams addEntriesFromDictionary:@{ @"user_id":@(userId)
     , @"edit_key":editKey?:NSNull.null
     , @"status":self.localUser.status?:NSNull.null
     }];
    
    //active languages
    
    [allParams addEntriesFromDictionary:@{
     @"learning_language":[self localUser].activeLearningLan?:NSNull.null,
     @"native_language":[self localUser].activeSpeakingLan?:NSNull.null,
     @"learning_languages":self.localUser.learningLanguages?:NSNull.null,
     @"native_languages":self.localUser.speakingLanguages?:NSNull.null,
     @"learning_flags":self.localUser.learningLanguagesFlags?:NSNull.null,
     @"native_flags":self.localUser.speakingLanguagesFlags?:NSNull.null
     }];
    
    [allParams setObject:[self localUser].screenName?:NSNull.null forKey: @"screen_name"];
    [allParams setObject:[self localUser].twitter?:NSNull.null forKey: @"twitter"];
    [allParams setObject:[self localUser].mail?:NSNull.null forKey: @"mail"];
    [allParams setObject:[self localUser].url?:NSNull.null forKey: @"url"];
    [allParams setObject:[self localUser].address?:NSNull.null forKey: @"address"];
    
    if ([self localUser].fuzzyLocation)
        [allParams setObject:@"1" forKey:@"fuzzy_location"];
    else
        [allParams setObject:@"0" forKey:@"fuzzy_location"];
    [allParams setObject: ([self localUser].hasPicture? @"1": @"0") forKey: @"has_picture"];
    
    
    NSMutableDictionary *nonNullParams = [NSMutableDictionary dictionary];
    
    [allParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj != NSNull.null) {
            [nonNullParams setObject:obj forKey:key];
        }
    }];
    
    AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:LX_BASE_URL]];
    
    //NSDictionary *allParams = [self complete:path parameters:parameters method:method];
    NSURLRequest *request = [client multipartFormRequestWithMethod:@"POST"
                                                              path:UPDATE_USER
                                                        parameters:nonNullParams
                                         constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
                                             if (self.localUser.image!=nil && saveImage)
                                             {
                                                 [formData appendPartWithFileData:UIImageJPEGRepresentation([self localUser].image, 0.7)
                                                                             name:@"image"
                                                                         fileName:@"image.jpg"
                                                                         mimeType:@"image/jpeg"];
                                             }
                                         }];
    
    AFHTTPRequestOperation *operation =
    [client HTTPRequestOperationWithRequest:request
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        //NSLog(@"ok with update of user, it is going to be saved");
                                        NSError *parseError = nil;
                                        NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:responseObject options:nil error:&parseError]];
                                        
                                        if ([newDict objectForKey:@"result"] == nil || [[newDict objectForKey:@"status"] isEqual:@"error"])
                                        {
                                            [del didFail:[newDict objectForKey:@"result"]];
                                            return;
                                        }
                                        
                                        LTUser *user = [[LTUser alloc] initWithDict: [newDict objectForKey:@"result"]];
                                        
                                        // override server location with latest valid location
                                        if (!user.fuzzyLocation)
                                        {
                                            if( ([self latestLocation].longitude != 0) && ([self latestLocation].latitude != 0) ) {
                                                [user setCoordinate: [self latestLocation]];
                                            }
                                        }
                                        
                                        //and save the image before overwritting the local user
                                        [self saveProfileImage:self.localUser.image];
                                        
                                        // now set the user
                                        [self setLocalUser: user
                                           andPasswordHash: [[NSUserDefaults standardUserDefaults] objectForKey: @"LocalUserHash"]];
                                        
                                        if([del respondsToSelector: @selector(didUpdateUser)])
                                            [del didUpdateUser];
                                    }
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"error with update");
                                        NSDictionary *result = nil;
                                        if (operation.responseData != nil)
                                            result = [NSJSONSerialization JSONObjectWithData:operation.responseData options:nil error:nil];
                                        if (!result) {
                                            result = @{@"error_title":@"Error", @"error_message":error.description};
                                        }
                                        
                                        if([del respondsToSelector: @selector(didFail:)])
                                            [del didFail:result];
                                        if([del respondsToSelector: @selector(didFailUpdatingUser)])
                                            [del didFailUpdatingUser];
                                    }];
    [client enqueueHTTPRequestOperation:operation];
    return;
}

- (void) blockUser:(NSInteger) userId withBlockStatus:(BOOL) block delegate:(id<LTDataDelegate>) del
{
    NSMutableDictionary *allParams = [NSMutableDictionary dictionary];
    
    [allParams addEntriesFromDictionary:@{
     @"user_id":@(self.localUser.userId),
     @"edit_key":self.localUser.editKey?:NSNull.null,
     @"block_user_id":@(userId),
     @"block":@(block ? 1:0)
     }];
    
    NSMutableDictionary *nonNullParams = [NSMutableDictionary dictionary];
    [allParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj != NSNull.null)
            [nonNullParams setObject:obj forKey:key];
    }];
    
    AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:LX_BASE_URL]];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:BLOCK_USER parameters:nonNullParams];
    
    AFHTTPRequestOperation *operation =
    [client HTTPRequestOperationWithRequest:request
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        
                                        NSError *parseError = nil;
                                        NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary: [NSJSONSerialization JSONObjectWithData:responseObject options:nil error:&parseError]];
                                        
                                        //NSLog(@"ok with blocking user: %@", newDict);
                                        
                                        if ([newDict objectForKey:@"result"] == nil || [[newDict objectForKey:@"status"] isEqual:@"error"])
                                        {
                                            [del didFail:[newDict objectForKey:@"result"]];
                                            return;
                                        }
                                        
                                        //I update the local user but do not save it since this data is downloaded
                                        //when I restore the session, or perform login or any other kind of update
                                        NSMutableArray * mut = [NSMutableArray arrayWithArray: self.localUser.blockedUsers];
                                        if (block)
                                            [mut addObject:[NSNumber numberWithInteger:userId]];
                                        else
                                            [mut removeObject:[NSNumber numberWithInteger:userId]];
                                        self.localUser.blockedUsers=mut;
                                        
                                        if([del respondsToSelector: @selector(didBlockUser:withBlockStatus:)])
                                            [del didBlockUser:userId withBlockStatus:block];
                                    }
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        //NSLog(@"error with blocking user");
                                        
                                        if([del respondsToSelector: @selector(didFail:)])
                                        {
                                            NSDictionary *result = nil;
                                            if (operation.responseData != nil)
                                                result = [NSJSONSerialization JSONObjectWithData:operation.responseData options:nil error:nil];
                                            if (!result) {
                                                result = @{@"error_title":@"Error", @"error_message":error.description};
                                            }
                                            
                                            [del didFail:result];
                                        }
                                    }];
    [client enqueueHTTPRequestOperation:operation];
    return;
}

- (void) deleteLocalUserWithDelegate:(id<LTDataDelegate>) del
{
    NSMutableDictionary *allParams = [NSMutableDictionary dictionary];
    
    [allParams addEntriesFromDictionary:@{
     @"user_id":@(self.localUser.userId),
     @"edit_key":self.localUser.editKey?:NSNull.null
     }];
    
    NSMutableDictionary *nonNullParams = [NSMutableDictionary dictionary];
    [allParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj != NSNull.null)
            [nonNullParams setObject:obj forKey:key];
    }];
    
    AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:LX_BASE_URL]];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:DELETE_USER parameters:nonNullParams];
    
    AFHTTPRequestOperation *operation =
    [client HTTPRequestOperationWithRequest:request
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        
                                        NSError *parseError = nil;
                                        NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary: [NSJSONSerialization JSONObjectWithData:responseObject options:nil error:&parseError]];
                                        
                                        //NSLog(@"ok with deleting user: %@", newDict);
                                        
                                        if ([newDict objectForKey:@"result"] == nil || [[newDict objectForKey:@"status"] isEqual:@"error"])
                                        {
                                            [del didFail:[newDict objectForKey:@"result"]];
                                            return;
                                        }
                                        
                                        //Delete and save local user
                                        [self setLocalUser:nil andPasswordHash:nil];
                                        
                                        // delete cached data
                                        //[userList removeAllObjects];
                                        [self.chatList removeAllObjects];
                                        self.chatListTimestamp = @"";
                                        
                                        
                                        // bring all navigation view controllers to root view controller
                                        LextTalkAppDelegate *appDel = (LextTalkAppDelegate*) [UIApplication sharedApplication].delegate;
                                        [appDel setBadgeValueTo: 0];
                                        [appDel resetNavgationControllers];
                                        
                                        if([del respondsToSelector: @selector(didDeleteLocalUser)])
                                            [del didDeleteLocalUser];
                                    }
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        //NSLog(@"error with blocking user");
                                        
                                        if([del respondsToSelector: @selector(didFail:)])
                                        {
                                            NSDictionary *result = nil;
                                            if (operation.responseData != nil)
                                                result = [NSJSONSerialization JSONObjectWithData:operation.responseData options:nil error:nil];
                                            if (!result) {
                                                result = @{@"error_title":@"Error", @"error_message":error.description};
                                            }
                                            [del didFail:result];
                                        }
                                    }];
    [client enqueueHTTPRequestOperation:operation];
    return;
}

- (void) loginWithFacebookToken:(NSString *) token delegate:(id<LTDataDelegate>) del
{
    NSMutableDictionary *allParams = [NSMutableDictionary dictionary];
    
    NSString * appId;
    if ([LTDataSource isLextTalkCatalan])
        appId = @"2";
    else
        appId = @"1";
    
    [allParams addEntriesFromDictionary:@{
     @"token": token,
     @"app_id": appId
     }];
    
    if(self.apnsToken != nil) {
        NSLog(@"[%@] Sending APNS token in Facebook Login: %@", [self class], self.apnsToken);
        [allParams addEntriesFromDictionary:@{
         @"dev_id": self.apnsToken
         }];
	}
    
    NSMutableDictionary *nonNullParams = [NSMutableDictionary dictionary];
    [allParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj != NSNull.null)
            [nonNullParams setObject:obj forKey:key];
    }];
    
    AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:LX_BASE_URL]];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:FB_LOGIN_USER parameters:nonNullParams];
    
    AFHTTPRequestOperation *operation =
    [client HTTPRequestOperationWithRequest:request
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        NSError *parseError = nil;
                                        NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary: [NSJSONSerialization JSONObjectWithData:responseObject options:nil error:&parseError]];
                                        
                                        //NSLog(@"ok with logging with facebook: %@", newDict);
                                        
                                        if ([newDict objectForKey:@"result"] == nil || [[newDict objectForKey:@"status"] isEqual:@"error"])
                                        {
                                            [del didFail:[newDict objectForKey:@"result"]];
                                            return;
                                        }
                                        
                                        NSDictionary * result = [newDict objectForKey:@"result"];
                                        
                                        [self didLoginUserWithResult:result withPasswordHash:@"FacebookLogin" andDelegate:del];
                                        
                                    }
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        //NSLog(@"error logging with facebook");
                                        
                                        if([del respondsToSelector: @selector(didFail:)])
                                        {
                                            NSDictionary *result = nil;
                                            if (operation.responseData != nil)
                                                result = [NSJSONSerialization JSONObjectWithData:operation.responseData options:nil error:nil];
                                            if (!result) {
                                                result = @{@"error_title":@"Error", @"error_message":error.description};
                                            }
                                            [del didFail:result];
                                        }
                                    }];
    [client enqueueHTTPRequestOperation:operation];
    return;
}

- (void) rememberPasswordForEmail:(NSString *) email withDelegate:(id<LTDataDelegate>) del
{
    NSMutableDictionary *allParams = [NSMutableDictionary dictionary];
    
    [allParams addEntriesFromDictionary:@{
                                          @"email":email
                                          }];
    
    NSMutableDictionary *nonNullParams = [NSMutableDictionary dictionary];
    [allParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj != NSNull.null)
            [nonNullParams setObject:obj forKey:key];
    }];
    
    AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:LX_BASE_URL]];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:REMEMBER_PASSWORD parameters:nonNullParams];
    
    AFHTTPRequestOperation *operation =
    [client HTTPRequestOperationWithRequest:request
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        
                                        NSError *parseError = nil;
                                        NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary: [NSJSONSerialization JSONObjectWithData:responseObject options:nil error:&parseError]];
                                        
                                        if ([newDict objectForKey:@"result"] == nil || [[newDict objectForKey:@"status"] isEqual:@"error"])
                                        {
                                            if([del respondsToSelector: @selector(didFail:)])
                                                [del didFail:[newDict objectForKey:@"result"]];
                                            //NSLog(@"Remember password failed %@", newDict);
                                            return;
                                        }
                                        
                                        if ([newDict objectForKey:@"result"] == nil || [[newDict objectForKey:@"status"] isEqual:@"success"])
                                        {
                                            if([del respondsToSelector: @selector(didRememberPassword)])
                                                [del didRememberPassword];
                                            //NSLog(@"Remember password sent: %@", newDict);
                                            return;
                                        }
                                    }
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        //NSLog(@"error with blocking user");
                                        
                                        if([del respondsToSelector: @selector(didFail:)])
                                        {
                                            NSDictionary *result = nil;
                                            if (operation.responseData != nil)
                                                result = [NSJSONSerialization JSONObjectWithData:operation.responseData options:nil error:nil];
                                            if (!result) {
                                                result = @{@"error_title":@"Error", @"error_message":error.description};
                                            }
                                            [del didFail:result];
                                        }
                                    }];
    [client enqueueHTTPRequestOperation:operation];
    return;
}

- (void) searchUserContacts:(NSArray *) emails withDelegate:(id<LTDataDelegate>) del useFacebook:(BOOL) useFacebook
{
    NSMutableDictionary *allParams = [NSMutableDictionary dictionary];
    
    for (NSInteger i = 0; i < [emails count]; i++)
        [allParams setObject:[emails objectAtIndex:i] forKey:[NSString stringWithFormat:@"email%d", i+1]];
    
    //If a Facebook session is opened and if the user is signed in, I add tue token and the user id
    if ((useFacebook) && (self.localUser != nil))
    {
        [allParams setObject:[FBSession activeSession].accessTokenData.accessToken forKey:@"token"];
        [allParams setObject:[NSNumber numberWithInteger:self.localUser.userId] forKey:@"user_id"];
    }
    
    NSMutableDictionary *nonNullParams = [NSMutableDictionary dictionary];
    [allParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj != NSNull.null)
            [nonNullParams setObject:obj forKey:key];
    }];
    
    AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:LX_BASE_URL]];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:SEARCH_USER_EMAIL parameters:nonNullParams];
    
    AFHTTPRequestOperation *operation =
    [client HTTPRequestOperationWithRequest:request
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        
                                        NSError *parseError = nil;
                                        NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary: [NSJSONSerialization JSONObjectWithData:responseObject options:nil error:&parseError]];
                                        
                                        //NSLog(@"newDict: %@", newDict);
                                        
                                        if ([newDict objectForKey:@"result"] == nil || [[newDict objectForKey:@"status"] isEqual:@"error"])
                                        {
                                            if([del respondsToSelector: @selector(didFail:)])
                                                [del didFail:[newDict objectForKey:@"result"]];
                                            //NSLog(@"SEARCH_USER_EMAIL failed: %@", newDict);
                                            return;
                                        }
                                        
                                        if ([newDict objectForKey:@"result"] == nil || [[newDict objectForKey:@"status"] isEqual:@"success"])
                                        {
                                            if([del respondsToSelector: @selector(didUpdateSearchResultsUsers:)])
                                            {
                                                NSArray *newUsers = [[newDict objectForKey: @"result"] objectForKey:@"users"];
                                                
                                                NSMutableArray *searchResults = [[NSMutableArray alloc] initWithCapacity: [newUsers count]];
                                                
                                                IQVerbose(VERBOSE_DEBUG,@"[%@] Got %d users", [self class], [newUsers count]);
                                                
                                                for(NSDictionary *d in newUsers) {
                                                    LTUser *u = [[LTUser alloc] initWithDict: d];
                                                    // do not include local userin resuts
                                                    if(u.userId != self.localUser.userId)  
                                                        [searchResults addObject: u];
                                                }
                                                
                                                //
                                                NSMutableArray * storedUserContactsFromChats = [self getStoredUserContactsFromChats];
                                                
                                                //Coger los usuarios de los chats
                                                __block BOOL errorDownloadingUsers = NO;
                                                NSMutableSet * set = [NSMutableSet set];
                                                for (LTChat * chat in self.chatList)
                                                    [set addObject:[NSNumber numberWithInteger:chat.userId]];
                                                NSMutableSet * setCopy = [set copy];
                                                if ([setCopy count] > 0)
                                                {
                                                    for (NSNumber * number in setCopy)
                                                    {
                                                        [self getUserWithUserId:[number integerValue] andExecuteBlockInMainQueue:^(LTUser *user, NSError *error) {
                                                            
                                                            @synchronized(self)
                                                            {
                                                                if (error != nil)
                                                                    errorDownloadingUsers = YES;
                                                                
                                                                [set removeObject:number];
                                                                if ((error == nil) && (user != nil))
                                                                {
                                                                    if (![storedUserContactsFromChats containsObject:user])
                                                                        [storedUserContactsFromChats addObject:user];
                                                                }
                                                                
                                                                if ([set count] == 0)
                                                                {
                                                                    for (LTUser * u in storedUserContactsFromChats)
                                                                    {
                                                                        if (![searchResults containsObject:u])
                                                                            [searchResults addObject:u];
                                                                    }
                                                                    //Store storedUserContactsFromChats
                                                                    [self saveStoredUserContactsFromChats:storedUserContactsFromChats];
                                                                    
                                                                    //Ordenar por screen name
                                                                    [searchResults sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"screenName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
                                                                    
                                                                    //Store users
                                                                    [self saveUserContacts:searchResults];
                                                                    
                                                                    [del didUpdateSearchResultsUsers: searchResults];
                                                                    
                                                                    if (errorDownloadingUsers)
                                                                    {
                                                                        UIAlertView * alert =
                                                                        [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Some user details could not be downloaded, please, try again", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
                                                                        [alert show];
                                                                    }
                                                                }
                                                            }
                                                            
                                                        }];
                                                    }
                                                }
                                                else
                                                {
                                                    for (LTUser * u in storedUserContactsFromChats)
                                                    {
                                                        if (![searchResults containsObject:u])
                                                            [searchResults addObject:u];
                                                    }
                                                    //Ordenar por screen name
                                                    [searchResults sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"screenName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
                                                    
                                                    //Store users
                                                    [self saveUserContacts:searchResults];
                                                    
                                                    [del didUpdateSearchResultsUsers: searchResults];
                                                }
                                            }
                                            //NSLog(@"SEARCH_USER_EMAIL OK: %@", newDict);
                                            return;
                                        }
                                    }
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        //NSLog(@"error with blocking user");
                                        
                                        if([del respondsToSelector: @selector(didFail:)])
                                        {
                                            NSDictionary *result = nil;
                                            if (operation.responseData != nil)
                                                result = [NSJSONSerialization JSONObjectWithData:operation.responseData options:nil error:nil];
                                            if (!result) {
                                                result = @{@"error_title":@"Error", @"error_message":error.description};
                                            }
                                            [del didFail:result];
                                        }
                                    }];
    [client enqueueHTTPRequestOperation:operation];
    return;
}

- (NSArray *) getUserContacts
{
    NSString * key = [NSString stringWithFormat:@"LTUsersInContacts-%ld",(long)self.localUser.userId];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey: key];
    if (data != nil)
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    else
        return nil;
}

- (void) saveUserContacts: (NSArray *) array
{
    NSString * key = [NSString stringWithFormat:@"LTUsersInContacts-%ld",(long)self.localUser.userId];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: array];
    [[NSUserDefaults standardUserDefaults] setObject: data forKey: key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMutableArray *) getStoredUserContactsFromChats
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey: [NSString stringWithFormat:@"LTUsersStoredUserContactsFromChats-%ld",(long)self.localUser.userId]];
    if (data != nil)
        return [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    else
        return [NSMutableArray array];
}

- (void) saveStoredUserContactsFromChats: (NSArray *) array
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: array];
    [[NSUserDefaults standardUserDefaults] setObject: data forKey: [NSString stringWithFormat:@"LTUsersStoredUserContactsFromChats-%ld",(long)self.localUser.userId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) deleteUserFromStoredUserContactsFromChats: (LTUser * ) user
{
    NSMutableArray * array = [self getStoredUserContactsFromChats];
    if ([array containsObject:user])
        [array removeObject:user];
    
    [self saveStoredUserContactsFromChats:array];
}

#pragma mark - Nueva API con blocks

- (BOOL) isThereErrorInDict:(NSDictionary *) dict
{
    BOOL result = NO;
    if ([dict objectForKey:@"result"] == nil)
    {
        LextTalkAppDelegate * del = (LextTalkAppDelegate *) [[UIApplication sharedApplication] delegate];
        if (!del.showingError)
        {
            del.showingError=YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Network error", @"Network error")
                                                            message: NSLocalizedString(@"Could not process the request", @"Could not process the request")
                                                           delegate: self
                                                  cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
                                                  otherButtonTitles: nil];
            alert.tag = 404;
            [alert show];
        }
        
        result = YES;
    }
    else if ([[dict objectForKey:@"status"] isEqual:@"success"])
    {
        result = NO;
    }
    else if ([[dict objectForKey:@"status"] isEqual:@"error"])
    {
        result = YES;
        
        LextTalkAppDelegate * del = (LextTalkAppDelegate *) [[UIApplication sharedApplication] delegate];
        if (!del.showingError)
        {
            del.showingError=YES;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: [[dict objectForKey:@"result"] objectForKey: @"error_title"]
                                                            message: [[dict objectForKey:@"result"] objectForKey: @"error_message"]
                                                           delegate: self
                                                  cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
                                                  otherButtonTitles: nil];
            alert.tag = 404;
            [alert show];
        }
    }
    else
    {
        result = YES;
        
        LextTalkAppDelegate * del = (LextTalkAppDelegate *) [[UIApplication sharedApplication] delegate];
        if (!del.showingError)
        {
            del.showingError=YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Network error", @"Network error")
                                                            message: NSLocalizedString(@"Could not process the request", @"Could not process the request")
                                                           delegate: self
                                                  cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
                                                  otherButtonTitles: nil];
            alert.tag = 404;
            [alert show];
        }
    }
    
    return result;
}

- (void) getUserWithUserId:(NSInteger) userId andExecuteBlockInMainQueue:(void(^)(LTUser * user, NSError *error)) block
{
    NSMutableDictionary *allParams = [NSMutableDictionary dictionary];
    
    
    [allParams addEntriesFromDictionary:@{
     @"user_id": @(userId)
     }];
    
    NSMutableDictionary *nonNullParams = [NSMutableDictionary dictionary];
    [allParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj != NSNull.null)
            [nonNullParams setObject:obj forKey:key];
    }];
    
    AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:LX_BASE_URL]];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:GET_USER parameters:nonNullParams];
    
    AFHTTPRequestOperation *operation =
    [client HTTPRequestOperationWithRequest:request
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        NSError *parseError = nil;
                                        NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary: [NSJSONSerialization JSONObjectWithData:responseObject options:nil error:&parseError]];
                                        
                                        //NSLog(@"ok with getting user with block: %@", newDict);
                                        if ([newDict objectForKey:@"result"] == nil)
                                        {
                                            //I return a non nil NSError, so that no error is not displayed in LTChat
                                            block(nil, [NSError errorWithDomain:@"Could not get user info" code:0 userInfo:nil]);
                                            return;
                                        }
                                            
                                        if ([[newDict objectForKey:@"status"] isEqual:@"error"])
                                        {
                                            //NSLog(@"getUserWith block dic: %@", newDict);
                                            NSInteger errorCode = [[[newDict objectForKey:@"result"] objectForKey:@"error_code"] integerValue];
                                            
                                            //404 means that the user was deleted, so there is no error, the reciving block should handle this condition
                                            if (errorCode == 404) 
                                                block (nil, nil);
                                            else
                                                block(nil, [NSError errorWithDomain:@"Could not get user info" code:0 userInfo:nil]);
                                            return;
                                        }
                                        
                                        NSDictionary * result = [newDict objectForKey:@"result"];
                                        
                                        LTUser * user = [[LTUser alloc] initWithDict:result];
                                        
                                        //Add to cache
                                        [self.userCache setObject:user forKey:[NSNumber numberWithInteger:user.userId]];
                                        
                                        block(user, nil);
                                        
                                    }
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        //NSLog(@"error logging with facebook");
                                        
                                        block(nil, error);
                                    }];
    [client enqueueHTTPRequestOperation:operation];
    return;
}


- (void) sendMessage: (NSString*) msg
			  toUser: (NSInteger) receiverId
		 withEditKey: (NSString*) editKey
andExecuteBlockInMainQueue:(void(^)(BOOL hasPendingMessages , NSError *error)) block
{
    NSMutableDictionary *allParams = [NSMutableDictionary dictionary];
    
    
    [allParams addEntriesFromDictionary:@{
                                          @"user_id": @([self localUser].userId),
                                          @"edit_key": [self localUser].editKey,
                                          @"dest_id": @(receiverId),
                                          @"message": msg
                                          }];
    
    NSMutableDictionary *nonNullParams = [NSMutableDictionary dictionary];
    [allParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj != NSNull.null)
            [nonNullParams setObject:obj forKey:key];
    }];
    
    AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:LX_BASE_URL]];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:SEND_MSG parameters:nonNullParams];
    
    AFHTTPRequestOperation *operation =
    [client HTTPRequestOperationWithRequest:request
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        NSError *parseError = nil;
                                        NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary: [NSJSONSerialization JSONObjectWithData:responseObject options:nil error:&parseError]];
                                        
                                        //NSLog(@"New Dict send Message: %@", newDict);
                                        
                                        if ([self isThereErrorInDict:newDict])
                                        {
                                            block(NO, [NSError errorWithDomain:@"Could not send message" code:0 userInfo:nil]);
                                            return;
                                        }
                                        
                                        NSDictionary * result = [newDict objectForKey:@"result"];
                                        
                                        LTMessage * message = [LTMessage newMessageWithDict:result];
                                        
                                        //Asegurarse que se sigue enviando en la API.
                                        BOOL has_messages = [[result objectForKey:@"has_messages"] boolValue];
                                        
                                        //Complete LTMessage with info, if destUser is not cached, retrieve that info too
                                        message.body = msg;
                                        message.destId = receiverId;
                                        message.senderId = [self localUser].userId;
                                        message.deliverStatus = DELIVER_FINISHED;//Este se queda en local guardado
                                        if ([self localUser].screenName != nil)
                                            message.senderName = [self localUser].screenName;
                                        else
                                            message.senderName = [self localUser].name;
                                        message.senderLearningLan = [self localUser].activeLearningLan;
                                        message.senderLearningFlag = [self localUser].activeLearningFlag;
                                        message.senderSpeakingLan = [self localUser].activeSpeakingLan;
                                        message.senderSpeakingFlag = [self localUser].activeSpeakingFlag;
                                        
                                        
                                        LTUser * user = [self.userCache objectForKey: [NSNumber numberWithInteger:receiverId]];
                                        //También puede estar en userList
                                        if (user == nil)
                                        {
                                            for (LTUser * u in self.userList)
                                            {
                                                if (u.userId == receiverId)
                                                {
                                                    [self.userCache setObject:u forKey:[NSNumber numberWithInteger:receiverId]];
                                                    user = u;
                                                    break;
                                                }
                                            }
                                        }
                                        
                                        if (user == nil)
                                        {
                                            [self getUserWithUserId:receiverId andExecuteBlockInMainQueue:^(LTUser *user, NSError *error) {
                                                
                                                //NSLog(@"Got user from server");
                                                //Si el bloque fuera (nil,nil) significa que el usuarios se ha borrado
                                                //Debería fallar la llamada anterior, pero por si acaso gestiono esto aquí también
                                                if ((user == nil) && (error == nil))
                                                {
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil)
                                                                                                    message: NSLocalizedString(@"The user you are trying to write to has deleted his account", nil)
                                                                                                   delegate: nil
                                                                                          cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
                                                                                          otherButtonTitles: nil];
                                                    [alert show];
                                                }
                                                
                                                else if (error == nil)
                                                {
                                                    if (user.screenName != nil)
                                                        message.destName = user.screenName;
                                                    else
                                                        message.destName = user.name;
                                                    
                                                    message.destLearningLan = user.activeLearningLan;
                                                    message.destLearningFlag = user.activeLearningFlag;
                                                    message.destSpeakingLan = user.activeSpeakingLan;
                                                    message.destSpeakingFlag = user.activeSpeakingFlag;
                                                }
                                                else
                                                {
                                                    //No dar mensaje de error. El mensaje se ha enviado, aunque no se han podido poner las banderas
                                                    //Luego es posible que se vea mal, pero si se ha enviado
                                                }
                                                
                                                NSArray * messageList =[NSArray arrayWithObject:message];
                                                [self updateChatListWithMessages: messageList];
                                                block(has_messages, nil);
                                            }];
                                            
                                        }
                                        else
                                        {
                                            //NSLog(@"Got user from cache");
                                            if (user.screenName != nil)
                                                message.destName = user.screenName;
                                            else
                                                message.destName = user.name;
                                            
                                            message.destLearningLan = user.activeLearningLan;
                                            message.destLearningFlag = user.activeLearningFlag;
                                            message.destSpeakingLan = user.activeSpeakingLan;
                                            message.destSpeakingFlag = user.activeSpeakingFlag;
                                            
                                            NSArray * messageList =[NSArray arrayWithObject:message];
                                            [self updateChatListWithMessages: messageList];
                                            
                                            block(has_messages, nil);
                                        }
                                        
                                        
                                        
                                    }
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        //NSLog(@"error logging with facebook");
                                        
                                        block(NO, error);
                                    }];
    [client enqueueHTTPRequestOperation:operation];
    return;
}

#pragma mark -
#pragma mark POST SEND_MSG request


#pragma mark -
#pragma mark POST UPDATE_USER request

- (void) updateUserOld: (NSInteger) userId
		withEditKey: (NSString*) editKey
		   delegate: (id <LTDataDelegate>) del
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@", LX_BASE_URL,UPDATE_USER];
	
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = UPDATE_USER;
	IQVerbose(VERBOSE_DEBUG,@"[%@] Updating with latest location: %f, %f", [self class], latestLocation.longitude, latestLocation.latitude);
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
	[request setPostValue: [NSString stringWithFormat:@"%ld", (long)userId] forKey: @"user_id"];
	[request setPostValue: editKey forKey: @"edit_key"];
    
    if (!self.localUser.fuzzyLocation)
    {
        [request setPostValue: [NSString stringWithFormat:@"%f", latestLocation.longitude] forKey: @"longitude"];
        [request setPostValue: [NSString stringWithFormat:@"%f", latestLocation.latitude] forKey: @"latitude"];
    }
    else
    {
        [request setPostValue: [NSString stringWithFormat:@"%f", self.localUser.coordinate.longitude] forKey: @"longitude"];
        [request setPostValue: [NSString stringWithFormat:@"%f", self.localUser.coordinate.latitude] forKey: @"latitude"];
    }
    [request setPostValue: [self localUser].status forKey: @"status"];
    
    //active languages
	[request setPostValue: [self localUser].activeLearningLan forKey: @"learning_language"]; 
	[request setPostValue: [self localUser].activeSpeakingLan forKey: @"native_language"]; 
    //other languages
    [request setPostValue:self.localUser.learningLanguages?:NSNull.null forKey:@"learning_languages"];
    [request setPostValue:self.localUser.speakingLanguages?:NSNull.null forKey:@"native_languages"];
    [request setPostValue:self.localUser.learningLanguagesFlags?:NSNull.null forKey:@"learning_flags"];
    [request setPostValue:self.localUser.speakingLanguagesFlags?:NSNull.null forKey:@"native_flags"];
    
    if (self.localUser.image!=nil)
    {
//        /*
//        NSData *imageData = UIImageJPEGRepresentation([self localUser].image, 0.7);
//        //[request setData:imageData withFileName:@"file" andContentType:@"image/jpeg" forKey:@"image"];
//        //[request setPostValue:imageData forKey:@"image"];
//        [request addData:imageData forKey:@"image"];
//         */
        
        NSData *jd = UIImageJPEGRepresentation(self.localUser.image, 0.2);
        NSString *tempFile = [NSTemporaryDirectory() stringByAppendingPathComponent: @"image.jpg"];
        [[NSFileManager defaultManager] removeItemAtPath:tempFile error:NULL];
        if([jd writeToFile:tempFile atomically:YES])
            [request addFile:tempFile forKey:@"image"];
    }
    
    [request setPostValue: [self localUser].screenName forKey: @"screen_name"];
    [request setPostValue: [self localUser].twitter forKey: @"twitter"];
    [request setPostValue: [self localUser].mail forKey: @"mail"];
    [request setPostValue: [self localUser].url forKey: @"url"];
    [request setPostValue: [self localUser].address forKey: @"address"];
    if ([self localUser].fuzzyLocation)
        [request setPostValue:@"1" forKey:@"fuzzy_location"];
    else
        [request setPostValue:@"0" forKey:@"fuzzy_location"];
    [request setPostValue: ([self localUser].hasPicture? @"1": @"0") forKey: @"has_picture"];
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];
	[self.requests addObject: dataRequest];
}

- (void) didUpdateUserWithResult: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary: result];
    //[newDict setObject: [self localUser].editKey forKey: @"edit_key"];
    
    LTUser *user = [[LTUser alloc] initWithDict: newDict];
    
    // override server location with latest valid location
    if (!user.fuzzyLocation)
    {
        if( ([self latestLocation].longitude != 0) && ([self latestLocation].latitude != 0) ) {
            [user setCoordinate: [self latestLocation]];
        }
    }
    
    // now set the user
    [self setLocalUser: user
       andPasswordHash: [[NSUserDefaults standardUserDefaults] objectForKey: @"LocalUserHash"]];
    
    if([dataRequest.delegate respondsToSelector: @selector(didUpdateUser)])		
        [dataRequest.delegate didUpdateUser];    
}

#pragma mark -
#pragma mark POST SEARCH_IN_ZONE request
/*

- (void) searchInRegion: (MKCoordinateRegion) region
			   forUsers: (BOOL) users
               delegate: (id <LTDataDelegate>) del
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@", LX_BASE_URL,SEARCH_IN_ZONE];

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
    
    if(users)
        [request setPostValue: @"1" forKey: @"s_type"];
 
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];    
	[self.requests addObject: dataRequest];    
    [dataRequest release];
}

- (void) searchInZoneResult: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
    
    [self.userList removeAllObjects];
    
    NSArray *newUsers = [result objectForKey: @"users"];
    NSString *flag = [result objectForKey: @"complete_results"];
    
    [self setCompleteResults: [flag intValue]];
    IQVerbose(VERBOSE_DEBUG,@"[%@] Got %d users (complete results %d)", [self class], [newUsers count], self.completeResults);
    
    // now add old users that are not present in new users
    for(NSDictionary *d in newUsers) {
        LTUser *u = [[LTUser alloc] initWithDict: d];
        // do not include local userin resuts
        if(u.userId != self.localUser.userId)  [self.userList addObject: u];
        [u release];
    }
    
    if([dataRequest.delegate respondsToSelector: @selector(didUpdateSearchResults)])		
        [dataRequest.delegate didUpdateSearchResults];		
}
 */

#pragma mark -
#pragma mark POST SEARCH_USERS request

- (void) searchUsers: (NSString *) name
         learningLan: (NSString *) learningLan
         speakingLan: (NSString *) speakingLan
            inRegion: (MKCoordinateRegion) region
       withBothLangs: (BOOL) bothLangs
            delegate: (id <LTDataDelegate>) del
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@", LX_BASE_URL,SEARCH_USERS];
    
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = SEARCH_USERS;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];         
    
    if ([name length]>0)
        [request setPostValue: name forKey: @"name"];
    if (learningLan!=nil)
        [request setPostValue:learningLan forKey:@"learningLan"];
    if (speakingLan!=nil)
        [request setPostValue:speakingLan forKey:@"speakingLan"];
    //[request setPostValue: @"1" forKey: @"s_type"];
    
    [request setPostValue: [NSString stringWithFormat: @"%f",region.center.latitude-region.span.latitudeDelta/2.0] forKey: @"lat_br"];
	[request setPostValue: [NSString stringWithFormat: @"%f",region.center.longitude-region.span.longitudeDelta/2.0] forKey: @"lon_tl"];
	[request setPostValue: [NSString stringWithFormat: @"%f",region.center.latitude+region.span.latitudeDelta/2.0] forKey: @"lat_tl"];
	[request setPostValue: [NSString stringWithFormat: @"%f",region.center.longitude+region.span.longitudeDelta/2.0] forKey: @"lon_br"];
    
    if (bothLangs)
        [request setPostValue:@"1" forKey:@"bothLangs"];
    
    
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];    
	[self.requests addObject: dataRequest];   
}

- (void) searchUsersResult: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
    NSArray *newUsers = [result objectForKey: @"users"];
    
    NSMutableArray *searchResults = [[NSMutableArray alloc] initWithCapacity: [newUsers count]];
    
    IQVerbose(VERBOSE_DEBUG,@"[%@] Got %d users", [self class], [newUsers count]);
    
    for(NSDictionary *d in newUsers) {
        LTUser *u = [[LTUser alloc] initWithDict: d];
        // do not include local userin resuts
        if(u.userId != self.localUser.userId)  
            [searchResults addObject: u];
    }
    
    if([dataRequest.delegate respondsToSelector: @selector(didUpdateSearchResultsUsers:)])		
        [dataRequest.delegate didUpdateSearchResultsUsers: searchResults];
    
}

#pragma mark -
#pragma mark POST GET_MSG request
- (void) getMessagesForUser: (NSInteger) userId
				withEditKey: (NSString*) editKey
				   delegate: (id <LTDataDelegate>) del 
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@", LX_BASE_URL,GET_MSG];
	
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = GET_MSG;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];         
	[request setPostValue: [NSString stringWithFormat: @"%ld",(long)[self localUser].userId] forKey: @"user_id"];
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
    
    //NSLog(@"gotMessagesWithResult: %@", result);
    
    NSArray *newMessages = [result objectForKey: @"messages"];
    NSMutableArray *messageList = [[NSMutableArray alloc] initWithCapacity: [newMessages count]];
    
    [self setChatListTimestamp:[result objectForKey: @"timestamp"]];
    
    IQVerbose(VERBOSE_DEBUG,@"[%@] Got %d new messages (timestamp is %@)", [self class], [newMessages count], self.chatListTimestamp);
    
    for(NSDictionary *d in newMessages) {
        LTMessage *msg = [LTMessage newMessageWithDict: d];
        
        msg.destId = self.localUser.userId;//Olvidado en la versión anterior
        
        if ([self localUser].screenName != nil)
            msg.destName = [self localUser].screenName;
        else
            msg.destName = [self localUser].name;
        
        msg.destLearningLan = [self localUser].activeLearningLan;
        msg.destLearningFlag = [self localUser].activeLearningFlag;
        msg.destSpeakingLan = [self localUser].activeSpeakingLan;
        msg.destSpeakingFlag = [self localUser].activeSpeakingFlag;
        
        
        LTUser * user = [self.userCache objectForKey:[NSNumber numberWithInteger:msg.senderId]];
        //También puede estar en userList
        if (user == nil)
        {
            for (LTUser * u in self.userList)
            {
                if (u.userId == msg.senderId)
                {
                    [self.userCache setObject:u forKey:[NSNumber numberWithInteger:msg.senderId]];
                    user = u;
                    break;
                }
            }
        }
        
        if (user != nil)
        {
            if (user.screenName != nil)
                msg.senderName = user.screenName;
            else
                msg.senderName = user.name;
            
            msg.senderLearningLan = user.activeLearningLan;
            msg.senderLearningFlag = user.activeLearningFlag;
            msg.senderSpeakingLan = user.activeSpeakingLan;
            msg.senderSpeakingFlag = user.activeSpeakingFlag;
        }
        else
            [self.userIdsToDownload addObject:[NSNumber numberWithInteger:msg.senderId]];
        
        
        [messageList addObject: msg];
    }

    [self updateChatListWithMessages: messageList];
    
    
    if([dataRequest.delegate respondsToSelector: @selector(didGetListOfMessages)])
        [dataRequest.delegate didGetListOfMessages];
    
    [self downloadUsersForMessages];
}

- (void) downloadUsersForMessages
{
    //Download where LTUsers are needed in order to know the flags and screen name
    NSSet * set = [self.userIdsToDownload copy];
    for (NSNumber * number in set)
    {
        [self getUserWithUserId:[number integerValue] andExecuteBlockInMainQueue:^(LTUser *user, NSError *error) {
            
            //NSLog(@"Block for user: %d", [number integerValue]);
            
            if (error == nil)
            {
                //Se borra tanto si user = nil (usuario borrado) como si se ha descargado correctamente (user != nil):
                //Correcto
                [self.userIdsToDownload removeObject:number];
                
                if ([self.userIdsToDownload count] == 0) //Rellenar los mensajes y actualizar los chats
                {
                    //NSLog(@"Rellenar mensajes");
                    
                    [self setDetailsInMessages];
                }
            }
            else // Could not download user
            {
                //Retry in 60 seconds
                [self performSelector:@selector(downloadUsersForMessages) withObject:nil afterDelay:60];
                
                //Fill in what I have got in a few seconds in case not all the network calls to get user deatils have failed
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setDetailsInMessages) object:nil];
                [self performSelector:@selector(setDetailsInMessages) withObject:nil afterDelay:10];
            }
            
        }];
    }
}

- (void) setDetailsInMessages
{
    
    for (LTChat *chat in self.chatList)
    {
        LTUser * senderUser = [self.userCache objectForKey:[NSNumber numberWithInteger:chat.userId]];
        
        //Rellenar si faltan datos en el chat
        BOOL shouldSave = NO;
        if (senderUser != nil)
        {
            if (chat.userName == nil)
            {
                if (senderUser.screenName != nil)
                    chat.userName = senderUser.screenName;
                else
                    chat.userName = senderUser.name;
                
                shouldSave = YES;
            }
            if (chat.learningLang == nil)
            {
                chat.learningLang = senderUser.activeLearningLan;
                chat.learningFlag = senderUser.activeLearningFlag;
                
                shouldSave = YES;
            }
            if (chat.speakingLang == nil)
            {
                chat.speakingLang = senderUser.activeSpeakingLan;
                chat.speakingFlag = senderUser.activeSpeakingFlag;
                
                shouldSave = YES;
            }
        }
        
        //Save in sqlite message database
        if (shouldSave)
            [[MessageHandler sharedInstance] updateUser:chat withActivity:[NSDate dateWithTimeIntervalSince1970:0] andUnread:0];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadChatList" object:nil];
}


#pragma mark -
#pragma mark POST GET_USER request

- (void) getUser: (NSInteger) userId
	withDelegate: (id <LTDataDelegate>) del
{
	NSString *reqURL = [NSString stringWithFormat: @"%@/%@", LX_BASE_URL,GET_USER];
    
    IQDataRequest *dataRequest = [[IQDataRequest alloc] init];
	dataRequest.delegate = del;
	dataRequest.url = reqURL;
	dataRequest.note = GET_USER;
	
	NSURL *url = [NSURL URLWithString: dataRequest.url];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
	[request setPostValue: [NSString stringWithFormat:@"%ld", (long)userId] forKey: @"user_id"];
	
	[request setDelegate: self];
	[request startAsynchronous];
    [dataRequest setRequest: request];
	[self.requests addObject: dataRequest];
}

- (void) gotUserWithResult: (NSDictionary*) result withDataRequest: (IQDataRequest*) dataRequest {
    LTUser *user = [[LTUser alloc] initWithDict: result];
    
    //Add to cache
    [self.userCache setObject:user forKey:[NSNumber numberWithInteger:user.userId]];
    
    if([dataRequest.delegate respondsToSelector: @selector(didGetUser:)])
        [dataRequest.delegate didGetUser:user];
    
}

#pragma mark -
#pragma mark Dispatch methods

- (void) dispatchError:(IQDataRequest *)dataRequest {
	
	ASIFormDataRequest *req = (ASIFormDataRequest*) dataRequest.request;
    NSError *jsonerror = nil;
    NSData * data = [req responseData];
    if (data != nil)
    {
        NSMutableDictionary *d = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&jsonerror];
        NSString *status = [d objectForKey:@"status"];
        
        // handle error
        [dataRequest.delegate didFail:[d objectForKey: @"result"]];
        
        if(![status isEqualToString: @"error"]) {
            
            LextTalkAppDelegate * del = (LextTalkAppDelegate *) [[UIApplication sharedApplication] delegate];
            if (!del.showingError)
            {
                del.showingError=YES;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Network error", @"Network error")
                                                                message: NSLocalizedString(@"Could not process the request", @"Could not process the request")
                                                               delegate: self
                                                      cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
                                                      otherButtonTitles: nil];
                alert.tag = 404;
                [alert show];
            }
        }
    }
}

- (BOOL) dispatchNote:(IQDataRequest *)dataRequest {
	// process POST requests
	ASIFormDataRequest *req = (ASIFormDataRequest*) dataRequest.request;
    //NSLog(@"responseString: %@", [req responseString]);
    NSError *jsonerror = nil;
    NSMutableDictionary *d = [NSJSONSerialization JSONObjectWithData:[req responseData]
                                                             options:kNilOptions
                                                               error:&jsonerror];
    
    if (jsonerror) {
        NSLog(@"dispatchNote ::: NSJSONSerialization ::: ERROR\n%@\n%@", jsonerror, [req responseString]);
    }
    
    //NSLog(@"dataRequest: %@", d);
//    if (!d) {
//        // the parse may have failed with "Unrecognised leading character", so trim leading characters
//        NSString *response = [req responseString];
//        NSLog(@"WARNING: %@: %@", [req url], response);
//        NSRange responseRange = [response rangeOfString:@"{"];
//        if (responseRange.location != NSNotFound) {
//            response = [response substringFromIndex:responseRange.location];
//            d = [response JSONValue];
//        }
//    }
	NSString *status = [d objectForKey:@"status"];
	NSDictionary *result = [d objectForKey:@"result"];
    
    if (result == (id)NSNull.null) {
        result = nil;
        NSLog(@"dispatchNote, result is null and result should never be null");
    }
    
    //NSLog(@"Note: %@ with dic: %@", dataRequest.note, d);
	
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
			[self didLogoutWithResult:result withDataRequest:dataRequest];
		
	} else if([dataRequest.note isEqualToString: UPDATE_USER]) {
		
        [self didUpdateUserWithResult: result withDataRequest: dataRequest];
		
	}
    /*
    else if([dataRequest.note isEqualToString: SEARCH_IN_ZONE]) {
		
        [self searchInZoneResult: result withDataRequest: dataRequest];
        
	}
    */
    else if([dataRequest.note isEqualToString: SEARCH_USERS]) {
		
        [self searchUsersResult: result withDataRequest: dataRequest];        
		
	} else if([dataRequest.note isEqualToString: SEND_MSG]) {
        
        //[self sentMessageWithResult:result withDataRequest:dataRequest];
		
	} else if([dataRequest.note isEqualToString: GET_MSG]) {
        
        [self gotMessagesWithResult: result withDataRequest: dataRequest];
		
	} else if([dataRequest.note isEqualToString: GET_USER]) {
		
        [self gotUserWithResult: result withDataRequest: dataRequest];
        
	} else if([dataRequest.note isEqualToString: RESTORE_SESSION]) {
        
        [self didLoginUserWithResult:result withDataRequest:dataRequest];
        
	} else if([dataRequest.note isEqualToString: ADORDER]) {
        
        [self didGetAdOrder:result withDataRequest:dataRequest];
    } else if([dataRequest.note isEqualToString: SEARCH_CHATROOM]) {
        
        [self searchChatroomResult:result withDataRequest:dataRequest];
        
    } else if([dataRequest.note isEqualToString: CREATE_CHATROOM]) {
        
        [self didCreateChatroomResult:result withDataRequest:dataRequest];

    } else if([dataRequest.note isEqualToString: ENTER_CHATROOM]) {
        
        if([dataRequest.delegate respondsToSelector: @selector(didEnterChatroom)])
			[dataRequest.delegate didEnterChatroom];

    } else if([dataRequest.note isEqualToString: LEAVE_CHATROOM]) {
        
        if([dataRequest.delegate respondsToSelector: @selector(didLeaveChatroom)])
			[dataRequest.delegate didLeaveChatroom];
        
    } else if([dataRequest.note isEqualToString: SEND_MESSAGE_CHATROOM]) {
        
        if([dataRequest.delegate respondsToSelector: @selector(didSendMessage)])
			[dataRequest.delegate didSendMessage];
    
    } else if([dataRequest.note isEqualToString: GET_MESSAGE_CHATROOM]) {
        
        [self getMessageChatroomResult: result withDataRequest:dataRequest];
    
    } else {
        return NO;
    }
	
	return YES;
}

#pragma mark -
#pragma mark LTDataDelegate

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
    
    [self updateUser: self.localUser.userId 
         withEditKey: self.localUser.editKey
           saveImage: NO
            delegate: self];  
}

static LTDataSource *theLTDataSource = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (LTDataSource*) sharedDataSource {
    @synchronized(self) {
        if(theLTDataSource == nil)
            theLTDataSource = [[super allocWithZone:NULL] init];
    }
    return theLTDataSource;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedDataSource];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id) init {
	if (self = [super init]) {
		self.requests = [NSMutableArray array];
		self.userList = [NSMutableArray array];
		self.chatList = [NSMutableArray array];        		
		self.unreadedMessages = [NSMutableArray array];
        
        self.userCache = [NSMutableDictionary dictionary];
        self.userIdsToDownload = [NSMutableSet set];
		
		// create a no user just in case
		self.noUser = [[LTNotLoggedUser alloc] init];//No tenía el auto release
		
        // restore last location
        [self restoreLatestLocation];
		[self restoreApnsToken];
	}
	return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
