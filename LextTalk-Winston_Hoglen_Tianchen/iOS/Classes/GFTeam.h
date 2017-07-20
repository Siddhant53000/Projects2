//
//  GFTeam.h
// LextTalk
//
//  Created by nacho on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GFObject.h"
#import "GFTableObjectProtocol.h"

@interface GFTeam : GFObject <GFTableObjectProtocol> {
	NSString *_name;
	NSInteger teamId;
	NSInteger parentId;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) NSInteger teamId;
@property (nonatomic, assign) NSInteger parentId;

+ (GFTeam*) newTeamWithName: (NSString*) n parentId: (NSInteger) p andId: (NSInteger) i;
@end
