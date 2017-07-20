//
//  ImageCache.m
//  LextTalk
//
//  Created by Yo on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageCache.h"
#import "LanguageReference.h"

@interface ImageCache()

@property (atomic, strong) NSMutableDictionary * smallDic;
@property (atomic, strong) NSMutableDictionary * bigDic;

@end

@implementation ImageCache
@synthesize smallDic, bigDic;

- (id) init
{
    self=[super init];
    if (self)
    {
        smallDic=[[NSMutableDictionary alloc] initWithCapacity:5];
        bigDic=[[NSMutableDictionary alloc] initWithCapacity:5];
    }
    
    return self;
}


- (UIImage *) getImage:(NSString *) imageName withBigSize:(BOOL)big
{
    if (big)
        return [self.bigDic objectForKey:imageName];
    else
        return [self.smallDic objectForKey:imageName];
}

- (void) putImage:(UIImage *) image forName:(NSString *) imageName withBigSize:(BOOL)big
{
    if (big)
        [self.bigDic setObject:image forKey:imageName];
    else
        [self.smallDic setObject:image forKey:imageName];
}

- (void) fillInCache
{
    dispatch_queue_t queue0=dispatch_queue_create("FillInCache", NULL);
    dispatch_async(queue0, ^{
        //langs for english and master langs are the same, I can do this this way
        NSArray * langArray=[LanguageReference availableLangsForAppLan:@"English"];
        NSInteger counter;
        NSString * imageName;
        UIImage * smallImage, * bigImage, * image;
        CGRect smallRect=CGRectMake(0, 0, 30, 20);
        CGRect bigRect=CGRectMake(0, 0, 45, 30);
        for (NSString * language in langArray)
        {
            counter=0;
            NSArray * flagArray=[LanguageReference flagsForMasterLan:language];
            for (NSData * imageData in flagArray)
            {
                imageName=[language stringByAppendingFormat:@"-%ld", (long)counter];
                counter++;
                
                image=[UIImage imageWithData:imageData];
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 20), NO, [UIScreen mainScreen].scale);
                [image drawInRect:smallRect];
                smallImage=UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [self putImage:smallImage forName:imageName withBigSize:NO];
                
                
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(45, 30), NO, [UIScreen mainScreen].scale);
                [image drawInRect:bigRect];
                bigImage=UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [self putImage:bigImage forName:imageName withBigSize:YES];
            }
        }
        /*
        dispatch_queue_t mainQueue=dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            NSLog(@"Finsished caching");
        });
         */
    });
}

@end
