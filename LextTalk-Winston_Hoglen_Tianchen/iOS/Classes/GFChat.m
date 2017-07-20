//
//  GFChat.m
// LextTalk
//
//  Created by David on 11/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GFChat.h"
#import "TeamReference.h"
#import "LTDataSource.h"


@implementation GFChat
@synthesize userId = _userId;
@synthesize teamId = _teamId;
@synthesize userName = _userName;
@synthesize messages = _messages;
@synthesize unreadMessages = _unreadMessages;

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
	if([self.userName rangeOfString: searchText options: NSCaseInsensitiveSearch].location != NSNotFound) {
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
	
	[self.cell.titleLabel setText: self.userName];
	if(self.unreadMessages == 0) {
		[self.cell.subtitleLabel setText: [NSString stringWithFormat: NSLocalizedString(@"%d messages", @"%d messages"), [self.messages count]]];    	
	} else {
		[self.cell.subtitleLabel setText: [NSString stringWithFormat: NSLocalizedString(@"%d messages (%d unread)", @"%d messages (%d unread)"), [self.messages count], self.unreadMessages]];    			
	}

    UIImage *img = [[TeamReference newImageForTeamWithId: 0] autorelease];
	[self.cell.leftImageView setImage: img];
	[self.cell setAccessoryType: UITableViewCellAccessoryDetailDisclosureButton];	
	return self.cell;	
}

#pragma mark -
#pragma mark GFChat methods

+ (GFChat*) newChat {
	GFChat *chat = [[GFChat alloc] init];
	[chat setMessages: [[NSMutableArray alloc] init]];
	return chat;
}

- (NSString*) newestMessage {
	return nil;
}

- (NSString*) oldestMessage {
	return nil;
}

- (void) dealloc {
    self.userName = nil;
	self.messages = nil;
	[super dealloc];
}
@end
