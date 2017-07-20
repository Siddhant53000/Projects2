//
//  UIViewWithGradient.m
//  LextTalk
//
//  Created by Yo on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIViewWithGradient.h"
#import "QuartzCore/QuartzCore.h"

@implementation UIViewWithGradient

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+(Class) layerClass {
    return [CAGradientLayer class];
}

@end
