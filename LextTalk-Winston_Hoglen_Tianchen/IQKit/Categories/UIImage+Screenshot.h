//
//  UIImage+Screenshot.h
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

@interface UIImage (Screenshot)
+ (UIImage *) screenshotOfWindow: (UIWindow*) window;
+ (UIImage *) screenshotOfWindow: (UIWindow*) window withCropRect: (CGRect) rect;
@end
