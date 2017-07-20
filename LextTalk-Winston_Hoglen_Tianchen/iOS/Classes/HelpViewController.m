//
//  HelpViewController.m
// LextTalk
//
//  Created by David on 10/07/10.
//  Copyright 2010 inqbarna. All rights reserved.
//

#import "HelpViewController.h"
#import "IQKit.h"
#import "GeneralHelper.h"

@implementation HelpViewController

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate methods
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark HelpViewController methods

- (void) sendMailToSupport {
	// CREATING MAIL VIEW
	MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	[controller.navigationBar setBarStyle: UIBarStyleBlack];
	controller.mailComposeDelegate = self;
	[controller setToRecipients: [NSArray arrayWithObject: @"info@lext-talk.com"]];
	
    [self presentViewController:controller animated:YES completion:nil];
}
#pragma mark -
#pragma mark UIViewController methods
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	[self.navigationController setNavigationBarHidden: NO animated: NO];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle: NSLocalizedString(@"LextTalk Help", @"LextTalk Help")];
    
    NSString *resourceName;
    NSString *path;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        resourceName = @"Help";
    else
        resourceName = @"Help2";
        
    path = [[NSBundle mainBundle] pathForResource:resourceName
                                           ofType:@"html"];
    
    if (!path) {
        path = [[NSBundle mainBundle] pathForResource:resourceName
                                               ofType:@"html"
                                          inDirectory:@"en.lproj"
                                      forLocalization:@"en"];
    }
    
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
    self.navigationItem.leftBarButtonItem = [GeneralHelper plainBarButtonItemWithText:nil image:[UIImage imageNamed:@"arrow-back"] target:self selector:@selector(popViewController)];
}

- (void) popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark UIWebViewDelegate methods

- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error {
	IQVerbose(VERBOSE_DEBUG,@"[HelpViewController] didFailLoadWithError: %@", [error description]);
    [activityIndicator stopAnimating];
}

- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	IQVerbose(VERBOSE_DEBUG,@"[HelpViewController] shouldStartLoadWithRequest: %@", [request.URL absoluteString]);
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        if( [[request.URL absoluteString] rangeOfString:@"Help.html"].location != NSNotFound ) {
            return YES;
        }
    }
    else
    {
        if( [[request.URL absoluteString] rangeOfString:@"Help2.html"].location != NSNotFound ) {
            return YES;
        }
    }
    
 	if( [[request.URL absoluteString] rangeOfString:@"info@lext-talk.com"].location != NSNotFound ) {
		
		if ( ![MFMailComposeViewController canSendMail] ) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Cannot compose an email", @"Cannot compose an email")
															message: NSLocalizedString(@"Your mail account is not configured", @"Your mail account is not configured")
														   delegate: nil 
												  cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
												  otherButtonTitles: nil];
			
			[alert show];
			return NO;
		}		
		
		[self sendMailToSupport];
		return NO;
	}
	
    [[UIApplication sharedApplication] openURL: [request URL]];
	return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
	IQVerbose(VERBOSE_DEBUG,@"[HelpViewController] webViewDidFinishLoad: %@", [[theWebView request].URL absoluteString]);
    [activityIndicator stopAnimating];    
}

- (void)webViewDidStartLoad:(UIWebView *)theWebView {
	IQVerbose(VERBOSE_DEBUG,@"[HelpViewController] webViewDidStartLoad: %@", [[theWebView request].URL absoluteString]);
    [activityIndicator startAnimating];    
}

@end
