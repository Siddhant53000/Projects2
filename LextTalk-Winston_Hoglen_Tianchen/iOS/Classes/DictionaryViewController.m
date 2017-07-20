//
//  DictionaryViewController.m
//  LextTalk
//
//  Created by Yo on 11/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DictionaryViewController.h"
#import "DictionaryHandler.h"
#import "LanguageReference.h"
#import "EntryInDicViewController.h"
#import "GeneralHelper.h"
#import "LTDataSource.h"
#import "IconGeneration.h"
#import "Flurry.h"

@interface DictionaryViewController()

@property (nonatomic, strong) NSMutableArray * fromArray;
@property (nonatomic, strong) NSMutableArray * toArray;
@property (nonatomic, assign) BOOL isEditing;

- (void) dictionaryWasModified;

@end

@implementation DictionaryViewController
@synthesize fromArray, toArray;


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
    self.myTableView=[[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStylePlain];
    self.view=[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.myTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.myTableView];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    self.myTableView.backgroundColor = [UIColor clearColor];
    
    self.scrollViewToLayout = self.myTableView;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self setWallpaperIndex:1];
    //[self showWallpaper];
    
    self.fromArray=[NSMutableArray arrayWithCapacity:5];
    self.toArray=[NSMutableArray arrayWithCapacity:5];
    
    [DictionaryHandler getDictinariesFrom:self.fromArray andTo:self.toArray];
    
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
    

    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.0 green:181.0/255.0 blue:138.0/255.0 alpha:1.0];
    self.title = NSLocalizedString(@"Dictionaries", nil);
    

    self.navigationItem.leftBarButtonItem = [GeneralHelper plainBarButtonItemWithText:nil image:[UIImage imageNamed:@"arrow-back"] target:self selector:@selector(popViewController)];
    
    //Navigation bar color
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack; 
    //self.navigationController.navigationBar.tintColor=[UIColor colorWithRed:0.384 green:0.125 blue:0.506 alpha:1.0];
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    CGRect frame = self.view.frame;
    frame.origin = CGPointMake(0, 0);
    self.myTableView.frame = frame;
    
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.myTableView flashScrollIndicators];
}



#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.fromArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"DictionaryViewControllerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
     // Configure the cell...
    NSString * fromLanName=[LanguageReference getLanForAppLan:[LanguageReference appLan] andMasterLan:[self.fromArray objectAtIndex:indexPath.row]];
    NSString * toLanName=[LanguageReference getLanForAppLan:[LanguageReference appLan] andMasterLan:[self.toArray objectAtIndex:indexPath.row]];
    NSString * text=[fromLanName stringByAppendingFormat:@" - %@", toLanName];
    cell.textLabel.text=text;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    //Flags
    CGSize imageSize=CGSizeMake(80, 43);
    CGRect imageRect1 = CGRectMake(0.0, 4.0, 39, 35);
    CGRect imageRect2 = CGRectMake(41.0, 0.0, 39, 43);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    
    UIImage * image1 = [IconGeneration smallWithGlowIconForLearningLan:[self.fromArray objectAtIndex:indexPath.row] withFlag:[[LTDataSource sharedDataSource].localUser preferredFlagFor:[self.fromArray objectAtIndex:indexPath.row]]];
    UIImage * image2 = [IconGeneration smallWithGlowIconForSpeakingLan:[self.toArray objectAtIndex:indexPath.row] withFlag:[[LTDataSource sharedDataSource].localUser preferredFlagFor:[self.toArray objectAtIndex:indexPath.row]]];
    
    [image1 drawInRect:imageRect1];
    [image2 drawInRect:imageRect2];
    
    UIImage * retinaImage = UIGraphicsGetImageFromCurrentImageContext();  // UIImage returned
    UIGraphicsEndImageContext();
    
    cell.imageView.image=retinaImage;

    //Flags
    /*
    CGSize flagSize=CGSizeMake(45, 30);
    CGSize imageSize=CGSizeMake(95, 30);
    CGRect imageRect1 = CGRectMake(0.0, 0.0, flagSize.width, flagSize.height);
    CGRect imageRect2 = CGRectMake(50.0, 0.0, flagSize.width, flagSize.height);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    
    UIImage * nonRetinaImage=[UIImage imageWithData:[LanguageReference flagForMasterLan:[self.fromArray objectAtIndex:indexPath.row] andId:[[LTDataSource sharedDataSource].localUser preferredFlagFor:[self.fromArray objectAtIndex:indexPath.row]]]];
    [nonRetinaImage drawInRect:imageRect1];
    nonRetinaImage=[UIImage imageWithData:[LanguageReference flagForMasterLan:[self.toArray objectAtIndex:indexPath.row] andId:[[LTDataSource sharedDataSource].localUser preferredFlagFor:[self.toArray objectAtIndex:indexPath.row]]]];
    [nonRetinaImage drawInRect:imageRect2];
    
    UIImage * retinaImage = UIGraphicsGetImageFromCurrentImageContext();  // UIImage returned
    UIGraphicsEndImageContext();
    
    cell.imageView.image=retinaImage;
     */
    
    return cell;
}



 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 



 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
     if (editingStyle == UITableViewCellEditingStyleDelete)
     {
         // Delete the row from the data source.
         [DictionaryHandler removeDictionaryFrom:[self.fromArray objectAtIndex:indexPath.row] andTo:[self.toArray objectAtIndex:indexPath.row]];
         [self.fromArray removeObjectAtIndex:indexPath.row];
         [self.toArray removeObjectAtIndex:indexPath.row];
         
         [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
     }   
     else if (editingStyle == UITableViewCellEditingStyleInsert) 
     {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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
	
    
    
	NSString * fromMasterLan=[self.fromArray objectAtIndex:indexPath.row];
    NSString * toMasterLan=[self.toArray objectAtIndex:indexPath.row];
    
    //Flurry
    NSDictionary * dic =
    [NSDictionary dictionaryWithObjectsAndKeys:
     fromMasterLan, @"fromLang",
     toMasterLan, @"toLang", nil];
    [Flurry logEvent:@"DIC_OPEN_ENTRIES_ACTION" withParameters:dic];
    
    //Recreate the text of the cell to get the name of the controller
    NSString * str1=[LanguageReference getLanForAppLan:@"English" andMasterLan:fromMasterLan];
    NSString * str2=[str1 stringByAppendingFormat:@" - %@", [LanguageReference getLanForAppLan:@"English" andMasterLan:toMasterLan]];
    //Create and push the controller now
    EntryInDicViewController * controller=[[EntryInDicViewController alloc] init];
    controller.fromLan=fromMasterLan;
    controller.toLan=toMasterLan;
    controller.title=str2;
    [self.navigationController pushViewController:controller animated:YES];
    [self.myTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor=[UIColor clearColor];
}


#pragma mark -
#pragma mark Reimplementation from UIViewController 

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.myTableView setEditing:editing animated:animated];
}


#pragma mark -
#pragma mark DictionaryViewController methods

- (void) dictionaryWasModified
{
    //If I don't reinit the arrays, the information is appended, not replaced
    self.fromArray=[NSMutableArray arrayWithCapacity:5];
    self.toArray=[NSMutableArray arrayWithCapacity:5];
    [DictionaryHandler getDictinariesFrom:self.fromArray andTo:self.toArray];
    [self.myTableView reloadData];
}




@end
