//
//  FormViewController.h
// LextTalk
//
//  Created by David on 12/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdViewController2.h"

@protocol FormViewControllerProtocol
@required
- (void) hideKeyboard;
- (void) nextField;
- (void) previousField;
@optional
- (BOOL) shouldShowButtonBar;
@end


@interface FormViewController2 : AdViewController2 
{
	UIToolbar				*_keyboardToolbar;
}

@property (nonatomic, strong) UIToolbar *keyboardToolbar;
@end
