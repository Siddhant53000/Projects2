//
//  IconGeneration.h
//  BingTranslatorClass
//
//  Created by Yo on 11/8/11.
//  Copyright (c) 2011 Freelance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IconGeneration : NSObject
{
    
}

+ (UIImage *) stdIconForLearningLan:(NSString *) learningMasterLan
                           withFlag:(NSInteger) learningFlagId
                     andSpeakingLan:(NSString *)speakingMasterLan
                           withFlag:(NSInteger) speakingFlagId
                          writeText:(BOOL) writeText
                     withStatusDate:(NSDate *) date;

+ (UIImage *) bigIconForLearningLan:(NSString *)learningMasterLan withFlag:(NSInteger)learningFlagId;

+ (UIImage *) bigIconForSpeakingLan:(NSString *)speakingMasterLan withFlag:(NSInteger)speakingFlagId;

+ (UIImage *) smallWithGlowIconForLearningLan:(NSString *)learningMasterLan withFlag:(NSInteger)learningFlagId;

+ (UIImage *) smallWithGlowIconForSpeakingLan:(NSString *)speakingMasterLan withFlag:(NSInteger)speakingFlagId;

+ (UIImage *) activityImageForDate:(NSDate *) date;


@end
