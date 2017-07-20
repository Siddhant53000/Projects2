//
//  GFTeam.m
// LextTalk
//
//  Created by nacho on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GFTeam.h"
#import "TeamReference.h"
#import "GFDataSource.h"


@implementation GFTeam
@synthesize teamId, parentId;
@synthesize name = _name;

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
	if([self.name rangeOfString: searchText options: NSCaseInsensitiveSearch].location != NSNotFound) {
		return YES;
	}	
	return NO;
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
	
	if(search){
		[self.cell.titleLabel setTextColor: [UIColor blackColor]];
		[self.cell.titleLabel setShadowColor: [UIColor clearColor]];
		[self.cell.subtitleLabel setTextColor: [UIColor blackColor]];
		[self.cell.subtitleLabel setShadowColor: [UIColor clearColor]];
	} else {
		[self.cell.titleLabel setTextColor: [UIColor whiteColor]];
		[self.cell.titleLabel setShadowColor: [UIColor blackColor]];
		[self.cell.subtitleLabel setTextColor: [UIColor whiteColor]];
		[self.cell.subtitleLabel setShadowColor: [UIColor blackColor]];
	}
	
	[self.cell.titleLabel setText: self.name];
    [self.cell.subtitleLabel setText: @""];    	
	
	UIImage *img = [TeamReference newImageForTeamWithId: self.teamId];
	[self.cell.leftImageView setImage: img];
	[img release];	

	[self.cell setAccessoryType: UITableViewCellAccessoryNone];		
	
	if(self.teamId == [[GFDataSource sharedDataSource] localUser].teamId) {
		if(search)
			self.cell.accessoryView = [[[UIImageView alloc] initWithImage: [UIImage imageNamed: @"checkmark_black.png"]]autorelease];
		else
			self.cell.accessoryView = [[[UIImageView alloc] initWithImage: [UIImage imageNamed: @"checkmark.png"]]autorelease];
	} else {
		self.cell.accessoryView = nil;
	}
	return self.cell;	
}

#pragma mark -
#pragma mark GFTeam methods
+ (GFTeam*) newTeamWithName: (NSString*) n parentId: (NSInteger) p andId: (NSInteger) i {
	GFTeam *team = [[GFTeam alloc] init];
    [team setName: n];    
	[team setParentId: p];
	[team setTeamId: i];
	return team;
}

- (void) dealloc {
	self.name = nil;
	[super dealloc];
}

@end
