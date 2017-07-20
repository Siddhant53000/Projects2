//
//  CaptureLocationView.m
// LextTalk
//
//  Created by nacho on 11/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CaptureLocationView.h"
#import <CoreLocation/CoreLocation.h>

@implementation CaptureLocationView
@synthesize delegate = _delegate;

#pragma mark -
#pragma mark UIView methods

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
	[self.delegate didTouchAt: point withEvent: event];
    return [super hitTest:point withEvent:event];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/



@end
