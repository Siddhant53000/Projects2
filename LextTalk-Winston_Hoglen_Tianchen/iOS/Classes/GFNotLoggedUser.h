//
//  GFNotLoggedUser.h
// LextTalk
//
//  Created by David on 12/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "GFObject.h"

@interface GFNotLoggedUser : NSObject <MKAnnotation>{
    // MKAnnotation fields
    CLLocationCoordinate2D	_coordinate; 
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate; 

- (NSString *)subtitle;
- (NSString *)title;
- (UIImage*) getPin;

- (MKAnnotationView *) annotationViewInMapView:(MKMapView *)theMapView;
@end
