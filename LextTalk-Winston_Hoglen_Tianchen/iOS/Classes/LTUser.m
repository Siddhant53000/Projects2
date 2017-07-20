//
//  LTUser.m
// LextTalk
//
//  Created by nacho on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LTUser.h"
#import "IconGeneration.h"
#import "LanguageReference.h"
#import "IconGeneration.h"
#import "ChatListCell.h"
#import "LTDataSource.h"
#import "GeneralHelper.h"
#import "NSDate+NVTimeAgo.h"

@implementation LTUser
@synthesize coordinate = _coordinate; 
@synthesize userId = _userId;
@synthesize editKey = _editKey;
@synthesize name = _name;
@synthesize status = _status;
@synthesize lastUpdate = _lastUpdate;
@synthesize udid = _udid;
@synthesize creationDate = _creationDate;
@synthesize locationSwitch = _locationSwitch;
@synthesize physAddress = _physAddress;
//Lextalk
@synthesize address = _address;
@synthesize mail = _mail;
@synthesize hasPicture = _hasPicture;
@synthesize fuzzyLocation = _fuzzyLocation;
@synthesize screenName = _screenName;
@synthesize twitter = _twitter;
@synthesize url = _url;
@synthesize image = _image;
//Languages
@synthesize activeLearningLan = _activeLearningLan;
@synthesize activeSpeakingLan = _activeSpeakingLan;
@synthesize activeLearningFlag = _activeLearningFlag;
@synthesize activeSpeakingFlag = _activeSpeakingFlag;
@synthesize learningLanguages = _learningLanguages;
@synthesize speakingLanguages = _speakingLanguages;
@synthesize learningLanguagesFlags = _learningLanguagesFlags;
@synthesize speakingLanguagesFlags = _speakingLanguagesFlags;

#pragma mark -
#pragma mark LTTableObjectProtocol methods

- (CGFloat) cellHeightInTableView:(UITableView *)tableView {
    /*
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {	
		return 74;
	} else {
		return 50;
	}	
     */
    return 60;
}

- (BOOL) shouldAppearInContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    BOOL result=NO;
    
    NSString * learning=[LanguageReference getLanForAppLan:[LanguageReference appLan] andMasterLan:self.activeLearningLan];
    NSString * speaking=[LanguageReference getLanForAppLan:[LanguageReference appLan] andMasterLan:self.activeSpeakingLan];
    
    NSString * text = self.screenName;
    if (text==nil)
        text = self.name;
    
    if ([scope isEqualToString:NSLocalizedString(@"Name", @"Name")])
    {
        if([text rangeOfString: searchText options: NSCaseInsensitiveSearch].location != NSNotFound)
            result=YES;
    }
    else if ([scope isEqualToString:NSLocalizedString(@"Learning", @"Learning")])
    {
        if([learning rangeOfString: searchText options: NSCaseInsensitiveSearch].location != NSNotFound)
            result=YES;
    }
    else if ([scope isEqualToString:NSLocalizedString(@"Native", @"Native")])
    {
        if([speaking rangeOfString: searchText options: NSCaseInsensitiveSearch].location != NSNotFound)
            result=YES;
    }
    else
    {
        if (([text rangeOfString: searchText options: NSCaseInsensitiveSearch].location != NSNotFound) || ([learning rangeOfString: searchText options: NSCaseInsensitiveSearch].location != NSNotFound) || ([speaking rangeOfString: searchText options: NSCaseInsensitiveSearch].location != NSNotFound))
            result=YES;
    }
    

	return result;
}

- (UITableViewCell *) cellInTableView:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath searchResult:(BOOL)search
{
	
    static NSString *cellIdentifier = @"DefaultUserListCell";

    ChatListCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil)
        cell = [[ChatListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    cell.userImageView.image = [UIImage imageNamed:@"Contact"];
    cell.learningImageView.image = [IconGeneration smallWithGlowIconForLearningLan:self.activeLearningLan withFlag:self.activeLearningFlag];
    cell.speakingImageView.image = [IconGeneration smallWithGlowIconForSpeakingLan:self.activeSpeakingLan withFlag:self.activeSpeakingFlag];
    
    if (self.screenName != nil)
        cell.userLabel.text = self.screenName;
    else
        cell.userLabel.text = self.name;
    
    if (self.status!= nil)
        cell.messageLabel.text = self.status;
    else
        //cell.messageLabel.text =[NSString stringWithFormat:NSLocalizedString(@"Last con on: %@", nil), [LTUser stringForDate: [LTUser dateForUtcTime:self.lastUpdate]]];
        cell.messageLabel.text = nil;
    
    
    cell.activityImageView.image = [IconGeneration activityImageForDate:[LTUser dateForUtcTime:self.lastUpdate]];
    
    
    //Donwload image
    void(^myBlock)(UIImage * image, BOOL gotFromCache);
    myBlock = ^(UIImage * image, BOOL gotFromCache) {
        if (image!=nil)
        {
            if (gotFromCache)
                cell.userImageView.image = [GeneralHelper centralSquareFromImage:image];
            else
            {
                ChatListCell * cell2 = (ChatListCell *) [tableView cellForRowAtIndexPath:indexPath];
                cell2.userImageView.image = [GeneralHelper centralSquareFromImage:image];
            }
        }
    };
    
    if (self.url != nil)
        [[LTDataSource sharedDataSource] getImageForUrl:self.url withUserId:self.userId andExecuteBlockInMainQueue:myBlock];
    
    /*
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    
    cell.textLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Ubuntu-Medium" size:13];
    
    cell.textLabel.text = self.screenName;
    if (self.status!= nil)
        cell.detailTextLabel.text = self.status;
    else
        cell.detailTextLabel.text =[NSString stringWithFormat:NSLocalizedString(@"Last connection on: ", nil), [LTUser stringForDate: [LTUser dateForUtcTime:self.lastUpdate]]];
    
    NSDate * date=[LTUser dateForUtcTime:self.lastUpdate];
    cell.imageView.image=[IconGeneration stdIconForLearningLan:self.activeLearningLan withFlag:self.activeLearningFlag andSpeakingLan:self.activeSpeakingLan withFlag:self.activeSpeakingFlag writeText:NO withStatusDate:date];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;+
     */
    
    return cell;
}

#pragma mark -
#pragma mark MKAnnotation methods

- (NSString *)subtitle{
	//IQVerbose(VERBOSE_DEBUG,@"STATUS: %@", self.status);
//	if( ([self.status compare: @""] == NSOrderedSame) || (self.status == nil) ) {
    //NSString *date = [LTUser utcTimeToLocalTime: self.lastUpdate];
    //NSLog(@"Date from LTUser call is: \"%@\"", date);
     NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *date = [[dateFormat dateFromString:[LTUser utcTimeToLocalTime: self.lastUpdate]] formattedAsTimeAgo];


    //NSString *date2 = @"About " + [[dateFormat dateFromString:[LTUser utcTimeToLocalTime: self.lastUpdate]] formattedAsTimeAgo];
    //NSLog(@"Output is: \"%@\"", date2);

    return [NSString stringWithFormat: NSLocalizedString(@"Last update: %@", @"Last update: %@") , date];
    //  return [NSString stringWithFormat: NSLocalizedString(@"Last update: %@", @"Last update: %@") , [LTUser utcTimeToLocalTime: self.creationDate]];
//	}
//	return self.status;
    // Commenting the above out forces every annotation to display the user's last update time.
    //Needed format: "MM/dd/yyyy HH:mm:ss"
}

- (NSString *)title{
	return self.screenName;
}

#pragma mark -
#pragma mark LTUser methods

+ (LTUser*) newUserWithName: (NSString*) n
				  andUdid: (NSString*) u
{
	LTUser *user = [[LTUser alloc] init];
	[user setName: n];
	[user setUdid: u];
	
	return user;
}

+ (LTUser*) newUserWithName: (NSString*) n
					andId: (NSInteger) i 
{
	LTUser *user = [[LTUser alloc] init];
	[user setName: n];
	[user setUserId: i];
	
	return user;
}

- (void) dump {
    IQVerbose(VERBOSE_DEBUG,@"                id: %d", [self userId]);
    IQVerbose(VERBOSE_DEBUG,@"          edit key: %@", [self editKey]);	
    IQVerbose(VERBOSE_DEBUG,@"[%@] Dump of user %@", [self class], [self name]);				
    IQVerbose(VERBOSE_DEBUG,@"          latitude: %f", self.coordinate.latitude);        
    IQVerbose(VERBOSE_DEBUG,@"         longitude: %f", self.coordinate.longitude);      
    IQVerbose(VERBOSE_DEBUG,@"            status: %@", self.status);      
    IQVerbose(VERBOSE_DEBUG,@"       last update: %@", self.lastUpdate);
    IQVerbose(VERBOSE_DEBUG,@"              udid: %@", self.udid);
    IQVerbose(VERBOSE_DEBUG,@"     creation date: %@", self.creationDate);
    IQVerbose(VERBOSE_DEBUG,@"      locationSwitch: %d", self.locationSwitch);
    IQVerbose(VERBOSE_DEBUG,@"      physSwitch: %@", self.physAddress);
    //Lextalk
    IQVerbose(VERBOSE_DEBUG,@"           address: %@", self.address);
    IQVerbose(VERBOSE_DEBUG,@"              mail: %@", self.mail);
    IQVerbose(VERBOSE_DEBUG,@"        hasPicture: %d", self.hasPicture);
    IQVerbose(VERBOSE_DEBUG,@"     fuzzyLocation: %d", self.fuzzyLocation);
    IQVerbose(VERBOSE_DEBUG,@"        screenName: %@", self.screenName);
    IQVerbose(VERBOSE_DEBUG,@"               url: %@", self.url);
    IQVerbose(VERBOSE_DEBUG,@"           twitter: %@", self.twitter);
    //Languages
    IQVerbose(VERBOSE_DEBUG,@" activeLearningLan: %@", self.activeLearningLan);
    IQVerbose(VERBOSE_DEBUG,@"activeLearningFlag: %d", self.activeLearningFlag);
    IQVerbose(VERBOSE_DEBUG,@" activeSpeakingLan: %@", self.activeSpeakingLan);
    IQVerbose(VERBOSE_DEBUG,@"activeSpeakingFlag: %d", self.activeLearningFlag);
    
    IQVerbose(VERBOSE_DEBUG,@"     learningLangs: %@", self.learningLanguages);
    IQVerbose(VERBOSE_DEBUG,@"learningLangsFlags: %@", self.learningLanguagesFlags);
    IQVerbose(VERBOSE_DEBUG,@"     speakingLangs: %@", self.speakingLanguages);
    IQVerbose(VERBOSE_DEBUG,@"speakingLangsFlags: %@", self.speakingLanguagesFlags);
    
    IQVerbose(VERBOSE_DEBUG,@"      blockedUsers: %@", self.blockedUsers);
}
-(NSArray*) getSpeakingLangs{
    return _speakingLanguages;
}

- (LTUser*) initWithDict: (NSDictionary*) d {
    if (self = [super init]) {		
        IQVerbose(VERBOSE_DEBUG,@"User Dictionary: %@", d);
        
        //NSLog(@"User Dictionary: %@", d);
        
		[self setUserId: [self integerForKey: @"id" inDict: d]];
        //VER COMO VA EL MECANISMO DE SESION AQUÍ
		[self setEditKey: [self stringForKey: @"token" inDict: d]];
		[self setName: [self stringForKey: @"login_name" inDict: d]];
        [self setStatus: [self stringForKey: @"status" inDict: d]];
		[self setLastUpdate: [self stringForKey: @"last_update" inDict: d]];
        [self setUdid: [self stringForKey: @"udid" inDict: d]];
        [self setCreationDate: [self stringForKey: @"creation_date" inDict: d]];
        [self setLocationSwitch:[self boolForKey:@"locatin_switch" inDict:d]];
        [self setPhysAddress:[self stringForKey:@"phys_address" inDict:d]];
    
        //Lextalk
        [self setAddress: [self stringForKey: @"address" inDict: d]];
        [self setMail: [self stringForKey: @"mail" inDict: d]];
        [self setHasPicture:[self boolForKey:@"has_picture" inDict: d]];
        [self setFuzzyLocation: [self boolForKey:@"fuzzy_location" inDict: d]];
        [self setScreenName: [self stringForKey: @"screen_name" inDict: d]];
        [self setTwitter: [self stringForKey: @"twitter" inDict: d]];
        [self setUrl: [self stringForKey: @"url" inDict: d]];
        
        
        //Languages
        /*
         Languages can come in 2 fashions:
         - When we are dealing with the local user, the dic has the keys "learning_languages" and "native_languages"
         They are an array of dictionaries with the fields: language_id, flag and active. You must go through the array
         in order to load the learning and speaking laguages, both active and not active
         - When you are dealing with other users, the dic has the following keys: activeLearningLan, activeNativeFlag,
         activeLearningFlag and activeNativeFlag, i.e., only the active languages are retrieved, no more is needed. So
         in this case you need to fill in the language information with this.
         
         That's why the following code distinguishes between these 2 situations
         */
        
        self.activeLearningLan=nil;
        self.activeSpeakingLan=nil;
        //Learning, local user
        NSArray * array = [d objectForKey:@"learning_languages"];
        NSMutableArray * langArray;
        NSMutableArray * flagArray;
        NSString * lang;
        NSInteger flag;
        if (![array isEqual:[NSNull null]])
        {
            langArray=[NSMutableArray arrayWithCapacity:[array count]];
            flagArray=[NSMutableArray arrayWithCapacity:[array count]];
            for (NSDictionary * dic in array)
            {
                lang=[self stringForKey:@"language_id" inDict:dic];
                flag=[self integerForKey:@"flag" inDict:dic];
                if (lang!=nil)
                {
                    [langArray addObject:lang];
                    if (flag==-1)
                        flag=0;
                    [flagArray addObject:[NSNumber numberWithInteger:flag]];
                    
                    if ([self boolForKey:@"active" inDict:dic]) {
                        self.activeLearningLan = lang;
                        self.activeLearningFlag = flag;
                    }
                }
            }
            if ([langArray count]>0)
            {
                self.learningLanguages=langArray;
                self.learningLanguagesFlags=flagArray;
            }
            else
            {
                self.learningLanguages=nil;
                self.learningLanguagesFlags=nil;
            }
        }
        
        //Speaking, local user
        array = [d objectForKey:@"native_languages"];
        if (![array isEqual:[NSNull null]])
        {
            langArray=[NSMutableArray arrayWithCapacity:[array count]];
            flagArray=[NSMutableArray arrayWithCapacity:[array count]];
            
            for (NSDictionary * dic in array)
            {
                lang=[self stringForKey:@"language_id" inDict:dic];
                flag=[self integerForKey:@"flag" inDict:dic];
                if (lang!=nil)
                {
                    [langArray addObject:lang];
                    if (flag==-1)
                        flag=0;
                    [flagArray addObject:[NSNumber numberWithInteger:flag]];
                    
                    if ([self boolForKey:@"active" inDict:dic]) {
                        self.activeSpeakingLan = lang;
                        self.activeSpeakingFlag = flag;
                    }
                }
            }
            if ([langArray count]>0)
            {
                self.speakingLanguages=langArray;
                self.speakingLanguagesFlags=flagArray;
            }
            else
            {
                self.speakingLanguages=nil;
                self.speakingLanguagesFlags=nil;
            }
        }
        
        
        //Learning, other users
        if (([d objectForKey:@"activeLearningLan"]!=nil) && ([d objectForKey:@"activeLearningFlag"]!=nil))
        {
            if ((![[d objectForKey:@"activeLearningLan"] isEqual:[NSNull null]]) && (![[d objectForKey:@"activeLearningFlag"] isEqual:[NSNull null]]))
            {
                self.activeLearningLan=[self stringForKey:@"activeLearningLan" inDict:d];
                self.activeLearningFlag=[self integerForKey:@"activeLearningFlag" inDict:d];
                self.learningLanguages=[NSArray arrayWithObject:self.activeLearningLan];
                self.learningLanguagesFlags=[NSArray arrayWithObject:[NSNumber numberWithInteger:self.activeLearningFlag]];
            }
        }
        //Speaking, other users
        if (([d objectForKey:@"activeNativeLan"]!=nil) && ([d objectForKey:@"activeNativeFlag"]!=nil))
        {
            if ((![[d objectForKey:@"activeNativeLan"] isEqual:[NSNull null]]) && (![[d objectForKey:@"activeNativeFlag"] isEqual:[NSNull null]]))
            {
                self.activeSpeakingLan=[self stringForKey:@"activeNativeLan" inDict:d];
                self.activeSpeakingFlag=[self integerForKey:@"activeNativeFlag" inDict:d];
                self.speakingLanguages=[NSArray arrayWithObject:self.activeSpeakingLan];
                self.speakingLanguagesFlags=[NSArray arrayWithObject:[NSNumber numberWithInteger:self.activeSpeakingFlag]];
            }
        }
        
        
        //Latitude and longitude
		if( (![[d objectForKey: @"longitude"] isEqual: [NSNull null]]) && (![[d objectForKey: @"latitude"] isEqual: [NSNull null]]) ) {
			CLLocationCoordinate2D c;
            
			c.longitude = [[d objectForKey: @"longitude"] doubleValue];
			c.latitude = [[d objectForKey: @"latitude"] doubleValue];
			//IQVerbose(VERBOSE_DEBUG,@"%@ %@ - %@", [dict objectForKey: @"name"], [[dict objectForKey: @"longitude"] class], [[dict objectForKey: @"latitude"] class]);			
			
			[self setCoordinate: c];
		}
        
        //blockedUsers
        //These fields, because of how they come from the server or how they are treated in the
        //parser, come as strings, so I have to convert them to NSNumbers
        if ([d objectForKey:@"block_users"])
        {
            NSArray * blockedArray = [d objectForKey:@"block_users"];
            NSMutableArray * mut=[NSMutableArray arrayWithCapacity:[blockedArray count] ];
            for (NSDictionary * dic in blockedArray)
                [mut addObject:[NSNumber numberWithInteger:[[dic objectForKey:@"user_id"] intValue]] ];
            self.blockedUsers = mut;
        }
        else
            self.blockedUsers = [NSArray array];
        
        // TODO handle nulls...
	}
	return self;
}

- (BOOL) userIsInMap {
	if( (self.coordinate.latitude == 0) && (self.coordinate.longitude == 0) ) {
		return NO;
	}
	return YES;
}

- (NSComparisonResult) compareByTimestamp: (LTUser *) other {
	return -[[self lastUpdate] compare: [other lastUpdate]];
}

- (NSString *) localTimestamp {
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
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
	
	NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];	
	
	return [NSString stringWithFormat:@"%@ %@", [df stringFromDate:destinationDate], [[NSTimeZone systemTimeZone] abbreviation]];
}

/*
- (UIImage*) getPin {
	return [UIImage imageNamed: @"user_pin.png"];
}
 */

- (MKAnnotationView *) annotationViewInMapView:(MKMapView *)theMapView {
	
    MKAnnotationView *anView = nil;
	NSString *identifier = @"userView";
	
	anView = (MKAnnotationView*)[theMapView dequeueReusableAnnotationViewWithIdentifier: identifier];
	if (nil == anView) {
		anView = [[MKAnnotationView alloc] initWithAnnotation: self reuseIdentifier: identifier];
		[anView setCanShowCallout:YES];
	}
	
    NSDate* date=[LTUser dateForUtcTime:self.lastUpdate];
    // Attempt to add the user's creation date.
//  NSDate* joinDate = [LTUser dateForUtcTime:self.creationDate];
	UIImage *img = [IconGeneration stdIconForLearningLan:self.activeLearningLan
                                                withFlag:self.activeLearningFlag
                                          andSpeakingLan:self.activeSpeakingLan
                                                withFlag:self.activeSpeakingFlag
                                               writeText:NO
                                          withStatusDate:date];
	anView.image=img; // This line attaches the flags to the annotation, and replcaes the pin
    
    /*
    UIImageView *tmp = [[UIImageView alloc] initWithImage: img];
	CGRect frame;
	frame.size.width = 28;
	frame.size.height = 55;
	tmp.frame=frame;
    anView.leftCalloutAccessoryView=tmp;
	[tmp release];
     */
    
    // Uncommenting the above code adds a squished view of the two glads into the annotation. It's probably best to leave this commented. Also: this method is what is causing errors when trying to set setShowsUserLocation to true!
    

	
	return anView;
}

#pragma mark -
#pragma mark NSObject methods


- (BOOL)isEqual:(id)anObject
{
    if ([anObject isMemberOfClass:[LTUser class]])
        return self.userId == [(LTUser *) anObject userId];
    else
        return NO;
}

#pragma mark -
#pragma mark NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)encoder {
    NSAssert1([encoder allowsKeyedCoding], @"[%@] Does not support sequential archiving.", [self class]);
        
    [encoder encodeInteger: self.userId forKey: @"userId"];

    [encoder encodeDouble: self.coordinate.longitude forKey: @"longitude"];    
    [encoder encodeDouble: self.coordinate.latitude forKey: @"latitude"];        
    
    [encoder encodeObject: self.editKey forKey:@"editKey"];
    [encoder encodeObject: self.name forKey:@"name"];
    [encoder encodeObject: self.status forKey:@"status"];
    [encoder encodeObject: self.lastUpdate forKey:@"lastUpdate"];
    [encoder encodeObject: self.udid forKey:@"udid"];
    [encoder encodeObject: self.creationDate forKey:@"creationDate"];
    [encoder encodeBool: self.locationSwitch forKey:@"location_switch"];
    [encoder encodeObject: self.physAddress forKey:@"phys_address"];

    
    //Lextalk
    [encoder encodeObject:self.address forKey:@"address"];
    [encoder encodeObject:self.mail forKey:@"mail"];
    [encoder encodeBool:self.hasPicture forKey:@"hasPicture"];
    [encoder encodeBool:self.fuzzyLocation forKey:@"fuzzyLocation"];
    [encoder encodeObject:self.screenName forKey:@"screenName"];
    [encoder encodeObject:self.twitter forKey:@"twitter"];
    [encoder encodeObject:self.url forKey:@"url"];
    
    [encoder encodeObject:self.activeLearningLan forKey:@"activeLearningLan"];
    [encoder encodeObject:self.activeSpeakingLan forKey:@"activeSpeakingLan"];
    [encoder encodeInteger:self.activeLearningFlag forKey:@"activeLearningFlag"];
    [encoder encodeInteger:self.activeSpeakingFlag forKey:@"activeSpeakingFlag"];
    
    [encoder encodeObject:self.learningLanguages forKey:@"learningLanguages"];
    [encoder encodeObject:self.learningLanguagesFlags forKey:@"learningLanguagesFlags"];
    [encoder encodeObject:self.speakingLanguages forKey:@"speakingLanguages"];
    [encoder encodeObject:self.speakingLanguagesFlags forKey:@"speakingLanguagesFlags"];
    
    [encoder encodeObject:self.blockedUsers forKey:@"blockedUsers"];

}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) return nil;
        
    // now use the coder to initialize your state
    [self setUserId: [decoder decodeIntForKey: @"userId"]];
    
    CLLocationCoordinate2D c;
    c.longitude = [decoder decodeDoubleForKey: @"longitude"];
    c.latitude = [decoder decodeDoubleForKey: @"latitude"];
    [self setCoordinate: c];
    
    [self setEditKey: [decoder decodeObjectForKey: @"editKey"]];
    [self setName: [decoder decodeObjectForKey: @"name"]];
    [self setStatus: [decoder decodeObjectForKey: @"status"]];
    [self setLastUpdate: [decoder decodeObjectForKey: @"lastUpdate"]];
    [self setUdid: [decoder decodeObjectForKey: @"udid"]];
    [self setCreationDate: [decoder decodeObjectForKey: @"creationDate"]];
    [self setLocationSwitch: [decoder decodeObjectForKey:@"location_switch"]];
    [self setPhysAddress: [decoder decodeObjectForKey:@"phys_address"]];
    
    //Lextalk
    [self setAddress:[decoder decodeObjectForKey:@"address"]];
    [self setMail:[decoder decodeObjectForKey:@"mail"]];
    [self setHasPicture:[decoder decodeBoolForKey:@"hasPicture"]];
    [self setFuzzyLocation:[decoder decodeBoolForKey:@"fuzzyLocation"]];
    [self setScreenName:[decoder decodeObjectForKey:@"screenName"]];
    [self setTwitter:[decoder decodeObjectForKey:@"twitter"]];
    [self setUrl:[decoder decodeObjectForKey:@"url"]];
    
    [self setActiveLearningLan:[decoder decodeObjectForKey:@"activeLearningLan"]];
    [self setActiveSpeakingLan:[decoder decodeObjectForKey:@"activeSpeakingLan"]];
    [self setActiveLearningFlag:[decoder decodeIntForKey:@"activeLearningFlag"]];
    [self setActiveSpeakingFlag:[decoder decodeIntForKey:@"activeSpeaingFlag"]];
    
    [self setLearningLanguages:[decoder decodeObjectForKey:@"learningLanguages"]];
    [self setLearningLanguagesFlags:[decoder decodeObjectForKey:@"learningLanguagesFlags"]];
    [self setSpeakingLanguages:[decoder decodeObjectForKey:@"speakingLanguages"]];
    [self setSpeakingLanguagesFlags:[decoder decodeObjectForKey:@"speakingLanguagesFlags"]];
    
    [self setBlockedUsers:[decoder decodeObjectForKey:@"blockedUsers"]];
    
    return self;
}

- (NSDictionary *) preferredFlagForLangs
{
    NSMutableDictionary * result=[NSMutableDictionary dictionaryWithCapacity:5];
    
    if ([self.learningLanguages count]==[self.learningLanguagesFlags count])
    {
        for (int i=0; i< [self.learningLanguages count]; i++)
            [result setObject:[self.learningLanguagesFlags objectAtIndex:i] forKey:[self.learningLanguages objectAtIndex:i]];
    }
    if ([self.speakingLanguages count]==[self.speakingLanguagesFlags count])
    {
        for (int i=0; i< [self.speakingLanguages count]; i++)
            [result setObject:[self.speakingLanguagesFlags objectAtIndex:i] forKey:[self.speakingLanguages objectAtIndex:i]];
    }
    
    if ([result count]==0)
        result=nil;
    
    return result;
}

- (NSInteger) preferredFlagFor: (NSString *) lang
{
    NSInteger result=0;
    NSDictionary * dic=[self preferredFlagForLangs];
    if ([dic objectForKey:lang])
        result=[[dic objectForKey:lang] intValue];
    return result;
}

@end
