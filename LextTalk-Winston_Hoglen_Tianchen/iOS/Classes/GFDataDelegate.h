/*
 *  GFDataDelegate.h
 *  GlocalFans
 *
 *  Created by David on 11/30/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
#import "GFUser.h"

@protocol GFDataDelegate<NSObject>
@optional
- (void) didCreateUser;
- (void) didLoginUser;
- (void) didUpdateUser;
- (void) didLogoutUser;

- (void) didUpdateSearchResults;

- (void) didUpdateSearchResultsByName: (NSArray*) results;
- (void) didUpdateUserStatistics: (NSArray*) userStats;
- (void) didUpdateDistanceStatistics: (NSArray*) distanceStats;
- (void) didUpdateTeamStatistics: (NSArray*) teamStats;

- (void) didSendMessage;
- (void) didGetListOfMessages;

- (void) didGetUser: (GFUser*) user;

@required
- (void) didFail: (NSDictionary*) result;

@end
