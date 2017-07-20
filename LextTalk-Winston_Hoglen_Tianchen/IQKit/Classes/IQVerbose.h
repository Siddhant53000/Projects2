//
//  IQVerbose.h
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VERBOSE_NO		0
#define VERBOSE_ERROR	1
#define VERBOSE_WARNING	2
#define VERBOSE_DEBUG	3
#define VERBOSE_ALL		4

void IQVerbose (NSInteger level, NSString *format, ...);
void IQVerboseLevel(NSInteger level);
