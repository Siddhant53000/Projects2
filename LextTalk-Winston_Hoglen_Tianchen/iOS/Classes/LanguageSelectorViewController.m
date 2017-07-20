//
//  LanguageSelectorViewController.m
// LextTalk
//
//  Created by Yo on 10/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LanguageSelectorViewController.h"
#import "LanguageReference.h"
#import "GeneralHelper.h"

@interface LanguageSelectorViewController()
@property (nonatomic, strong) LanguageSelectorController * controller;
@end

@implementation LanguageSelectorViewController
@synthesize textArray, multiple, delegate, selectedItems, textTag, flagIndexForSelectedItems, preferredFlagForLan, showFlags;
@synthesize controller;

#pragma mark - View lifecycle

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
 */

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    self.myTableView=[[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStylePlain];
    self.view=[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    [self.view addSubview:self.myTableView];
    self.myTableView.frame=self.view.frame;
    self.myTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    
    self.scrollViewToLayout = self.myTableView;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self showWallpaper];
    
    //Uncomment if a wallpaper is going to be used
    //self.myTableView.backgroundColor=[UIColor clearColor];
    
    if (self.multiple)
    {
        self.controller=[[LanguageSelectorController alloc] initWithMultipleSelectionTableView:self.myTableView textArray:self.textArray selectedItems:self.selectedItems flagIndexForSelectedItems:self.flagIndexForSelectedItems textTag:self.textTag delegate:self];
        
        //Title
        self.title=NSLocalizedString(@"Select languages", "Select languages");
    }
    else
    {
        self.controller=[[LanguageSelectorController alloc] initWithSingleSelectionTableView:self.myTableView textArray:self.textArray selectedItems:self.selectedItems preferredFlagForLan:self.preferredFlagForLan showFlags:YES textTag:self.textTag delegate:self];
        
        //Title
        self.title=NSLocalizedString(@"Select language", "Select language");
    }
    
    self.navigationItem.leftBarButtonItem = [GeneralHelper plainBarButtonItemWithText:nil image:[UIImage imageNamed:@"arrow-back"] target:self selector:@selector(popViewController)];
}

- (void) popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    self.myTableView=nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) viewWillAppear:(BOOL)animated
{
    //Before calling the super method
    CGRect frame = self.view.frame;
    frame.origin = CGPointMake(0, 0);
    self.myTableView.frame=frame;
    
    [super viewWillAppear:animated];
    [self.myTableView flashScrollIndicators];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.myTableView flashScrollIndicators];
}

#pragma mark - LanguageSelectorControllerDelegate

- (void) selectedItem:(NSString *)selected2 withTextTag:(NSString *)textTag2
{
    if ([self.delegate respondsToSelector:@selector(selectedItem:withTextTag:)])
        [self.delegate selectedItem:selected2 withTextTag:textTag2];
}

- (void) selectedItems:(NSArray *)selectedItems2 withFlags:(NSArray *)flags2 withTextTag:(NSString *)textTag2
{
    if ([self.delegate respondsToSelector:@selector(selectedItems:withFlags:withTextTag:)])
        [self.delegate selectedItems:selectedItems2 withFlags:flags2 withTextTag:textTag2];
}


@end
