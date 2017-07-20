//
//  GFObject.h
// LextTalk
//
//  Created by David on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IQKit.h"

@interface LTObject : NSObject {

}

- (double_t) doubleForKey: (NSString*) key inDict: (NSDictionary*) d;
- (BOOL) boolForKey: (NSString*) key inDict: (NSDictionary*) d;
- (NSInteger) integerForKey: (NSString*) key inDict: (NSDictionary*) d;
- (NSString*) stringForKey: (NSString*) key inDict: (NSDictionary*) d;
+ (NSString*) utcTimeToLocalTime: (NSString*) utcTime;
+ (NSDate *) dateForUtcTime:(NSString *) utcTime;
+ (NSString *) stringForDate:(NSDate *) date;
	
- (BOOL)loadNibFile:(NSString *)nibName;
@end
