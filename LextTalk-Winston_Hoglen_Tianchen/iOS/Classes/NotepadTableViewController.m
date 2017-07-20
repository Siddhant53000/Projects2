//
//  NotepadTableViewController.m
//  LextTalk
//
//  Created by Isaaca Hoglen on 10/11/16.
//
//

#import "NotepadTableViewController.h"
#import "LTUser.h"
#import "LTDataSource.h"
#import "NotepadHandler.h"
#import "NewNoteViewController.h"

@interface NotepadTableViewController ()
@property (strong, nonatomic) LTUser *currUser;
@end

@implementation NotepadTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _currUser = [[LTDataSource sharedDataSource] localUser];
    [self.navigationItem setTitle:@"Notepad"];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addItem:(id)sender {
    NewNoteViewController *newVC = [[NewNoteViewController alloc]init];
    [self.navigationController showViewController:newVC sender:self];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[NotepadHandler getSharedInstance] getUserNotepad].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentfier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentfier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentfier];
    }
    cell.textLabel.text = [[[NotepadHandler getSharedInstance] getUserNotepad] objectAtIndex:indexPath.row];
    //cell.textLabel.text = @"cellIdentifier";
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSString* noteToDelete = [[[NotepadHandler getSharedInstance] getUserNotepad] objectAtIndex:indexPath.row];
        [[NotepadHandler getSharedInstance] deleteFromDatabase:noteToDelete];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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

@end
