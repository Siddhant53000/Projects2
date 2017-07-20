//
//  DBLangsGenerator.m
//  LextTalk
//
//  Created by Yo on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DBLangsGenerator.h"

@implementation DBLangsGenerator
@synthesize bingTranslator, app_lan, translatedLangs, masterLangs;

- (id) init
{
    self=[super init];
    if (self)
    {
        self.bingTranslator=[[BingTranslator alloc] init];
        [self.bingTranslator downloadToken];
    }
    return self;
}


- (void) translateTo:(NSString *) lang withAppLan:(NSString *) app_lan2
{
    self.masterLangs=[LanguageReference availableLangsForAppLan:@"English"];
    self.app_lan=app_lan2;
    self.translatedLangs=[NSMutableArray arrayWithCapacity:[self.masterLangs count]];
    for (int i=0; i<[self.masterLangs count]; i++)
        [self.translatedLangs insertObject:@"" atIndex:i];
    
    //Para que dé tiempo a descargar el token
    [self performSelector:@selector(calculate:) withObject:lang afterDelay:10];
}

- (void) calculate:(NSString *) lang
{
    count=0;
    for (int i=0; i<[self.masterLangs count]; i++)
    {
        NSString * str=[self.masterLangs objectAtIndex:i];
        [self.bingTranslator translateText:str 
                                fromLocale:[LanguageReference getLocaleForMasterLan:@"English"] 
                                        to:[LanguageReference getLocaleForMasterLan:lang]  
                              withDelegate:self 
                                    withId:i];
    }
}

#pragma mark BingTranslatorDelegate methods
- (void) translatedText:(NSString *)text withId:(NSInteger)identifier
{
    //NSLog(@"Traducción: %@",[NSString stringWithUTF8String: [text UTF8String]]);
    NSLog(@"INSERT INTO \"Languages\" VALUES('%@','%@','%@');", 
          [self.masterLangs objectAtIndex:identifier], 
          self.app_lan,
          [NSString stringWithUTF8String: [text UTF8String]]);
    [self.translatedLangs replaceObjectAtIndex:identifier withObject:[NSString stringWithUTF8String: [text UTF8String]]];
    
    count++;
    if (count==[self.masterLangs count])
    {
        NSDictionary * dic=[NSDictionary dictionaryWithObjects:self.translatedLangs forKeys:self.masterLangs];
        NSLog(@"Traducción: %@", dic);
    }
}

- (void) connectionFailedWithError:(NSError *) error withId:(NSInteger) identifier;
{
    NSLog(@"fallo");
}

@end
