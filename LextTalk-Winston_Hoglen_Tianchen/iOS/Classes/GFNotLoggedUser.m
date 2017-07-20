//
//  GFNotLoggedUser.m
// LextTalk
//
//  Created by David on 12/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GFNotLoggedUser.h"

@implementation GFNotLoggedUser
@synthesize coordinate = _coordinate;

- (NSString *)subtitle{
	return NSLocalizedString(@"Register to get full access", @"Register to get full access");
}

- (NSString *)title{
	return NSLocalizedString(@"You are here!", @"You are here!");
}

- (UIImage*) getPin {
	return [UIImage imageNamed: @"user_pin.png"];
}

- (MKAnnotationView *) annotationViewInMapView:(MKMapView *)theMapView {
	
    MKAnnotationView *anView = nil;
	NSString *identifier = @"notLoggedUserView";
	
	anView = (MKAnnotationView*)[theMapView dequeueReusableAnnotationViewWithIdentifier: identifier];
	if (nil == anView) {
		anView = [[[MKAnnotationView alloc] initWithAnnotation: self reuseIdentifier: identifier]autorelease];
		[anView setCanShowCallout:YES];
	}
	
	[anView setImage: [self getPin]];
	
	return anView;
}

- (void) dealloc {
    [super dealloc];
}
@end
