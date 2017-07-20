//
//  ContactInfoTableViewController.m
//  LextTalk
//
//  Created by Isaaca Hoglen on 10/5/16.
//
//

#import "ContactInfoTableViewController.h"
#import "LTUser.h"
#import "LTDataSource.h"

@interface ContactInfoTableViewController ()
@property (strong, nonatomic) NSMutableArray *allContactInfo;
@end

@implementation ContactInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _allContactInfo = [[NSMutableArray alloc] init];
    [self.navigationItem setTitle:@"Contact Information"];
    LTUser *currUser = [[LTDataSource sharedDataSource] localUser];
    
    if (currUser.name) [_allContactInfo addObject:[NSString stringWithFormat:@"Username: %@", currUser.name]];
    if (currUser.address) [_allContactInfo addObject:[NSString stringWithFormat:@"Address: %@", currUser.address]];
    if (currUser.mail) [_allContactInfo addObject:[NSString stringWithFormat:@"Mail: %@", currUser.mail]];
    if (currUser.screenName) [_allContactInfo addObject:[NSString stringWithFormat:@"Screenname: %@", currUser.screenName]];
    if (currUser.twitter) [_allContactInfo addObject:[NSString stringWithFormat:@"Twitter: %@", currUser.twitter]];
    /*
    [_allContactInfo setObject:currUser.name forKey:@"name"];
    [_allContactInfo setObject:currUser.address forKey:@"address"];
    [_allContactInfo setObject:currUser.mail forKey:@"mail"];
    [_allContactInfo setObject:currUser.screenName forKey:@"screenname"];
    [_allContactInfo setObject:currUser.twitter forKey:@"url"];
    */
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_allContactInfo count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentfier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentfier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentfier];
    }
    cell.textLabel.text = [_allContactInfo objectAtIndex:indexPath.row];
    //cell.textLabel.text = @"cellIdentifier";
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
