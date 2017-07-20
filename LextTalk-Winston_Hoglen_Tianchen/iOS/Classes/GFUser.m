//
//  GFUser.m
// LextTalk
//
//  Created by nacho on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GFUser.h"
#import "TeamReference.h"

@implementation GFUser
@synthesize coordinate = _coordinate; 
@synthesize userId = _userId;
@synthesize editKey = _editKey;
@synthesize name = _name;
@synthesize status = _status;
@synthesize teamId = _teamId;
@synthesize creationDate = _creationDate;
@synthesize lastUpdate = _lastUpdate;
@synthesize distance = _distance;
@synthesize udid = _udid;
@synthesize accesses = _accesses;
@synthesize oldUser = _oldUser;

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

- (UITableViewCell*) cellInTableView: (UITableView *)tableView searchResult: (BOOL) search {
	
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
	
	NSString *time = self.oldUser ? @"old user" : [GFUser utcTimeToLocalTime: self.lastUpdate];
	
	NSString *sta = (self.status==nil) ? @"" : [self.status stringByReplacingOccurrencesOfString: @"\n" withString: @" "];
	[self.cell.subtitleLabel setText: [NSString stringWithFormat: @"%@ (%@)", sta, time]];  			
	
	UIImage *img = [TeamReference newImageForTeamWithId: self.teamId];
	[self.cell.leftImageView setImage: img];
	[img release];
	[self.cell setAccessoryType: UITableViewCellAccessoryDetailDisclosureButton];
	return self.cell;
}

#pragma mark -
#pragma mark MKAnnotation methods

- (NSString *)subtitle{
	//IQVerbose(VERBOSE_DEBUG,@"STATUS: %@", self.status);
	if( ([self.status compare: @""] == NSOrderedSame) || (self.status == nil) ) {
		return [NSString stringWithFormat: NSLocalizedString(@"Last update: %@", @"Last update: %@") , [GFUser utcTimeToLocalTime: self.lastUpdate]];
	}
	
	return self.status;
}

- (NSString *)title{
	return self.name;
}

#pragma mark -
#pragma mark GFUser methods

+ (GFUser*) newUserWithName: (NSString*) n
				  andUdid: (NSString*) u
{
	GFUser *user = [[GFUser alloc] init];
	[user setName: n];
	[user setUdid: u];
	
	return user;
}

+ (GFUser*) newUserWithName: (NSString*) n
					andId: (NSInteger) i 
{
	GFUser *user = [[GFUser alloc] init];
	[user setName: n];
	[user setUserId: i];
	
	return user;
}

- (void) dump {
    IQVerbose(VERBOSE_DEBUG,@"[%@] Dump of user %@", [self class], [self name]);				
    IQVerbose(VERBOSE_DEBUG,@"              id: %d", [self userId]);						
    //IQVerbose(VERBOSE_DEBUG,@"        edit key: %@", [self editKey]);						
    IQVerbose(VERBOSE_DEBUG,@"         team id: %d", [self teamId]);								
    IQVerbose(VERBOSE_DEBUG,@"        latitude: %f", self.coordinate.latitude);        
    IQVerbose(VERBOSE_DEBUG,@"       longitude: %f", self.coordinate.longitude);      
    IQVerbose(VERBOSE_DEBUG,@"          status: %@", self.status);      
    IQVerbose(VERBOSE_DEBUG,@"     last update: %@", self.lastUpdate);          
    IQVerbose(VERBOSE_DEBUG,@"   creation date: %@", self.creationDate);              
    IQVerbose(VERBOSE_DEBUG,@"        old user: %d", self.oldUser);              
}

- (GFUser*) initWithDict: (NSDictionary*) d {
	if (self = [super init]) {		
		[self setUserId: [self integerForKey: @"id" inDict: d]];
		[self setName: [self stringForKey: @"name" inDict: d]];
		[self setEditKey: [self stringForKey: @"edit_key" inDict: d]];
		[self setTeamId: [self integerForKey: @"team_id" inDict: d]];
		[self setStatus: [self stringForKey: @"status" inDict: d]];
		[self setLastUpdate: [self stringForKey: @"last_update" inDict: d]];
		[self setOldUser: [self boolForKey: @"old_user" inDict: d]];
		[self setDistance: [self doubleForKey: @"distance" inDict: d]];
		[self setAccesses: [self integerForKey: @"accesses" inDict: d]];

		if( (![[d objectForKey: @"longitude"] isEqual: [NSNull null]]) && (![[d objectForKey: @"latitude"] isEqual: [NSNull null]]) ) {
			CLLocationCoordinate2D c;
		
			c.longitude = [[d objectForKey: @"longitude"] doubleValue];
			c.latitude = [[d objectForKey: @"latitude"] doubleValue];
			//IQVerbose(VERBOSE_DEBUG,@"%@ %@ - %@", [dict objectForKey: @"name"], [[dict objectForKey: @"longitude"] class], [[dict objectForKey: @"latitude"] class]);			
			
			[self setCoordinate: c];
		}
	}
	return self;
}

- (BOOL) userIsInMap {
	if( (self.coordinate.latitude == 0) && (self.coordinate.longitude == 0) ) {
		return NO;
	}
	return YES;
}

- (NSComparisonResult) compareByTimestamp: (GFUser *) other {
	return -[[self lastUpdate] compare: [other lastUpdate]];
}

NSDateFormatter *df = nil;

- (NSString *) localTimestamp {
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
    }
    [df setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
	[df setTimeZone: [NSTimeZone timeZoneWithName: @"GMT"]];
	
	if(self.lastUpdate == nil) {
		return NSLocalizedString(@"Data not available", @"Data not available");
	}
	
	NSDate* sourceDate = [df dateFromString: self.lastUpdate];
	NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    
	NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone]; // local timezone
	
	NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
	NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
	NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
	
	NSDate* destinationDate = [[[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate] autorelease];	
	
	return [NSString stringWithFormat:@"%@ %@", [df stringFromDate:destinationDate], [[NSTimeZone systemTimeZone] abbreviation]];
}

- (UIImage*) getPin {
	return [UIImage imageNamed: @"user_pin.png"];
}

- (UIImage*) getOldPin {
	int oldTeamId = self.teamId - 1;
	
    switch (oldTeamId) {
        case 0:  return [UIImage imageNamed:@"RSA_pin.png"];
		case 1:  return [UIImage imageNamed:@"MEX_pin.png"];
		case 2:	 return [UIImage imageNamed:@"URU_pin.png"];
		case 3:  return [UIImage imageNamed:@"FRA_pin.png"];
		case 4:  return [UIImage imageNamed:@"ARG_pin.png"];
		case 5:  return [UIImage imageNamed:@"NGA_pin.png"];
		case 6:  return [UIImage imageNamed:@"KOR_pin.png"];
		case 7:  return [UIImage imageNamed:@"GRE_pin.png"];
		case 8:  return [UIImage imageNamed:@"ENG_pin.png"];
		case 9:  return [UIImage imageNamed:@"USA_pin.png"];
		case 10: return [UIImage imageNamed:@"ALG_pin.png"];
		case 11: return [UIImage imageNamed:@"SVN_pin.png"];
		case 12: return [UIImage imageNamed:@"GER_pin.png"];
		case 13: return [UIImage imageNamed:@"AUS_pin.png"];
		case 14: return [UIImage imageNamed:@"SRB_pin.png"];
		case 15: return [UIImage imageNamed:@"GHA_pin.png"];
		case 16: return [UIImage imageNamed:@"NED_pin.png"];
		case 17: return [UIImage imageNamed:@"DEN_pin.png"];
		case 18: return [UIImage imageNamed:@"JPN_pin.png"];
		case 19: return [UIImage imageNamed:@"CMR_pin.png"];
		case 20: return [UIImage imageNamed:@"ITA_pin.png"];
		case 21: return [UIImage imageNamed:@"PAR_pin.png"];
		case 22: return [UIImage imageNamed:@"NZL_pin.png"];
		case 23: return [UIImage imageNamed:@"SVK_pin.png"];
		case 24: return [UIImage imageNamed:@"BRA_pin.png"];
		case 25: return [UIImage imageNamed:@"PRK_pin.png"];
		case 26: return [UIImage imageNamed:@"CIV_pin.png"];
		case 27: return [UIImage imageNamed:@"POR_pin.png"];
		case 28: return [UIImage imageNamed:@"ESP_pin.png"];
		case 29: return [UIImage imageNamed:@"SUI_pin.png"];
		case 30: return [UIImage imageNamed:@"HON_pin.png"];
		case 31: return [UIImage imageNamed:@"CHI_pin.png"];	
    }
	return nil;
}

- (MKAnnotationView *) annotationViewInMapView:(MKMapView *)theMapView {
	
    MKAnnotationView *anView = nil;
	NSString *identifier = @"userView";
	
	anView = (MKAnnotationView*)[theMapView dequeueReusableAnnotationViewWithIdentifier: identifier];
	if (nil == anView) {
		anView = [[[MKAnnotationView alloc] initWithAnnotation: self reuseIdentifier: identifier]autorelease];
		[anView setCanShowCallout:YES];
	}
	
	UIImage *img = [TeamReference newPinForTeamWithId: self.teamId];
	[anView setImage: img];
	[img release];
	
	img = [TeamReference newImageForTeamWithId: self.teamId];
	UIImageView *tmp = [[UIImageView alloc] initWithImage: img];
	CGRect frame = tmp.frame;
	frame.size.width = 42;
	frame.size.height = 30;
	[tmp setFrame: frame];
	[anView setLeftCalloutAccessoryView: tmp];
	[tmp release];
	[img release];

	
	if(self.oldUser) {
		[anView setImage: [self getOldPin]];
	}	
	return anView;
}

#pragma mark -
#pragma mark NSObject methods

- (void) dealloc {
    self.editKey = nil;
    self.name = nil;
    self.status = nil;
    self.lastUpdate = nil;
    self.udid = nil;
    self.creationDate = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)encoder {
    NSAssert1([encoder allowsKeyedCoding], @"[%@] Does not support sequential archiving.", [self class]);
        
    [encoder encodeInt: self.userId forKey: @"userId"];
    [encoder encodeInt: self.teamId forKey: @"teamId"];
    [encoder encodeInt: self.accesses forKey: @"accesses"];

    [encoder encodeDouble: self.coordinate.longitude forKey: @"longitude"];    
    [encoder encodeDouble: self.coordinate.latitude forKey: @"latitude"];        
    [encoder encodeDouble: self.distance forKey: @"distance"];            
    [encoder encodeBool: self.oldUser forKey: @"oldUser"];
    
    [encoder encodeObject: self.editKey forKey:@"editKey"];
    [encoder encodeObject: self.name forKey:@"name"];
    [encoder encodeObject: self.status forKey:@"status"];
    [encoder encodeObject: self.lastUpdate forKey:@"lastUpdate"];
    [encoder encodeObject: self.udid forKey:@"udid"];
    [encoder encodeObject: self.creationDate forKey:@"creationDate"];    
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) return nil;
        
    // now use the coder to initialize your state
    [self setEditKey: [decoder decodeObjectForKey: @"editKey"]];
    [self setName: [decoder decodeObjectForKey: @"name"]];
    [self setStatus: [decoder decodeObjectForKey: @"status"]];
    [self setLastUpdate: [decoder decodeObjectForKey: @"lastUpdate"]];
    [self setUdid: [decoder decodeObjectForKey: @"udid"]];
    [self setCreationDate: [decoder decodeObjectForKey: @"creationDate"]];

    [self setUserId: [decoder decodeIntForKey: @"userId"]];
    [self setTeamId: [decoder decodeIntForKey: @"teamId"]];
    [self setAccesses: [decoder decodeIntForKey: @"accesses"]];
    
    CLLocationCoordinate2D c;
    c.longitude = [decoder decodeDoubleForKey: @"longitude"];
    c.latitude = [decoder decodeDoubleForKey: @"latitude"];
    [self setCoordinate: c];
    [self setDistance: [decoder decodeDoubleForKey: @"distance"]];    
    [self setOldUser: [decoder decodeBoolForKey: @"oldUser"]];
    
    return self;
}

@end
