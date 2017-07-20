//
//  GFGroup.m
// LextTalk
//
//  Created by David on 11/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GFGroup.h"
#import "TeamReference.h"


@implementation GFGroup
@synthesize name = _name;
@synthesize groupId, parentId;

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
	UIImage *img = [TeamReference newImageForGroupWithId: self.groupId];
	[self.cell.leftImageView setImage: img];
	[img release];
	[self.cell setAccessoryType: UITableViewCellAccessoryDetailDisclosureButton];	
	
	return self.cell;	
}

#pragma mark -
#pragma mark GFGroup methods
+ (GFGroup*) newGroupWithName: (NSString*) n parentId: (NSInteger) p andId: (NSInteger) i {
	GFGroup *group = [[GFGroup alloc] init];
	[group setName: n];
	[group setGroupId: i];
	[group setParentId: p];
	return group;
}

- (void) dealloc {
	self.name = nil;
	[super dealloc];
}

@end
