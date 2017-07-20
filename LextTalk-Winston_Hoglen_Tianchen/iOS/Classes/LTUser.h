//
//  LTUser.h
// LextTalk
//
//  Created by nacho on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "LTObject.h"
#import "LTTableObjectProtocol.h"

@interface LTUser : LTObject <MKAnnotation, LTTableObjectProtocol>{
    // MKAnnotation fields
    CLLocationCoordinate2D	_coordinate; 
    
    // data fields
    NSInteger				_userId;
    NSString				*_editKey;
    NSString				*_name;
    NSString				*_status;
    NSString				*_lastUpdate;
    CGFloat					_distance;
	NSInteger				_accesses;
    NSString				*_udid;
    NSString				*_creationDate;
    BOOL                    locationSwitch;
    NSString                *physAddress;
    	
    //New data fields for LextTalk
    NSString  *_address;
    NSString *_mail;
    BOOL _hasPicture;
    BOOL _fuzzyLocation;
    NSString *_screenName;
    NSString *_twitter;
    NSString *_url;
    UIImage * _image; //not loaded automatically, load from utl
    //Languages
    NSString  *_activeLearningLan;
    NSString *_activeSpeakingLan;
    NSInteger _activeLearningFlag;
    NSInteger _activeSpeakingFlag;
    NSArray *_learningLanguages;
    NSArray *_speakingLanguages;
    NSArray *_learningLanguagesFlags;
    NSArray *_speakingLanguagesFlags;
    
    
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate; 

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *editKey;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *lastUpdate;
@property (nonatomic, strong) NSString *udid;
@property (nonatomic, strong) NSString *creationDate;
@property (nonatomic, assign) BOOL locationSwitch;
@property (nonatomic, strong) NSString *physAddress;
//_distance and _accesses?

//New fields
@property (nonatomic, strong) NSString  * address;
@property (nonatomic, strong) NSString * mail;
@property (nonatomic, assign) BOOL hasPicture;
@property (nonatomic, assign) BOOL fuzzyLocation;
@property (nonatomic, strong) NSString * screenName;
@property (nonatomic, strong) NSString * twitter;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) UIImage * image;
//Languages
@property (nonatomic, strong) NSString  *activeLearningLan;
@property (nonatomic, strong) NSString *activeSpeakingLan;
@property (nonatomic, assign) NSInteger activeLearningFlag;
@property (nonatomic, assign) NSInteger activeSpeakingFlag;
@property (nonatomic, strong) NSArray *learningLanguages;
@property (nonatomic, strong) NSArray *speakingLanguages;
@property (nonatomic, strong) NSArray *learningLanguagesFlags;
@property (nonatomic, strong) NSArray *speakingLanguagesFlags;
//Blocking users
@property (nonatomic, strong) NSArray * blockedUsers;

+ (LTUser*) newUserWithName: (NSString*) n
				  andUdid: (NSString*) u;

+ (LTUser*) newUserWithName: (NSString*) n
					andId: (NSInteger) i;

- (LTUser*) initWithDict: (NSDictionary*) d;

- (BOOL) userIsInMap;

- (NSString *)subtitle;
- (NSString *)title;
- (MKAnnotationView *) annotationViewInMapView:(MKMapView *)theMapView;

- (NSDictionary *) preferredFlagForLangs;
- (NSInteger) preferredFlagFor:(NSString *) lang;
-(NSArray*) getSpeakingLangs;

@end
