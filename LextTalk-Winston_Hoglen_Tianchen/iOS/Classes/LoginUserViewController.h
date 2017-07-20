//
//  LoginUserViewController.h
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 7/13/13.
//
//

#import <UIKit/UIKit.h>
#import "AdInheritanceViewController.h"
#import "ModalSignInViewController.h"
#import "ConfigurationViewController.h"

@interface LoginUserViewController : AdInheritanceViewController <ModalSignInViewControllerDelegate, UIPopoverControllerDelegate>

@end
