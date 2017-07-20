//
//  SearchChatRoomViewController.h
//  LextTalk
//
//  Created by Yo on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdInheritanceViewController.h"
#import "LanguageSelectorController.h"
#import "LanguageSelectorViewController.h"
#import "MBProgressHUD.h"
#import "LTDataSource.h"

@interface SearchChatRoomViewController : AdInheritanceViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, LanguageSelectorViewControllerDelegate, LanguageSelectorControllerDelegate, LTDataDelegate>
{
    UILabel * insLabel;
    UILabel * nameLabel;
    UITextField * textField;
    UIView * backgroundView;
    UILabel * langLabel;
    UIButton * button;
    
    NSString * lang;
    LanguageSelectorController * languageSelectorController;
    MBProgressHUD * HUD;
}

@property (nonatomic, strong) NSString * lang;

@end
