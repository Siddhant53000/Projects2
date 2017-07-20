//
//  ChatConfigController.m
//  LextTalk
//
//  Created by Yo on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "UIColor+ColorFromImage.h"
#import "LextTalkAppDelegate.h"
#import "GeneralHelper.h"

@interface ConfigurationViewController ()

@property (nonatomic, strong) UITableView * myTableView;

@end


@implementation ConfigurationViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"RemoveAdsBought" object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    self.myTableView=[[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStylePlain];
    self.view=[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.myTableView];
    self.myTableView.frame=self.view.frame;
    self.myTableView.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleBottomMargin /*| UIViewAutoresizingFlexibleTopMargin*/ | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    self.myTableView.delegate=self;
    self.myTableView.dataSource=self;
    
    self.scrollViewToLayout = self.myTableView;
    
    //self.myTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    //self.myTableView.backgroundView = nil;
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Configuration", nil);
    
    self.navigationItem.leftBarButtonItem = [GeneralHelper plainBarButtonItemWithText:nil image:[UIImage imageNamed:@"arrow-back"] target:self selector:@selector(popViewController)];
    
    /*  Disable AdInheritanceViewController   */
    self.disableAds = YES;
}

- (void) popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.myTableView.delegate = nil;
    self.myTableView.dataSource = nil;
    self.myTableView=nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    //Before calling the super method
    CGRect frame = self.view.frame;
    frame.origin.y = 0.0;
    self.myTableView.frame = frame;
    
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ((section ==0) && ([self tableView:tableView numberOfRowsInSection:section] ==0) )
        return 0;
    else
        return 26.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * label = [[UILabel alloc] init];
    label.font=[UIFont fontWithName:@"Ubuntu-Bold" size:13];
    //label.backgroundColor=[UIColor colorFromBottomPixelFromImage:[UIImage imageNamed:@"bar-yellow"]];
    label.backgroundColor=[UIColor colorWithRed:240.0/255.0 green:222.0/255.0 blue:66.0/255.0 alpha:1.0];
    label.textColor=[UIColor whiteColor];
    label.textAlignment=NSTextAlignmentCenter;
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    return label;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        [self.myTableView deselectRowAtIndexPath:indexPath animated:YES];
        
        LextTalkAppDelegate * del = (LextTalkAppDelegate *) [UIApplication sharedApplication].delegate;
        if (indexPath.row == 0)
        {
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
        }
        else
        {
            [del startSpinnerWithText:NSLocalizedString(@"Restoring purchases...", nil)];
            [del.storeManager startRestoreProcess];
        }
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
    {
        /*
        LextTalkAppDelegate * del = (LextTalkAppDelegate *) [UIApplication sharedApplication].delegate;
        if (del.hasAds)
            return 2;
        else
            return 0;
         */
        return 2;
    }
    else
        return 2;
}

- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section
{
    if (section == 0)
        return NSLocalizedString(@"Purchases", nil);
    else
        return NSLocalizedString(@"When receiving a message", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView2 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
     static NSString *CellIdentifier = @"SoundConfigCell";
     
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     if (cell == nil) {
     cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
     }
     */
    
    
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    // Configure the cell...
    
    cell.textLabel.font = [UIFont fontWithName:@"Ubuntu" size:18];
    cell.accessoryType=UITableViewCellAccessoryNone;
    
    if (indexPath.section == 0)
    {
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        if (indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Remove ads", nil);
            LextTalkAppDelegate * del = (LextTalkAppDelegate *) [UIApplication sharedApplication].delegate;
            if (![del hasAds])
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
            cell.textLabel.text = NSLocalizedString(@"Restore purchases", nil);
    }
    else
    {
        NSUserDefaults * defs=[NSUserDefaults standardUserDefaults];
        if (indexPath.row==0)
        {
            UISwitch *aSwitch = [[UISwitch alloc] init];
            aSwitch.onTintColor = [UIColor colorWithRed:240.0/255.0 green:222.0/255.0 blue:66.0/255.0 alpha:1.0];
            [aSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            
            aSwitch.tag=indexPath.row;
            aSwitch.on=[[defs objectForKey:@"config_chatSound"] isEqual:@"on"];
            cell.accessoryView=aSwitch;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.textLabel.text=NSLocalizedString(@"Play sound", nil);
        }
        else
        {
            UISwitch *aSwitch = [[UISwitch alloc] init];
            aSwitch.onTintColor = [UIColor colorWithRed:240.0/255.0 green:222.0/255.0 blue:66.0/255.0 alpha:1.0];
            [aSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            
            aSwitch.tag=indexPath.row;
            aSwitch.on=[[defs objectForKey:@"config_chatVibration"] isEqual:@"on"];
            cell.accessoryView=aSwitch;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.textLabel.text=NSLocalizedString(@"Vibrate",nil);
        }
    }
    
	return cell;
}

#pragma mark -
#pragma mark ConfigurationViewController methods

- (void) switchChanged:(id)sender
{
	if ([sender isKindOfClass:[UISwitch class]])
	{
		UISwitch * toggle=(UISwitch *)sender;
		NSUserDefaults * defs=[NSUserDefaults standardUserDefaults];
		NSInteger number=toggle.tag;
		switch (number)
		{
            case 0:
				if (toggle.on)
					[defs setObject:@"on" forKey:@"config_chatSound"];
				else 
					[defs setObject:@"off" forKey:@"config_chatSound"];;
				break;
            case 1:
                if (toggle.on)
					[defs setObject:@"on" forKey:@"config_chatVibration"];
				else 
					[defs setObject:@"off" forKey:@"config_chatVibration"];;
				break;
        }
        [defs synchronize];
    }
}

- (void) reloadTable
{
    [self.myTableView reloadData];
}


#pragma mark UIViewController

- (CGSize) contentSizeForViewInPopover
{
    CGSize size;
    /*
    LextTalkAppDelegate * del = (LextTalkAppDelegate *) [UIApplication sharedApplication].delegate;
    if (del.hasAds)
        size=CGSizeMake(320, 228);
    else
        size=CGSizeMake(320, 114);
     */
    size=CGSizeMake(320, 228);
    return size;
}

@end
