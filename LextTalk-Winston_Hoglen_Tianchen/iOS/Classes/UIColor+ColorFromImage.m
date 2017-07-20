//
//  UIColor+ColorFromImage.m
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 7/2/13.
//
//

#import "UIColor+ColorFromImage.h"

@implementation UIColor (ColorFromImage)

+ (UIColor *) colorFromImage:(UIImage *) image
{
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    //int pixelInfo = ((image.size.width  * y) + x ) * 4; // The image is png
    NSInteger y = image.size.height / 2;
    NSInteger x = image.size.width / 2;
    if (image.size.width>0 && image.size.height>1)
    {
        int pixelInfo = ((image.size.width  * y) + x ) * 4; // The image is png
        
        UInt8 red = data[pixelInfo];         // If you need this info, enable it
        UInt8 green = data[(pixelInfo + 1)]; // If you need this info, enable it
        UInt8 blue = data[pixelInfo + 2];    // If you need this info, enable it
        UInt8 alpha = data[pixelInfo + 3];     // I need only this info for my maze game
        CFRelease(pixelData);
        
        return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha/255.0f]; // The pixel color info
    }
    else
        return nil;
}

+ (UIColor *) colorFromBottomPixelFromImage:(UIImage *) image
{
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    //int pixelInfo = ((image.size.width  * y) + x ) * 4; // The image is png
    NSInteger y = image.size.height-1;
    NSInteger x = image.size.width / 2;
    if (image.size.width>0 && image.size.height>1)
    {
        int pixelInfo = ((image.size.width  * y) + x ) * 4; // The image is png
        
        UInt8 red = data[pixelInfo];         // If you need this info, enable it
        UInt8 green = data[(pixelInfo + 1)]; // If you need this info, enable it
        UInt8 blue = data[pixelInfo + 2];    // If you need this info, enable it
        UInt8 alpha = data[pixelInfo + 3];     // I need only this info for my maze game
        CFRelease(pixelData);
        
        return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha/255.0f]; // The pixel color info
    }
    else
        return nil;
}

@end
