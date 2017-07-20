//
//  CaptureLocationView.h
// LextTalk
//
//  Created by nacho on 11/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CaptureLocationDelegate
@required
- (void) didTouchAt:(CGPoint)point withEvent:(UIEvent *)event;
@end

@interface CaptureLocationView : UIView {
    id <CaptureLocationDelegate> __weak _delegate;
}
@property (nonatomic, weak) id <CaptureLocationDelegate> delegate;
@end
