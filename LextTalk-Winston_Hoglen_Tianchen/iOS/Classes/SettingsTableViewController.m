//
//  SettingsTableViewController.m
//  LextTalk
//
//  Created by Isaaca Hoglen on 10/4/16.
//
//

#import "SettingsTableViewController.h"
#import "ContactInfoTableViewController.h"
#import "LocationTableViewController.h"
#import "LanguagePreferencesTableViewController.h"
#import "DictionaryTableViewController.h"
#import "NotepadTableViewController.h"
#import "LocationViewController.h"

@interface SettingsTableViewController ()
@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Settings"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[self.navigationController navigationBar] setBarTintColor:[UIColor colorWithRed:241.0/255.0 green:111.0/255.0 blue:90/255.0 alpha:1.0]];
    self.settingsArray = [NSArray arrayWithObjects: @"Language Preferences", @"Location", @"Contact Information", @"Dictionary", @"Notepad", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //_settingsArray = [[NSMutableArray alloc] initWithObjects:@"Language Preferences", @"Location", @"Contact Information", "@Dictionary", @"Notepad", nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.settingsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentfier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentfier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentfier];
    }
    cell.textLabel.text = [self.settingsArray objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *newVC;
    switch (indexPath.row) {
        case 0:
        {
            newVC = [[LanguagePreferencesTableViewController alloc] init];
            break;
        }
        case 1:
        {
            newVC = [[LocationViewController alloc] init];
            break;
        }
        case 2:
        {
            newVC = [[ContactInfoTableViewController alloc] init];
            break;
        }
        case 3:
        {
            newVC = [[DictionaryTableViewController alloc] init];
            break;
        }
        case 4:
        {
            newVC = [[NotepadTableViewController alloc] init];
            break;
        }
            
        default:
            break;
    }
    [self.navigationController showViewController:newVC sender:self];
    
}
@end
