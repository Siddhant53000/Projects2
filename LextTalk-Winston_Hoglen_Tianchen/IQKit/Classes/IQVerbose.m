//
//  IQVerbose.h
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import "IQVerbose.h"

#define VERBOSE_LEVEL	VERBOSE_ALL
static int verbose_level = VERBOSE_LEVEL;

void IQVerboseLevel(NSInteger level) {
	verbose_level = level;
}

void IQVerbose (NSInteger level, NSString *format, ...) {  
	if(level > verbose_level) return;
	
    if (format == nil) {  
        printf("nil\n");  
        return;  
    }  
    // Get a reference to the arguments that follow the format parameter  
    va_list argList;  
    va_start(argList, format);  
    // Perform format string argument substitution, reinstate %% escapes, then print  
    NSMutableString *s = [[NSMutableString alloc] initWithFormat: format   
                                                       arguments: argList];  
    [s replaceOccurrencesOfString: @"%%"  
                       withString: @"%%%%"  
                          options: 0  
                            range: NSMakeRange(0, [s length])];  
	
	NSString *l;
	switch (level) {
		case VERBOSE_ERROR: l = @"E";break;
		case VERBOSE_WARNING: l = @"W";break;			
		case VERBOSE_DEBUG: l = @"D";break;			
		case VERBOSE_ALL: l = @"A";break;			
		case VERBOSE_NO: l = @"N";break;			
		default: l = @"X";break;			
	}
	NSLog(@"[%@]:%@",l, s);
    //printf("%s\n", [s UTF8String]);  
    va_end(argList);  
}

