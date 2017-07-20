//
//  GFGroup.h
// LextTalk
//
//  Created by David on 11/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GFObject.h"
#import "GFTableObjectProtocol.h"

@interface GFGroup : GFObject <GFTableObjectProtocol> {
	NSString *_name;
	NSInteger groupId;
	NSInteger parentId;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) NSInteger groupId;
@property (nonatomic, assign) NSInteger parentId;

+ (GFGroup*) newGroupWithName: (NSString*) n parentId: (NSInteger) p andId: (NSInteger) i;

@end
