//
//  GFMessage.m
// LextTalk
//
//  Created by David on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GFMessage.h"
#import "TeamReference.h"
#import "LTDataSource.h"

@interface GFMessage (PrivateMethods)
- (UIView*) newViewForMessage;
@end


@implementation GFMessage
@synthesize	messageId = _messageId;
@synthesize	senderId = _senderId;
@synthesize	senderTeamId = _senderTeamId;
@synthesize	senderName = _senderName;
@synthesize	destId = _destId;
@synthesize	destTeamId = _destTeamId;
@synthesize	destName = _destName;
@synthesize	timestamp = _timestamp;
@synthesize	eventId = _eventId;
@synthesize	eventName = _eventName;
@synthesize	body = _body;
@synthesize	deliverStatus = _deliverStatus;

#pragma mark -
#pragma mark GFTableObjectProtocol methods

- (CGFloat) cellHeightInTableView:(UITableView *)tableView {

	UITableViewCell *cell = [self cellInTableView: tableView searchResult: NO];
	return cell.frame.size.height;
}

- (BOOL) shouldAppearInContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	return NO;
}

- (UITableViewCell*) cellInTableView: (UITableView *) tableView searchResult: (BOOL) search {
	
    static NSString *CellIdentifier = @"MessageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	for(UIView *v in cell.subviews) {
		[v removeFromSuperview];
	}
	
	UIView *msgView = [self newViewForMessage];
	[cell addSubview: msgView];
	
	CGRect frame = msgView.frame;
	frame.origin.y = 8;
	
	
    CGFloat width;
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        width = 768;
    } else {
        width = 320;
    }    
    
	if(self.senderId == [[LTDataSource sharedDataSource] localUser].userId) {
		frame.origin.x = 8;
	} else {
		frame.origin.x = width - 8 - msgView.frame.size.width;
	}	
	
	[msgView setFrame: frame];
	
	// resize cell
	frame = cell.frame;
	
	frame.size.height = msgView.frame.size.height + 16;
	[cell setFrame: frame];	
	[msgView release];
	
	return cell;
}

#pragma mark -
#pragma mark GFMessage methods
+ (GFMessage*) newMessageWithDict: (NSDictionary*) d {
    GFMessage *result = [[GFMessage alloc] init];
    
    result.messageId = [result integerForKey: @"id" inDict: d];
    result.senderId = [result integerForKey: @"from_id" inDict: d];
    result.senderTeamId = [result integerForKey: @"sender_team" inDict: d];
    result.senderName = [result stringForKey: @"sender_name" inDict: d];
    result.destId = [result integerForKey: @"to_id" inDict: d];
    result.destTeamId = [result integerForKey: @"dest_team" inDict: d];
    result.destName = [result stringForKey: @"dest_name" inDict: d];	
    result.timestamp = [result stringForKey: @"sent_time" inDict: d];
    result.eventId = [result integerForKey: @"event_id" inDict: d];
    result.eventName = [result stringForKey: @"event_name" inDict: d];
    result.body = [result stringForKey: @"body" inDict: d];
    result.deliverStatus = [result integerForKey: @"deliver_status" inDict: d];	

	return result;	
}

- (NSComparisonResult)compare:(GFMessage *)anotherMessage {
	return [self.timestamp compare: anotherMessage.timestamp];
}

- (UIView*) newViewForMessage {
	CGRect frame;
	
    CGFloat width;
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        width = 400;
    } else {
        width = 280;
    }
    
	UIView *view = [[UIView alloc] initWithFrame: CGRectMake( 0, 0, width, 60)];

	// add header	
	UIImageView *header;
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        header = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"message_header-iPad.png"]];
    } else {
        header = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"message_header.png"]];
    }    

	[view addSubview: header];
	[header release];
	
	// add content
	UIImage *img = [TeamReference newImageForTeamWithId: self.senderTeamId];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: img];
	[imageView setImage: img];
	[img release];

	if(self.senderId == [[LTDataSource sharedDataSource] localUser].userId) {
		[imageView setFrame: CGRectMake( 4, 4, 42, 30)];
	} else {
		[imageView setFrame: CGRectMake( width - 4 - 42, 4, 42, 30)];
	}	
	
	[view addSubview: imageView];
	[imageView release];

	UILabel *detailLabel;	
	if(self.senderId == [[LTDataSource sharedDataSource] localUser].userId) {
		detailLabel = [[UILabel alloc] initWithFrame: CGRectMake( 42+8, 4, width-8-42-4, 30)];		
	} else {
		detailLabel = [[UILabel alloc] initWithFrame: CGRectMake( 4, 4, width-8-42, 30)];	
		[detailLabel setTextAlignment: UITextAlignmentRight];			
	}
	
	[detailLabel setNumberOfLines: 0];
	[detailLabel setFont: [UIFont systemFontOfSize: 12.0]];
    [detailLabel setText: [NSString stringWithFormat: @"%@, %@", self.senderName, [GFMessage utcTimeToLocalTime: self.timestamp]]];    	
	//[detailLabel setText: [NSString stringWithFormat: @"%@, %@ %d", senderName, [GFMessage utcTimeToLocalTime: timestamp], messageId]];    		

	//[detailLabel sizeToFit];
	[view addSubview: detailLabel];
	
	
	[detailLabel release];
	
	UILabel *textLabel = [[[UILabel alloc] initWithFrame: CGRectMake( 4, 30+8, width-8, 60)]autorelease];		
	[view addSubview: textLabel];
	[textLabel setNumberOfLines: 0];
    [textLabel setText: self.body];    	
	[textLabel sizeToFit];

	// add footer
	UIImageView *footer;
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        footer = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"message_footer-iPad.png"]];
    } else {
        footer = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"message_footer.png"]];
    }    

	[view addSubview: footer];
	frame = footer.frame;
	frame.origin.y = textLabel.frame.origin.y + textLabel.frame.size.height;
	[footer setFrame: frame];
	
	
	// resize view to fit its content
	frame = view.frame;
	frame.size.height = footer.frame.origin.y + footer.frame.size.height;
	[view setFrame: frame];	
	[footer release];	
	
	// finally, add body background
	UIImageView *b;
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        b = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"message_body-iPad.png"]];
    } else {
        b = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"message_body.png"]];
    }     

	[view addSubview: b];
	[view sendSubviewToBack: b];
	frame = view.frame;
	frame.origin.y += 14;
	frame.size.height -= 2*14;
	[b setFrame: frame];
	[b release];
	
	
	return view;
}

#pragma mark -
#pragma mark NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)encoder {
    NSAssert1([encoder allowsKeyedCoding], @"[%@] Does not support sequential archiving.", [self class]);
    
    [encoder encodeInt: self.messageId forKey: @"messageId"];
    [encoder encodeInt: self.senderId forKey: @"senderId"];
    [encoder encodeInt: self.senderTeamId forKey: @"senderTeamId"];
    [encoder encodeInt: self.destId forKey: @"destId"];
    [encoder encodeInt: self.destTeamId forKey: @"destTeamId"];
    [encoder encodeInt: self.eventId forKey: @"eventId"];
    [encoder encodeInt: self.deliverStatus forKey: @"deliverStatus"];    
    
    [encoder encodeObject: self.senderName forKey:@"senderName"];
    [encoder encodeObject: self.destName forKey:@"destName"];
    [encoder encodeObject: self.timestamp forKey:@"timestamp"];
    [encoder encodeObject: self.eventName forKey:@"eventName"];
    [encoder encodeObject: self.body forKey:@"body"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) return nil;
    
    // now use the coder to initialize your state
    [self setMessageId: [decoder decodeIntForKey: @"messageId"]];
    [self setSenderId: [decoder decodeIntForKey: @"senderId"]];
    [self setSenderTeamId: [decoder decodeIntForKey: @"senderTeamId"]];
    [self setDestId: [decoder decodeIntForKey: @"destId"]];
    [self setDestTeamId: [decoder decodeIntForKey: @"destTeamId"]];
    [self setEventId: [decoder decodeIntForKey: @"eventId"]];
    [self setDeliverStatus: [decoder decodeIntForKey: @"deliverStatus"]];
    
    [self setSenderName: [decoder decodeObjectForKey: @"senderName"]];
    [self setDestName: [decoder decodeObjectForKey: @"destName"]];
    [self setTimestamp: [decoder decodeObjectForKey: @"timestamp"]];
    [self setEventName: [decoder decodeObjectForKey: @"eventName"]];
    [self setBody: [decoder decodeObjectForKey: @"body"]];
    
    return self;
}

#pragma mark -
#pragma mark NSObject methods

- (void) dealloc {
    self.senderName = nil;
    self.destName = nil;
    self.timestamp = nil;
    self.eventName = nil;
    self.body = nil;
    [super dealloc];
}

@end
