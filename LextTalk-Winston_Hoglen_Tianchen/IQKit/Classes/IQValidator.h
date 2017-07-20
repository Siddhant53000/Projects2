//
//  IQValidator.h
//
//  Created by David on 2/18/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IQVerbose.h"

@interface IQValidator : NSObject {

}

+ (BOOL) validateUrl: (NSString *) candidate;
+ (BOOL) validateEmailAddress: (NSString*) candidate;

@end
