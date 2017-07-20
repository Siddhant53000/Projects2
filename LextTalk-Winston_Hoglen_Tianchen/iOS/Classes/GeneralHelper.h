//
//  GeneralHelper.h
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 7/11/13.
//
//

#import <Foundation/Foundation.h>

@interface GeneralHelper : NSObject

+ (void) setTitleInNavigationBarForController:(UIViewController *) controller;
+ (void) setTitleTextAttributesForController:(UIViewController *) controller;

+ (UIBarButtonItem *) plainBarButtonItemWithText:(NSString *) text image:(UIImage *) image target:(id) target selector:(SEL) sel;

+ (UIImage *) centralSquareFromImage:(UIImage *) image;

@end
