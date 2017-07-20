//
//  IQFormViewController.h
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface IQFormViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate> {
	IBOutlet UIScrollView	*scrollView;
	IBOutlet UIView			*contentView;
	
	UIToolbar				*_keyboardToolbar;
	NSArray					*_fields;
}

@property (nonatomic, strong) UIToolbar *keyboardToolbar;
@property (nonatomic, strong) NSArray *fields;

- (void) hideKeyboard;

@end
