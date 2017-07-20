//
//  LocationTableViewController.m
//  LextTalk
//
//  Created by Isaaca Hoglen on 10/11/16.
//
//

#import "LocationTableViewController.h"
#import "LTDataSource.h"
@interface LocationTableViewController ()
@property (strong, nonatomic) NSMutableArray *location;
@end

@implementation LocationTableViewController

- (void)viewDidLoad {
    
    // Geocoding not necessary (mentioned in meeting on November 7th, 2016) w/ Antonio
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Location"];
    _location = [[NSMutableArray alloc] init];
    LTUser *currUser = [[LTDataSource sharedDataSource] localUser];
    __block NSString *userLocation;
    CLLocationCoordinate2D currUserCoords = currUser.coordinate;
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:currUserCoords.latitude longitude:currUserCoords.longitude];
    CLGeocoder *ceo = [[CLGeocoder alloc] init];
    [ceo reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placeMark = [placemarks objectAtIndex:0];
        userLocation = [[placeMark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
    }];
    [_location addObject:userLocation];
    if ([_location count] > 0) NSLog(@"Location2: %@", [_location objectAtIndex:0]);
    
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
    return [_location count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentfier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentfier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentfier];
    }
    cell.textLabel.text = [_location objectAtIndex:indexPath.row];
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
