//
//  TeamReference.h
// LextTalk
//
//  Created by David on 11/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reference.h"
#import "GFTeam.h"

@interface TeamReference : Reference {

}

+ (void)readObjects:(NSMutableArray*)objects withParentId:(NSInteger)parentId;
+ (UIImage*) newImageForGroupWithId: (NSInteger) gId;
+ (UIImage*) newImageForTeamWithId: (NSInteger) tId;
+ (UIImage*) newPinForTeamWithId: (NSInteger) tId;
+ (GFTeam*) newTeamWithId: (NSInteger) tId;
@end
