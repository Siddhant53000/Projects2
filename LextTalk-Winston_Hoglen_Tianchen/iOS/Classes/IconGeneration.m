//
//  IconGeneration.m
//  BingTranslatorClass
//
//  Created by Yo on 11/8/11.
//  Copyright (c) 2011 Freelance. All rights reserved.
//

#import "IconGeneration.h"
#import "LanguageReference.h"

static NSMutableDictionary * stdLanPairImageDic=nil;
static NSMutableDictionary * lanImageDic=nil;

@implementation IconGeneration

+ (UIImage *) stdIconForLearningLan:(NSString *) learningMasterLan
                           withFlag:(NSInteger) learningFlagId
                     andSpeakingLan:(NSString *)speakingMasterLan
                           withFlag:(NSInteger) speakingFlagId
                          writeText:(BOOL) writeText
                     withStatusDate:(NSDate *) date
{
    //Caching mechanism
    NSString * colorStr=@"nothing";
    if (date!=nil)
    {
        NSTimeInterval timeInterval= - [date timeIntervalSinceNow];
        if (timeInterval<3600*24)
            colorStr = @"green";
        else if ((timeInterval>=3600*24) && (timeInterval<=3600*24*7))
            colorStr = @"yellow";
    }
    NSString * key = [NSString stringWithFormat:@"%@-%ld-%@-%ld-%@", learningMasterLan, (long)learningFlagId, speakingMasterLan, (long)speakingFlagId, colorStr];
    if (key==nil)
    {
        if (writeText)
            key=@"noLan-text";
        else
            key=@"noLan-notext";
    }
    
    
    UIImage * composedImage = [stdLanPairImageDic objectForKey:key];
    
    if (!composedImage)
    {
        //NSLog(@"Generation image for key: %@", key);
        //Image generation, apart from loading the flags, I cut a square area of the center of each one
        UIImage * learningFlag, * speakingFlag;
        if (learningMasterLan)
        {
            learningFlag=[UIImage imageWithData:[LanguageReference flagForMasterLan:learningMasterLan andId:learningFlagId]];
            //Corto un cuadrado
            CGRect cropRect=CGRectMake((learningFlag.size.width - learningFlag.size.height) / 2.0, 0, learningFlag.size.height, learningFlag.size.height);
            CGImageRef imageRef = CGImageCreateWithImageInRect([learningFlag CGImage], cropRect);
            learningFlag = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
        else
            learningFlag=[UIImage imageNamed:@"white"];
        if (speakingMasterLan)
        {
            speakingFlag=[UIImage imageWithData:[LanguageReference flagForMasterLan:speakingMasterLan andId:speakingFlagId]];
            //Corto en una proporción 34 / 31
            CGRect cropRect=CGRectMake((speakingFlag.size.width - speakingFlag.size.height*34.0/31.0) / 2.0, 0, speakingFlag.size.height*34.0/31.0, speakingFlag.size.height);
            CGImageRef imageRef = CGImageCreateWithImageInRect([speakingFlag CGImage], cropRect);
            speakingFlag = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
        else
            speakingFlag=[UIImage imageNamed:@"white"];
        
        
        
        
        //Creo la imagen
        UIImage * icon=[UIImage imageNamed:@"flagsicon_filled"];
        CGSize iconSize=CGSizeMake(48, 30);
        CGRect imageRect = CGRectMake(0.0, 0.0, iconSize.width, iconSize.height);
        UIGraphicsBeginImageContextWithOptions(iconSize, NO, [UIScreen mainScreen].scale);
        [icon drawInRect:imageRect];
        
        CGRect flag1Rect=CGRectMake(7.5, 5, 14, 14);
        [learningFlag drawInRect:flag1Rect];
        
        //Speaking flag, with clipping
        CGRect flag2Rect=CGRectMake(26, 5, 17, 15.5);
        CGContextRef context = UIGraphicsGetCurrentContext(); //Save context before adding the bezierPath to the clipping
        CGContextSaveGState(context);
        //[[UIBezierPath bezierPathWithRoundedRect:flag2Rect cornerRadius:4] addClip];
        [[UIBezierPath bezierPathWithRoundedRect:flag2Rect byRoundingCorners:UIRectCornerBottomRight | UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(4, 4)] addClip];
        [speakingFlag drawInRect:flag2Rect];
        CGContextRestoreGState(context); //Restore, done with the clipping
        
        UIImage * icon2=[UIImage imageNamed:@"flagsicon_trans"];
        CGRect icon2Rect=CGRectMake(0, 0, 48, 30);
        [icon2 drawInRect:icon2Rect];
        
        
        //Write text if there are no languages
        if ((learningMasterLan==nil && writeText) || (speakingMasterLan==nil && writeText))
        {
            UIFont * font=[UIFont systemFontOfSize:7];
            NSString * text=NSLocalizedString(@"Sign in", @"Sign in");
            CGSize size = [text sizeWithAttributes:@{NSFontAttributeName: font}];
            CGSize textSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
            
            [text drawAtPoint:CGPointMake((48 - textSize.width)/2.0 + 2, (30 - textSize.height)/2.0 - 3) withAttributes:@{NSFontAttributeName: font}];
        }
        
        composedImage = UIGraphicsGetImageFromCurrentImageContext();  // UIImage returned
        UIGraphicsEndImageContext();
        
        
        //Activity
        UIColor * color = nil;
        if ([colorStr isEqualToString:@"green"])
            color = [UIColor greenColor];
        else if ([colorStr isEqualToString:@"yellow"])
            color = [UIColor yellowColor];
        
        if (color != nil)
        {
            CGFloat red, green, blue, alpha;
            [color getRed:&red green:&green blue:&blue alpha:&alpha];
            
            //Sobre la imagen lo dibujo
            CGSize iconSize=CGSizeMake(48, 30);
            CGRect imageRect = CGRectMake(0.0, 0.0, iconSize.width, iconSize.height);
            UIGraphicsBeginImageContextWithOptions(iconSize, NO, [UIScreen mainScreen].scale);
            [composedImage drawInRect:imageRect];
            
            CGContextRef contextRef = UIGraphicsGetCurrentContext();
            
            CGRect rect=CGRectMake(22, 1, 5, 5);
            
            CGContextSetRGBFillColor(contextRef, red, green, blue, 1.0);
            CGContextSetRGBStrokeColor(contextRef, 1.0, 1.0, 1.0, 1.0);
            
            // Draw a circle (filled)
            CGContextFillEllipseInRect(contextRef, rect);
            // Draw a circle (border only)
            CGContextStrokeEllipseInRect(contextRef, rect);
            
            composedImage = UIGraphicsGetImageFromCurrentImageContext();  // UIImage returned
            UIGraphicsEndImageContext();
        }
        
        //Caching mechanism
        if (stdLanPairImageDic==nil)
            stdLanPairImageDic=[[NSMutableDictionary alloc] init ];
        [stdLanPairImageDic setObject:composedImage forKey:key];
        
    }
    //else
    //    NSLog(@"Got from cache image for key: %@", key);

    return composedImage;
}




+ (UIImage *) bigIconForLearningLan:(NSString *)learningMasterLan withFlag:(NSInteger)learningFlagId
{
    UIImage * composedImage=nil;
    
    NSString * key = [NSString stringWithFormat:@"big-learning-%@-%ld", learningMasterLan, (long)learningFlagId];
    composedImage = [lanImageDic objectForKey:key];
    
    if (composedImage == nil)
    {
        //Image generation, apart from loading the flags, I cut a square area of the center of each one
        UIImage * learningFlag;
        if (learningMasterLan)
        {
            learningFlag=[UIImage imageWithData:[LanguageReference flagForMasterLan:learningMasterLan andId:learningFlagId]];
            ///Corto en una proporción 59 / 55
            CGRect cropRect=CGRectMake((learningFlag.size.width - learningFlag.size.height*59.0/56.0) / 2.0, 0, learningFlag.size.height*59.0/56.0, learningFlag.size.height);
            CGImageRef imageRef = CGImageCreateWithImageInRect([learningFlag CGImage], cropRect);
            learningFlag = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
        else
            learningFlag=[UIImage imageNamed:@"white"];
        
        //Imagen
        CGSize iconSize=CGSizeMake(38, 32);
        UIGraphicsBeginImageContextWithOptions(iconSize, NO, [UIScreen mainScreen].scale);
        
        CGRect learningFlagRect=CGRectMake(6.5, 1.5, 59.0/2, 56.0/2);
        [learningFlag drawInRect:learningFlagRect];
        
        CGRect imageRect = CGRectMake(0.0, 0.0, iconSize.width, iconSize.height);
        UIImage * icon=[UIImage imageNamed:@"flag-notebook"];
        [icon drawInRect:imageRect];
        
        composedImage = UIGraphicsGetImageFromCurrentImageContext();  // UIImage returned
        UIGraphicsEndImageContext();
        
        if (lanImageDic == nil)
            lanImageDic = [[NSMutableDictionary alloc] init];
        [lanImageDic setObject:composedImage forKey:key];
    }
    
    return composedImage;
}


+ (UIImage *) bigIconForSpeakingLan:(NSString *)speakingMasterLan withFlag:(NSInteger)speakingFlagId
{
    UIImage * composedImage=nil;
    
    NSString * key = [NSString stringWithFormat:@"big-speaking-%@-%ld", speakingMasterLan, (long)speakingFlagId];
    composedImage = [lanImageDic objectForKey:key];
    
    if (composedImage==nil)
    {
        //Image generation, apart from loading the flags, I cut a square area of the center of each one
        UIImage * speakingFlag;
        if (speakingMasterLan)
        {
            speakingFlag=[UIImage imageWithData:[LanguageReference flagForMasterLan:speakingMasterLan andId:speakingFlagId]];
            ///Corto en una proporción 59 / 55
            CGRect cropRect=CGRectMake((speakingFlag.size.width - speakingFlag.size.height*68.0/62.0) / 2.0, 0, speakingFlag.size.height*68.0/62.0, speakingFlag.size.height);
            CGImageRef imageRef = CGImageCreateWithImageInRect([speakingFlag CGImage], cropRect);
            speakingFlag = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
        else
            speakingFlag=[UIImage imageNamed:@"white"];
        
        //Imagen
        CGSize iconSize=CGSizeMake(38, 46);
        UIGraphicsBeginImageContextWithOptions(iconSize, NO, [UIScreen mainScreen].scale);
        
        CGRect imageRect = CGRectMake(0.0, 0.0, iconSize.width, iconSize.height);
        UIImage * icon=[UIImage imageNamed:@"flag-speaking"];
        [icon drawInRect:imageRect];
        
        CGRect speakingFlagRect=CGRectMake(2, 2, 68.0/2, 62.0/2);
        CGContextRef context = UIGraphicsGetCurrentContext(); //Save context before adding the bezierPath to the clipping
        CGContextSaveGState(context);
        [[UIBezierPath bezierPathWithRoundedRect:speakingFlagRect byRoundingCorners:UIRectCornerBottomRight | UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(8, 8)] addClip];
        [speakingFlag drawInRect:speakingFlagRect];
        CGContextRestoreGState(context); //Restore, done with the clipping
        
        composedImage = UIGraphicsGetImageFromCurrentImageContext();  // UIImage returned
        UIGraphicsEndImageContext();
        
        if (lanImageDic == nil)
            lanImageDic = [[NSMutableDictionary alloc] init];
        [lanImageDic setObject:composedImage forKey:key];
    }
    
    return composedImage;
}

+ (UIImage *) smallWithGlowIconForLearningLan:(NSString *)learningMasterLan withFlag:(NSInteger)learningFlagId
{
    UIImage * composedImage=nil;
    
    NSString * key = [NSString stringWithFormat:@"small-learning-%@-%ld", learningMasterLan, (long)learningFlagId];
    composedImage = [lanImageDic objectForKey:key];
    
    if (composedImage == nil)
    {
        //Image generation, apart from loading the flags, I cut a square area of the center of each one
        UIImage * learningFlag;
        if (learningMasterLan)
        {
            learningFlag=[UIImage imageWithData:[LanguageReference flagForMasterLan:learningMasterLan andId:learningFlagId]];
            ///Corto en una proporción 59 / 55
            CGRect cropRect=CGRectMake((learningFlag.size.width - learningFlag.size.height*48.0/45.0) / 2.0, 0, learningFlag.size.height*48.0/45.0, learningFlag.size.height);
            CGImageRef imageRef = CGImageCreateWithImageInRect([learningFlag CGImage], cropRect);
            learningFlag = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
        else
            learningFlag=[UIImage imageNamed:@"white"];
        
        //Imagen
        CGSize iconSize=CGSizeMake(39, 35);
        UIGraphicsBeginImageContextWithOptions(iconSize, NO, [UIScreen mainScreen].scale);
        
        CGRect learningFlagRect=CGRectMake(9, 6, 48.0/2, 45.0/2);
        [learningFlag drawInRect:learningFlagRect];
        
        CGRect imageRect = CGRectMake(0.0, 0.0, iconSize.width, iconSize.height);
        UIImage * icon=[UIImage imageNamed:@"flag-notebook-small-glow"];
        [icon drawInRect:imageRect];
        
        composedImage = UIGraphicsGetImageFromCurrentImageContext();  // UIImage returned
        UIGraphicsEndImageContext();
        
        if (lanImageDic == nil)
            lanImageDic = [[NSMutableDictionary alloc] init];
        [lanImageDic setObject:composedImage forKey:key];
    }
    
    return composedImage;
}


+ (UIImage *) smallWithGlowIconForSpeakingLan:(NSString *)speakingMasterLan withFlag:(NSInteger)speakingFlagId
{
    UIImage * composedImage=nil;
    
    NSString * key = [NSString stringWithFormat:@"small-speaking-%@-%ld", speakingMasterLan, (long)speakingFlagId];
    composedImage = [lanImageDic objectForKey:key];
    
    if (composedImage == nil)
    {
        //Image generation, apart from loading the flags, I cut a square area of the center of each one
        UIImage * speakingFlag;
        if (speakingMasterLan)
        {
            speakingFlag=[UIImage imageWithData:[LanguageReference flagForMasterLan:speakingMasterLan andId:speakingFlagId]];
            ///Corto en una proporción 59 / 55
            CGRect cropRect=CGRectMake((speakingFlag.size.width - speakingFlag.size.height*53.0/48.0) / 2.0, 0, speakingFlag.size.height*53.0/48.0, speakingFlag.size.height);
            CGImageRef imageRef = CGImageCreateWithImageInRect([speakingFlag CGImage], cropRect);
            speakingFlag = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
        else
            speakingFlag=[UIImage imageNamed:@"white"];
        
        //Imagen
        CGSize iconSize=CGSizeMake(39, 43);
        UIGraphicsBeginImageContextWithOptions(iconSize, NO, [UIScreen mainScreen].scale);
        
        CGRect imageRect = CGRectMake(0.0, 0.0, iconSize.width, iconSize.height);
        UIImage * icon=[UIImage imageNamed:@"flag-speaking-small-glow"];
        [icon drawInRect:imageRect];
        
        CGRect speakingFlagRect=CGRectMake(6.5, 6, 53.0/2, 48.0/2);
        CGContextRef context = UIGraphicsGetCurrentContext(); //Save context before adding the bezierPath to the clipping
        CGContextSaveGState(context);
        [[UIBezierPath bezierPathWithRoundedRect:speakingFlagRect byRoundingCorners:UIRectCornerBottomRight | UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(6, 6)] addClip];
        [speakingFlag drawInRect:speakingFlagRect];
        CGContextRestoreGState(context); //Restore, done with the clipping
        
        composedImage = UIGraphicsGetImageFromCurrentImageContext();  // UIImage returned
        UIGraphicsEndImageContext();
        
        if (lanImageDic == nil)
            lanImageDic = [[NSMutableDictionary alloc] init];
        [lanImageDic setObject:composedImage forKey:key];
    }
    
    return composedImage;
}


+ (UIImage *) activityImageForDate:(NSDate *) date
{
    if (date==nil)
        return nil;
    
    NSTimeInterval timeInterval= - [date timeIntervalSinceNow];
    //NSLog(@"Time interval: %f", timeInterval);
    if (timeInterval<3600*24)
        return [UIImage imageNamed:@"activity-green"];
    else if ((timeInterval>=3600*24) && (timeInterval<=3600*24*7))
        return [UIImage imageNamed:@"activity-yellow"];
    else
        return nil;
}

@end
