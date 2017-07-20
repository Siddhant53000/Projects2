//
//  DictionaryTableViewController.m
//  LextTalk
//
//  Created by Isaaca Hoglen on 10/11/16.
//
//

#import "DictionaryTableViewController.h"
#import "DictionaryDBHandler.h"
#import "DictionaryDefinitionViewController.h"
#import "NewDictionaryViewController.h"

@interface DictionaryTableViewController ()
@property (strong, nonatomic) NSArray* dictWords;
@end

@implementation DictionaryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Dictionary"];
    _dictWords = [[DictionaryDBHandler getSharedInstance] getUserDictionary].allKeys;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) addItem:(id)sender {
    NewDictionaryViewController *newDict = [[NewDictionaryViewController alloc] init];
    [self.navigationController showViewController:newDict sender:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dictWords.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentfier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentfier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentfier];
    }
    cell.textLabel.text = [_dictWords objectAtIndex:indexPath.row];
    //cell.textLabel.text = @"cellIdentifier";
    return cell;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _dictWords = [[DictionaryDBHandler getSharedInstance] getUserDictionary].allKeys;
    [self.tableView reloadData];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [_dictWords objectAtIndex:indexPath.row];
    DictionaryDefinitionViewController *dictVC = [[DictionaryDefinitionViewController alloc] init];
    [dictVC setWordToDefine:key];
    [dictVC setDefinition:[[[DictionaryDBHandler getSharedInstance] getUserDictionary] objectForKey:key]];
    [self.navigationController showViewController:dictVC sender:self];
    
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
        NSString* wordToDelete = [_dictWords objectAtIndex:indexPath.row];
        [[DictionaryDBHandler getSharedInstance] deleteFromDatabase:wordToDelete];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
