//
//  IQMessageComposerViewController.m
//
//  Created by David on 1/12/11.
//  Copyright 2011 InQBarna. All rights reserved.
//
#import "IQVerbose.h"
#import "IQMessageComposerViewController.h"

#define MAX_MESSAGE_TEXT_LENGTH 149

@implementation IQMessageComposerViewController

#pragma mark -
#pragma mark SkinProtocol methods

- (void) applySkin:(IQSkin *)skin {
	if(!skin.active) return;

	[keyboardToolbar setTintColor: skin.tabBarColor];
}


#pragma mark -
#pragma mark UIKeyboard notifications
- (void)keyboardDidShow:(NSNotification *)notification {
	
	NSValue *v = [[notification userInfo] valueForKey:UIKeyboardBoundsUserInfoKey];
	CGRect kbBounds = [v CGRectValue];
	
	[UIView beginAnimations: @"ScrollUp" context: nil];
	[UIView setAnimationDuration: 0.30];	
	CGRect newFrame = self.view.frame;
	CGPoint p = [self.view.superview convertPoint:self.view.frame.origin toView:nil];
	newFrame.origin.y -= kbBounds.size.height - ([[UIApplication sharedApplication] keyWindow].frame.size.height - (p.y + self.view.frame.size.height));	
	[self.view setFrame: newFrame];
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	
	[UIView beginAnimations: @"ScrollDown" context: nil];
	[UIView setAnimationDelegate: self];
	CGRect newFrame = self.view.frame;
	newFrame.origin.y = 0;
	[self.view setFrame: newFrame];
	[UIView setAnimationDuration: 0.40];	
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *) theTextField { 
	[self sendMessage];
	return NO;
}

- (BOOL)textField:(UITextField *) theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if([theTextField.text length] < MAX_MESSAGE_TEXT_LENGTH) return YES;
	if(range.length == 1) return YES;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Too long" 
													message: [NSString stringWithFormat: @"Messages are limited to %d characters", MAX_MESSAGE_TEXT_LENGTH]
												   delegate: nil 
										  cancelButtonTitle: @"Close" 
										  otherButtonTitles: nil];
	[alert show];

	return NO;	
}

#pragma mark -
#pragma mark IQMessageComposerViewController methods

- (IBAction) sendMessage {
	[textField resignFirstResponder];
	// override in subclasses
}

- (IBAction) cancelMessage {
	textField.text = @"";
	[textField resignFirstResponder];
}

- (void) setPlaceholder: (NSString*) text {
	[textField setPlaceholder: text];
}

- (void) setSendTitle: (NSString*) text {
	[sendButton setTitle: text];
}
#pragma mark -
#pragma mark UIViewController methods

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

- (void) viewDidLoad {
	[self applySkin: [IQSkin defaultSkin]];
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	IQVerbose(VERBOSE_ERROR,@"[%@] Registering to receive keyboard notifications", [self class]);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];		
	[super viewWillAppear: animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	IQVerbose(VERBOSE_ERROR,@"[%@] Unregistering to stop receiving keyboard notifications", [self class]);	
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[[NSNotificationCenter defaultCenter] removeObserver: self];	
	[super viewWillDisappear: animated];
}	

@end

