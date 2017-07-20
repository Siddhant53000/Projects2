//
//  GFDistanceStat.m
// LextTalk
//
//  Created by David on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GFDistanceStat.h"
#import "GFTeam.h"
#import "TeamReference.h"
#import "LextTalkAppDelegate.h"

@implementation GFDistanceStat

#pragma mark -
#pragma mark GFTableObjectProtocol methods
- (CGFloat) cellHeightInTableView:(UITableView *)tableView {
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {	
		return 74;
	} else {
		return 50;
	}		
}

- (BOOL) shouldAppearInContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	return NO;
}

- (void) showMe {
	LextTalkAppDelegate *del = (LextTalkAppDelegate*)[[UIApplication sharedApplication] delegate];
    [del goToUserAtLongitude: self.coordinate.longitude andLatitude: self.coordinate.latitude];
}

- (UITableViewCell*) cellInTableView: (UITableView *) tableView searchResult: (BOOL) search {
	
    static NSString *cellIdentifier = @"DefaultCell";
	
	self.cell = (GFDefaultCellView *)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
	if ( self.cell == nil ) {
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {	
			[self loadNibFile: @"GFDefaultCellView-iPad"];
		} else {
			[self loadNibFile: @"GFDefaultCellView-iPhone"];
		}
	}
	
	[self.cell.titleLabel setTextColor: [UIColor whiteColor]];
	[self.cell.titleLabel setShadowColor: [UIColor blackColor]];
	[self.cell.subtitleLabel setTextColor: [UIColor whiteColor]];
	[self.cell.subtitleLabel setShadowColor: [UIColor blackColor]];
	
	[self.cell.titleLabel setText: self.name];  
    [self.cell.subtitleLabel setText: [NSString stringWithFormat: NSLocalizedString(@"%d Km", @"%d Km"), (int)self.distance]];    	
	
	UIImage *img = [TeamReference newImageForTeamWithId: self.teamId];
	[self.cell.leftImageView setImage: img];
	[img release];
	
	[self.cell setAccessoryType: UITableViewCellAccessoryNone];		
	/*
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setImage:[UIImage imageNamed:@"locate_icon.png"] forState:UIControlStateNormal];

	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {		
		button.frame = CGRectMake(0, 0, 30, 30);
	} else {
		button.frame = CGRectMake(0, 0, 24, 24);
	}

	button.userInteractionEnabled = YES;
	[button addTarget:self action:@selector(showMe) forControlEvents:UIControlEventTouchDown];
	self.cell.accessoryView = button; 
	 */
	return self.cell;
}

@end
