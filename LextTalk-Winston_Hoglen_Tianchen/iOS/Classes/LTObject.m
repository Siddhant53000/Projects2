//
//  GFObject.m
// LextTalk
//
//  Created by David on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LTObject.h"


@implementation LTObject

- (double_t) doubleForKey: (NSString*) key inDict: (NSDictionary*) d {
    if ([d isKindOfClass:[NSDictionary class]])
    {
        if(![[d objectForKey: key] isEqual: [NSNull null]]) {
            return [[d objectForKey: key] doubleValue];
        }
    }
    
    //IQVerbose(VERBOSE_DEBUG,@"No key %@ found in dictionary for double value!!", key);
    return -1.0;
}

- (BOOL) boolForKey: (NSString*) key inDict: (NSDictionary*) d {
    if ([d isKindOfClass:[NSDictionary class]])
    {
        if(![[d objectForKey: key] isEqual: [NSNull null]]) {
            return [[d objectForKey: key] boolValue];
        }
    }
    
    //IQVerbose(VERBOSE_DEBUG,@"No key %@ found in dictionary for bool value!!", key);
    return NO;
}

- (NSInteger) integerForKey: (NSString*) key inDict: (NSDictionary*) d {
    if ([d isKindOfClass:[NSDictionary class]])
    {
        if(![[d objectForKey: key] isEqual: [NSNull null]]) {
            return [[d objectForKey: key] intValue];
        }
    }
    
    //IQVerbose(VERBOSE_DEBUG,@"No key %@ found in dictionary for integer value!!", key);
    return -1;
}

- (NSString*) stringForKey: (NSString*) key inDict: (NSDictionary*) d {
    if ([d isKindOfClass:[NSDictionary class]])
    {
        if(![[d objectForKey: key] isEqual: [NSNull null]]) {
            return [d objectForKey: key];
        }
    }
    
    //IQVerbose(VERBOSE_DEBUG,@"No key %@ found in dictionary for string!!", key);
    return nil;
}

NSDateFormatter *df = nil;

+ (NSString*) utcTimeToLocalTime: (NSString*) utcTime {
    
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    }
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [df setTimeZone: [NSTimeZone timeZoneWithName: @"GMT"]];
    
    if(utcTime == nil) {
        df = nil;
        return nil;//@"Time not available";
    }
    
    NSDate* sourceDate = [df dateFromString: utcTime];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone]; // local timezone, con systemTimeZone no devuelve la correcta y se ve mal la hora
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    
    // set output format
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    //[df setTimeZone: destinationTimeZone];
    //	NSString *result = [NSString stringWithFormat:@"%@ %@", [df stringFromDate:destinationDate], [[NSTimeZone systemTimeZone] abbreviationForDate:destinationDate]];
    NSString *result = [NSString stringWithFormat:@"%@", [df stringFromDate:destinationDate]];
    
    
    return result;
}

+ (NSDate *) dateForUtcTime:(NSString *) utcTime
{
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    }
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [df setTimeZone: [NSTimeZone timeZoneWithName: @"GMT"]];
    
    if(utcTime == nil) {
        df = nil;
        return nil;//@"Time not available";
    }
    
    return [df dateFromString: utcTime];
}

+ (NSString *) stringForDate:(NSDate *) date
{
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    }
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [df setTimeZone: [NSTimeZone localTimeZone]];
    
    return [df stringFromDate:date];
}

- (BOOL)loadNibFile:(NSString *)nibName {
    // The Nib file must be in the bundle that defines self's class.
    if ([[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] == nil)
    {
        IQVerbose(VERBOSE_DEBUG,@"[%@] Warning! Could not load %@ file.\n", [self class], nibName);
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark NSObject methods


@end
