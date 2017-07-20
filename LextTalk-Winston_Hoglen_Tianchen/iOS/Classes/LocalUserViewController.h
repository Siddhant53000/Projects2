//
//  LocalUserViewController.h
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 4/28/13.
//
//

#import "AdInheritanceViewController.h"
#import "LTDataDelegate.h"
#import "LTUser.h"
#import "LanguageSelectorViewController.h"
#import "LangView.h"
#import <MapKit/MapKit.h>
#import "ConfigurationViewController.h"
#import "TutViewController.h"


@protocol PushControllerProtocol<NSObject>
@optional

- (void) pushController:(UIViewController *) controller;

@end

@interface LocalUserViewController : AdInheritanceViewController <LTDataDelegate, UITextFieldDelegate, UITextViewDelegate, LanguageSelectorViewControllerDelegate, LangViewDelegate, /*UIImagePickerControllerDelegate,*/ UINavigationControllerDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate>


@property (nonatomic, strong) LTUser * user;

@property (nonatomic, weak) id<PushControllerProtocol> delegate;


- (void) customizeForUser;

@end
