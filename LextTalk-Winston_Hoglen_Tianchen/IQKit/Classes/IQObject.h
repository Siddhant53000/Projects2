//
//  IQObject.h
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IQObject : NSObject {
}

- (double_t) doubleForKey: (NSString*) key inDict: (NSDictionary*) d;
- (BOOL) boolForKey: (NSString*) key inDict: (NSDictionary*) d;
- (NSInteger) integerForKey: (NSString*) key inDict: (NSDictionary*) d;
- (NSString*) stringForKey: (NSString*) key inDict: (NSDictionary*) d;
- (NSString*) localTimestampForUTCTimestamp: (NSString*) utcTime;
	
@end
