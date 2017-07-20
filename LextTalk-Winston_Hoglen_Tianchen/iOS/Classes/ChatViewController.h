//
//  ChatViewController.h
// LextTalk
//
//  Created by David on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdInheritanceViewController.h"
#import "LTDataSource.h"
#import "LTChat.h"
#import "LTUser.h"
#import "IQKit.h"
#import "UICopyTextView.h"
#import "BingTranslator.h"
#import "MBProgressHUD.h"

@interface ChatViewController : AdInheritanceViewController < UITableViewDelegate, UITableViewDataSource, IQLocalizableProtocol, LTDataDelegate, UITextViewDelegate, UIPopoverControllerDelegate, BingTranslatorProtocol, UIAlertViewDelegate>{
    
	LTChat      *_chat;
	NSInteger    _userId;
    
    IBOutlet UICopyTextView * messageTextView;
    IBOutlet UIButton * sendButton;
    IBOutlet UIActivityIndicatorView * _indicatorView;
    IBOutlet UIView * backgroundView;
    UIView * backgroundView2;
    
    NSString * textToChat;
    
    //Button to load more messages
    NSInteger messagesShown;
    NSInteger loadMoreButtonPressedCount;
    BOOL showLoadMoreButton;
    
    //Handle rotation
    NSArray * visibleIndexPaths;
    BOOL visible;
    
    BOOL isChatroom;
    
    UIPopoverController * popoverController;
}


@property (nonatomic, strong) LTChat *chat;
@property (nonatomic, assign) NSInteger userId;

@property (nonatomic, strong) UITableView *chatTableView;

@property (nonatomic, strong) IBOutlet UICopyTextView                * messageTextView;
@property (nonatomic, strong) IBOutlet UIButton            * sendButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView    *indicatorView;
@property (nonatomic, strong) IBOutlet UIButton                   *dismissButton;
@property (nonatomic, strong) IBOutlet UIView * backgroundView;
@property (nonatomic, strong) UIView * backgroundView2;
@property (nonatomic, strong) NSString * textToChat;
@property (nonatomic, strong) NSArray * visibleIndexPaths;
@property (nonatomic, strong) NSMutableArray * language_name;
@property (nonatomic, strong) NSString *translation;
@property (nonatomic,strong) NSString *before;
@property (readonly) BOOL visible;

//Translation in chat
@property (nonatomic) NSInteger messageToTranslateId;
@property (nonatomic, strong) NSString * messageToTranslateText;
@property (nonatomic, strong) MBProgressHUD * HUD;
@property (nonatomic, strong) BingTranslator * bingTranslator;

@property (nonatomic) BOOL isChatroom;

// Added in from merge between Winston_Hoglen and Tianchen
//picker

@property (weak, nonatomic)IBOutlet UIPickerView *singlePicker;
@property (strong, nonatomic) NSArray *languageArray;
@property (weak,nonatomic) NSString *clientID;
@property (weak,nonatomic) NSString *clientSecret;
@property (weak,nonatomic) NSString *from;



@property (nonatomic, strong) UIPopoverController * popoverController;

- (IBAction) sendMessage;
- (IBAction) dismissKeyboard;
- (void) messagesDelivered;
- (void) updateChatViewController;

@end
