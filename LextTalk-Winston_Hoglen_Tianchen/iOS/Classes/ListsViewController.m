//
//  ListsViewController.m
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 16/03/14.
//
//

#import "ListsViewController.h"
#import "UIColor+ColorFromImage.h"
#import "GeneralHelper.h"

@interface ListsViewController ()

@property (strong, nonatomic) UIView * containerView;

@end

@implementation ListsViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _chatSelected = YES;
    }
    return self;
}

- (void)dealloc {
    self.containerView = nil;
}

- (void) loadView
{
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
	UIView *view = [[UIView alloc] initWithFrame:frame];
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	//view.backgroundColor = [UIColor blueColor];
    
	// set up content view a bit inset
	//frame = CGRectMake(0, 50, view.bounds.size.width, view.bounds.size.height - 50);
	self.containerView = [[UIView alloc] initWithFrame:frame];
	//self.containerView.backgroundColor = [UIColor redColor];
	self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[view addSubview:self.containerView];
    
	// from here on the container is automatically adjusting to the orientation
	self.view = view;
    
    
    //Segmented Controller to switch between controllers
    UISegmentedControl * seg = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Chats", nil), NSLocalizedString(@"Chat rooms", nil), nil]];
    seg.selectedSegmentIndex = 0;
//    seg.segmentedControlStyle = UISegmentedControlStyleBar;
    [seg addTarget: self action: @selector(segmentChanged:) forControlEvents: UIControlEventValueChanged];
    self.navigationItem.titleView = seg;
    if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 7)
    {
        seg.tintColor = [UIColor whiteColor];
        NSShadow *shadow = [[NSShadow alloc] init];
        [shadow setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
        NSDictionary * dic1 = [NSDictionary dictionaryWithObjectsAndKeys:
                               [UIFont fontWithName:@"Ubuntu-Bold" size:12], NSFontAttributeName,
                               [UIColor colorFromImage:[UIImage imageNamed:@"search-blue"]], NSForegroundColorAttributeName,
                               shadow, NSShadowAttributeName, nil];
        NSDictionary * dic2 = [NSDictionary dictionaryWithObjectsAndKeys:
                               [UIFont fontWithName:@"Ubuntu-Bold" size:12], NSFontAttributeName,
                               [UIColor whiteColor], NSForegroundColorAttributeName,
                               shadow, NSShadowAttributeName, nil];
        
        [seg setTitleTextAttributes:dic1 forState:UIControlStateSelected];
        [seg setTitleTextAttributes:dic2 forState:UIControlStateHighlighted];
        [seg setTitleTextAttributes:dic2 forState:UIControlStateNormal];
        [seg setTitleTextAttributes:dic2 forState:UIControlStateDisabled];
    }
    else
        seg.tintColor = [UIColor colorFromImage:[UIImage imageNamed:@"search-blue"]];
    
    
    
    [GeneralHelper setTitleTextAttributesForController:self];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-background"]];
    
    self.viewToLayout = self.containerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Color de la barra
    if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 7)
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"bar-blue-ios7"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] forBarMetrics:UIBarMetricsDefault];
    else
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"bar-blue"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] forBarMetrics:UIBarMetricsDefault];
    
    //self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-back"] landscapeImagePhone:[UIImage imageNamed:@"arrow-back"] style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
    
    /*  Disable AdInheritanceViewController   */
    self.disableAds = YES;
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIViewController * controller;
    if (self.chatSelected)
        controller = self.chatListViewController;
    else
        controller = self.chatRoomListViewController;
    
    if (controller.parentViewController == self)
        return;
    
    // adjust the frame to fit in the container view
	controller.view.frame = self.containerView.bounds;
	// make sure that it resizes on rotation automatically
	controller.view.autoresizingMask = self.containerView.autoresizingMask;
	// add as child VC
	[self addChildViewController:controller];
	// add it to container view, calls willMoveToParentViewController for us
	[self.containerView addSubview:controller.view];
	// notify it that move is done
	[controller didMoveToParentViewController:self];
}

- (void) setChatSelected:(BOOL)chatSelected
{
    _chatSelected = chatSelected;
    
    UIViewController * fromViewController;
    UIViewController * toViewController;
    if (chatSelected)
    {
        fromViewController = self.chatRoomListViewController;
        toViewController = self.chatListViewController;
    }
    else
    {
        fromViewController = self.chatListViewController;
        toViewController = self.chatRoomListViewController;
    }
    
    // animation setup
	toViewController.view.frame = self.containerView.bounds;
	toViewController.view.autoresizingMask = self.containerView.autoresizingMask;
    
	// notify
	[fromViewController willMoveToParentViewController:nil];
	[self addChildViewController:toViewController];
    
    
    [self transitionFromViewController:fromViewController
                      toViewController:toViewController
                              duration:0.0
                               options:UIViewAnimationOptionTransitionNone
                            animations:^{
                                
                            } completion:^(BOOL finished) {
                                [toViewController didMoveToParentViewController:self];
                                [fromViewController removeFromParentViewController];
                                
                                self.navigationItem.leftBarButtonItem = toViewController.navigationItem.leftBarButtonItem;
                                self.navigationItem.rightBarButtonItem = toViewController.navigationItem.rightBarButtonItem;
                            }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void) segmentChanged:(UISegmentedControl * ) seg
{
    NSLog(@"seg.selectedSegmentIndex !! %ld", (long)seg.selectedSegmentIndex);
    if (seg.selectedSegmentIndex == 0)
        self.chatSelected = YES;
    else
        self.chatSelected = NO;
}

@end
