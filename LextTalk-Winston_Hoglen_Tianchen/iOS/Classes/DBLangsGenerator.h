//
//  DBLangsGenerator.h
//  LextTalk
//
//  Created by Yo on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BingTranslator.h"
#import "LanguageReference.h"

@interface DBLangsGenerator : NSObject <BingTranslatorProtocol>
{
    BingTranslator * bingTranslator;
    NSString * app_lan;
    NSMutableArray * translatedLangs;
    NSArray * masterLangs;
    
    NSInteger count;
}



@property (nonatomic, strong) BingTranslator * bingTranslator;
@property (nonatomic, strong) NSString * app_lan;
@property (nonatomic, strong) NSMutableArray * translatedLangs;
@property (nonatomic, strong) NSArray * masterLangs;

- (void) translateTo:(NSString *) lang withAppLan:(NSString *) app_lan2;

@end
