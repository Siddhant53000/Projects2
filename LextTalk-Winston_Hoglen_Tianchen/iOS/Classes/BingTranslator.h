//
//  BingTranslator.h
//  BingTranslatorClass
//
//  Created by Raúl Martín Carbonell on 7/23/11.
//  Copyright 2011 Freelance. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark -
#pragma mark BingTranslatorProtocol

@protocol BingTranslatorProtocol <NSObject>
@optional

- (void) translatedText:(NSString *) text;
- (void) translatedText:(NSString *) text withId:(NSInteger) identifier;

- (void) detectedLanguage:(NSString *) locale;
- (void) detectedLanguage:(NSString *) locale withId:(NSInteger) identifier;

- (void) spokenText:(NSData *) wav;
- (void) spokenText:(NSData *)wav withId:(NSInteger) identifier;

- (void) translations:(NSArray *) tranlationArray withRating:(NSArray *) ratingArray;
- (void) translations:(NSArray *) tranlationArray withRating:(NSArray *) ratingArray withId:(NSInteger) identifier;

- (void) langNames:(NSArray *) langNames;
- (void) langNames:(NSArray *) langNames withId:(NSInteger) identifier;

- (void) connectionFailedWithError:(NSError *) error;
- (void) connectionFailedWithError:(NSError *) error withId:(NSInteger) identifier;


- (void) gotToken:(NSString *) aNewToken withExpiracyDate:(NSDate *) date;
- (void) downloadToken;

@end


#pragma mark -
#pragma mark BingConnectionDelegate

@interface BingConnectionDelegate : NSObject
{
    NSMutableData * _receivedData;
    id<BingTranslatorProtocol> __weak delegate;
    NSInteger _identifier;
}

@property (weak) id<BingTranslatorProtocol> delegate;
@property NSInteger _identifier;

@end

@interface TranslateBingConnectionDelegate : BingConnectionDelegate
{
    
}

@end

@interface DetectBingConnectionDelegate : BingConnectionDelegate
{
    
}

@end

@interface SpeakBingConnectionDelegate : BingConnectionDelegate
{
    
}

@end

@interface TranslationsBingConnectionDelegate : BingConnectionDelegate
{
    
}


@end

@interface LangNamesBingConnectionDelegate : BingConnectionDelegate
{
    
}

@end

@interface GetSpeakLanguagesBingConnectionDelegate : BingConnectionDelegate
{
    
}
@end

@interface TokenConnectionDelegate : BingConnectionDelegate
{
    
}

@end

#pragma mark -
#pragma mark BingTranslator

@interface BingTranslator : NSObject <BingTranslatorProtocol>
{
    
    id<BingTranslatorProtocol> __weak delegate;
    
    NSString * token;
    NSDate * expiracyDate;
    NSInteger retries;
    
}

@property (weak) id<BingTranslatorProtocol> delegate;
@property (nonatomic, strong) NSString * token;
@property (nonatomic, strong) NSDate * expiracyDate;

+ (void) initialize;

- (void) translateText:(NSString *) text 
            fromLocale: (NSString *)from 
                    to:(NSString *) to 
          withDelegate:(id<BingTranslatorProtocol>)delegate2
                withId:(NSInteger) identifier;
- (void) translateText:(NSString *) text 
            fromLocale: (NSString *)from 
                    to:(NSString *) to 
          withDelegate:(id<BingTranslatorProtocol>)delegate2;

- (void) detectLanguage:(NSString *) text
           withDelegate:(id<BingTranslatorProtocol>) delegate2;
- (void) detectLanguage:(NSString *) text
           withDelegate:(id<BingTranslatorProtocol>) delegate2
                 withId:(NSInteger) identifier;

- (void) speakText:(NSString *) text 
        inLanguage:(NSString *)locale 
      withDelegate:(id<BingTranslatorProtocol>) delegate2;
- (void) speakText:(NSString *) text 
        inLanguage:(NSString *)locale 
      withDelegate:(id<BingTranslatorProtocol>) delegate2 
            withId:(NSInteger) identifier;

- (void) translationsText:(NSString *) text 
               fromLocale:(NSString *)from 
                       to:(NSString *) to 
             withDelegate:(id<BingTranslatorProtocol>)delegate2
                   withId:(NSInteger) identifier;
- (void) translationsText:(NSString *) text 
               fromLocale:(NSString *)from 
                       to:(NSString *) to 
             withDelegate:(id<BingTranslatorProtocol>)delegate2;

- (void) langNames: (NSArray *) localeArray 
         forLocale:(NSString *) locale
      withDelegate:(id<BingTranslatorProtocol>) delegate2;
- (void) langNames: (NSArray *) localeArray 
         forLocale:(NSString *) locale
      withDelegate:(id<BingTranslatorProtocol>) delegate2
            withId:(NSInteger) identifier;

- (void) getLanguagesForSpeak;

- (void) downloadToken;
- (BOOL) isTokenValid;
- (void) giveWarning;

@end
