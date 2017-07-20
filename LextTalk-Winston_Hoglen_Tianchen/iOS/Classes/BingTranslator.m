//
//  BingTranslator.m
//  BingTranslatorClass
//
//  Created by Raúl Martín Carbonell on 7/23/11.
//  Copyright 2011 Freelance. All rights reserved.
//

#import "BingTranslator.h"

//#define appId @"8C396EB4FD595EBB5B14EE5E857BF559A5519618"
#define appId       @""
#define secret      @"v9XLN8NWQIi3XcAlKFR020+Y/jjffMsJv5LgVp98qrA="
#define client_id   @"inqbarna"
#define timeout 15.0

static NSSet * _allowedLocales=nil;
static NSSet * _allowedLocalesForSpeak=nil;

#pragma mark -
#pragma mark BingConnectionDelegate

@implementation BingConnectionDelegate
@synthesize delegate, _identifier;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [_receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    // receivedData is declared as a method instance elsewhere
    _receivedData=nil;
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    if (self._identifier<0)
    {
        if ([delegate respondsToSelector:@selector(connectionFailedWithError:)])
            [delegate connectionFailedWithError:error];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(connectionFailedWithError:withId:)])
            [delegate connectionFailedWithError:error withId:self._identifier];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    //NSLog(@"Succeeded! Received %d bytes of data",[_receivedData length]);
    
    // release the connection, and the data object
    _receivedData=nil;
}

- (id) init
{
    self=[super init];
    if (self)
    {
        _receivedData=[[NSMutableData alloc] init];
    }
    return self;
}


@end

#pragma mark -
#pragma mark TranslateBingConnectionDelegate

@implementation TranslateBingConnectionDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    //NSLog(@"Succeeded! Received %d bytes of data",[_receivedData length]);
    

    NSString * result=[[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
    //NSLog(@"Traducción: %@", result);
    NSRange match;
    match = [result rangeOfString: @">"];
    result = [result substringFromIndex: match.location+1];
    
    match = [result rangeOfString: @"<"];
    result = [result substringWithRange: NSMakeRange (0, match.location)];
    
    if (self._identifier<0)
    {
        if ([delegate respondsToSelector:@selector(translatedText:)])
            [delegate translatedText:result];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(translatedText:withId:)])
            [delegate translatedText:result withId:self._identifier];
    }

    //[connection release];
    //[_receivedData release];
    [super connectionDidFinishLoading:connection];
}

@end

@implementation DetectBingConnectionDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    //NSLog(@"Succeeded! Received %d bytes of data",[_receivedData length]);
    
    
    NSString * result=[[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
    NSRange match;
    match = [result rangeOfString: @">"];
    result = [result substringFromIndex: match.location+1];
    
    match = [result rangeOfString: @"<"];
    result = [result substringWithRange: NSMakeRange (0, match.location)];
    
    if (self._identifier<0)
    {
        if ([delegate respondsToSelector:@selector(detectedLanguage:)])
            [delegate detectedLanguage:result];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(detectedLanguage:withId:)])
            [delegate detectedLanguage:result withId:self._identifier];
    }
    
    //[connection release];
    //[_receivedData release];
    
    [super connectionDidFinishLoading:connection];
}

@end

@implementation SpeakBingConnectionDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    //NSLog(@"Succeeded! Received %d bytes of data",[_receivedData length]);
    
    
    NSData * data=[NSData dataWithData:_receivedData];
    
    if (self._identifier<0)
    {
        if ([delegate respondsToSelector:@selector(spokenText:)])
            [delegate spokenText:data];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(spokenText:withId:)])
            [delegate spokenText:data withId:self._identifier];
    }
    
    //[connection release];
    //[_receivedData release];
    
    [super connectionDidFinishLoading:connection];
}

@end

@implementation TranslationsBingConnectionDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    //NSLog(@"Succeeded! Received %d bytes of data",[_receivedData length]);
    
    NSString * result=[[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
    NSArray * array1=[result componentsSeparatedByString:@"<TranslatedText>"];
    NSArray * array2=[result componentsSeparatedByString:@"<Rating>"];
    NSInteger len1=[array1 count] -1; if (len1<0) len1=0;
    NSInteger len2=[array2 count] -1; if (len2<0) len2=0;
    NSMutableArray * translationArray=[NSMutableArray arrayWithCapacity:len1];
    NSMutableArray * ratingArray=[NSMutableArray arrayWithCapacity:len2];
    for (int i=1; i<[array1 count]; i++)
    {
        NSString * str=[array1 objectAtIndex:i];
        NSRange match;
        match = [str rangeOfString: @"</TranslatedText>"];
        NSString * clean= [str substringWithRange:NSMakeRange(0, match.location)];
        [translationArray addObject:clean];
    }
    for (int i=1; i<[array2 count]; i++)
    {
        NSString * str=[array2 objectAtIndex:i];
        NSRange match;
        match = [str rangeOfString: @"</Rating>"];
        NSString * clean= [str substringWithRange:NSMakeRange(0, match.location)];
        [ratingArray addObject:[NSNumber numberWithInt:[clean intValue]]];
    }
    
    if ([translationArray count]==[ratingArray count])
    {
        //Limpio de palabras iguales.
        for (int i=0; i<[translationArray count]; i++)
        {
            NSString * str=[translationArray objectAtIndex:i];
            for (int j=i+1; j<[translationArray count]; j++)
            {
                NSString * str2=[translationArray objectAtIndex:j];
                if ([str localizedCaseInsensitiveCompare:str2] == NSOrderedSame)
                {
                    [translationArray removeObjectAtIndex:j];
                    [ratingArray removeObjectAtIndex:j];
                    j--;
                }
            }
        }
    }
    if (self._identifier<0)
    {
        if ([delegate respondsToSelector:@selector(translations:withRating:)])
            [delegate translations:translationArray withRating:ratingArray];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(translations:withRating:withId:)])
            [delegate translations:translationArray withRating:ratingArray withId:self._identifier];
    }
    /*
    NSLog(@"Traducciones: %@", translationArray);
    NSLog(@"Ratings: %@", ratingArray);
    
    
    NSString * str=[[[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"Translationssss: %@", str);
     */
    
    //[connection release];
    //[_receivedData release];
    [super connectionDidFinishLoading:connection];
}

@end

@implementation LangNamesBingConnectionDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    //NSLog(@"Succeeded! Received %d bytes of data",[_receivedData length]);
    
    
    NSString * result=[[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
    //NSLog(@"Lang Names: %@", result);
    
    NSArray * array=[result componentsSeparatedByString:@"\",\""];
    NSMutableArray * resultArray=[NSMutableArray arrayWithCapacity:5];
    if ([result length]>2)
    {
        NSString * piece;
        for (int i=0; i<[array count]; i++)
        {
            piece=[array objectAtIndex:i];
            //En el 0, tengo un carcter extra[
            if (i==0) {
                NSRange range=NSMakeRange(2, [piece length] -2);
                NSString * str=[piece substringWithRange:range];
                [resultArray addObject:str];
            }
            else if (i==([array count]-1)) {
                NSRange range=NSMakeRange(0, [piece length] -2);
                NSString * str=[piece substringWithRange:range];
                [resultArray addObject:str];
            }
            else {
                [resultArray addObject:piece];
            }
            //En el ultimo tengo la " al final en vez de al principio.
        }
    }
    //NSLog(@"Lang Names: %@", resultArray);

    if (self._identifier<0)
    {
        if ([delegate respondsToSelector:@selector(langNames:)])
            [delegate langNames:resultArray];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(langNames:withId:)])
            [delegate langNames:resultArray withId:self._identifier];
    }
    //[connection release];
    //[_receivedData release];
    
    [super connectionDidFinishLoading:connection];
}

@end

@implementation GetSpeakLanguagesBingConnectionDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    //NSLog(@"Succeeded! Received %d bytes of data",[_receivedData length]);
    
    NSString * result=[[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"Speak locales: %@", result);
    /*
    NSArray * array1=[result componentsSeparatedByString:@"<TranslatedText>"];
    NSArray * array2=[result componentsSeparatedByString:@"<Rating>"];
    NSInteger len1=[array1 count] -1; if (len1<0) len1=0;
    NSInteger len2=[array2 count] -1; if (len2<0) len2=0;
    NSMutableArray * translationArray=[NSMutableArray arrayWithCapacity:len1];
    NSMutableArray * ratingArray=[NSMutableArray arrayWithCapacity:len2];
    for (int i=1; i<[array1 count]; i++)
    {
        NSString * str=[array1 objectAtIndex:i];
        NSRange match;
        match = [str rangeOfString: @"</TranslatedText>"];
        NSString * clean= [str substringWithRange:NSMakeRange(0, match.location)];
        [translationArray addObject:clean];
    }
    for (int i=1; i<[array2 count]; i++)
    {
        NSString * str=[array2 objectAtIndex:i];
        NSRange match;
        match = [str rangeOfString: @"</Rating>"];
        NSString * clean= [str substringWithRange:NSMakeRange(0, match.location)];
        [ratingArray addObject:[NSNumber numberWithInt:[clean intValue]]];
    }
    
    if ([translationArray count]==[ratingArray count])
    {
        //Limpio de palabras iguales.
        for (int i=0; i<[translationArray count]; i++)
        {
            NSString * str=[translationArray objectAtIndex:i];
            for (int j=i+1; j<[translationArray count]; j++)
            {
                NSString * str2=[translationArray objectAtIndex:j];
                if ([str localizedCaseInsensitiveCompare:str2] == NSOrderedSame)
                {
                    [translationArray removeObjectAtIndex:j];
                    [ratingArray removeObjectAtIndex:j];
                    j--;
                }
            }
        }
    }
    if (self._identifier<0)
    {
        if ([delegate respondsToSelector:@selector(translations:withRating:)])
            [delegate translations:translationArray withRating:ratingArray];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(translations:withRating:withId:)])
            [delegate translations:translationArray withRating:ratingArray withId:self._identifier];
    }
     */
    /*
     NSLog(@"Traducciones: %@", translationArray);
     NSLog(@"Ratings: %@", ratingArray);
     
     
     NSString * str=[[[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding] autorelease];
     NSLog(@"Translationssss: %@", str);
     */
    
    //[connection release];
    //[_receivedData release];
    [super connectionDidFinishLoading:connection];
}

@end

@implementation TokenConnectionDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    //NSLog(@"Succeeded! Received %d bytes of data",[_receivedData length]);
    
    
//    NSString * result=[[[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding] autorelease];
    //NSLog(@"Token: %@", result);
//    SBJsonParser * parser=[[[SBJsonParser alloc] init] autorelease];
//    NSDictionary * dic = [parser objectWithString:result];
    
    NSError* error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:_receivedData
                                                        options:kNilOptions
                                                          error:&error];
    
    NSString * token=[dic objectForKey:@"access_token"];
    NSInteger seconds=[[dic objectForKey:@"expires_in"] intValue];
    NSDate * date=[NSDate date];
    seconds= seconds + [date timeIntervalSince1970];
    NSDate * expiracyDate=[NSDate dateWithTimeIntervalSince1970:seconds];
    
    if ([self.delegate respondsToSelector:@selector(gotToken:withExpiracyDate:)])
        [self.delegate gotToken:token withExpiracyDate:expiracyDate];
    

    
    [super connectionDidFinishLoading:connection];
}

@end

#pragma mark -
#pragma mark BingTranslator

@implementation BingTranslator
@synthesize delegate;
@synthesize token, expiracyDate;


+ (void) initialize
{
    if (_allowedLocales==nil)
        _allowedLocales=[[NSSet alloc ] initWithObjects:@"ar", @"bg", @"ca", @"zh-CHS", @"zh-CHT", @"cs", @"da", @"nl", @"en", @"et", @"fa", @"fi", @"fr", @"de", @"el", @"hi", @"ht", @"he", @"hu", @"id", @"it", @"ja", @"ko", @"lv", @"lt", @"ms", @"mww", @"no", @"pl", @"pt", @"ro", @"ru", @"sk", @"sl", @"es", @"sv", @"th", @"tr", @"uk", @"ur", @"vi", nil];
    
    if (_allowedLocalesForSpeak==nil)
        _allowedLocalesForSpeak=[[NSSet alloc] initWithObjects:@"ca", @"ca-es", @"da", @"da-dk", @"de", @"de-de", @"en", @"en-au", @"en-ca", @"en-gb", @"en-in", @"en-us", @"es", @"es-es", @"es-mx", @"fi", @"fi-fi", @"fr", @"fr-ca", @"fr-fr", @"it", @"it-it", @"ja", @"ja-jp", @"ko", @"ko-kr", @"nb-no", @"nl", @"nl-nl", @"no", @"pl", @"pl-pl", @"pt", @"pt-br", @"pt-pt", @"ru", @"ru-ru", @"sv", @"sv-se", @"zh-chs", @"zh-cht", @"zh-cn", @"zh-hk", @"zh-tw", nil];
}

- (void) translateText:(NSString *) text 
            fromLocale: (NSString *)from 
                    to:(NSString *) to 
          withDelegate:(id<BingTranslatorProtocol>)delegate2
{
    [self translateText:text fromLocale:from to:to withDelegate:delegate2 withId:-1];
}
- (void) translateText:(NSString *) text 
            fromLocale: (NSString *)from 
                    to:(NSString *) to 
          withDelegate:(id<BingTranslatorProtocol>)delegate2
                withId:(NSInteger)identifier
{
    if ([_allowedLocales containsObject:from] && [_allowedLocales containsObject:from] && [self isTokenValid])
    {
        NSLog(@"entered translatetext for other \n \n \n \n \n\n\n\n\n\n\n\n\n\n\n\n\n");
        self.delegate=delegate2;
        
        NSMutableString * urlString=[NSMutableString stringWithString:@"http://api.microsofttranslator.com/v2/Http.svc/Translate?appId="];
        [urlString appendString:appId];
        [urlString appendString:@"&text="];
        [urlString appendString:text];
        [urlString appendString:@"&from="];
        [urlString appendString:from];
        [urlString appendString:@"&to="];
        [urlString appendString:to];
        
        //Convierto la cadena de texto en algo que pueda ser utilizado como una URL
        NSString * urlString2=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL * url=[NSURL URLWithString:urlString2];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: timeout];
        [request setValue:self.token forHTTPHeaderField:@"Authorization"];
        
        TranslateBingConnectionDelegate * connectionDelegate=[[TranslateBingConnectionDelegate alloc] init];
        connectionDelegate.delegate=self.delegate;
        connectionDelegate._identifier=identifier;
        NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:connectionDelegate];
        
        if (theConnection) {
            // Create the NSMutableData to hold the received data.
            // receivedData is an instance variable declared elsewhere.
            //_receivedData = [[NSMutableData data] retain];
        } else {
            // Inform the user that the connection failed.
            NSLog(@"La conexión con el servidor ha fallado");
        }
    }
    else
    {
        //NSLog(@"no locale");
        if (identifier<0)
        {
            if ([delegate respondsToSelector:@selector(translatedText:)])
                [delegate translatedText:nil];
        }
        else
        {
            if ([delegate respondsToSelector:@selector(translatedText:withId:)])
                [delegate translatedText:nil withId:identifier];
        }
    }

}

- (void) detectLanguage:(NSString *) text
           withDelegate:(id<BingTranslatorProtocol>) delegate2
{
    [self detectLanguage:text withDelegate:delegate2 withId:-1];
}

- (void) detectLanguage:(NSString *) text
           withDelegate:(id<BingTranslatorProtocol>) delegate2
                 withId:(NSInteger)identifier
{
    if ([self isTokenValid])
    {
        self.delegate=delegate2;
        
        NSMutableString * urlString=[NSMutableString stringWithString:@"http://api.microsofttranslator.com/v2/Http.svc/Detect?appId="];
        [urlString appendString:appId];
        [urlString appendString:@"&text="];
        [urlString appendString:text];
        
        //Convierto la cadena de texto en algo que pueda ser utilizado como una URL
        NSString * urlString2=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL * url=[NSURL URLWithString:urlString2];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: timeout];
        [request setValue:self.token forHTTPHeaderField:@"Authorization"];
        
        DetectBingConnectionDelegate * connectionDelegate=[[DetectBingConnectionDelegate alloc] init];
        connectionDelegate.delegate=self.delegate;
        connectionDelegate._identifier=identifier;
        NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:connectionDelegate];
        
        if (theConnection) {
            // Create the NSMutableData to hold the received data.
            // receivedData is an instance variable declared elsewhere.
            //_receivedData = [[NSMutableData data] retain];
        } else {
            // Inform the user that the connection failed.
            NSLog(@"La conexión con el servidor ha fallado");
        }
    }
    else
    {
        if (identifier<0)
        {
            if ([delegate respondsToSelector:@selector(detectedLanguage:)])
                [delegate detectedLanguage:nil];
        }
        else
        {
            if ([delegate respondsToSelector:@selector(detectedLanguage:withId:)])
                [delegate detectedLanguage:nil withId:identifier];
        }
    }
}


- (void) speakText:(NSString *) text 
        inLanguage:(NSString *)locale 
      withDelegate:(id<BingTranslatorProtocol>) delegate2
{
    [self speakText:text inLanguage:locale withDelegate:delegate2 withId:-1];
}

- (void) speakText:(NSString *) text 
        inLanguage:(NSString *)locale 
      withDelegate:(id<BingTranslatorProtocol>) delegate2 
            withId:(NSInteger) identifier
{
    if ([_allowedLocalesForSpeak containsObject:locale] && [self isTokenValid])
    {
        self.delegate=delegate2;
        
        NSMutableString * urlString=[NSMutableString stringWithString:@"http://api.microsofttranslator.com/v2/Http.svc/Speak?appId="];
        [urlString appendString:appId];
        [urlString appendString:@"&text="];
        [urlString appendString:text];
        [urlString appendString:@"&language="];
        [urlString appendString:locale];
        
        //Convierto la cadena de texto en algo que pueda ser utilizado como una URL
        NSString * urlString2=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL * url=[NSURL URLWithString:urlString2];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: timeout];
        [request setValue:self.token forHTTPHeaderField:@"Authorization"];
        
        SpeakBingConnectionDelegate * connectionDelegate=[[SpeakBingConnectionDelegate alloc] init];
        connectionDelegate.delegate=self.delegate;
        connectionDelegate._identifier=identifier;
        NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:connectionDelegate];
        
        if (theConnection) {
            // Create the NSMutableData to hold the received data.
            // receivedData is an instance variable declared elsewhere.
            //_receivedData = [[NSMutableData data] retain];
        } else {
            // Inform the user that the connection failed.
            NSLog(@"La conexión con el servidor ha fallado");
        }
    }
    else
    {
        //NSLog(@"no locale");
        if (identifier<0)
        {
            if ([delegate respondsToSelector:@selector(spokenText:)])
                [delegate spokenText:nil];
        }
        else
        {
            if ([delegate respondsToSelector:@selector(spokenText:withId:)])
                [delegate spokenText:nil withId:identifier];
        }
    }
}



- (void) translationsText:(NSString *) text 
               fromLocale: (NSString *)from 
                       to:(NSString *) to 
             withDelegate:(id<BingTranslatorProtocol>)delegate2
{
    [self translationsText:text fromLocale:from to:to withDelegate:delegate2 withId:-1];
}
- (void) translationsText:(NSString *) text 
               fromLocale: (NSString *)from 
                       to:(NSString *) to 
             withDelegate:(id<BingTranslatorProtocol>)delegate2
                   withId:(NSInteger)identifier
{
    if ([_allowedLocales containsObject:from] && [_allowedLocales containsObject:from] && [self isTokenValid])
    {
        self.delegate=delegate2;
        
        NSMutableString * urlString=[NSMutableString stringWithString:@"http://api.microsofttranslator.com/v2/Http.svc/GetTranslations?appId="];
        [urlString appendString:appId];
        [urlString appendString:@"&text="];
        [urlString appendString:text];
        [urlString appendString:@"&from="];
        [urlString appendString:from];
        [urlString appendString:@"&to="];
        [urlString appendString:to];
        [urlString appendString:@"&maxTranslations="];
        [urlString appendString:@"5"];
        
        //Convierto la cadena de texto en algo que pueda ser utilizado como una URL
        NSString * urlString2=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL * url=[NSURL URLWithString:urlString2];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: timeout];
        [request setValue:self.token forHTTPHeaderField:@"Authorization"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request setHTTPMethod:@"POST"];
        
        //No sé como poner el objeto con los valores al que hace referencia la API, así que lo dejo
        //con los valores por defecto.
        //NSString * options=@"State=myState";
        //NSData * data=[NSData dataWithBytes:[options UTF8String] length:[options length]];
        //[request setHTTPBodyStream:[NSInputStream inputStreamWithData:[options dataUsingEncoding:NSUTF8StringEncoding]]];
        //[request setHTTPBody:data];
        
        TranslationsBingConnectionDelegate * connectionDelegate=[[TranslationsBingConnectionDelegate alloc] init];
        connectionDelegate.delegate=self.delegate;
        connectionDelegate._identifier=identifier;
        NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:connectionDelegate];
        
        if (theConnection) {
            // Create the NSMutableData to hold the received data.
            // receivedData is an instance variable declared elsewhere.
            //_receivedData = [[NSMutableData data] retain];
        } else {
            // Inform the user that the connection failed.
            NSLog(@"La conexión con el servidor ha fallado");
        }
    }
    else
    {
        //NSLog(@"no locale");
        if (identifier<0)
        {
            if ([delegate respondsToSelector:@selector(translations:withRating:)])
                [delegate translations:nil withRating:nil];
        }
        else
        {
            if ([delegate respondsToSelector:@selector(translations:withRating:withId:)])
                [delegate translations:nil withRating:nil withId:identifier];
        }
    }
    
}

- (void) langNames: (NSArray *) localeArray 
         forLocale:(NSString *) locale
      withDelegate:(id<BingTranslatorProtocol>) delegate2
{
    [self langNames:localeArray forLocale:locale withDelegate:delegate2 withId:-1];
}
- (void) langNames: (NSArray *) localeArray 
         forLocale:(NSString *) locale
      withDelegate:(id<BingTranslatorProtocol>) delegate2
            withId:(NSInteger) identifier
{
    if ([_allowedLocales containsObject:locale] && [self isTokenValid])
    {
        self.delegate=delegate2;
        
        //NSMutableString * urlString=[NSMutableString stringWithString:@"http://api.microsofttranslator.com/v2/Http.svc/GetLanguageNames?appId="];
        NSMutableString * urlString=[NSMutableString stringWithString:@"http://api.microsofttranslator.com/V2/Ajax.svc/GetLanguageNames?appId="];
        [urlString appendString:appId];
        [urlString appendString:@"&locale="];
        [urlString appendString:locale];
        [urlString appendString:@"&languageCodes="];
        
        NSMutableString * locales=[NSMutableString stringWithString:@"["];
        for (int i=0; i<[localeArray count]; i++)
        {
            NSString * str=[localeArray objectAtIndex:i];
            if (i!=([localeArray count] -1))
                [locales appendFormat:@"\"%@\",", str];
            else
                [locales appendFormat:@"\"%@\"]", str];
        }
        
        [urlString appendString:locales];
        //NSLog(@"locales: %@", locales);
        
        //Convierto la cadena de texto en algo que pueda ser utilizado como una URL
        NSString * urlString2=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL * url=[NSURL URLWithString:urlString2];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: timeout];
        [request setValue:self.token forHTTPHeaderField:@"Authorization"];
        
        
        
        LangNamesBingConnectionDelegate * connectionDelegate=[[LangNamesBingConnectionDelegate alloc] init];
        connectionDelegate.delegate=self.delegate;
        connectionDelegate._identifier=identifier;
        NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:connectionDelegate];
        
        if (theConnection) {
            // Create the NSMutableData to hold the received data.
            // receivedData is an instance variable declared elsewhere.
            //_receivedData = [[NSMutableData data] retain];
        } else {
            // Inform the user that the connection failed.
            NSLog(@"La conexión con el servidor ha fallado");
        }
        
        //Lo dejo aquí por referencia, no hay modo de que el POST me funcione con este metodo, así que uso la API AJAX
        //No sé como poner el objeto con los valores al que hace referencia la API, así que lo dejo
        //con los valores por defecto.
        /*
         NSMutableString * locales=[NSMutableString stringWithString:@"languageCodes={"];
         for (int i=0; i<[localeArray count]; i++)
         {
         NSString * str=[localeArray objectAtIndex:i];
         if (i!=([localeArray count] -1))
         [locales appendFormat:@"%@,", str];
         else
         [locales appendFormat:@"%@}", str];
         }
         */
        //NSString * locales=@"<array><string>en</string><string>es</string></array>";
        /*
         NSString * locales=@"<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\">en</string><string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\">es</string>";
         NSLog(@"locales: %@", locales);
         //NSData * data=[NSData dataWithBytes:[locales UTF8String] length:[locales length]];
         NSData *data = [locales dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
         
         NSString *postLength = [NSString stringWithFormat:@"%d", [data length]];
         //[request setHTTPBodyStream:[NSInputStream inputStreamWithData:[options dataUsingEncoding:NSUTF8StringEncoding]]];
         [request setHTTPMethod:@"POST"];
         [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
         //[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
         [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
         [request setHTTPBody:data];
         */
        
    }
    else
    {
        //NSLog(@"no locale");
        if (identifier<0)
        {
            if ([delegate respondsToSelector:@selector(langNames:)])
                [delegate langNames:nil];
        }
        else
        {
            if ([delegate respondsToSelector:@selector(langNames:withId:)])
                [delegate langNames:nil withId:identifier];
        }
    }
}





- (void) getLanguagesForSpeak
{
    
    NSMutableString * urlString=[NSMutableString stringWithString:@"http://api.microsofttranslator.com/v2/Http.svc/GetLanguagesForSpeak?appId="];
    //NSMutableString * urlString=[NSMutableString stringWithString:@"http://api.microsofttranslator.com/v2/Ajax.svc/GetLanguageForSpeak?appId="];
    [urlString appendString:appId];
    //NSLog(@"URL String : %@", urlString);
    //Convierto la cadena de texto en algo que pueda ser utilizado como una URL
    NSString * urlString2=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * url=[NSURL URLWithString:urlString2];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: timeout];
    [request setValue:self.token forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPMethod:@"GET"];//Con POST no funciona, esa ha sido la clave
    
    //No sé como poner el objeto con los valores al que hace referencia la API, así que lo dejo
    //con los valores por defecto.
    //NSString * options=@"State=myState";
    //NSData * data=[NSData dataWithBytes:[options UTF8String] length:[options length]];
    //[request setHTTPBodyStream:[NSInputStream inputStreamWithData:[options dataUsingEncoding:NSUTF8StringEncoding]]];
    //[request setHTTPBody:data];
    
    GetSpeakLanguagesBingConnectionDelegate * connectionDelegate=[[GetSpeakLanguagesBingConnectionDelegate alloc] init];
    connectionDelegate.delegate=self.delegate;
    //connectionDelegate._identifier=identifier;
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:connectionDelegate];
    
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        //_receivedData = [[NSMutableData data] retain];
    } else {
        // Inform the user that the connection failed.
        NSLog(@"La conexión con el servidor ha fallado");
    }
    
}





- (void) downloadToken
{
    //NSLog(@"Download token");
    //reset of retries
    if (retries==3)
    {
        retries=0;
        //I have retried 3 times, so schedule for 5 minutes later
        [self performSelector:@selector(downloadToken) withObject:nil afterDelay:300];
        
        [self giveWarning];
    }
    else
    {
        //Schedule for 20 seconds later.
        //If the token is succesfully retrieved, cancel the request later
        retries=retries + 1;
        [self performSelector:@selector(downloadToken) withObject:nil afterDelay:20];
    }
        
    
    NSString * urlString=@"https://datamarket.accesscontrol.windows.net/v2/OAuth2-13";
    NSURL * url=[NSURL URLWithString:urlString];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: timeout];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPMethod:@"POST"];
    
    //No sé como poner el objeto con los valores al que hace referencia la API, así que lo dejo
    //con los valores por defecto.
    NSString * encodedSecret =
    (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, 
                                                        (CFStringRef)secret,
                                                        NULL,
                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                        kCFStringEncodingUTF8 ));
    //NSString * encodedSecret=[secret stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * options=[ NSString stringWithFormat: @"grant_type=client_credentials&client_id=%@&client_secret=%@&scope=http://api.microsofttranslator.com", client_id, encodedSecret];
    //NSString * encodedString=[options stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSData * data=[NSData dataWithBytes:[options UTF8String] length:[options length]];
    [request setHTTPBody:data];
    
    TokenConnectionDelegate * connectionDelegate=[[TokenConnectionDelegate alloc] init];
    connectionDelegate.delegate=self;
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:connectionDelegate];
    
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        //_receivedData = [[NSMutableData data] retain];
    } else {
        // Inform the user that the connection failed.
        NSLog(@"La conexión con el servidor ha fallado");
    }
//    if (encodedSecret) {
//        encodedSecret = nil;
//    }
//    CFRelease((__bridge CFTypeRef)(encodedSecret));
}

- (void) gotToken:(NSString *)aNewToken withExpiracyDate:(NSDate *)date
{
    //It is quite hidden in the docs, but you must prepend this, with the space, so that all this text is set
    //later to the Authorization header.
    aNewToken=[NSString stringWithFormat:@"Bearer %@", aNewToken];
    
    self.token=aNewToken;
    self.expiracyDate=date;
    
    //NSLog(@"token: %@", aNewToken);
    //NSLog(@"date: %@", date);
    
    //Check if I got the token and date. If I have, cancel the retry requests (retries=0)
    //and schedule a new one a little before the expiracy of the token
    if ([self isTokenValid])
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        NSTimeInterval seconds=[self.expiracyDate timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970] - 20;
        retries=0;
        [self performSelector:@selector(downloadToken) withObject:nil afterDelay:seconds];
    }
    //Do not have to reschedule, I did that before
}

- (BOOL) isTokenValid
{
    if ((self.token!=nil) && ([self.expiracyDate compare:[NSDate date]]==NSOrderedDescending))
        return YES;
    else
        return NO;
}

- (void) connectionFailedWithError:(NSError *) error
{
    //I handle everything in getToken, do not have to do anything here
}

- (void) giveWarning
{
    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Problem with the translation service!", @"Problem with the translation service!")
                                                    message:NSLocalizedString(@"Please, try again in some minutes", @"Please, try again in some minutes") 
                                                   delegate:nil 
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK") 
                                          otherButtonTitles: nil];
    [alert show];
}

#pragma mark -
#pragma mark Memoria


@end
