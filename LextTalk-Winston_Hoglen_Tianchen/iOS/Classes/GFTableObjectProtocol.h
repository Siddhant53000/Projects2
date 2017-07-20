/*
 *  GFTableObject.h
 *  GlocalFans
 *
 *  Created by David on 12/23/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
@protocol GFTableObjectProtocol
@required
- (UITableViewCell*) cellInTableView: (UITableView *)tableView searchResult: (BOOL) search;
- (BOOL) shouldAppearInContentForSearchText:(NSString*)searchText scope:(NSString*)scope;

@optional

- (CGFloat) cellHeightInTableView:(UITableView *)tableView;
@end

