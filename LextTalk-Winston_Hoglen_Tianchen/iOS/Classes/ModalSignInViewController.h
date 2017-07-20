//
//  ModalSignInViewController.h
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 4/26/13.
//
//

#import <UIKit/UIKit.h>
#import "LTDataSource.h"
#import "LTDataDelegate.h"

@protocol ModalSignInViewControllerDelegate <NSObject>
@optional

- (void) didCancelSignIn;
- (void) didSignIn;

@end

@interface ModalSignInViewController : UIViewController <UITextFieldDelegate, LTDataDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) BOOL signIn;
@property (nonatomic, weak) id<ModalSignInViewControllerDelegate> delegate;

@end
