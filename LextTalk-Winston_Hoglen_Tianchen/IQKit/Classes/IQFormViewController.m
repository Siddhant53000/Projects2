//
//  IQFormViewController.m
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//
#import "IQVerbose.h"
#import "IQFormViewController.h"

#define TOOLBAT_HEIGHT_IPHONE		32
#define TOOLBAT_HEIGHT_IPAD			44

@implementation IQFormViewController
@synthesize keyboardToolbar = _keyboardToolbar;
@synthesize fields = _fields;

#pragma mark -
#pragma mark UIView Touches Methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	for(UIControl *control in self.fields) {
		if([control isFirstResponder]) {
			[self hideKeyboard];
			return;
		}
	}	
}

#pragma mark -
#pragma mark UITextViewDelegate methods

- (void) textViewDidBeginEditing:(UITextView *)textView {
	
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {	
        // no scroll needed in iPad
        return;
    }
    
	CGPoint newOrigin = textView.frame.origin;
    newOrigin.x = 0;
    newOrigin.y -= 20;    
	[scrollView setContentOffset: newOrigin animated: YES];    
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {	
        // no scroll needed in iPad
        return;
    }
    
	CGPoint newOrigin = textField.frame.origin;
    newOrigin.x = 0;
    newOrigin.y -= 30;    
	[scrollView setContentOffset: newOrigin animated: YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField { 
    
	for(int i = 0;i<[self.fields count];i++) {
		UIControl *control = [self.fields objectAtIndex: i];
		if(textField == control) {
			int index = (i+1) % [self.fields count];
			UIControl *newControl = [self.fields objectAtIndex: index];
			[newControl becomeFirstResponder];
			return NO;
		}
	}
	return NO;
}

#pragma mark -
#pragma mark IQFormViewController methods

- (BOOL) shouldShowButtonBar {
	
	if( self.fields == nil) return NO;
	
	for(UIControl *control in self.fields) {
		if([control isFirstResponder]) return YES;
	}
    return NO;
}

- (void) hideKeyboard {
	if( self.fields == nil) return;
	
	for(UIControl *control in self.fields) {
		if([control isFirstResponder]) {
			[control resignFirstResponder];
		}
	}	
	
	// reset scroll offset
	[scrollView setContentOffset: CGPointMake(0,0) animated: YES];	
}

- (void) nextField {
	if( self.fields == nil) return;
	
	for(int i=0;i<[self.fields count];i++) {
		UIControl *control = (UIControl*) [self.fields objectAtIndex: i];
		if([control isFirstResponder]) {
			int next = (i+1) % [self.fields count];
			UIControl *nextControl = (UIControl*) [self.fields objectAtIndex: next];
			[nextControl becomeFirstResponder];
			break;
		}
	}
}

- (void) previousField {
	if( self.fields == nil) return;
	
	for(int i=0;i<[self.fields count];i++) {
		UIControl *control = (UIControl*) [self.fields objectAtIndex: i];
		if([control isFirstResponder]) {
			int next = (i-1) % [self.fields count];
			UIControl *nextControl = (UIControl*) [self.fields objectAtIndex: next];
			[nextControl becomeFirstResponder];
			break;
		}
	}
}

#pragma mark -
#pragma mark UIView delegate methods

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[self.keyboardToolbar removeFromSuperview];
}

#pragma mark -
#pragma mark UIKeyboard notifications
- (void)keyboardWillShow:(NSNotification *)notification {
	
	if( ![self shouldShowButtonBar] ) return;	
	
	CGFloat keyboardHeight;
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {		
		keyboardHeight = TOOLBAT_HEIGHT_IPAD;
	} else {
		keyboardHeight = TOOLBAT_HEIGHT_IPHONE;
	}
	
	NSValue *v = [[notification userInfo] valueForKey:UIKeyboardBoundsUserInfoKey];
	CGRect kbBounds = [v CGRectValue];	
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	
	if(self.keyboardToolbar == nil) {
		self.keyboardToolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, window.frame.size.width, keyboardHeight)];
		self.keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
		
		UISegmentedControl *segment = [[UISegmentedControl alloc] init];
//		[segment setSegmentedControlStyle: UISegmentedControlStyleBar];
		[segment insertSegmentWithTitle: @"Previous" atIndex: 0 animated: NO];
		[segment insertSegmentWithTitle: @"Next" atIndex: 1 animated: NO];
		[segment setMomentary: YES];
		[segment addTarget: self action: @selector(segmentChanged:) forControlEvents: UIControlEventValueChanged];
		
		UIBarButtonItem *control = [[UIBarButtonItem alloc] initWithCustomView: segment];
		[segment sizeToFit];
		
		UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle: @"Done" 
																 style: UIBarButtonItemStyleDone 
																target: self 
																action: @selector(hideKeyboard)];
		
		UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace 
																			  target: nil 
																			  action: nil];
		
		NSArray *items = [[NSArray alloc] initWithObjects: control, flex, done, nil];		
		[self.keyboardToolbar setItems:items];
	}
	
	
	CGRect newFrame = self.keyboardToolbar.frame;
	newFrame.origin.y = window.frame.size.height;
	[self.keyboardToolbar setFrame: newFrame];
	
	[self.keyboardToolbar removeFromSuperview];
	[window addSubview: self.keyboardToolbar];
	
	[UIView beginAnimations: @"ShowToolbar" context: nil];
	[UIView setAnimationDuration: 0.30];	
	newFrame = self.keyboardToolbar.frame;
	newFrame.origin.y = window.frame.size.height-kbBounds.size.height - keyboardHeight;
	[self.keyboardToolbar setFrame: newFrame];
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	IQVerbose(VERBOSE_ALL,@"[%@] keyboardDidHide", [self class]);
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	
	[UIView beginAnimations: @"HideToolbar" context: nil];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	CGRect newFrame = self.keyboardToolbar.frame;
	newFrame.origin.y = window.frame.size.height;
	[self.keyboardToolbar setFrame: newFrame];
	[UIView setAnimationDuration: 0.30];	
	[UIView commitAnimations];
}

#pragma mark --
#pragma mark IQFormViewController methods

- (void) segmentChanged: (id) sender {
	UISegmentedControl *segment = (UISegmentedControl*) sender;
	switch( segment.selectedSegmentIndex ) {
		case 0: [self performSelector: @selector(previousField)]; break;
		case 1: [self performSelector: @selector(nextField)]; break;
	}
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


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	[contentView setBackgroundColor: [UIColor clearColor]];
    [scrollView addSubview: contentView];
    [scrollView setContentSize: [contentView sizeThatFits: CGSizeZero]];	
	
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	IQVerbose(VERBOSE_DEBUG,@"[%@] Registering to receive keyboard notifications", [self class]);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];		
	[super viewWillAppear: animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	IQVerbose(VERBOSE_ALL,@"[%@] Unregistering to stop receiving keyboard notifications", [self class]);	
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[[NSNotificationCenter defaultCenter] removeObserver: self];	
	[super viewWillDisappear: animated];
}	

- (void)dealloc {
    self.keyboardToolbar = nil;
    self.fields = nil;
}

@end
