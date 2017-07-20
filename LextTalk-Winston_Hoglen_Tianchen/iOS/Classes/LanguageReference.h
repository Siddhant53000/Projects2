//
//  LanguageDB.h
//  BingTranslatorClass
//
//  Created by Raúl Martín Carbonell on 8/21/11.
//  Copyright 2011 Freelance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reference.h"

@interface LanguageReference : Reference
{
    
}

+ (NSString *) appLan;
+ (NSArray *) availableLangsForAppLan: (NSString *) appLan;
+ (NSString *) getMasterLanForAppLan: (NSString *) appLan andLanName:(NSString *) lanName;
+ (NSString *) getLocaleForMasterLan: (NSString *) masterLan;
+ (NSString *) getLanForAppLan:(NSString *) appLan andMasterLan: (NSString *) masterLan;

+ (NSData *) flagForMasterLan:(NSString *) masterLan andId:(NSInteger) identifier;
+ (NSArray *) flagsForMasterLan:(NSString *) masterLan;



+ (NSArray *) availableSpeakLangsForAppLan: (NSString *) appLan andMasterLan:(NSString *) masterLan;
+ (NSInteger) getIdForAppLan: (NSString *) appLan andLanSpeak:(NSString *) lanName andMasterLan:(NSString *) masterLan;
+ (NSString *) getSpeakLocaleForMasterLan: (NSString *) masterLan withId:(NSInteger) number;
+ (NSString *) getSpeakLanForAppLan:(NSString *) appLan andMasterLan: (NSString *) masterLan withId:(NSInteger) number;


@end
