//
//  MicrosoftTranslator.h
//
//  Created by Florian on 31.03.13.
//  Copyright (c) 2013 Florian Killius. All rights reserved.
//


/*
 *  How to use:
 *  
 *  1. Sign up for Microsoft Translator ( https://datamarket.azure.com/developer/applications/ ) 2,000,000 chars/month are free
 *  2. Register your application ( https://datamarket.azure.com/developer/applications/register )
 *  3. You should now have a clientID and a clientSecret string
 *  4. In your application:
 *      4.1 Add the file MicrosoftTranslator.h and MicrosoftTranslator.m to your project and #import "MicrosoftTranslator.h"
 *      4.2 MicrosoftTranslator *translator = [[MicrosoftTranslator alloc] initWithClientID:***yourClientID*** clientSecret:***yourClientSecret***]
 *      4.3 Use NSString *translation = [translator translateText:@"Hello world" from:@"en" to @"es"]; or
 *      4.4 NSString *translation = [translator translateText:@"Hello world" to @"es"]; and to detect the language of a given string use
 *      4.5 NSString *language = [translator detectLanguageOfText:@"Hello world"];
 */

/* TODO:
 * - add some kind of error handling
 * - change to asynchonos requests so the app (especially the ui) can continue running (workaround for now: call MicrosoftTranslator in own thread)
 */

// uncommet for some sort of error loggin
// #define DEBUG_MICROSOFT_TRANSLATOR

#import <Foundation/Foundation.h>

@interface MicrosoftTranslator : NSObject {
    NSString *accessToken;
    int timeExpiring;
}

-(id)initWithClientID:(NSString*)_client_id clientSecret:(NSString*)_client_secret;

-(NSString*)translateText:(NSString*)_text from:(NSString*)_from to:(NSString*)_to;
-(NSString*)translateText:(NSString*)_text to:(NSString*)_to;

-(NSString*)detectLanguageOfText:(NSString*)_text;

@property (nonatomic, retain) NSString *client_id;
@property (nonatomic, retain) NSString *client_secret;

@end
