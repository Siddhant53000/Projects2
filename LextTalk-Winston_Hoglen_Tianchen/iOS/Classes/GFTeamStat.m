//
//  GFTeamStat.m
// LextTalk
//
//  Created by David on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GFTeamStat.h"
#import "GFTeam.h"
#import "TeamReference.h"

@implementation GFTeamStat
@synthesize teamId = _teamId;
@synthesize followers = _followers;
@synthesize percentage = _percentage;

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
	
    GFTeam *team = [TeamReference newTeamWithId: self.teamId];

	[self.cell.titleLabel setText: team.name];  
    [self.cell.subtitleLabel setText: [NSString stringWithFormat: NSLocalizedString(@"%d followers (%2.1f\%%)", @"%d followers (%2.1f\%%)"), self.followers, self.percentage]];    	
	
	UIImage *img = [TeamReference newImageForTeamWithId: self.teamId];
	[self.cell.leftImageView setImage: img];
	[img release];
	[team release];
	
	[self.cell setAccessoryType: UITableViewCellAccessoryNone];	
	
	return self.cell;	
}

#pragma mark -
#pragma mark GFTeamStat methods

+ (GFTeamStat*) newTeamStatWithDict: (NSDictionary*) d {
    GFTeamStat *result = [[GFTeamStat alloc] init];
    
    [result setTeamId: [result integerForKey: @"team_id" inDict: d]];
    [result setFollowers: [result integerForKey: @"followers" inDict: d]];
    
    return result;
}

- (void) dump {
	IQVerbose(VERBOSE_DEBUG,@"TeamId: %d", self.teamId);
	IQVerbose(VERBOSE_DEBUG,@"Followers: %d", self.followers);
}

@end
