//
//  IQMessageComposerViewController.h
//
//  Created by David on 1/12/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQKit.h"

@interface IQMessageComposerViewController : UIViewController <IQSkinProtocol> {
	IBOutlet UIToolbar					*keyboardToolbar;
	IBOutlet UITextField				*textField;
	IBOutlet UIBarButtonItem			*sendButton;
}

- (IBAction) sendMessage;
- (IBAction) cancelMessage;
- (void) setPlaceholder: (NSString*) text;
- (void) setSendTitle: (NSString*) text;

@end
