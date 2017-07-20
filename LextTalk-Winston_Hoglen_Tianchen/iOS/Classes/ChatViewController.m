//
//  ChatViewController.m
//  
//
//  Created by David on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LanguageSelectorViewController.h"
#import "LanguageReference.h"
#import "LTDataSource.h"
#import "DictionaryHandler.h"
#import "DictionaryViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>



#import "ChatViewController.h"
#import "IQKit.h"
#import "LTMessage.h"
#import "LextTalkAppDelegate.h"
#import "QuartzCore/QuartzCore.h"
#import "UIViewWithGradient.h"
#import "LextTalkAppDelegate.h"
#import "Flurry.h"
#import "LanguageReference.h"
#import "UIColor+ColorFromImage.h"
#import "GeneralHelper.h"
#import "MessageHandler.h"
#import "MicrosoftTranslator.h"
#import "MMPickerView.h"
//Have to be exactly the same as daughter class
#define MAX_MESSAGE_TEXT_LENGTH 249
#define TAB_BAR_HEIGHT 50
#define MAX_MESSAGES_IN_TABLE 25



@interface ChatViewController (PrivateMethods)

- (UITableViewCell*) prepareCellForMesssage: (LTMessage*) message inTableView: (UITableView *)tableView;
- (BOOL) addTimeForCellIn:(NSIndexPath *) indexPath;
- (void) goToTranslator:(UIButton *) button;
@end

@implementation ChatViewController

@synthesize chat = _chat;
@synthesize userId = _userId;
@synthesize messageTextView;
@synthesize sendButton;
@synthesize indicatorView = _indicatorView;
@synthesize backgroundView;
@synthesize backgroundView2;
@synthesize textToChat;
@synthesize visibleIndexPaths;
@synthesize isChatroom;
@synthesize popoverController;
@synthesize messageToTranslateText;
@synthesize messageToTranslateId;
@synthesize HUD;
@synthesize visible;


static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.25;
//static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
//static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;

#define SECONDS_TO_SHOW_TIME_TEXT 300

#pragma mark - 
#pragma mark IQLocalizableProtocol methods

- (void) localize {    
    [self.sendButton setTitle:NSLocalizedString(@"Send", @"Send") forState:UIControlStateNormal];
}

#pragma mark - 
#pragma mark LTDataDelegate methods

- (void) didSendMessageAndHasPendingMessages:(BOOL)hasMessages
{
	// tell app delegate to update ChatListViewController
    if (hasMessages)
        [[LextTalkAppDelegate sharedDelegate] updateChatList];
    else
        [self updateChatViewController];
    
    [self.chatTableView reloadData];
	[_indicatorView stopAnimating];
    self.sendButton.enabled = YES;
    [self.messageTextView setText:@""];
    
    
    //Fix for iOS 4.x
    CGSize contentSize=self.messageTextView.contentSize;
    contentSize.height=34;
    self.messageTextView.contentSize=contentSize;
    
    [self adjustBackgroundViewToTextViewAndScrollTableAnimated:YES];
}

- (void) didFail: (NSDictionary*) result {
	[_indicatorView stopAnimating];
    self.sendButton.enabled = YES;
	
	// handle error
	if(result == nil) return;
	
    //	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"LextTalk server error", @"LextTalk server error")
    //													message: [result objectForKey: @"message"]
    //												   delegate: self
    //										  cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
    //										  otherButtonTitles: nil];
    
    LextTalkAppDelegate * del = (LextTalkAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!del.showingError)
    {
        del.showingError=YES;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: [result objectForKey: @"error_title"]
                                                        message: [result objectForKey: @"error_message"]
                                                       delegate: self
                                              cancelButtonTitle: NSLocalizedString(@"Close", @"Close")
                                              otherButtonTitles: nil];
        alert.tag = 404;
        [alert show];
    }
}

#pragma mark -
#pragma mark UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((buttonIndex==0) && (alertView.tag==404))
    {
        LextTalkAppDelegate * del = (LextTalkAppDelegate *) [[UIApplication sharedApplication] delegate];
        del.showingError = NO;
    }
}

#pragma mark - 
#pragma mark Keyboard notification

- (void) keyboardWillShow:(NSNotification *)nsNotification {
    
    BOOL scrollToBottom=NO;
    if (self.keyboardDistance < 1)
        scrollToBottom=YES;
    
    [super keyboardWillShow:nsNotification];
    
    
    [self scrollToBottom:scrollToBottom];
}

- (void) keyboardWillHide:(NSNotification *)notif
{
    BOOL scrollToBottom=NO;
    if (self.keyboardDistance > 1)
        scrollToBottom=YES;
    
    [super keyboardWillHide:notif];
    
    [self scrollToBottom:scrollToBottom];
    
}

- (void) scrollToBottom:(BOOL) scrollToBottom
{
    [UIView animateWithDuration: KEYBOARD_ANIMATION_DURATION animations:^{
        
        //INCREIBLE. Si lo pongo dentro del bloque de animación con "animated:NO", utiliza la duración del bloque
        //y la animación queda sincronizada con el teclado. Funciona con scrollToRowAtIndexPath y scrollRectToVisible
        if (scrollToBottom)
        {
            if ([self.chat.messages count]>0)
            {
                NSIndexPath * indexPath=[NSIndexPath indexPathForRow:[self.chat.messages count] -1 inSection:1];
                [self.chatTableView scrollToRowAtIndexPath: indexPath
                                          atScrollPosition: UITableViewScrollPositionTop
                                                  animated: NO];
            }
        }
        else
        {
            CGFloat tableHeight=self.chatTableView.frame.size.height - self.chatTableView.contentInset.bottom - self.chatTableView.contentInset.top;
            CGRect offsetRect=CGRectMake(0, self.chatTableView.contentOffset.y + tableHeight -1, 1, 1);
            
            [self.chatTableView scrollRectToVisible:offsetRect animated:NO];
        }
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //Fix for iOS 4.x
    [self.messageTextView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void) textViewDidChange:(UITextView *)textView
{
    
    [self adjustBackgroundViewToTextViewAndScrollTableAnimated:YES];
}

- (void) adjustBackgroundViewToTextViewAndScrollTableAnimated:(BOOL) animated
{
    //CGSize contentSize=textView.contentSize;
    //Ugly hack for iOS 7
    CGSize contentSize = [self.messageTextView.text sizeWithFont:self.messageTextView.font constrainedToSize:CGSizeMake(self.messageTextView.frame.size.width -10.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    contentSize.height += 20;
    if (contentSize.height<34)
        contentSize.height=34;//Do not want it to disappear
    
    //I just resize the background view height, the rest is taken care of by layoutBanners
    CGFloat backgroundViewHeight=contentSize.height + 10;//Keep the same margin
    
    
    CGFloat tableHeight=self.chatTableView.frame.size.height - self.chatTableView.contentInset.bottom - self.chatTableView.contentInset.top;
    CGRect offsetRect=CGRectMake(0, self.chatTableView.contentOffset.y + tableHeight -1, 1, 1);
    
    [UIView animateWithDuration: (animated ? KEYBOARD_ANIMATION_DURATION : 0.0) animations:^{
        
        //Resize heiht
        CGRect newFrame = self.backgroundView.frame;
        newFrame.size.height=backgroundViewHeight;
        self.backgroundView.frame=newFrame;
        
        //messageTextView (needed for iOS 7)
        self.messageTextView.frame = CGRectMake(self.messageTextView.frame.origin.x, self.messageTextView.frame.origin.y, self.messageTextView.frame.size.width, contentSize.height);
        
        [self layoutBanners:YES];
        
        
        //hacer un scroll de lo que crece
        //INCREIBLE, TAMBIEN ESTE METODO AL LLAMARLO CON animated:NO en el bloque de animación, utiliza la duración del bloque
        [self.chatTableView scrollRectToVisible:offsetRect animated:NO];
        
    } completion:^(BOOL finished) {
        
    }];
}


- (BOOL)textViewShouldEndEditing:(UITextField *)textField
{
    if(textField.text.length <= MAX_MESSAGE_TEXT_LENGTH) return YES;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Too long", @"Too long") 
													message: [NSString stringWithFormat: NSLocalizedString(@"Your message is limited to %d characters", @"Your message is limited to %d characters"), MAX_MESSAGE_TEXT_LENGTH]
												   delegate: nil 
										  cancelButtonTitle: NSLocalizedString(@"Close", @"Close") 
										  otherButtonTitles: nil];
	[alert show];
	// now remove extra chars
    [textField setText: [textField.text substringToIndex: MAX_MESSAGE_TEXT_LENGTH]];
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (self.sendButton.enabled)
        return YES;
    else
        return NO;
}

#pragma mark - 
#pragma mark UITableViewDelegate methds

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section==0)
        return 60.0;
    else
    {
        LTMessage *msg = [self.chat.messages objectAtIndex: indexPath.row];
        BOOL addTime=[self addTimeForCellIn:indexPath];
        return [msg cellHeightInTableView: tableView withOrientation:self.interfaceOrientation withTime:addTime isChatroom:self.isChatroom];
    }
    
    return 44.0;
}

#pragma mark - 
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0)
    {
        if (showLoadMoreButton)
            return 1;
        else
            return 0;
    }
    else
        return [self.chat.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0)
    {
        static NSString *CellIdentifier = @"ButtonCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        CGRect rect=self.chatTableView.bounds;
        CGRect buttonFrame=CGRectMake((rect.size.width - 200)/2, 15, 200, 30);
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        //button.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        //button.layer.cornerRadius = 5.0;
        //button.borderWidth = 1.0f;
        //shadow
        button.layer.shadowColor=[[UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0] CGColor];
        button.layer.shadowOpacity = 1.0;
        button.layer.shadowRadius = 2;
        button.layer.shadowOffset = CGSizeMake(0, 2);
        button.clipsToBounds=NO;
        //font
        button.titleLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:15];
        button.backgroundColor = [UIColor colorFromImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]];
        [button setTitle:NSLocalizedString(@"Load more messages", nil) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(loadMoreButton) forControlEvents:UIControlEventTouchUpInside];
        button.frame=buttonFrame;
        
        cell.backgroundColor = [UIColor clearColor];
        
        [cell.contentView addSubview:button];
        
        return cell;
    }
    else
    {
        LTMessage *msg = [self.chat.messages objectAtIndex: indexPath.row];
        //I need the date from the previous message
        BOOL addTime=[self addTimeForCellIn:indexPath];
        UITableViewCell * cell=[msg cellInTableView: tableView withOrientation:self.interfaceOrientation addTime:addTime isChatroom:self.isChatroom];
        //Add selector if there is a button for translator
        UIButton * button=(UIButton *) [cell viewWithTag:222];
        if (button!=nil)
            [button addTarget:self action:@selector(goToTranslator:) forControlEvents:UIControlEventTouchUpInside];
        
        button=(UIButton *) [cell viewWithTag:333];
        if (button!=nil)
            [button addTarget:self action:@selector(translateInChat:) forControlEvents:UIControlEventTouchUpInside];
        
        button=(UIButton *) [cell viewWithTag:444];
        if (button!=nil)
            [button addTarget:self action:@selector(removeTranslation:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

#pragma mark -
#pragma mark Bing Translator Delegate

- (void) detectedLanguage:(NSString *)locale
{
    self.HUD.labelText=NSLocalizedString(@"Translating...", nil);
    
    //NSLog(@"Detected locale: %@", locale);
    //Traduzco al idioma nativo del usuario
    NSString * speaking=[[LTDataSource sharedDataSource] localUser].activeSpeakingLan;    
    if (speaking) {
        NSString * toLocale=[LanguageReference getLocaleForMasterLan:speaking];
        //NSLog(@"to locale: %@", toLocale);
        LextTalkAppDelegate * del=(LextTalkAppDelegate *)[[UIApplication sharedApplication] delegate];
        [del.translatorViewController.bingTranslator translateText:self.messageToTranslateText fromLocale:locale to:toLocale withDelegate:self];
        [del countBingUses];
        
        NSDictionary * dic =
        [NSDictionary dictionaryWithObjectsAndKeys:
         locale, @"fromLocale",
         toLocale, @"toLocale",
         [NSNumber numberWithInteger:[self.messageToTranslateText length]], @"charNumber", nil];
        [Flurry logEvent:@"TRANSLATE_IN_CHAT_ACTION" withParameters:dic];
    } else {
        [self.HUD hide:YES];
        self.HUD=nil;
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Complete your profile!", nil)
                                    message:NSLocalizedString(@"Please, select the languages you speak and the ones you are learning", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil, nil] show];
    }
}

- (void) translatedText:(NSString *)text
{
    [self.HUD hide:YES];
    self.HUD=nil;
    //NSLog(@"Texto traducido: %@", text);
    
    //Look for LTMessage, update its member translataed text and reload the cell
    NSInteger index=-1;
    for (NSInteger i=[self.chat.messages count] -1; i>=0; i--)
    {
        LTMessage * message=[self.chat.messages objectAtIndex:i];
        if (message.messageId==self.messageToTranslateId)
        {
            message.translatedText=text;
            index=i;
            break;
        }
    }
    
    if (index>=0)
    {
        NSIndexPath * indexPath=[NSIndexPath indexPathForRow:index inSection:1];
        [self.chatTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void) connectionFailedWithError:(NSError *)error
{
    [self.HUD hide:YES];
    self.HUD=nil;
    
    NSString * str=NSLocalizedString(@"Please make sure you have data coverage or wi-fi. Error: %@", nil);
    str=[NSString stringWithFormat:str, [error localizedDescription]];
    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                    message:str
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [alert show];
}

#pragma mark -
#pragma mark ChatViewController methods

- (void) dismiss:(UITapGestureRecognizer *) tap
{
    if (tap.state==UIGestureRecognizerStateEnded)
    {
        [self.messageTextView resignFirstResponder];
    }
}

- (void) loadMoreButton
{
    CGPoint point=[self.chatTableView contentOffset];
    CGSize size=[self.chatTableView contentSize];
    
    loadMoreButtonPressedCount++;
    
    self.chat.messages = [[MessageHandler sharedInstance] last:(MAX_MESSAGES_IN_TABLE * (1 + loadMoreButtonPressedCount)) messagesForUser:self.chat.userId moreAvailable:&showLoadMoreButton];
    
    [self.chatTableView reloadData];
    
    CGSize size2=[self.chatTableView contentSize];
    NSInteger iContentOffset=size2.height - size.height;
    if (iContentOffset>=0)
    {
        point=CGPointMake(0, point.y + (CGFloat) iContentOffset);
        [self.chatTableView setContentOffset:point];
    }
}
-(int) name_to_char:(NSString *) lang_name
{
    for ( int i=0;i<[_language_name count];i++){
        if([lang_name isEqualToString:_language_name[i]])
        {
            return i;
        }
    }
    return -1;
}

- (void) goToTranslator:(UIButton *) button
{
    UIView * view=[button superview];
    UILabel * label=(UILabel *) [view viewWithTag:111];
    if (label!=nil)
    {
        NSString * str=label.text;
        NSString *to;
        //NSLog (@"@%@",str);
        MicrosoftTranslator *translator = [[MicrosoftTranslator alloc] initWithClientID:_clientID clientSecret:_clientSecret];
        LTUser *currUser = [[LTDataSource sharedDataSource] localUser];
        NSString *tempLanguage = [currUser.speakingLanguages objectAtIndex:0];
       // NSLog(@"@%@", tempLanguage);
        int code=[self name_to_char:tempLanguage];
        if(code!= -1)
        {
            to=_languageArray[code];
        }
        else{
            to=[[NSLocale preferredLanguages]objectAtIndex:0];
            
        }
        self.from = [translator detectLanguageOfText:str];
        if([_translation isEqualToString:str])
            {
                [label setText:_before];
            }
        else{
        _translation = [translator translateText:str from:self.from to:to];
            _before =str;
        //   NSLog(@"%@",translation);
        [label setText:_translation];
        }
        
        // NSLog(@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        //  NSDictionary * dic=[NSDictionary dictionaryWithObjectsAndKeys:str, @"textToTranslate",
        //             self.chat.learningLang, @"toLang", //My native lang is the one my partner is learning
        //               self.chat.speakingLang, @"fromLang", //This is the lang I am learning
        //           nil];
        // NSLog(@"/n/n/n/n/n/n/n/n/n/n/n/n//n/n/n//n/n/n/n");
        //  [self.bingTranslator translateText:str
        //                        fromLocale:[LanguageReference getLocaleForMasterLan:[LanguageReference getMasterLanForAppLan:@"English" andLanName:self.chat.learningLang]]
        //                              to:[LanguageReference getLocaleForMasterLan:[LanguageReference getMasterLanForAppLan:@"English" andLanName:self.chat.speakingLang]]
        //                  withDelegate:self];
        
        
        //  [[NSNotificationCenter defaultCenter] postNotificationName:@"GoToTranslator" object:self userInfo:dic];
    }
}

- (void) translateInChat:(UIButton *) button
{
    //contentView
    UIView * view=[[button superview] superview];
    UILabel * label=(UILabel *) [view viewWithTag:111];
    //NSString *to=@"en";
    if(label!=nil)
    {
        NSString *str=label.text;
        MicrosoftTranslator *translator = [[MicrosoftTranslator alloc] initWithClientID:_clientID clientSecret:_clientSecret];
        [MMPickerView showPickerViewInView:self.view
                               withStrings:_language_name
                               withOptions:nil
                                completion:^(NSString *selectedString) {
                                    //selectedString is the return value which you can use as you wish
                                    int code= [self name_to_char:selectedString ];
                                    NSString * to = _languageArray[code];
                                    self.from = [translator detectLanguageOfText:str];
                                    NSString *translate = [translator translateText:str from:self.from to:to];
                                    [label setText:translate];
                                }];
        
    }
    //Showing picker to select language to translate to
    
    
    
    
    //En iOS 7, el superview de cell.contentView, no es la celda es UITableViewCellScrollView
    //Cell
    //    while (![view isKindOfClass:[UITableViewCell class]])
    //        view = [view superview];
    //    if (label!=nil)
    //    {
    //        NSIndexPath * indexPath=[self.chatTableView indexPathForCell:(UITableViewCell *)view];
    //
    //        self.messageToTranslateText=label.text;
    //        self.messageToTranslateId=[[self.chat.messages objectAtIndex:indexPath.row] messageId];
    //
    //        self.HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.view];
    //        [self.tabBarController.view addSubview:HUD];
    //        HUD.mode = MBProgressHUDModeIndeterminate;
    //        HUD.labelText = NSLocalizedString(@"Detecting language...", nil);
    //        [HUD show:YES];
    //        LextTalkAppDelegate * del=(LextTalkAppDelegate *)[[UIApplication sharedApplication] delegate];
    //        [del.translatorViewController.bingTranslator detectLanguage:self.messageToTranslateText withDelegate:self];
    //        [del countBingUses];
    //    }
}
- (void) removeTranslation:(UIButton *) button
{
    UIView * view= button;
    //En iOS 7, el superview de cell.contentView, no es la celda es UITableViewCellScrollView
    //Cell
    while (![view isKindOfClass:[UITableViewCell class]])
        view = [view superview];
    
    UILabel * label=(UILabel *) [view viewWithTag:111];
    if (label!=nil)
    {
        NSIndexPath * indexPath=[self.chatTableView indexPathForCell:(UITableViewCell *)view];
        
        LTMessage * message=[self.chat.messages objectAtIndex:indexPath.row];
        message.translatedText=nil;
        [self.chatTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void) textFromTranslator:(NSNotification *) not
{
    //NSLog(@"LLego texto del traductor al chat...");
    NSDictionary * dic=[not userInfo];
    NSString * str=[dic objectForKey:@"textToChat"];
    self.textToChat=str;
    self.messageTextView.text=str;
    
    //Adjust text
    [self adjustBackgroundViewToTextViewAndScrollTableAnimated:NO];
    
    //If there are two chat windows active, the text is moved to both of them. It is not defined
    //which one is selected
    LextTalkAppDelegate * del=[LextTalkAppDelegate sharedDelegate];
    if (self.navigationController==del.mapViewController.navigationController)
        [del.tabBarController selectTab:0];
    else
        [del.tabBarController selectTab:1];
    
}

NSDateFormatter *dform = nil;

- (BOOL) addTimeForCellIn:(NSIndexPath *) indexPath
{
    if (dform == nil) {
        dform = [[NSDateFormatter alloc] init];
        dform.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    }
    BOOL addTime=NO;
    //if ((indexPath.row -1)>=0)
    
    if (indexPath.row >= 1)
    {
        [dform setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dform setTimeZone: [NSTimeZone timeZoneWithName: @"GMT"]];
        
        LTMessage * prevMessage=[self.chat.messages objectAtIndex:indexPath.row -1];
        LTMessage * message= [self.chat.messages objectAtIndex:indexPath.row];
        NSDate * prevDate = [dform dateFromString: prevMessage.timestamp];
        NSDate * date = [dform dateFromString: message.timestamp];
        if (([date timeIntervalSince1970] - [prevDate timeIntervalSince1970])>=SECONDS_TO_SHOW_TIME_TEXT)
            addTime=YES;
    }
    else
        addTime=YES;
    return addTime;
}

- (void) updateChatViewController
{
    // leave this view if user is no longer logged in
	if( ![[LTDataSource sharedDataSource] isUserLogged] ) {
		[self.navigationController popViewControllerAnimated: NO];
		return;
	}
    
    self.chat = [[LTDataSource sharedDataSource] chatForUserId: self.userId];
    self.chat.messages = [[MessageHandler sharedInstance] last:(MAX_MESSAGES_IN_TABLE * (1 + loadMoreButtonPressedCount)) messagesForUser:self.chat.userId moreAvailable:&showLoadMoreButton];
    
    self.title = [NSString stringWithFormat: NSLocalizedString(@"Chat with %@", @"Chat with %@"), self.chat.userName];
    
    if(self.chat == nil) {
		IQVerbose(VERBOSE_DEBUG,@"No chat to display!!");
        //[chatTableView reloadData];        
        return; 
    }
    
    if([self.chat.messages count] > 0) 
    {

        NSIndexPath * indexPath=[NSIndexPath indexPathForRow:[self.chat.messages count] -1 inSection:1];
        [self.chatTableView reloadData];
        
        [self.chatTableView scrollToRowAtIndexPath: indexPath
                                  atScrollPosition: UITableViewScrollPositionTop
                                      animated: NO];
	}
    
    IQVerbose(VERBOSE_DEBUG,@"[%@] updateChatViewController: marking all messages as read", [self class]);
    if (self.chat)
        [self messagesDelivered];
}

- (IBAction) dismissKeyboard {
	[self.messageTextView resignFirstResponder];
}

- (IBAction) sendMessage {
    [Flurry logEvent:@"SEND_MESSAGE_ACTION"];

    if(self.sendButton.enabled && (self.messageTextView.text.length > 0)){
        //[self.messageTextView resignFirstResponder];
        self.sendButton.enabled = NO;
        [self.indicatorView startAnimating];
        
        
        
        /*
        [[LTDataSource sharedDataSource] sendMessage: self.messageTextView.text
                                              toUser: self.chat.userId
                                            fromUser: [[LTDataSource sharedDataSource] localUser].userId
                                         withEditKey: [[LTDataSource sharedDataSource] localUser].editKey
                                            delegate: self];
         */
        
        [[LTDataSource sharedDataSource] sendMessage:self.messageTextView.text toUser:self.chat.userId withEditKey:[[LTDataSource sharedDataSource] localUser].editKey andExecuteBlockInMainQueue:^(BOOL hasPendingMessages, NSError *error) {
            
            [self.indicatorView stopAnimating];
            self.sendButton.enabled = YES;
            
            if (error == nil)
            {
                if (hasPendingMessages)
                    [[LextTalkAppDelegate sharedDelegate] updateChatList];
                else
                    [self updateChatViewController];
                
                [self.chatTableView reloadData];
                [self.messageTextView setText:@""];
                
                
                //Fix for iOS 4.x
                CGSize contentSize=self.messageTextView.contentSize;
                contentSize.height=34;
                self.messageTextView.contentSize=contentSize;
                
                [self adjustBackgroundViewToTextViewAndScrollTableAnimated:YES];
            }
            else
            {
                //El tratamiento de error se hace en LTDataSource
            }
            
        }];
    }
}

- (void) messagesDelivered {
    if (visible)
    {
        // mark as readed all messages in this chat
        NSInteger counter = 0;
        NSMutableArray * mut = [NSMutableArray array];
        for(LTMessage *m in self.chat.messages) {
            if( (m.deliverStatus != DELIVER_FINISHED) ) {
                
                [mut addObject:m];
                
                m.deliverStatus = DELIVER_FINISHED;
                counter ++;
                
                IQVerbose(VERBOSE_DEBUG, @"[%@] Marking message %d as delivered", [self class], m.messageId);
            }
        }
        if (self.chat.unreadMessages >= counter)
            self.chat.unreadMessages -= counter;
        else
            self.chat.unreadMessages = 0;
        [[MessageHandler sharedInstance] markMessagesAsRead:mut];
        
        [[LTDataSource sharedDataSource] updateChatList];
        [self.chatTableView reloadData];
    }
}

#pragma mark -
#pragma mark UIPopoverController Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverController=nil;//Lo libero así
}

#pragma mark -
#pragma mark UIViewController methods

- (id) init
{
    self=[super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFromTranslator:) name:@"GoToChat" object:nil];
        self.bingTranslator=[[BingTranslator alloc] init];
        [self.bingTranslator downloadToken];
       // self.userData=[[LTUser alloc]init];

    }
    return self;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    visible=NO;
    
    /*
	IQVerbose(VERBOSE_DEBUG,@"[%@] viewWillDisappear: marking all messages as read", [self class]);
	if (self.chat) {
        [self messagesDelivered];
    }
     */
}

- (void) viewWillAppear:(BOOL)animated {
    
    [self adjustBackgroundViewToTextViewAndScrollTableAnimated:NO];
    
    [super viewWillAppear:animated];
    visible=YES;

    //I call the update with a separate method, so that I can call the update from the currentChatViewController
    //without calling viewWillAppear which gives a lot of problems with the AdViewController
    [self updateChatViewController];
    
    //Weird animation if I don't call again the layout of banners with no animation
    
    
    //After laying out the banner without animation, I have to scroll again
    if ([self.chat.messages count]>0)
    {
        NSIndexPath * indexPath=[NSIndexPath indexPathForRow:[self.chat.messages count] -1 inSection:1];
        [self.chatTableView scrollToRowAtIndexPath: indexPath
                                  atScrollPosition: UITableViewScrollPositionTop 
                                          animated: NO];
    }
    
    
    //Once the view is going to appear, I will be showing the messages, so I mark them as delivered:
    IQVerbose(VERBOSE_DEBUG,@"[%@] viewWillAppear: marking all messages as read", [self class]);
    if (self.chat) {
        [self messagesDelivered];
    }
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self adjustBackgroundViewToTextViewAndScrollTableAnimated:NO];
}

- (void) loadView
{
    CGRect applicationFrame=[UIScreen mainScreen].applicationFrame;
    CGRect rect = applicationFrame;
    //NSLog(@"width: %f, height: %f", applicationFrame.size.width, applicationFrame.size.height);
    rect.size.height -= self.navigationController.navigationBar.frame.size.height;
    rect.size.height -= self.tabBarController.tabBar.frame.size.height;
    
    self.view=[[UIView alloc] initWithFrame:rect];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //TableView
    CGRect tableFrame;
    tableFrame=CGRectMake(0, 0, rect.size.width, rect.size.height);
    self.chatTableView=[[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    self.chatTableView.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.chatTableView.allowsSelection=NO;
    self.chatTableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    self.chatTableView.separatorColor=[UIColor clearColor];
    self.chatTableView.delegate=self;
    self.chatTableView.dataSource=self;
    [self.view addSubview:self.chatTableView];
    //Tap para quitar el teclado
    UITapGestureRecognizer * tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tap.numberOfTapsRequired=1;
    tap.numberOfTouchesRequired=1;
    [self.chatTableView addGestureRecognizer:tap];
    
    //backGroundView
    self.backgroundView=[[UIViewWithGradient alloc] initWithFrame:CGRectMake(0, rect.size.height-44.0, rect.size.width, 44.0)];
    self.backgroundView.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.backgroundView.autoresizesSubviews=YES;
    [self.view addSubview:self.backgroundView];
    
    //UITextView
    self.messageTextView=[[UICopyTextView alloc] initWithFrame:CGRectMake(5.0, 5.0, /*239.0*/ rect.size.width - 81.0, 34.0)];
    self.messageTextView.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.messageTextView.delegate=self;
    //en iOS 7 no se adapta al escribir si scrollEnabled=NO;
    self.messageTextView.scrollEnabled=YES;
    self.messageTextView.bounces=NO;
    self.messageTextView.editable=YES;
    self.messageTextView.font=[UIFont fontWithName:@"Ubuntu" size:14.0];
    //Rounded corners
    [self.messageTextView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.messageTextView.layer setBorderWidth:2.0];
    self.messageTextView.layer.cornerRadius=14;
    self.messageTextView.clipsToBounds=YES;
    [self.backgroundView addSubview:self.messageTextView];
    
    self.messageTextView.autocorrectionType = UITextAutocorrectionTypeYes;
    
    
    //SendButton
    self.sendButton=[[UIButton alloc] initWithFrame:CGRectMake(/*252.0*/ rect.size.width - 68.0, 9.0, 61.0, 26.0)];
    self.sendButton.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.sendButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.backgroundView addSubview:self.sendButton];
    
    //color
    UIColor * barColor = [UIColor colorFromImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]];
    CGFloat red, green, blue, alpha;
    [barColor getRed:&red green:&green blue:&blue alpha:&alpha];
    red -= 55.0/255.0; if (red<0) red=0;
    green -= 55.0/255.0; if (green<0) green=0;
    blue -= 55.0/255.0; if (blue<0) blue=0;
    UIColor * buttonColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    self.sendButton.backgroundColor =  buttonColor;
    self.sendButton.layer.cornerRadius = 5.0;
    //self.sendButton.layer.borderWidth = 1.0f;
    //shadow
    self.sendButton.layer.shadowColor=[[UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0] CGColor];
    self.sendButton.layer.shadowOpacity = 1.0;
    self.sendButton.layer.shadowRadius = 1;
    self.sendButton.layer.shadowOffset = CGSizeMake(0, 1);
    self.sendButton.clipsToBounds=NO;
    //font
    self.sendButton.titleLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:15];
    
    //IndicatorView
    self.indicatorView=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(/*272.0*/ rect.size.width - 48.0, 12.0, 20.0, 20.0)];
    self.indicatorView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    self.indicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
    self.indicatorView.hidesWhenStopped=YES;
    [self.backgroundView addSubview:self.indicatorView];
    
    //Need another view to hide the table when the banner does not fit all the screen (usually in landscape mode)
    self.backgroundView2=[[UIView alloc] initWithFrame:CGRectMake(0,
                                                                   self.backgroundView.frame.origin.y + self.backgroundView.frame.size.height
                                                                   , self.backgroundView.frame.size.width, 400.0)];
    self.backgroundView2.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    self.backgroundView2.backgroundColor = [UIColor colorFromImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]];
    [self.view addSubview:self.backgroundView2];
    
    self.scrollViewToLayout = self.chatTableView;
    self.moveUpWhenKeyboardShown = YES;
    self.alignRemoveButtonToLeft = YES;
    self.hideRemoveButtonWhenKeyboardUp = YES;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [self adjustBackgroundViewToTextViewAndScrollTableAnimated:NO];
    
    [super viewDidLoad];
	//[self showWallpaper];
    [self localize];
    
    
	[self.chatTableView setAllowsSelection: NO];
    

    self.backgroundView.backgroundColor = [UIColor colorFromImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]];
    self.messageTextView.text=self.textToChat;
    
    
    //Tap para quitar el teclado
    UITapGestureRecognizer * tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    tap.numberOfTapsRequired=1;
    tap.numberOfTouchesRequired=1;
    [self.chatTableView addGestureRecognizer:tap];
    
    self.navigationItem.leftBarButtonItem = [GeneralHelper plainBarButtonItemWithText:nil image:[UIImage imageNamed:@"arrow-back"] target:self selector:@selector(popViewController)];
//<<<<<<< HEAD

    /*  Disable AdInheritanceViewController   */
    self.disableAds = YES;
    

    //Picker Languages

    //Picker Languages
    self.languageArray =@[@"af",
                          @"ar",
                          @"bs-Latn",
                          @"bg",
                          @"ca",
                          @"zh-CHS",
                          @"zh-CHT",
                          @"hr",
                          @"cs",
                          @"da",
                          @"nl",
                          @"en",
                          @"et",
                          @"fi",
                          @"fr",
                          @"de",
                          @"el",
                          @"ht",
                          @"he",
                          @"hi",
                          @"mww",
                          @"hu",
                          @"id",
                          @"it",
                          @"ja",
                          @"sw",
                          @"tlh",
                          @"tlh-Qaak",
                          @"ko",
                          @"lv",
                          @"lt",
                          @"ms",
                          @"mt",
                          @"no",
                          @"fa",
                          @"pl",
                          @"pt",
                          @"otq",
                          @"ro",
                          @"ru",
                          @"sr-Cyrl",
                          @"sr-Latn",
                          @"sk",
                          @"sl",
                          @"es",
                          @"sv",
                          @"th",
                          @"tr",
                          @"uk",
                          @"ur",
                          @"vi",
                          @"cy",
                          @"yua"];
    self.language_name = @[@"Afrikaans",
                           @"Arabic",
                           @"Bosnian (Latin)",
                           @"Bulgarian",
                           @"Catalan",
                           @"Chinese Simplified",
                           @"Chinese Traditional",
                           @"Croatian",
                           @"Czech",
                           @"Danish",
                           @"Dutch",
                           @"English",
                           @"Estonian",
                           @"Finnish",
                           @"French",
                           @"German",
                           @"Greek",
                           @"Haitian Creole",
                           @"Hebrew",
                           @"Hindi",
                           @"Hmong Daw",
                           @"Hungarian",
                           @"Indonesian",
                           @"Italian",
                           @"Japanese",
                           @"Kiswahili",
                           @"Klingon",
                           @"Klingon (pIqaD)",
                           @"Korean",
                           @"Latvian",
                           @"Lithuanian",
                           @"Malay",
                           @"Maltese",
                           @"Norwegian",
                           @"Persian",
                           @"Polish",
                           @"Portuguese",
                           @"Querétaro Otomi",
                           @"Romanian",
                           @"Russian",
                           @"Serbian (Cyrillic)",
                           @"Serbian (Latin)",
                           @"Slovak",
                           @"Slovenian",
                           @"Spanish",
                           @"Swedish",
                           @"Thai",
                           @"Turkish",
                           @"Ukrainian",
                           @"Urdu",
                           @"Vietnamese",
                           @"Welsh",
                           @"Yucatec Maya"];

    _clientID= @"Lext-Talk";
    _clientSecret= @"aP/9HWqnDNB4rEn1KSNnKizkJiMjHHvYYNPDPsNPBng=";
 //   [self.singlePicker setDelegate:self];

//=======
    
    
    //winstojl
    NSLog(@"chat");
    
    
//>>>>>>> Winston_Hoglen
}

- (void) popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.visibleIndexPaths=[self.chatTableView indexPathsForVisibleRows];
}

-(void) rotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
{
    //To adjust the textView to the text
    [self adjustBackgroundViewToTextViewAndScrollTableAnimated:NO];
    
    [self.chatTableView reloadData];
    
    if ([self.visibleIndexPaths count]>0)
    {
        NSIndexPath * finalIndexPath=[self.visibleIndexPaths objectAtIndex:0];
        for (NSIndexPath * indexPath in self.visibleIndexPaths)
        {
            if (indexPath.row>finalIndexPath.row)
                finalIndexPath=indexPath;
        }
        [self.chatTableView scrollToRowAtIndexPath:finalIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self rotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size
          withTransitionCoordinator:coordinator];
    
    UIInterfaceOrientation interfaceOrientation = UIInterfaceOrientationPortrait;
    if (size.width > size.height)
        interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
    
    //Dentro de este bloque las vistas ya tienen al tamaño al que transitan, así que no es necesario arrastrar size
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         //update views here, e.g. calculate your view
         [self rotateToInterfaceOrientation:interfaceOrientation];
     }
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
     }];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //It might be visible, so I dismiss it if it is not nil
    [self.popoverController dismissPopoverAnimated:YES];
    
    self.chat = nil;
    self.chatTableView.delegate = nil;
    self.chatTableView.dataSource = nil;
    self.chatTableView = nil;
    self.sendButton = nil;
    self.indicatorView = nil;
    
    //Por que no el del texto?, no se hace un retain cada vez que cargue?
    self.messageTextView=nil;
    self.backgroundView=nil;
    self.backgroundView2=nil;
    
}

#pragma mark Ad Reimplementation
- (CGFloat) layoutBanners:(BOOL) animated
{
    CGFloat animationDuration = animated ? KEYBOARD_ANIMATION_DURATION : 0.0f;
    
    self.extraBottomInset = self.backgroundView.bounds.size.height;
    
    CGFloat adHeight=[super layoutBanners:animated];
    
    CGRect backFrame=self.backgroundView.frame;
    backFrame.origin.y=self.view.frame.size.height - adHeight - self.backgroundView.frame.size.height - self.tabBarController.tabBar.frame.size.height;
    if (self.keyboardDistance > 0)
        backFrame.origin.y -= (self.keyboardDistance - self.tabBarController.tabBar.frame.size.height - (self.navigationController.toolbarHidden ? 0 : self.navigationController.toolbar.frame.size.height));
    
    CGRect back2Frame=backFrame;
    back2Frame.origin.y=backFrame.origin.y + backFrame.size.height;
    back2Frame.size.height=400.0;
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         
                         self.backgroundView.frame=backFrame;
                         self.backgroundView2.frame=back2Frame;
                     }];
    
    return 0.0;
}
#pragma picker implemetation
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *) pickerView{
    return 1;
}

- (NSInteger) pickerView: (UIPickerView *) pickerView
 numberOfRowsInComponent: (NSInteger) component
{
    return [self.languageArray count];
}
- (NSString *) pickerView: (UIPickerView *) pickerView
              titleForRow: (NSInteger) row
             forComponent: (NSInteger) component
{
    return self.languageArray[row];
}

@end
