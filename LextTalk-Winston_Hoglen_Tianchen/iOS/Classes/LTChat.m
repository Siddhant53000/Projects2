//
// LTChat.m
// LextTalk
//
//  Created by David on 11/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LTChat.h"
#import "LTDataSource.h"
#import "IconGeneration.h"
#import "LanguageReference.h"
#import "ChatListCell.h"
#import "LextTalkAppDelegate.h"
#import "GeneralHelper.h"
#import "MessageHandler.h"


@implementation LTChat
@synthesize userId = _userId;
@synthesize userName = _userName;
@synthesize messages = _messages;
@synthesize unreadMessages = _unreadMessages;
@synthesize speakingFlag, learningFlag, speakingLang ,learningLang;

#pragma mark -
#pragma mark LTTableObjectProtocol methods

- (CGFloat) cellHeightInTableView:(UITableView *)tableView {
    return 60;	
}

- (BOOL) shouldAppearInContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	if([self.userName rangeOfString: searchText options: NSCaseInsensitiveSearch].location != NSNotFound) {
		return YES;
	}
	return NO;
}

- (UITableViewCell *) cellInTableView:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath searchResult:(BOOL)search
{
	
    static NSString *cellIdentifier = @"LTChatCell";
	
    ChatListCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil)
        cell = [[ChatListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    cell.userImageView.image = [UIImage imageNamed:@"Contact"];
    cell.learningImageView.image = [IconGeneration smallWithGlowIconForLearningLan:self.learningLang withFlag:self.learningFlag];
    cell.speakingImageView.image = [IconGeneration smallWithGlowIconForSpeakingLan:self.speakingLang withFlag:self.speakingFlag];
    
    //cell.userLabel.text=@"XXXXXXXjjjXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
    //cell.messageLabel.text=@"3 messages xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
    cell.userLabel.text=self.userName;
  

    if (self.totalNumber==1)
        cell.messageLabel.text = [NSString stringWithFormat: NSLocalizedString(@"%d message", @"%d message"), self.totalNumber];
    else
        cell.messageLabel.text = [NSString stringWithFormat: NSLocalizedString(@"%d messages", @"%d messages"), self.totalNumber];
    cell.unreadMessages = self.unreadMessages;
    
    //Might be a reuse
    cell.activityImageView.image = nil;
    

    if (self.userDeleted)
    {
        cell.activityImageView.image = nil;
        
        UIImage * image = [[LTDataSource sharedDataSource] imageFromCacheForUserId:self.userId];
        if (image != nil)
            cell.userImageView.image = [GeneralHelper centralSquareFromImage:image];
    }
    else
    {
        //download image
        void(^myBlock)(UIImage * image, BOOL gotFromCache);
        myBlock = ^(UIImage * image, BOOL gotFromCache) {
            if (image!=nil)
            {
                if (gotFromCache)
                    cell.userImageView.image = [GeneralHelper centralSquareFromImage:image];
                else
                {
                    ChatListCell * cell2 = (ChatListCell *) [tableView cellForRowAtIndexPath:indexPath];
                    cell2.userImageView.image = [GeneralHelper centralSquareFromImage:image];
                }
            }
        };
        
        //Decide what to update
        BOOL updateUrl=NO, updateActivity=NO;
        if (([self.url length]==0) && ((self.urlUpdateDate == nil) || ([self.urlUpdateDate timeIntervalSinceNow]< - 3600.0)))
            updateUrl = YES;
        else if ([self.url length] > 0)
            [[LTDataSource sharedDataSource] getImageForUrl:self.url withUserId:self.userId andExecuteBlockInMainQueue:myBlock];
        
        //Activity indicator is updated if it is the first time or if more than an hour has passed since last update
        if ((self.lastUpdateDate == nil) && ((self.activityUpdateDate == nil) || ([self.activityUpdateDate timeIntervalSinceNow]< - 3600.0)))
            updateActivity = YES;
        else if (self.lastUpdateDate != nil)
            cell.activityImageView.image = [IconGeneration activityImageForDate:self.lastUpdateDate];
        
        if (updateUrl || updateActivity)
        {
            //NSLog(@"User id to get: %d", self.userId);
            [[LTDataSource sharedDataSource] getUserWithUserId:self.userId andExecuteBlockInMainQueue:^(LTUser *user, NSError *error) {
                
                if (error!=nil)
                {
                    if (updateActivity)
                        cell.activityImageView.image = nil;
                    
                    if (updateUrl) //I try to get the image from the cache, if it exists, it is set, no check to see if it has been invalidated
                    {
                        UIImage * image = [[LTDataSource sharedDataSource] imageFromCacheForUserId:self.userId];
                        if (image != nil)
                            cell.userImageView.image = [GeneralHelper centralSquareFromImage:image];
                    }
                    
                    LextTalkAppDelegate * del = (LextTalkAppDelegate *) [[UIApplication sharedApplication] delegate];
                    if (!del.showingError)
                    {
                        del.showingError=YES;
                        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network error!", nil)
                                                                         message:NSLocalizedString(@"The user information for one of your chats could not be downloaded", nil)
                                                                        delegate:self
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles: nil];
                        alert.tag = 404;
                        [alert show];
                    }
                }
                else if (user==nil) //No error but user==nil, which means that the user has been deleted
                {
                    self.userDeleted = YES;
                    
                    if (updateActivity)
                        cell.activityImageView.image = nil;
                    
                    if (updateUrl) //I try to get the image from the cache, if it exists, it is set, no check to see if it has been invalidated
                    {
                        UIImage * image = [[LTDataSource sharedDataSource] imageFromCacheForUserId:self.userId];
                        if (image != nil)
                            cell.userImageView.image = [GeneralHelper centralSquareFromImage:image];
                    }
                }
                else
                {
                    if (updateUrl)
                    {
                        self.urlUpdateDate = [NSDate date];
                        
                        self.url = user.url;
                        if ([self.url length] > 0)
                            [[LTDataSource sharedDataSource] getImageForUrl:self.url withUserId:self.userId andExecuteBlockInMainQueue:myBlock];
                        
                    }
                    
                    if (updateActivity)
                    {
                        self.activityUpdateDate = [NSDate date];
                        NSDate * date = [LTUser dateForUtcTime:user.lastUpdate];
                        self.lastUpdateDate = date;
                        cell.activityImageView.image = [IconGeneration activityImageForDate:date];
                    }
                }
                
                [[MessageHandler sharedInstance] updateChatActivityVars:self];
                
            }];
        }
    }
    


    return cell;
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
#pragma mark LTChat methods

+ (LTChat*) newChat {
    
	LTChat *chat = [[LTChat alloc] init];
	[chat setMessages: [[NSMutableArray alloc] init]] ;
     
    /*
    LTChat *chat = [[LTChat alloc] init] ;
	[chat setMessages: [[NSMutableArray alloc] init] ] ;
     */
	return chat;
}

- (NSString*) newestMessage {
	return nil;
}

- (NSString*) oldestMessage {
	return nil;
}

@end
