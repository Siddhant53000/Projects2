//
//  FormViewController.m
// LextTalk
//
//  Created by David on 12/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FormViewController2.h"
#import "LextTalkAppDelegate.h"

#define TOOLBAT_HEIGHT_IPHONE		32
#define TOOLBAT_HEIGHT_IPAD			44

@implementation FormViewController2
@synthesize keyboardToolbar = _keyboardToolbar;

#pragma mark --
#pragma mark FormViewController methods

- (BOOL) shouldShowButtonBar {
    // Override in subclass
    return YES;
}

#pragma mark -
#pragma mark UIView delegate methods

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	//[self.keyboardToolbar removeFromSuperview];
}

#pragma mark -
#pragma mark UIKeyboard notifications
- (void)keyboardWillShow:(NSNotification *)notification {
    //It is called also when it is being shown and a rotation is performed
	
    if( ![self shouldShowButtonBar] ) return;
    
	CGFloat keyboardHeight;
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {		
		keyboardHeight = TOOLBAT_HEIGHT_IPAD;
	} else {
		keyboardHeight = TOOLBAT_HEIGHT_IPHONE;
	}
	
	NSValue *v = [[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect kbBounds = [v CGRectValue];	
	LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
	
	if(self.keyboardToolbar == nil) {
		self.keyboardToolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, del.window.frame.size.width, keyboardHeight)];
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
		
		[self.keyboardToolbar setItems: [NSArray arrayWithObjects: control, flex, done, nil]];
        
	}
    
    kbBounds=[self.tabBarController.view convertRect:kbBounds fromView:nil];

    CGRect newFrame=CGRectMake(0, 0, kbBounds.size.width, keyboardHeight);
    newFrame.origin.y = del.window.frame.size.height;
	self.keyboardToolbar.frame=newFrame;
	
	[self.keyboardToolbar removeFromSuperview];
    [self.tabBarController.view addSubview:self.keyboardToolbar];
	
	[UIView beginAnimations: @"ShowToolbar" context: nil];
	[UIView setAnimationDuration: 0.30];	

    newFrame.origin.y=kbBounds.origin.y - keyboardHeight;

	self.keyboardToolbar.frame=newFrame;
    
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if( ![self shouldShowButtonBar] ) return;
    
	//IQVerbose(VERBOSE_DEBUG,@"keyboardDidHide");
	LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
	
	[UIView beginAnimations: @"HideToolbar" context: nil];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	CGRect newFrame = self.keyboardToolbar.frame;
	newFrame.origin.y = del.window.frame.size.height;
	[self.keyboardToolbar setFrame: newFrame];
	[UIView setAnimationDuration: 0.30];	
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark FormViewController

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
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	IQVerbose(VERBOSE_DEBUG,@"Registering %@ to receive keyboard notifications", [self class]);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];		
	[super viewWillAppear: animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	IQVerbose(VERBOSE_DEBUG,@"Unregistering %@ to stop receiving keyboard notifications", [self class]);	
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[[NSNotificationCenter defaultCenter] removeObserver: self];	
	[super viewWillDisappear: animated];
}

- (void)dealloc {
    self.keyboardToolbar = nil;
}

@end
