/*
 *  IQMapProtocol.h
 *
 *  Created by David on 12/27/10.
 *  Copyright 2010 InQBarna. All rights reserved.
 *
 */
#import <MapKit/MapKit.h>

@protocol IQMapProtocol
@required
- (MKAnnotationView *) annotationViewInMapView:(MKMapView *)theMapView;
@end

