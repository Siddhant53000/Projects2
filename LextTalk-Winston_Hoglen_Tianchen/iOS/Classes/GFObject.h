//
//  GFObject.h
// LextTalk
//
//  Created by David on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GFDefaultCellView.h"
#import "IQKit.h"

@interface GFObject : NSObject {
	GFDefaultCellView			*_cell;	
}

@property (nonatomic, retain) IBOutlet GFDefaultCellView *cell;

- (double_t) doubleForKey: (NSString*) key inDict: (NSDictionary*) d;
- (BOOL) boolForKey: (NSString*) key inDict: (NSDictionary*) d;
- (NSInteger) integerForKey: (NSString*) key inDict: (NSDictionary*) d;
- (NSString*) stringForKey: (NSString*) key inDict: (NSDictionary*) d;
+ (NSString*) utcTimeToLocalTime: (NSString*) utcTime;
	
- (BOOL)loadNibFile:(NSString *)nibName;
@end
