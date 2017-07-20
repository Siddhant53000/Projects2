//
//  ContactViewController.h
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 23/03/14.
//
//

#import <UIKit/UIKit.h>
#import "UserListViewController.h"

@interface ContactViewController : UserListViewController <UIAlertViewDelegate>
{
    BOOL reloading;
}

@end
