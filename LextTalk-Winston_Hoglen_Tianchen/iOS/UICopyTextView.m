//
//  UICopyTextView.m
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 2/10/13.
//
//

#import "UICopyTextView.h"

@interface UICopyTextView ()

@property (nonatomic, strong) UICopyLabel *copiedLabel;

@end

@implementation UICopyTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUIMenuController:) name:@"ShowUIMenuController" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuControllerDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (self)
    {
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUIMenuController:) name:@"ShowUIMenuController" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuControllerDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) showUIMenuController:(NSNotification *) not
{
    NSDictionary * dic=[not userInfo];
    self.copiedLabel=(__bridge UICopyLabel *)([[dic objectForKey:@"copyLabel"] pointerValue]);
    
    if (![self isFirstResponder])
        [self.copiedLabel becomeFirstResponder];
    
    if (self.copiedLabel.showTranslate)
    {
        UIMenuItem * item=[[UIMenuItem alloc]initWithTitle:NSLocalizedString(@"Translate", nil) action:@selector(translate:)];
        [UIMenuController sharedMenuController].menuItems=[NSArray arrayWithObject:item];
    }
    else
        [UIMenuController sharedMenuController].menuItems=nil;
    
    [[UIMenuController sharedMenuController] setTargetRect:self.copiedLabel.bounds inView:self.copiedLabel];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
}

- (void) menuControllerDidHide:(NSNotification *) not
{
    self.copiedLabel=nil;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    if (self.copiedLabel!=nil)
    {
        if(action == @selector(copy:))
            return YES;
        else if(action == @selector(translate:))
            return YES;
        else
            return NO;
    }
    else {
        return [super canPerformAction:action withSender:sender];
    }
}


//Selectors for the menus
- (void) copy:(id)sender
{
    if (self.copiedLabel!=nil)
    {
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
        
        UIPasteboard *board = [UIPasteboard generalPasteboard];
        [board setString:self.copiedLabel.text];
    }
    else
        [super copy:sender];
}

- (void) translate:(id)sender
{
    [self.copiedLabel translate:sender];
}

@end
