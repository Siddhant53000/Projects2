//
//  GeneralHelper.m
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 7/11/13.
//
//

#import "GeneralHelper.h"
//#import <QuartzCore/QuartzCore.h>

@implementation GeneralHelper

+ (void) setTitleInNavigationBarForController:(UIViewController *) controller
{
    UILabel * label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"Ubuntu-Bold" size:20];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = controller.title;
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    /*
    label.layer.shadowColor=[[UIColor blackColor] CGColor];
    label.layer.shadowOpacity = 0.5;
    label.layer.shadowRadius = 1;
    label.layer.shadowOffset = CGSizeMake(0, 1);
    */
    CGSize adjustedSize = [controller.title sizeWithAttributes:@{NSFontAttributeName:label.font}];
    CGSize size = CGSizeMake(ceilf(adjustedSize.width), ceilf(adjustedSize.height));
    label.frame = CGRectMake(0, 0, size.width, size.height);
    
    
    controller.navigationItem.titleView = label;
}

+ (void) setTitleTextAttributesForController:(UIViewController *) controller
{
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIFont fontWithName:@"Ubuntu-Bold" size:20], NSFontAttributeName,
                          [UIColor whiteColor], NSForegroundColorAttributeName,
                          shadow, NSShadowAttributeName, nil];
    
    controller.navigationController.navigationBar.titleTextAttributes = dic;
}

+ (UIBarButtonItem *) plainBarButtonItemWithText:(NSString *) text image:(UIImage *) image target:(id) target selector:(SEL) sel
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (image != nil)
        [button setImage:image forState:UIControlStateNormal];
    if (text != nil)
    {
        [button setTitle:text forState:UIControlStateNormal];
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
            button.titleLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:14];
        else
            button.titleLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:15];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        //button.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
    }
    [button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    button.showsTouchWhenHighlighted = YES;
    
    //I do sizeThatFits and add set: the height to 32
    // - The height to 32, maximum height in landscape iPhone, should be fine for other devices / orientations
    // - The width to width + 16 in order to have some margin to the edge of the screen
    [button sizeToFit];
    CGSize size = button.bounds.size;
    size.height = 32.0;
    size.width += 16;
    button.frame = CGRectMake(0, 0, size.width, size.height);
    
    
    UIBarButtonItem * buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return buttonItem;
}

+ (UIImage *) centralSquareFromImage:(UIImage *) image
{
    CGSize size = image.size;
    //If it is already square, avoid resizing (allow for a difference of 5 pixels)
    if (fabs(size.width - size.height) < 5.0)
        return image;
    
    size.width *= image.scale;
    size.height *= image.scale;
    CGRect bounds = CGRectMake(0, 0, 0, 0);
    
    if (size.width > size.height)
    {
        bounds.size.height = size.height;
        bounds.size.width = size.height;
        bounds.origin.x = fabs((size.width - size.height)) / 2.0;
        bounds.origin.y = 0;
    }
    else
    {
        bounds.size.height = size.width;
        bounds.size.width = size.width;
        bounds.origin.x = 0;
        bounds.origin.y = (fabs(size.height - size.width)) / 2.0;
    }

    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

@end
