//
//  IQObject.m
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import "IQObject.h"

@implementation IQObject

- (double_t) doubleForKey: (NSString*) key inDict: (NSDictionary*) d {
	if(![[d objectForKey: key] isEqual: [NSNull null]]) {
		return [[d objectForKey: key] doubleValue];	
	}
	
	//IQVerbose(VERBOSE_ERROR,@"No key %@ found in dictionary for double value!!", key);
	return -1.0;
}

- (BOOL) boolForKey: (NSString*) key inDict: (NSDictionary*) d {
	if(![[d objectForKey: key] isEqual: [NSNull null]]) {
		return [[d objectForKey: key] boolValue];	
	}
	
	//IQVerbose(VERBOSE_ERROR,@"No key %@ found in dictionary for bool value!!", key);
	return NO;
}

- (NSInteger) integerForKey: (NSString*) key inDict: (NSDictionary*) d {
	if(![[d objectForKey: key] isEqual: [NSNull null]]) {
		return [[d objectForKey: key] intValue];	
	}
	
	//IQVerbose(VERBOSE_ERROR,@"No key %@ found in dictionary for integer value!!", key);
	return -1;
}

- (NSString*) stringForKey: (NSString*) key inDict: (NSDictionary*) d {
	if(![[d objectForKey: key] isEqual: [NSNull null]]) {
		return [d objectForKey: key];	
	}
	
	//IQVerbose(VERBOSE_ERROR,@"No key %@ found in dictionary for string!!", key);
	return nil;
}

NSDateFormatter *dformatter = nil;

- (NSString*) localTimestampForUTCTimestamp: (NSString*) utcTime {
    if (dformatter == nil) {
        dformatter = [[NSDateFormatter alloc] init];
        dformatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
    }
	[dformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[dformatter setTimeZone: [NSTimeZone timeZoneWithName: @"GMT"]];
	
	if(utcTime == nil) {
		return @"Date not available";
	}
	
	NSDate* sourceDate = [dformatter dateFromString: utcTime];
	NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    
	NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone]; // local timezone
	
	NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
	NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
	NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
	
	NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];	
	
	// set output format
	[dformatter setDateFormat:@"yyyy-MM-dd HH:mm"];	
	NSString *result = [NSString stringWithFormat:@"%@", [dformatter stringFromDate:destinationDate]];	
	
	
	return result;
}

@end
