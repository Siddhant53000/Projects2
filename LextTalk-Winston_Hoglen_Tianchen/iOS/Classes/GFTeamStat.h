//
//  GFTeamStat.h
// LextTalk
//
//  Created by David on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GFObject.h"
#import "GFTableObjectProtocol.h"

@interface GFTeamStat : GFObject <GFTableObjectProtocol>{
	NSInteger _teamId;
	NSInteger _followers;
	CGFloat	  _percentage;
}

@property (nonatomic, assign) NSInteger teamId;
@property (nonatomic, assign) NSInteger followers;
@property (nonatomic, assign) CGFloat percentage;

+ (GFTeamStat*) newTeamStatWithDict: (NSDictionary*) d;
- (void) dump;
@end
