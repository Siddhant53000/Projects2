//
//  GFUser.h
// LextTalk
//
//  Created by nacho on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "GFObject.h"
#import "GFTableObjectProtocol.h"

@interface GFUser : GFObject <MKAnnotation, GFTableObjectProtocol>{
    // MKAnnotation fields
    CLLocationCoordinate2D	_coordinate; 
    
    // data fields
    NSInteger				_userId;
    NSString				*_editKey;
    NSString				*_name;
    NSString				*_status;
    NSInteger				_teamId;
    NSString				*_lastUpdate;
    CGFloat					_distance;
	NSInteger				_accesses;
    NSString				*_udid;
    NSString				*_creationDate;	
	BOOL					_oldUser;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate; 
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, retain) NSString *editKey;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, assign) NSInteger teamId;
@property (nonatomic, retain) NSString *lastUpdate;
@property (nonatomic, assign) CGFloat	distance;
@property (nonatomic, assign) NSInteger accesses;
@property (nonatomic, retain) NSString *udid;
@property (nonatomic, retain) NSString*creationDate;	
@property (nonatomic, assign) BOOL oldUser;

+ (GFUser*) newUserWithName: (NSString*) n
				  andUdid: (NSString*) u;

+ (GFUser*) newUserWithName: (NSString*) n
					andId: (NSInteger) i;

- (GFUser*) initWithDict: (NSDictionary*) d;

- (BOOL) userIsInMap;

- (NSString *)subtitle;
- (NSString *)title;
- (UIImage*) getPin;
- (MKAnnotationView *) annotationViewInMapView:(MKMapView *)theMapView;

@end
