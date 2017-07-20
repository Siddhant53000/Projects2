//
//  DictionaryHandler.h
//  BingTranslatorClass
//
//  Created by Raúl Martín Carbonell on 8/23/11.
//  Copyright 2011 Freelance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictionaryHandler : NSObject
{
    
}

+ (void) createDictionaryIfItDoesntExist;

+ (void) addEntry:(NSString *) original
  withTranslation:(NSString *) translated 
          fromLan:(NSString *) fromLan 
            toLan:(NSString *) toLan;

+ (NSString *) getTranslation:(NSString *) original
                      fromLan: (NSString *) fromLan 
                        toLan:(NSString *) toLan;

+ (NSArray *) getMatches:(NSString *) like
                      fromLan: (NSString *) fromLan 
                        toLan:(NSString *) toLan;

+ (void) getDictinariesFrom:(NSMutableArray *) fromArray andTo: (NSMutableArray* ) toArray;

+ (void) removeDictionaryFrom:(NSString *) fromLan andTo:(NSString *) toLan;

+ (NSDictionary *) getWholeDictionaryFromLan: (NSString *) fromLan toLan: (NSString *) toLan;

+ (void) removeEntryFrom:(NSString *) fromLan toLan:(NSString *) toLan withEntry: (NSString *) entry;

@end
