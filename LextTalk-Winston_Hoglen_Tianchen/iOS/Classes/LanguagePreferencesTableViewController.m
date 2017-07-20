//
//  LanguagePreferencesTableViewController.m
//  LextTalk
//
//  Created by Isaaca Hoglen on 10/6/16.
//
//

#import "LanguagePreferencesTableViewController.h"
#import "LTUser.h"
#import "LTDataSource.h"
#import "AddNewLanguageViewController.h"

@interface LanguagePreferencesTableViewController ()
@property (strong, nonatomic) NSMutableArray *languages;
@property (strong, nonatomic) NSArray *headers;
@end

@implementation LanguagePreferencesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Language Preferences"];
    LTUser *currUser = [[LTDataSource sharedDataSource] localUser];
    _languages = [[NSMutableArray alloc] init];
    if (currUser.speakingLanguages.count > 0) {
        [_languages addObject:currUser.speakingLanguages];
    } else {
        NSArray *tempArray = [[NSArray alloc] initWithObjects:@" ", nil];
        [_languages addObject:tempArray];
    }
    if (currUser.learningLanguages.count > 0) {
        [_languages addObject:currUser.learningLanguages];
    } else {
        NSArray *tempArray = [[NSArray alloc] initWithObjects:@" ", nil];
        [_languages addObject:tempArray];
    }

    _headers = [[NSArray alloc] initWithObjects:@"Native Languages", @"Languages Learning", nil];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _languages = [[NSMutableArray alloc] init];
    LTUser *currUser = [[LTDataSource sharedDataSource] localUser];
    if (currUser.speakingLanguages.count > 0) {
        [_languages addObject:currUser.speakingLanguages];
    } else {
        NSArray *tempArray = [[NSArray alloc] initWithObjects:@" ", nil];
        [_languages addObject:tempArray];
    }
    if (currUser.learningLanguages.count > 0) {
        [_languages addObject:currUser.learningLanguages];
    } else {
        NSArray *tempArray = [[NSArray alloc] initWithObjects:@" ", nil];
        [_languages addObject:tempArray];
    }
    [self.tableView reloadData];
}

- (void) addItem:(id) sender {
    AddNewLanguageViewController *newVC = [[AddNewLanguageViewController alloc] init];
    [self.navigationController showViewController:newVC sender:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_headers count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_headers objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionItems = [_languages objectAtIndex:(NSUInteger) section];
    NSUInteger numRows = [sectionItems count];
    return numRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentfier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentfier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentfier];
    }
    NSArray *sectionLangs = [_languages objectAtIndex:indexPath.section];
    NSString *language = [sectionLangs objectAtIndex:indexPath.row];
    cell.textLabel.text = language;
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
