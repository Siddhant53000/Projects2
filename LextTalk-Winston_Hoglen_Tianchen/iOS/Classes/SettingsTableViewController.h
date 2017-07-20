//
//  SettingsTableViewController.h
//  LextTalk
//
//  Created by Isaaca Hoglen on 10/4/16.
//
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSArray *settingsArray;
@end
