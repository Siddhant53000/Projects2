//
//  ContactViewController.m
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 23/03/14.
//
//

#import "ContactViewController.h"
#import "GeneralHelper.h"
#import "UIColor+ColorFromImage.h"
#import "LTDataSource.h"
#import <AddressBook/AddressBook.h>
#import "MBProgressHUD.h"
#import "LextTalkAppDelegate.h"

//Pendientes
// Invitar a usar la app si nadie de sus contactos la está ussando, utilizar Facebook y Twitter
// Poner bien los badges


@interface ContactViewController ()

@property (nonatomic, strong) MBProgressHUD * HUD;
@property (nonatomic) BOOL contactUpdateAlreadyOffered;

@property (nonatomic) BOOL fbContactsAvailable;
@property (nonatomic, strong) UIRefreshControl * refreshControl;

@end

@implementation ContactViewController

//This is the right init, UserListViewController does still have a xib
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginUser) name:@"LTDidLoginUser" object:nil];
    }
    return self;
}

- (void) dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    //Navigation bar color
    if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 7)
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"bar-teja-ios7"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] forBarMetrics:UIBarMetricsDefault];
    else
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"bar-teja"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] forBarMetrics:UIBarMetricsDefault];
    
    [GeneralHelper setTitleTextAttributesForController:self];
    
    self.searchDisplayController.searchBar.backgroundImage = [[UIImage imageNamed:@"search-teja"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    self.searchDisplayController.searchBar.tintColor = [UIColor colorFromImage:[UIImage imageNamed:@"search-teja"]];
    
    self.searchDisplayController.searchBar.placeholder = NSLocalizedString(@"Filter", nil);
    
    //Refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(contactUpdateWithQuestion) forControlEvents:UIControlEventValueChanged];
    [self.objectTableView addSubview:self.refreshControl];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Doing this in "init" does not work, session has not been initiated yet, and contacts are saved with the UserId
    //in order to be able to share several accounts in one device
    if (self.objectList == nil)
    {
        self.objectList = [[LTDataSource sharedDataSource] getUserContacts];
        [self.objectTableView reloadData];
    }
    
    if (([self.objectList count] == 0) && (!self.contactUpdateAlreadyOffered))
        [self contactUpdateWithQuestion];
    
    if ([LTDataSource sharedDataSource].localUser == nil)
    {
        LextTalkAppDelegate * del = (LextTalkAppDelegate *) [UIApplication sharedApplication].delegate;
        [del tellUserToSignIn];
    }
    
    
    if ( ![[LTDataSource sharedDataSource] openSessionWithAllowLoginUI:NO withDelegate:self withFacebokAction:LTFacebookActionTestContacts])
        [self didTestFacebookForContacts:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ContactViewController Methods

- (void) didLoginUser
{
    self.objectList = [[LTDataSource sharedDataSource] getUserContacts];
    [self.objectTableView reloadData];
}

- (void) connectToFB
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connect to Facebook", nil) message:NSLocalizedString(@"Would you like to connect to Facebook to find your friends who are in Lext Talk?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    alert.tag = 2;
    [alert show];
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

#pragma mark -
#pragma mark LTDataDelegate methods

//El método de fallo está en el contraldor padre
- (void) didUpdateSearchResultsUsers:(NSArray *)results
{
    //NSLog(@"Results: %@", results);
    
    [self.HUD hide:YES];
    self.HUD = nil;
    
    reloading = NO;
    [self.refreshControl endRefreshing];
    
    self.objectList = results;
    [self.objectTableView reloadData];
    
    
    if ([results count] == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No contacts found", nil)
                                                          message:NSLocalizedString(@"None of your contacts seem to be using Lext Talk. Tell them about it!", nil)
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"No", nil)
                                                otherButtonTitles: NSLocalizedString(@"Yes", nil), nil];
        alert.tag = 1;
        [alert show];
    }
    
}

- (void) didTestFacebookForContacts:(BOOL)fbAvailable
{
    if (fbAvailable)
        self.navigationItem.rightBarButtonItem = nil;
    else
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"+FB", nil) style:UIBarButtonItemStylePlain target:self action:@selector(connectToFB)];
}

- (void) didConnectToFacebookForContacts
{
    self.navigationItem.rightBarButtonItem = nil;
    [self contactUpdate];
}

- (void) didFail:(NSDictionary *)result
{
    //NSLog(@"DidFail: ");
    [self.HUD hide:YES];
    self.HUD = nil;
    
    reloading = NO;
    [self.refreshControl endRefreshing];
    
    [super didFail:result];
}

#pragma mark -
#pragma mark LTDataDelegate methods

- (void) contactUpdateWithQuestion
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Find your friends!", nil)
                                                     message:NSLocalizedString(@"Would you like to have your contacts searched to find the people who are already in Lext Talk?", nil)
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"No", nil)
                                           otherButtonTitles: NSLocalizedString(@"Yes", nil), nil];
    [alert show];
}

- (void) contactUpdate
{
    self.contactUpdateAlreadyOffered = YES;
    [self.refreshControl beginRefreshing];
    
    CFErrorRef errorRef;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &errorRef);
    
    __block BOOL accessGranted = NO;
    //See if an explanation can be used when permission to search the contacts is asked.
    //User an UIAlertView if it is not possible.

    //bloqueo la app para que no se pueda interactuar con ella hasta que el usuario conteste
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    ABAddressBookRequestAccessWithCompletion(addressBook,^(bool granted, CFErrorRef error) {
                                                 accessGranted=granted;
                                                 //desbloqueo la app
                                                 dispatch_semaphore_signal(sema);
                                             });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    if (accessGranted)
    {
        reloading = YES;
        
        self.HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.view];
        [self.tabBarController.view addSubview:self.HUD];
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        self.HUD.labelText = NSLocalizedString(@"Searching...", nil);
        [self.HUD show:YES];
        
        dispatch_queue_t queue0=dispatch_queue_create("AddressBook & Parse", NULL);
        dispatch_async(queue0, ^{
            
            //Extraigo todos los e-mails
            NSMutableArray * array=[NSMutableArray array];
            
            if (addressBook!=NULL)
            {
                CFArrayRef allPeopleRef = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, nil, kABPersonSortByFirstName);
                CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
                
                for( int i = 0 ; i < nPeople ; i++ ) {
                    ABRecordRef ref = CFArrayGetValueAtIndex(allPeopleRef, i );
                    ABMultiValueRef emails = ABRecordCopyValue(ref, kABPersonEmailProperty);
                    for (int j = 0; j< ABMultiValueGetCount(emails); j++)
                    {
                        //NSString * email= (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(emails, j);
                        NSString * email= CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails, j)); //No ARC
                        [array addObject:email];
                        //NSLog(@"E-mail: %@", email);
                    }
                    CFRelease(emails);//no estaba en el ejemplo de la doc de Apple
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (([array count] > 0))
                {
                    //Hay que ponerlo?????
                    reloading = YES;
                    self.HUD.labelText = NSLocalizedString(@"Searching...", nil);
                    if (self.navigationItem.rightBarButtonItem == nil)
                        [[LTDataSource sharedDataSource] searchUserContacts:array withDelegate:self useFacebook:YES];
                    else
                        [[LTDataSource sharedDataSource] searchUserContacts:array withDelegate:self useFacebook:NO];
                    
                    
                }
                else //Dar mensaje avisando de que no se ha  podido recorrer los contactos
                {
                    [self.HUD hide:YES];
                    self.HUD = nil;
                    reloading = NO;
                    [self.refreshControl endRefreshing];
                    
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                      message:NSLocalizedString(@"Your contacts couldn't be searched.", nil)
                                                                     delegate:nil
                                                            cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                            otherButtonTitles: nil];
                    [alert show];
                }
                
            });
        });
         //Cuando pongo el target a iOS 6.0 no puedo tenerlo
    }
    else //Access not granted
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Permission needed", nil)
                                                          message:NSLocalizedString(@"Finding who in your contacts  are using Lext Talk requires permission. You can authorise Lext Talk to do that in your device settings: Privacy / Contacts", nil)
                                                         delegate:nil
                                                cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark -
#pragma mark Table view data source

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (tableView == self.objectTableView)
        return YES;
    else
        return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Delete from the favorites if it is present there
        LTUser * user = [self.objectList objectAtIndex:indexPath.row];
        [[LTDataSource sharedDataSource] deleteUserFromStoredUserContactsFromChats:user];
        
        NSMutableArray * array = [NSMutableArray arrayWithArray:self.objectList];
        [array removeObjectAtIndex:indexPath.row];
        self.objectList = array;
        
        [[LTDataSource sharedDataSource] saveUserContacts:self.objectList];
        
        [self.objectTableView beginUpdates];
        [self.objectTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self.objectTableView endUpdates];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray * array = [NSMutableArray arrayWithArray:self.objectList];
    
    LTUser * user = [array objectAtIndex:fromIndexPath.row];
    [array removeObjectAtIndex:fromIndexPath.row];
    [array insertObject:user atIndex:toIndexPath.row];
    
    self.objectList = array;
    [[LTDataSource sharedDataSource] saveUserContacts:array];
}




// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    if (tableView == self.objectTableView)
        return YES;
    else
        return NO;
}

#pragma mark -
#pragma mark Reimplementation from UIViewController

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    
    [super setEditing:editing animated:animated];
    [self.objectTableView setEditing:editing animated:animated];
}

#pragma mark -
#pragma mark UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0)
    {
        if (buttonIndex == 1)
            [self contactUpdate];
        else
            [self.refreshControl endRefreshing];
    }
    else if (alertView.tag == 1)
    {
        if (buttonIndex == 1)
        {
            //Eventually move to the DataSource instead of using the map
            LextTalkAppDelegate * del = (LextTalkAppDelegate *) [UIApplication sharedApplication].delegate;
            [del.mapViewController share];
        }
    }
    else if (alertView.tag == 2)
    {
        if (buttonIndex == 1)
        {
            [[LTDataSource sharedDataSource] openSessionWithAllowLoginUI:YES withDelegate:self withFacebokAction:LTFacebookActionContacts];
        }
    }
}

@end
