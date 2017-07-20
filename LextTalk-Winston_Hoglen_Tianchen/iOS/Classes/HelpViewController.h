//
//  HelpViewController.h
// LextTalk
//
//  Created by David on 10/07/10.
//  Copyright 2010 inqbarna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface HelpViewController : UIViewController <MFMailComposeViewControllerDelegate, UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
}

@end
