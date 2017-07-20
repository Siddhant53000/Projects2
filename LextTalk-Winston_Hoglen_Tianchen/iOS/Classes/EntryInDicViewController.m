//
//  EntryInDicViewController.m
//  LextTalk
//
//  Created by Yo on 11/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EntryInDicViewController.h"
#import "DictionaryHandler.h"
#import "DefInDicViewController.h"
#import "UIColor+ColorFromImage.h"
#import "GeneralHelper.h"
#import "Flurry.h"

#define fontsize 14.0

@interface EntryInDicViewController()

@property (nonatomic, strong) NSMutableArray * keyArray;
@property (nonatomic, strong) NSMutableDictionary * currentDictionary;

@property (nonatomic, strong) NSMutableArray * searchArray;
@property (nonatomic, strong) NSString * savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;
@property (nonatomic, strong) UISearchDisplayController * mysearchdisplaycontroller;

@property (nonatomic, assign) BOOL isEditing;

- (void) dictionaryWasModified;

@end

@implementation EntryInDicViewController
@synthesize fromLan, toLan, keyArray, currentDictionary, searchArray, savedSearchTerm, searchWasActive;
@synthesize popoverController;
@synthesize mysearchdisplaycontroller = _mysearchdisplaycontroller;

/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dictionaryWasModified) name:@"DictionaryWasModified" object:nil];
 }
 return self;
 }
 */

- (void) awakeFromNib
{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dictionaryWasModified) name:@"DictionaryWasModified" object:nil];
}


- (id) init
{
    self=[super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dictionaryWasModified) name:@"DictionaryWasModified" object:nil];
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
    self.myTableView=[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.view=[[UIView alloc] initWithFrame:CGRectZero];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.myTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.myTableView.frame = CGRectMake(0, 0, self.myTableView.frame.size.width, self.myTableView.frame.size.height);
    
    [self.view addSubview:self.myTableView];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    self.myTableView.backgroundColor = [UIColor clearColor];
    
    self.scrollViewToLayout = self.myTableView;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self showWallpaper];
    
    if (self.fromLan && self.toLan)
    {
        self.currentDictionary=[NSMutableDictionary dictionaryWithDictionary:[DictionaryHandler getWholeDictionaryFromLan:self.fromLan toLan:self.toLan]];
        self.keyArray=[NSMutableArray arrayWithArray:[[self.currentDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCompare:)]];
        
    }
    
    //Transparent Table?
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        self.myTableView.backgroundView=nil;
        self.myTableView.backgroundView=[[UIView alloc] init];
    }
    self.myTableView.backgroundColor=[UIColor clearColor];
    
    self.myTableView.delegate=self;
    self.myTableView.dataSource=self;
    
    //self.navigationItem.rightBarButtonItem=self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [GeneralHelper plainBarButtonItemWithText:NSLocalizedString(@"Edit", nil) image:nil target:self selector:@selector(editButtonPressed)];
    
    
    
    //Search Display Controller stuff
    self.searchArray=[NSMutableArray arrayWithCapacity:5];
    
    CGRect rect=[[UIScreen mainScreen] applicationFrame];
    UISearchBar * theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,rect.size.width,44)];
    //theSearchBar.delegate = self;

    //theSearchBar.showsCancelButton = YES;
    theSearchBar.backgroundImage = [[UIImage imageNamed:@"button-green"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    self.myTableView.tableHeaderView=theSearchBar;

    _mysearchdisplaycontroller = [[UISearchDisplayController alloc] initWithSearchBar:theSearchBar contentsController:self];
    
    //[searchCon release];
    _mysearchdisplaycontroller.delegate = self;
    _mysearchdisplaycontroller.searchResultsDataSource = self;
    _mysearchdisplaycontroller.searchResultsDelegate = self;
    _mysearchdisplaycontroller.searchResultsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    
    if (self.savedSearchTerm)
    {
        [_mysearchdisplaycontroller setActive:self.searchWasActive];
        [_mysearchdisplaycontroller.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
    
    //For the cancel button
    _mysearchdisplaycontroller.searchBar.tintColor=[UIColor colorFromImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]];
    
    self.navigationItem.leftBarButtonItem = [GeneralHelper plainBarButtonItemWithText:nil image:[UIImage imageNamed:@"arrow-back"] target:self selector:@selector(popViewController)];
}

- (void) popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) editButtonPressed;
{
    self.isEditing = !self.isEditing;
    if (self.isEditing)
        self.navigationItem.rightBarButtonItem = [GeneralHelper plainBarButtonItemWithText:NSLocalizedString(@"OK", nil) image:nil target:self selector:@selector(editButtonPressed)];
    else
        self.navigationItem.rightBarButtonItem = [GeneralHelper plainBarButtonItemWithText:NSLocalizedString(@"Edit", nil) image:nil target:self selector:@selector(editButtonPressed)];
    
    [self setEditing:self.isEditing animated:YES];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DicationaryWasModified" object:nil];
    
    self.myTableView.delegate = nil;
    self.myTableView.dataSource = nil;
    self.myTableView=nil;
    
    //Usual problems with search display controller
    _mysearchdisplaycontroller.delegate = nil;
    _mysearchdisplaycontroller.searchResultsDataSource = nil;
    _mysearchdisplaycontroller.searchResultsDelegate = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.myTableView flashScrollIndicators];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [_mysearchdisplaycontroller isActive];
    self.savedSearchTerm = [_mysearchdisplaycontroller.searchBar text];
}


#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger result;
    if (tableView==self.myTableView)
        result = [self.keyArray count];
    else
        result = [self.searchArray count];
    
    return result;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier;
    if (tableView==self.myTableView)
        CellIdentifier = @"DictionaryViewControllerCell";
    else
        CellIdentifier = @"DictionarySearchViewControllerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:fontsize];
    
    NSString * text;
    if (tableView==self.myTableView)
        text=[self.keyArray objectAtIndex:indexPath.row];
    else
        text=[self.searchArray objectAtIndex:indexPath.row];
    cell.textLabel.text=text;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
        
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    BOOL result=NO;
    if (tableView==self.myTableView)
        result=YES;
    
    return result;
}




// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView==self.myTableView)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            // Delete the row from the data source.
            [DictionaryHandler removeEntryFrom:self.fromLan toLan:self.toLan withEntry:[self.keyArray objectAtIndex:indexPath.row]];
            [self.currentDictionary removeObjectForKey:[self.keyArray objectAtIndex:indexPath.row]];
            [self.keyArray removeObjectAtIndex:indexPath.row];
            
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }   
        else if (editingStyle == UITableViewCellEditingStyleInsert) 
        {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }   
    }
}



/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


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
	
    NSString * entry;
    if (tableView==self.myTableView)
        entry=[self.keyArray objectAtIndex:indexPath.row];
    else
        entry=[self.searchArray objectAtIndex:indexPath.row];

    NSString * definition=[self.currentDictionary objectForKey:entry];
    
    
    //Create and push the controller now
    DefInDicViewController * controller=[[DefInDicViewController alloc] init];
    controller.text=definition;
    controller.title=entry;
    
    [Flurry logEvent:@"DIC_OPEN_ENTRY_ACTION"];
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        [self.navigationController pushViewController:controller animated:YES];
    } 
    else
    {
        controller.disableAds=YES;
        
        CGRect cellRect;
        if ([_mysearchdisplaycontroller isActive])
            cellRect=[_mysearchdisplaycontroller.searchResultsTableView rectForRowAtIndexPath:indexPath];
        else
            cellRect=[self.myTableView rectForRowAtIndexPath:indexPath];
        
        CGRect showRect=CGRectMake(cellRect.origin.x + cellRect.size.width - 40,
                                   cellRect.origin.y + cellRect.size.height/2,
                                   1, 1);
        
        self.popoverController=[[UIPopoverController alloc] initWithContentViewController:controller];
        self.popoverController.delegate=self;
        if ([_mysearchdisplaycontroller isActive])
            [self.popoverController presentPopoverFromRect:showRect inView:_mysearchdisplaycontroller.searchResultsTableView permittedArrowDirections:UIPopoverArrowDirectionAny  animated:YES];
        else
            [self.popoverController presentPopoverFromRect:showRect inView:self.myTableView permittedArrowDirections:UIPopoverArrowDirectionAny  animated:YES];
    }
    
    [self.myTableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor=[UIColor clearColor];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellText;
    if (tableView==self.myTableView)
        cellText = [self.keyArray objectAtIndex:indexPath.row];
    else
        cellText = [self.searchArray objectAtIndex:indexPath.row];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:fontsize];
    CGSize constraintSize ;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        if ((self.interfaceOrientation==UIInterfaceOrientationPortrait) || (self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown))
            constraintSize = CGSizeMake(280.0f, CGFLOAT_MAX);
        else 
            constraintSize = CGSizeMake(440.0f, CGFLOAT_MAX);
    }
    else
    {
        if ((self.interfaceOrientation==UIInterfaceOrientationPortrait) || (self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown))
            constraintSize = CGSizeMake(728.0f, CGFLOAT_MAX);
        else 
            constraintSize = CGSizeMake(984.0f, CGFLOAT_MAX);
    }
    
    CGRect textRect = [cellText boundingRectWithSize:constraintSize
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:cellFont}
                                             context:nil];
    CGSize labelSize = textRect.size;
    return labelSize.height + 20;
}


#pragma mark -
#pragma mark Reimplementation from UIViewController 

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.myTableView setEditing:editing animated:animated];
}


#pragma mark -
#pragma mark EntryInDicViewController methods

- (void) dictionaryWasModified
{
    if (self.fromLan && self.toLan)
    {
        self.currentDictionary=[NSMutableDictionary dictionaryWithDictionary:[DictionaryHandler getWholeDictionaryFromLan:self.fromLan toLan:self.toLan]];
        self.keyArray=[NSMutableArray arrayWithArray:[[self.currentDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCompare:)]];
        [self.myTableView reloadData];
        
    }
    if ([_mysearchdisplaycontroller isActive])
    {
        [_mysearchdisplaycontroller setActive:NO];
        [_mysearchdisplaycontroller.searchBar setText:nil];
        self.savedSearchTerm = nil;
    }
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self.searchArray removeAllObjects];
    NSRange range;
    for (NSString * str in self.keyArray)
    {
        range=[str rangeOfString:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
        if (range.location!=NSNotFound)
            [self.searchArray addObject:str];
    }
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    if (self.automaticallyAdjustsScrollViewInsets == NO)
    {
        UIEdgeInsets insets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.origin.y, 0, 0, 0);
        self.myTableView.contentInset = insets;
        self.myTableView.scrollIndicatorInsets = insets;
        self.myTableView.contentOffset = CGPointMake(0.0, -20.0);
    }
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    self.layoutDisabled = YES;
    UIEdgeInsets insets =
    UIEdgeInsetsMake(64,
                     0,
                     self.tabBarController.tabBar.frame.size.height + (self.navigationController.toolbarHidden ? 0 : self.navigationController.toolbar.frame.size.height) + 0.0 ,
                     0);
    
    
    self.myTableView.contentInset = insets;
    self.myTableView.scrollIndicatorInsets = insets;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.searchDisplayController.searchBar.alpha = 0.0;
    }];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //If I do not do this, and the AD has been reloaded when the search is activ3
    //The AD is not placed correctly when I come back from the search.
    self.layoutDisabled = NO;
    [self layoutBanners:YES];
    self.searchDisplayController.searchBar.alpha = 1.0;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    //Si no se crean los banners sin necesidad al llamar a sharedInstance
    if (!self.disableAds)
    {
        [self bringBannersToFront];
        
        [self layoutBanners:NO];
    }
}

#pragma mark -
#pragma mark UIPopoverController Delegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if ([_mysearchdisplaycontroller isActive])
        [_mysearchdisplaycontroller.searchResultsTableView deselectRowAtIndexPath:[_mysearchdisplaycontroller.searchResultsTableView indexPathForSelectedRow] animated:YES];
    else
        [self.myTableView deselectRowAtIndexPath:[self.myTableView indexPathForSelectedRow] animated:YES];
    self.popoverController=nil;//Lo libero así
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

@end
