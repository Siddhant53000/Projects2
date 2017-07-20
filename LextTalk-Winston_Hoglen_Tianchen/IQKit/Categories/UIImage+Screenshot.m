//
//  UIImage+Screenshot.h
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import "UIImage+Screenshot.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage (Screenshot)

+ (UIImage *) screenshotOfWindow: (UIWindow*) window withCropRect: (CGRect) rect {
	UIGraphicsBeginImageContext(window.bounds.size);
	[window.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
	
	image = [UIImage imageWithCGImage:imageRef]; 
	CGImageRelease(imageRef);	
	
	return image;		
}

+ (UIImage *) screenshotOfWindow: (UIWindow*) window {
	return [UIImage screenshotOfWindow: window withCropRect: window.frame];
}

@end
