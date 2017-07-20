//
//  MicrosoftTranslator.m
//
//  Created by Florian on 31.03.13.
//  Copyright (c) 2013 Florian Killius. All rights reserved.
//

#define kAccessURL @"https://datamarket.accesscontrol.windows.net/v2/OAuth2-13/"

#define kGrantType @"client_credentials"
#define kScope @"http://api.microsofttranslator.com"

#define kTranslateURL @"http://api.microsofttranslator.com/v2/Http.svc/Translate"
#define kDetectURL @"http://api.microsofttranslator.com/V2/Http.svc/Detect"

#import "MicrosoftTranslator.h"
#import <time.h>

@implementation NSString (NSString_Extended)

- (NSString *)URLencode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' || 
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end

@interface MicrosoftTranslator ()

-(void)getAccessToken;

@end


@implementation MicrosoftTranslator

@synthesize client_id, client_secret;

-(NSString *)detectLanguageOfText:(NSString *)_text
{
    int a=0;
    while(time(NULL) > timeExpiring)
    {
        [self getAccessToken];
        if(++a > 2)
        {
            return nil;
        }
    }
    NSString *url = [NSString stringWithFormat:@"%@?text=%@", kDetectURL, [_text URLencode]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod:@"GET"];
    
    NSString *auth = [NSString stringWithFormat:@"Bearer %@", accessToken];
    
    [request setValue:auth forHTTPHeaderField:@"Authorization"];
    
    NSURLResponse *response;
    NSError *error = NULL;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSRange rangeStart = [string rangeOfString:@">"];
    NSRange rangeEnd = [string rangeOfString:@"</string>"];
    NSString *string_language = @"";
    
    if(rangeStart.length > 0)
    {
        string_language = [string substringWithRange:NSMakeRange(rangeStart.location + 1, rangeEnd.location - rangeStart.location - 1)];
    }
    
  //  [request release];
    //[string release];
    
    return string_language;
}

-(NSString *)translateText:(NSString *)_text to:(NSString *)_to
{
    return [self translateText:_text from:nil to:_to];
}

-(NSString*)translateText:(NSString *)_text from:(NSString *)_from to:(NSString *)_to
{
    int a=0;
    while(time(NULL) > timeExpiring)
    {
        [self getAccessToken];
        if(++a > 2)
        {
            return nil;
        }
    }
    
    NSString *url;
    
    if(_from)
        url = [NSString stringWithFormat:@"%@?text=%@&from=%@&to=%@", kTranslateURL, [_text URLencode], [_from URLencode], [_to URLencode]];
    else
        url = [NSString stringWithFormat:@"%@?text=%@&to=%@", kTranslateURL, [_text URLencode], [_to URLencode]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod:@"GET"];
    
    NSString *auth = [NSString stringWithFormat:@"Bearer %@", accessToken];
    
    [request setValue:auth forHTTPHeaderField:@"Authorization"];
    
    NSURLResponse *response;
    NSError *error = NULL;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSRange rangeStart = [string rangeOfString:@">"];
    NSRange rangeEnd = [string rangeOfString:@"</string>"];
    NSString *string_translation = @"";
    
    if(rangeStart.length > 0)
    {
        string_translation = [string substringWithRange:NSMakeRange(rangeStart.location + 1, rangeEnd.location - rangeStart.location - 1)];
    }
    
    //[request release];
    //[string release];
    
    return string_translation;
}

-(void)getAccessToken
{
    if([self.client_secret isEqualToString:@""] || [self.client_id isEqualToString:@""])
        return;
 
    //if(accessToken)
      //  [accessToken release];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL URLWithString:kAccessURL] standardizedURL]];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *client_id_encoded = [client_id URLencode];
    NSString *client_secret_encoded = [client_secret URLencode];
    NSString *grant_type = [kGrantType URLencode];
    NSString *scope = [kScope URLencode];
    
    NSString *body = [NSString stringWithFormat:@"grant_type=%@&client_id=%@&client_secret=%@&scope=%@",grant_type, client_id_encoded, client_secret_encoded, scope];
    
    [request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSURLResponse *response;
    NSError *error = NULL;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
  //  [request release];
    
    if(error)
    {
#ifdef DEBUG_MICROSOFT_TRANSLATOR
        NSLog(@"Error, getting access token: %@", error.localizedDescription);
#endif
        timeExpiring = 0;
        return;
    }
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if(error)
    {
#ifdef DEBUG_MICROSOFT_TRANSLATOR
        NSLog(@"Error, reading json object for access token: %@", error.localizedDescription);
#endif
        timeExpiring = 0;
        return;
    }
    
    accessToken = [[dict valueForKey:@"access_token"] copy];
    
    if(!accessToken)
    {
#ifdef DEBUG_MICROSOFT_TRANSLATOR
        NSLog(@"Error, access token doesn't exist in json object.");
#endif
        timeExpiring = 0;
        return;
    }
    
    timeExpiring = time(NULL)+590;
}

-(id)init
{
    if (( self = [super init] ))
    {
        accessToken = @"";
        timeExpiring = 0;
    }
    return self;
}

-(id)initWithClientID:(NSString *)_client_id clientSecret:(NSString *)_client_secret
{
    if ( [self init] )
    {
        self.client_id = _client_id;
        self.client_secret = _client_secret;
    }
    return self;
}

-(void)dealloc
{
    self.client_id = nil;
    self.client_secret = nil;
    
  //  [super dealloc];
}

@end
