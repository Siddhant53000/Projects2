/*
 *  IQTableViewProtocol.h
 *
 *  Created by David on 12/23/10.
 *  Copyright 2010 InQBarna. All rights reserved.
 *
 */

@class IQTableObject;

@protocol IQTableViewProtocol
@optional

- (UITableViewCellEditingStyle) editingStyleInTableView: (UITableView*) tableView;
- (BOOL) canBeEdited;
- (void) deletedInTableView: (UITableView*) tableView andViewController: (UIViewController*) viewController;

- (BOOL) shouldAppearInContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
- (void) didUpdateTableObject: (IQTableObject<IQTableViewProtocol>*) object;

- (UITableViewCell*) cellInTableView: (UITableView *)tableView searchResult: (BOOL) search;
- (CGFloat) cellHeightInTableView:(UITableView *)tableView;

- (UITableViewCell*) detailCellInTableView: (UITableView *)tableView;
- (CGFloat) detailCellHeightInTableView:(UITableView *)tableView;

@end

