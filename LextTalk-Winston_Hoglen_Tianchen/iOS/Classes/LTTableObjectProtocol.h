/*
 *  GFTableObject.h
 *  GlocalFans
 *
 *  Created by David on 12/23/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
@protocol LTTableObjectProtocol
@required
- (UITableViewCell*) cellInTableView: (UITableView *)tableView withIndexPath:(NSIndexPath *) indexPath searchResult: (BOOL) search;
- (BOOL) shouldAppearInContentForSearchText:(NSString*)searchText scope:(NSString*)scope;

@optional

- (CGFloat) cellHeightInTableView:(UITableView *)tableView;



@end


@protocol LTTableMessageProtocol
@required

- (UITableViewCell*) cellInTableView: (UITableView *)tableView 
                     withOrientation: (UIInterfaceOrientation) orientation
                             addTime: (BOOL) time 
                          isChatroom: (BOOL) chatroom;

- (CGFloat) cellHeightInTableView: (UITableView *)tableView 
                  withOrientation: (UIInterfaceOrientation) orientation
                         withTime: (BOOL) time
                       isChatroom: (BOOL) chatroom;

@end