//
//  MasterChatViewController.m
//  LextTalk
//
//  Created by Yo on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterChatViewController.h"
#import "LTDataSource.h"
#import "LextTalkAppDelegate.h"

@interface MasterChatViewController ()

@end

@implementation MasterChatViewController
@synthesize chatListViewController, chatRoomListViewController, popoverController, chatsNotRead;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadView
{
    self.myTableView=[[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStylePlain];
    self.view=[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.myTableView];
    self.myTableView.frame=self.view.frame;
    self.myTableView.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.myTableView.delegate=self;
    self.myTableView.dataSource=self;
    
    self.scrollViewToLayout = self.myTableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = NSLocalizedString(@"Chats", nil);
    //Color de la barra
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack; 
    self.navigationController.navigationBar.tintColor=[UIColor colorWithRed:0.886 green:0 blue:0.102 alpha:1.0];
    
    /*  Disable AdInheritanceViewController   */
    //self.disableAds = YES;

}

- (void) dealloc
{
    //It might be visible, so I dismiss it if it is not nil
    [self.popoverController dismissPopoverAnimated:YES];
    self.myTableView.delegate = nil;
    self.myTableView.dataSource = nil;
    self.myTableView=nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(![[LTDataSource sharedDataSource] isUserLogged]) {
        LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
        [del tellUserToSignIn];
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0)
        return 2;
    else 
        return 1;
}

- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section
{
    if (section==0)
        return NSLocalizedString(@"Chats", @"Chats");
    else 
        return NSLocalizedString(@"Configuration", @"Configuration");
}

- (UITableViewCell *)tableView:(UITableView *)tableView2 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     static NSString *CellIdentifier = @"MasterChatViewControllerCell";
     
     UITableViewCell *cell = [tableView2 dequeueReusableCellWithIdentifier:CellIdentifier];
     if (cell == nil) {
     cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
     }
    
    cell.detailTextLabel.text=nil;
    // Configure the cell...
    if (indexPath.section==0)
    {
        
        if (indexPath.row==0)
        {
            cell.textLabel.text=NSLocalizedString(@"Chats", @"Chats");
            if (self.chatsNotRead > 0)
                cell.detailTextLabel.text=[NSString stringWithFormat:@"%ld", (long)self.chatsNotRead];
        }
        else
        {
            cell.textLabel.text=NSLocalizedString(@"Chat rooms", @"Chat rooms");
        }
    }
    else 
    {
        cell.textLabel.text=NSLocalizedString(@"Chat configuration", @"Chat configuration");;
    }
    
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */

    //Create and push the controller now
    if (indexPath.section==0)
    {
        if(![[LTDataSource sharedDataSource] isUserLogged]) {
            LextTalkAppDelegate *del = (LextTalkAppDelegate*) [[UIApplication sharedApplication] delegate];
            [del tellUserToSignIn];
        }
        else 
        {
            if (indexPath.row==0)
                [self.navigationController pushViewController:self.chatListViewController animated:YES];
            else 
                [self.navigationController pushViewController:self.chatRoomListViewController animated:YES];
        }
    }
    else 
    {
        
    }
    
    [self.myTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UIPopoverController Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverController=nil;//Lo libero así
}

@end
