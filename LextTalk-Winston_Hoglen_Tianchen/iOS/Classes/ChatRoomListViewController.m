//
//  ChatRoomListViewController.m
//  LextTalk
//
//  Created by Yo on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChatRoomListViewController.h"
#import "CreateChatRoomViewController.h"
#import "LTDataSource.h"
#import "MBProgressHUD.h"
#import "LTChatroom.h"
#import "ChatroomViewController.h"
#import "LextTalkAppDelegate.h"
#import "LanguageReference.h"
#import "SearchChatRoomViewController.h"
#import "LTMessage.h"
#import "ChatroomCell.h"
#import "IconGeneration.h"
#import "UIColor+ColorFromImage.h"
#import "GeneralHelper.h"
#import "AdCell.h"
#import "AdModel.h"

@interface ChatRoomListViewController ()

@property (nonatomic, strong) UITableView * myTableView;
@property (nonatomic, strong) UIPopoverController * popoverController;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, strong) NSMutableArray * searchArray;
@property (nonatomic, strong) NSString * savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;
@property (nonatomic) NSInteger savedScopeButtonIndex;

@property (nonatomic, strong) UISearchDisplayController * mysearchdisplaycontroller;

@property (nonatomic, strong) UIRefreshControl * refreshControl;

//for addCell
@property (nonatomic) int freequencyOfAdCell;

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
- (void) orderList;

@end

@implementation ChatRoomListViewController
@synthesize myTableView, popoverController, HUD, chatrooms, searchBar, searchArray, savedSearchTerm, searchWasActive, savedScopeButtonIndex;
@synthesize isSearch, lang, searchText;
@synthesize mysearchdisplaycontroller = _mysearchdisplaycontroller;

- (id) init
{
    self=[super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinedChatroomsChanged:) name:@"JoinedChatroomsChanged" object:nil];
    }
    [self setFreequencyOfAdCell:10];
    return self;
}

- (void) awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinedChatroomsChanged:) name:@"JoinedChatroomsChanged" object:nil];
}

- (void) loadView
{
    self.view=[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
 
    self.myTableView=[[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStylePlain];
    self.myTableView.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.myTableView];
    //self.myTableView.frame=self.view.frame;
    
    
    self.myTableView.delegate=self;
    self.myTableView.dataSource=self;
    self.myTableView.rowHeight=62;
}

#pragma mark -
#pragma mark UISearchBarDelegate methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)sb
{
    sb.text = @"";
    [sb resignFirstResponder];
    self.HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.view];
    [self.tabBarController.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = NSLocalizedString(@"Searching...", nil);
    [HUD show:YES];
    [[LTDataSource sharedDataSource] searchChatroom:nil
                                               lang:nil
                                             userId:[LTDataSource sharedDataSource].localUser.userId
                                           delegate:self]; 
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)sb
{
    [sb resignFirstResponder];
    self.HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.view];
    [self.tabBarController.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = NSLocalizedString(@"Searching...", nil);
    [HUD show:YES];
    if (sb.text.length > 0) {
        [[LTDataSource sharedDataSource] searchChatroom:sb.text
                                                   lang:nil
                                                 userId:[LTDataSource sharedDataSource].localUser.userId
                                               delegate:self];
        sb.text = @"";
    } else {
        [[LTDataSource sharedDataSource] searchChatroom:nil
                                                   lang:nil
                                                 userId:[LTDataSource sharedDataSource].localUser.userId
                                               delegate:self];        
    }
}


#pragma mark -
#pragma mark LTDataDelegate methods

- (void)didUpdateSearchResultsChatrooms:(NSArray *)results
{
    reloading=NO;
    [self.refreshControl endRefreshing];
    
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    [self.HUD hide:YES];
    self.HUD = nil;
    self.chatrooms = results;
    [self.myTableView reloadData];
    
    /*
    for (LTChatroom * chatroom in results)
    {
        NSLog(@"Chat room timestamp: %@", chatroom.timestamp);
        NSLog(@"Chat room timestamp: %d", chatroom.chatroomId);
    }
     */
    
    if (checkNewMessagesInChatrooms)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.isUserIn == %d", YES];
        NSArray *array = [self.chatrooms filteredArrayUsingPredicate:predicate];
        for (LTChatroom * cr in array)
        {
            //NSLog(@"Chat room id: %d", cr.chatroomId);
            [[LTDataSource sharedDataSource] getMesssagesForChatroom:cr.chatroomId
                                                                user:[LTDataSource sharedDataSource].localUser.userId
                                                             editKey:[LTDataSource sharedDataSource].localUser.editKey
                                                                time: nil
                                                               limit:NSIntegerMin
                                                            delegate:self];
        }
        checkNewMessagesInChatrooms=NO;
    }
    else 
        [self orderList];
}

- (void) didGetMessages:(NSArray *)messages withChatroomId:(NSInteger)chatroomId withTimestamp:(NSString *)timestamp
{
    // Store new messages and reload data
    
    //No vienen ordenados
    NSArray * messages2=[messages sortedArrayUsingSelector:@selector(compare:)];
    LTMessage * message=[messages2 lastObject];

    
    NSInteger lastMessageIdRead=[[LTDataSource sharedDataSource] lastMessageReadInChatroom:chatroomId];
    if ((lastMessageIdRead!=message.messageId) && (lastMessageIdRead!=-1))
    {
        NSArray * array=self.navigationController.viewControllers;
        for (UIViewController * vc in array)
        {
            if ([vc isKindOfClass:[ChatroomViewController class]])
            {
                ChatroomViewController * chatroomViewController=(ChatroomViewController *) vc;
                LTChatroom * chatroom=chatroomViewController.chatroom;
                if (chatroom.chatroomId==chatroomId && chatroomViewController.visible)
                    return;
            }
        }
        
        [[LTDataSource sharedDataSource] addChatroomToUnread:chatroomId];
        [self.myTableView reloadData];
        
        LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
        //[del.tabBarController setBadgeValue:NSLocalizedString(@"new", @"new") atPosition:2];
        [del.tabBarController setSecondBadgeAtPosition:1];
    }
    
    //recargar la tabla
    [self orderList];
}

- (void)didFail:(NSDictionary *)result
{
    reloading=NO;
    
    [self.refreshControl endRefreshing];
    
    [self.HUD hide:YES];
    self.HUD = nil;
    
    //    NSString *title = [result objectForKey:@"error_title"];
    //    NSString *message = [result objectForKey:@"error_message"];
    //
    //    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: title
    //                                                   message: message
    //                                                  delegate: nil
    //                                         cancelButtonTitle: NSLocalizedString(@"OK", @"OK")
    //                                         otherButtonTitles: nil];
    
    if (result == nil) return;
    
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
#pragma mark CreatChatRoomViewControllerDelegate methods
- (void) chatroomCreated
{
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController=nil;
}

#pragma mark -
#pragma mark ChatRoomListViewController methods


- (void) createChatRoom
{
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    CreateChatRoomViewController * controller=[[CreateChatRoomViewController alloc] init];
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        [self.navigationController pushViewController:controller animated:YES];
    }
    else 
    {
        controller.disableAds=YES;
        controller.delegate=self;
        
        UINavigationController * nav=[[UINavigationController alloc] initWithRootViewController:controller];
        
        [self.popoverController dismissPopoverAnimated:NO];//In case the user presses the button twice
        self.popoverController=nil;
        self.popoverController=[[UIPopoverController alloc] initWithContentViewController:nav];
        self.popoverController.delegate=self;
        [self.popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (void)filterContentForSearchText:(NSString*)searchText2 scope:(NSString*)scope {
    [self.searchArray removeAllObjects]; // First clear the filtered array.
    
    for(LTChatroom * chatroom in self.chatrooms) {
		if( [chatroom shouldAppearInContentForSearchText: searchText2 scope: scope] ) {
			[self.searchArray addObject: chatroom];
        }
    }
}

- (void) searchChatrooms
{
    SearchChatRoomViewController * controller=[[SearchChatRoomViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) joinedChatroomsChanged:(NSNotification *) not
{
    [self.myTableView reloadData];
    /*
    self.HUD = [[[MBProgressHUD alloc] initWithView:self.tabBarController.view] autorelease];
    [self.tabBarController.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = NSLocalizedString(@"Getting chatrooms...", @"Getting chatrooms...");
    [HUD show:YES];
     */
    
    if (!self.isSearch)
    {
        [[LTDataSource sharedDataSource] searchChatroom: nil lang: nil userId:[LTDataSource sharedDataSource].localUser.userId delegate: self];
    }
    else 
    {
        [[LTDataSource sharedDataSource] searchChatroom:self.searchText
                                                   lang:self.lang
                                                 userId:[LTDataSource sharedDataSource].localUser.userId
                                               delegate:self];
    }
}

- (void) updateChatRooms
{
    [self.refreshControl beginRefreshing];
    
    [[LTDataSource sharedDataSource] searchChatroom: nil lang: nil userId:[LTDataSource sharedDataSource].localUser.userId delegate: self];
}

- (void) newMessagesInChatroom:(NSInteger) chatroomId
{
    NSNumber * number=[NSNumber numberWithInteger:chatroomId];
    NSArray * chatroomsIdsWithNewMessages=[[LTDataSource sharedDataSource] unreadChatrooms];
    if (![chatroomsIdsWithNewMessages containsObject:number])
    {
        //Miro si tengo la propia chatroom cargada. No actualizo nada puesto que lo verá en la propia pantalla.
        NSArray * array=self.navigationController.viewControllers;
        for (UIViewController * vc in array)
        {
            if ([vc isKindOfClass:[ChatroomViewController class]])
            {
                ChatroomViewController * chatroomViewController=(ChatroomViewController *) vc;
                LTChatroom * chatroom=chatroomViewController.chatroom;
                if (chatroom.chatroomId==chatroomId)
                {
                    [chatroomViewController downloadMessagesFromServer];
                    if (chatroomViewController.visible)
                        return;
                } 
            }
        }
        
        [[LTDataSource sharedDataSource] addChatroomToUnread:chatroomId];
        [self orderList];
        
        LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
        //[del.tabBarController setBadgeValue:NSLocalizedString(@"new", @"new") atPosition:2];
        [del.tabBarController setSecondBadgeAtPosition:1];
    }
}


- (void) reloadController:(BOOL) checkNewMessagesInChatrooms2
{
    checkNewMessagesInChatrooms=checkNewMessagesInChatrooms2;
    [[LTDataSource sharedDataSource] searchChatroom: nil lang: nil userId:[LTDataSource sharedDataSource].localUser.userId delegate: self];
    
    //Forzar la recarga: podría ser que el usuario hubiera mandado la app al background en la propia chatroom, y entonces no se recargarían los mensajes...
    NSArray * array=self.navigationController.viewControllers;
    for (UIViewController * vc in array)
    {
        if ([vc isKindOfClass:[ChatroomViewController class]])
        {
            ChatroomViewController * chatroomViewController=(ChatroomViewController *) vc;
            [chatroomViewController downloadMessagesFromServer];
        }
    }
}

- (void) markAsReadChatroom:(NSInteger) chatroomId
{
    [[LTDataSource sharedDataSource] removeChatroomFromUnread:chatroomId];
    [self orderList];

    NSArray * chatroomsIdsWithNewMessages=[[LTDataSource sharedDataSource] unreadChatrooms];
    if ([chatroomsIdsWithNewMessages count]==0)
    {
        LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
        [del.tabBarController removeSecondBadgeAtPosition:1];
    }
    
}

- (void) orderList
{
    //Order 
    NSArray * chatroomsIdsWithNewMessages=[[LTDataSource sharedDataSource] unreadChatrooms];
    NSArray * array= [self.chatrooms sortedArrayUsingComparator:^NSComparisonResult(LTChatroom * chat1, LTChatroom * chat2) {
        
        if ((![chatroomsIdsWithNewMessages containsObject:[NSNumber numberWithInteger:chat2.chatroomId]]) && (![chatroomsIdsWithNewMessages containsObject:[NSNumber numberWithInteger:chat1.chatroomId]]))
            return [chat2.timestamp compare:chat1.timestamp];
        else if (([chatroomsIdsWithNewMessages containsObject:[NSNumber numberWithInteger:chat2.chatroomId]]) && (![chatroomsIdsWithNewMessages containsObject:[NSNumber numberWithInteger:chat1.chatroomId]]))
            return NSOrderedDescending;
        else if ((![chatroomsIdsWithNewMessages containsObject:[NSNumber numberWithInteger:chat2.chatroomId]]) && ([chatroomsIdsWithNewMessages containsObject:[NSNumber numberWithInteger:chat1.chatroomId]]))
            return NSOrderedAscending;
        else if (([chatroomsIdsWithNewMessages containsObject:[NSNumber numberWithInteger:chat2.chatroomId]]) && ([chatroomsIdsWithNewMessages containsObject:[NSNumber numberWithInteger:chat1.chatroomId]]))
            return [chat2.timestamp compare:chat1.timestamp];
        else 
            return NSOrderedAscending;
    }];
    self.chatrooms=array;
    [self.myTableView reloadData];
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	[self filterContentForSearchText: searchString 
							   scope: [[_mysearchdisplaycontroller.searchBar scopeButtonTitles] objectAtIndex:[_mysearchdisplaycontroller.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText: [_mysearchdisplaycontroller.searchBar text]
							   scope: [[_mysearchdisplaycontroller.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Section 1 are the user's chatrooms and section 2 the other chatrooms
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        // these are the chatrooms where the user has entered
        return NSLocalizedString(@"Joined chat rooms", nil);
    } else {
        // these are the rest of chatrooms
        return NSLocalizedString(@"Other chat rooms", nil);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSPredicate *predicate = predicate = [NSPredicate predicateWithFormat:@"SELF.isUserIn == %d", (section == 0)];
    if (tableView==_mysearchdisplaycontroller.searchResultsTableView) {
        int result_num = [self.searchArray filteredArrayUsingPredicate:predicate].count;
        if (![[AdModel sharedInstance] disableAds] && result_num != 0) //withads
        {
            long newRowNum = [self totalNumOfCellWhenAdsShown:result_num];
            return newRowNum;
        }
        return result_num;
    } else {
        NSArray *filteredChatrooms = [self.chatrooms filteredArrayUsingPredicate:predicate];
        NSInteger rows = filteredChatrooms.count;
        if (![[AdModel sharedInstance] disableAds] && rows != 0 ) //with ads
        {
            long newRowNum = [self totalNumOfCellWhenAdsShown:rows];
            return newRowNum;
        }
        return rows;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"ChatRoomListViewControllerCell";
    static NSString *CellIdentifier1 = @"adCell";
    
    //load adcell at when adfreequency meets
    if (![AdModel sharedInstance].disableAds)
    {
        if ([self frequencyForAdCell:indexPath])
        {
            AdCell* adcell = [[AdCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier1];
            [[adcell contentView] addSubview:adcell.nativeAdView];
            NSLog(@"adcell %ld", (long)indexPath.row);
            return adcell;

        }
    }
    
    //load Chatroom cells
    ChatroomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell = [[ChatroomCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    // Configure the cell...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.isUserIn == %d", (indexPath.section == 0)];
    NSArray *array;
    if (tableView==_mysearchdisplaycontroller.searchResultsTableView)
        array= [self.searchArray filteredArrayUsingPredicate:predicate];
    else 
        array= [self.chatrooms filteredArrayUsingPredicate:predicate];
    
    LTChatroom *chatroom = nil;
    if ([self totalNumOfCellWhenAdsShown:array.count] > indexPath.row) {
        if ([AdModel sharedInstance].disableAds) //no ads
        {
            chatroom = [array objectAtIndex:indexPath.row];
        }
        else  if (![AdModel sharedInstance].disableAds) //has ads
        {
            long newIndex = [self tableViewIndexToDatasourceIndex:indexPath.row];
            chatroom = [array objectAtIndex:newIndex];
        }
        
    } else {
        NSLog(@"ERROR: %d: chatroom index out of bounds", __LINE__);
        NSLog(@"array.count = %lu", (unsigned long)array.count);
        NSLog(@"indexPath(s,r) = %ld,%ld", (long)indexPath.section, (long)indexPath.row);
        cell.nameLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.langImageView.image = nil;
        cell.usersLabel.text=nil;
        return cell;
    }
    
    //Labels
    cell.nameLabel.text = [chatroom chatroomName];
    if ([chatroom userNumber] == 1)
        cell.usersLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d user", nil), [chatroom userNumber]];
    else 
        cell.usersLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d users", nil), [chatroom userNumber]];
    
    //Image
    NSString * language=[chatroom lang];
    NSInteger flag=[[LTDataSource sharedDataSource].localUser preferredFlagFor:language];
    cell.langImageView.image = [IconGeneration smallWithGlowIconForLearningLan:language withFlag:flag];
    
    //Disclosure
    
    //¿Mensajes nuevos?
    NSInteger chatroomId=[chatroom chatroomId];
    NSArray * chatroomsIdsWithNewMessages=[[LTDataSource sharedDataSource] unreadChatrooms];
    if ([chatroomsIdsWithNewMessages containsObject:[NSNumber numberWithInteger:chatroomId]])
        cell.disclosureText = [NSString stringWithFormat:NSLocalizedString(@"(new) %d", nil),  [chatroom messageNumber]];
    else
        cell.disclosureText = [NSString stringWithFormat:NSLocalizedString(@"%d", nil),  [chatroom messageNumber]];
    
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor=[UIColor clearColor];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * label = [[UILabel alloc] init];
    label.font=[UIFont fontWithName:@"Ubuntu-Bold" size:13];
    label.backgroundColor=[UIColor colorFromImage:[UIImage imageNamed:@"bar-blue"]];
    label.textColor=[UIColor whiteColor];
    label.textAlignment=NSTextAlignmentCenter;
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ((section ==0) && ([self tableView:tableView numberOfRowsInSection:section] ==0) )
        return 0;
    else
        return 26.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [ChatroomCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    //only works if the cell is not Adcell or there is no ad
    if ((![AdModel sharedInstance].disableAds && ![self frequencyForAdCell:indexPath]) || [AdModel sharedInstance].disableAds)
    {
        self.searchBar.text = @"";
        [self.searchBar resignFirstResponder];
        
        [self.myTableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if(![[LTDataSource sharedDataSource] isUserLogged]) {
            LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
            [del tellUserToSignIn];
            return;
        }
        
        ChatroomViewController *vc = [[ChatroomViewController alloc] init];
        
        vc.isChatroom=YES;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.isUserIn == %d", (indexPath.section == 0)];
        NSArray *array;
        if (tableView==_mysearchdisplaycontroller.searchResultsTableView) {
            array = [self.searchArray filteredArrayUsingPredicate:predicate];
        } else {
            array = [self.chatrooms filteredArrayUsingPredicate:predicate];
        }
        if ([self totalNumOfCellWhenAdsShown:array.count] > indexPath.row) {
            if ([[AdModel sharedInstance] disableAds]) //without ads
            {
                vc.chat = [array objectAtIndex:indexPath.row];

            }
            else if (![[AdModel sharedInstance] disableAds]) //with ads
            {
                vc.chat = [array objectAtIndex: [self tableViewIndexToDatasourceIndex:indexPath.row]];
            }
        } else {
            NSLog(@"ERROR: %d: chatroom index out of bounds", __LINE__);
            vc.chat = nil;
        }
        [self.navigationController pushViewController:vc animated:YES];
        
        //Quitar el new si lo hay
        NSInteger chatroomId=[(LTChatroom *)vc.chat chatroomId]; // UGLY chat is chatroom indeed
        
        NSArray * chatroomsIdsWithNewMessages=[[LTDataSource sharedDataSource] unreadChatrooms];
        if ([chatroomsIdsWithNewMessages containsObject:[NSNumber numberWithInteger:chatroomId]])
        {
            [[LTDataSource sharedDataSource] removeChatroomFromUnread:chatroomId];
            
            [self.myTableView reloadData];
            LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
            
            //Vuelvo a leerlo
            chatroomsIdsWithNewMessages=[[LTDataSource sharedDataSource] unreadChatrooms];
            if ([chatroomsIdsWithNewMessages count]==0)
                [del.tabBarController removeSecondBadgeAtPosition:1];
        }

    }
}

//for Adcell
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if ([self frequencyForAdCell:indexPath] && ![AdModel sharedInstance].disableAds)
    {
        return YES;
    }
   
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
\
        LextTalkAppDelegate * del = (LextTalkAppDelegate *) [UIApplication sharedApplication].delegate;
       
            if ([del hasAds])
            {
                [del startSpinnerWithText:NSLocalizedString(@"Purchasing remove ads...", nil)];
                [del.storeManager startPurchaseProcessForProduct:LTRemoveAdsProductID];
            }
            else
            {
                UIAlertView * alert =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Already purchased!", nil)
                                                                  message:NSLocalizedString(@"You have already purchased \"remove ads\"", nil)
                                                                 delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                        otherButtonTitles: nil];
                [alert show];
            }
    
        [tableView reloadData];
    }
}

#pragma mark -
#pragma mark UIPopoverController Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverController=nil;//Lo libero así
}

#pragma mark Ad Reimplementation
/*
- (CGFloat) layoutBanners:(BOOL) animated
{
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    
    CGFloat adHeight=[super layoutBanners:animated];
    CGRect newFrame=self.view.frame;//If I do it with the table, it reduces itself everytime an ad is refreshed
    newFrame.size.height=newFrame.size.height - adHeight;
    
    //Needed in iOS 7
    newFrame.origin = CGPointMake(0, 0);
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.myTableView.frame=newFrame;
                     }];
    
    return 0.0;
}
 */



#pragma mark -
#pragma mark UIViewController methods

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self orderList];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //self.searchBar.text = @"";
    //[self.searchBar resignFirstResponder];
    
    // save the state of the search UI so that it can be restored if the view is re-created
    self.savedScopeButtonIndex = [_mysearchdisplaycontroller.searchBar selectedScopeButtonIndex];
    self.searchWasActive = [_mysearchdisplaycontroller isActive];
    self.savedSearchTerm = [_mysearchdisplaycontroller.searchBar text];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title=NSLocalizedString(@"Chat rooms", @"Chat rooms");
    
    //Navigation bar color
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"search-blue"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] forBarMetrics:UIBarMetricsDefault];
    
    
    //Search Display Controller stuff
    self.searchArray=[NSMutableArray arrayWithCapacity:5];
    CGRect rect=[[UIScreen mainScreen] applicationFrame];
    UISearchBar * theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,rect.size.width,44)];
    
    self.myTableView.tableHeaderView=theSearchBar;
    _mysearchdisplaycontroller = [[UISearchDisplayController alloc] initWithSearchBar:theSearchBar contentsController:self];
    _mysearchdisplaycontroller.delegate = self;
    _mysearchdisplaycontroller.searchResultsDataSource = self;
    _mysearchdisplaycontroller.searchResultsDelegate = self;
    _mysearchdisplaycontroller.searchResultsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    
    _mysearchdisplaycontroller.searchBar.scopeButtonTitles=[NSArray arrayWithObjects:
                                                              NSLocalizedString(@"Name", @"Name"), 
                                                              NSLocalizedString(@"Language", @"Language"), 
                                                              NSLocalizedString(@"All", @"All"),
                                                              nil];
    
    if (self.savedSearchTerm)
    {
        [_mysearchdisplaycontroller setActive:self.searchWasActive];
        [_mysearchdisplaycontroller.searchBar setText:savedSearchTerm];
        [_mysearchdisplaycontroller.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        
        self.savedSearchTerm = nil;
    }
    
    [_mysearchdisplaycontroller.searchBar setBackgroundImage:[[UIImage imageNamed:@"search-blue"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];
    _mysearchdisplaycontroller.searchBar.tintColor = [UIColor colorFromImage:[[UIImage imageNamed:@"search-blue"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];
    _mysearchdisplaycontroller.searchBar.placeholder = NSLocalizedString(@"Filter", nil);
    _mysearchdisplaycontroller.searchResultsTableView.rowHeight=62;
    
    
    if (!self.isSearch)
    {
        //Refresh control
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(updateChatRooms) forControlEvents:UIControlEventValueChanged];
        [self.myTableView addSubview:self.refreshControl];
    }
    
    //Color de fondo
    self.myTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    
    if (!self.isSearch)
    {
        //Button to create a chat room
        self.navigationItem.rightBarButtonItem = [GeneralHelper plainBarButtonItemWithText:nil image:[UIImage imageNamed:@"plus"] target:self selector:@selector(createChatRoom)];
        //Button to search the Chat rooms
        self.navigationItem.leftBarButtonItem = [GeneralHelper plainBarButtonItemWithText:NSLocalizedString(@"Search", @"Search") image:nil target:self selector:@selector(searchChatrooms)];
    }
    else
        self.navigationItem.leftBarButtonItem = [GeneralHelper plainBarButtonItemWithText:nil image:[UIImage imageNamed:@"arrow-back"] target:self selector:@selector(popViewController)];
    
    
    [GeneralHelper setTitleTextAttributesForController:self];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGRect frame = self.myTableView.frame;
    frame.origin.y = 0.0f;
    self.myTableView.frame = frame;
    
    //for test Adcell whether is working
    //[[AdModel sharedInstance] setDisableAds:YES];
}

- (void) popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark NSObject methods

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[LTDataSource sharedDataSource] removeFromRequestDelegates:self];
    
    //It might be visible, so I dismiss it if it is not nil
    [self.popoverController dismissPopoverAnimated:YES];
    popoverController = nil;;
    
    //Usual problems with search display controller
    _mysearchdisplaycontroller.delegate = nil;
    _mysearchdisplaycontroller.searchResultsDataSource = nil;
    _mysearchdisplaycontroller.searchResultsDelegate = nil;
    
    self.myTableView.delegate = nil;
    self.myTableView.dataSource = nil;
    self.myTableView = nil;
    
    self.searchBar = nil;
    
    [self.HUD hide:YES];
    
}

#pragma mark -
#pragma mark Adcell methods

- (BOOL) frequencyForAdCell: (NSIndexPath *)indexPath
{
    return (indexPath.row % (self.freequencyOfAdCell) == 0 );
}

//only called when Ads needed to show up
- (int) tableViewIndexToDatasourceIndex: (int)table_index
{
    return table_index - table_index/self.freequencyOfAdCell -1;
}

- (int) totalNumOfCellWhenAdsShown: (int)datasourceCount
{
    return datasourceCount + datasourceCount / (self.freequencyOfAdCell-1) + 1;
}

@end
