//
//  DefInDicIPadViewController.m
//  LextTalk
//
//  Created by Yo on 11/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DefInDicViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GeneralHelper.h"

@interface DefInDicViewController ()

@property (nonatomic, strong) UITextView * myTextView;
@property (nonatomic, strong) UIView * blindView;

@end

@implementation DefInDicViewController
@synthesize myTextView, text;

- (CGSize) contentSizeForViewInPopover
{
    CGSize size=CGSizeMake(320, 320);
    return size;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    self.myTextView=[[UITextView alloc] initWithFrame:CGRectMake(20, 20, 280, 280)];
    self.view=[[UIView alloc] init];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.blindView = [[UIView alloc] init];
    self.blindView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.blindView];
    
    [self.blindView addSubview:self.myTextView];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    
    self.viewToLayout = self.blindView;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self showWallpaper];
    
    [self.myTextView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]]; 
    [self.myTextView.layer setBorderWidth:2.0];
    self.myTextView.editable=NO;
    self.myTextView.layer.cornerRadius=10;
    self.myTextView.clipsToBounds=YES;
    self.myTextView.text=self.text;
    self.myTextView.font=[UIFont fontWithName:@"Helvetica" size:17];
    
    
    self.navigationItem.leftBarButtonItem = [GeneralHelper plainBarButtonItemWithText:nil image:[UIImage imageNamed:@"arrow-back"] target:self selector:@selector(popViewController)];
}

- (void) popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    self.myTextView=nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void) rotateToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        BOOL navigationBarHidden = self.navigationController.navigationBarHidden;
        if (self.navigationController == nil)
            navigationBarHidden = YES;
        
        
        if (toInterfaceOrientation==UIInterfaceOrientationPortrait || toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
            self.myTextView.frame=CGRectMake(20, 20, self.view.bounds.size.width - 40.0, 280);
        else 
            self.myTextView.frame=CGRectMake(20, 20, self.view.bounds.size.width - 40.0, 130);
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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self rotateToInterfaceOrientation:self.interfaceOrientation];
}



@end
