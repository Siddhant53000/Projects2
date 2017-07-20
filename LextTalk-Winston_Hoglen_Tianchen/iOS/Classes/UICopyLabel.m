//
//  UICopyLabel.m
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 2/10/13.
//
//

#import "UICopyLabel.h"

@interface UICopyLabel ()

@end

@implementation UICopyLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUserInteractionEnabled:YES];
        
        UILongPressGestureRecognizer * longPress=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        //longPress.numberOfTapsRequired=1;
        //longPress.numberOfTouchesRequired=1;
        longPress.minimumPressDuration=0.5;
        longPress.delaysTouchesBegan=YES;
        [self addGestureRecognizer:longPress];
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

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:))
        return YES;
    else if (action == @selector(translate:))
        return YES;
    else
        return [super canPerformAction:action withSender:sender];
}

- (BOOL) canBecomeFirstResponder
{
    return YES;
}

- (void) longPress:(UILongPressGestureRecognizer *) longPress
{
    if (longPress.state==UIGestureRecognizerStateBegan)
	{
        NSDictionary * dic=[NSDictionary dictionaryWithObject:[NSValue valueWithPointer:(__bridge const void *)(self)] forKey:@"copyLabel"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowUIMenuController" object:self userInfo:dic];
        /*
        [self becomeFirstResponder];
        [[UIMenuController sharedMenuController] setTargetRect:self.bounds inView:self];
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
         */
	}
}

//Selectors for the menus

- (void) copy:(id)sender
{
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    [board setString:self.text];
    
    //[self resignFirstResponder];
}

- (void) translate:(id)sender
{
    //Busco el boton y lo presiono
    UIView * view=[[self superview] superview];
    UIButton * button=(UIButton *)[view viewWithTag:333];
    [button sendActionsForControlEvents:UIControlEventTouchUpInside];
}



@end
