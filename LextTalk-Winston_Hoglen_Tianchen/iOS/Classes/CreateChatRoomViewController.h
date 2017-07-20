//
//  CreateChatRoomViewController.h
//  LextTalk
//
//  Created by Yo on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdInheritanceViewController.h"
#import "LanguageSelectorController.h"
#import "LTDataDelegate.h"

@protocol CreateChatRoomViewControllerDelegate <NSObject>
@optional

- (void) chatroomCreated;

@end

@interface CreateChatRoomViewController : AdInheritanceViewController <LanguageSelectorControllerDelegate, UITextFieldDelegate, LTDataDelegate>
{
    LanguageSelectorController * languageSelectorController;
    UITextField * textField;
    NSString * lang;
    
    id<CreateChatRoomViewControllerDelegate> __weak delegate;
}

@property (nonatomic, strong) UITableView * myTableView;
@property (nonatomic, strong) LanguageSelectorController * languageSelectorController;
@property (nonatomic, strong) UITextField * textField;
@property (nonatomic, strong) NSString * lang;
@property (nonatomic, weak) id<CreateChatRoomViewControllerDelegate> delegate;


@end