//
//  UIColor+ColorFromImage.h
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 7/2/13.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (ColorFromImage)

+ (UIColor *) colorFromImage:(UIImage *) image;
+ (UIColor *) colorFromBottomPixelFromImage:(UIImage *) image;

@end
