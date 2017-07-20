//
//  GFNotLoggedUser.m
// LextTalk
//
//  Created by David on 12/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LTNotLoggedUser.h"
#import "IconGeneration.h"

@implementation LTNotLoggedUser
@synthesize coordinate = _coordinate;

- (NSString *)subtitle{
	return NSLocalizedString(@"Register to get full access", @"Register to get full access");
}

- (NSString *)title{
	return NSLocalizedString(@"You are here!", @"You are here!");
}


- (MKAnnotationView *) annotationViewInMapView:(MKMapView *)theMapView {
	
    MKAnnotationView *anView = nil;
	NSString *identifier = @"notLoggedUserView";
	
	anView = (MKAnnotationView*)[theMapView dequeueReusableAnnotationViewWithIdentifier: identifier];
	if (nil == anView) {
		anView = [[MKAnnotationView alloc] initWithAnnotation: self reuseIdentifier: identifier];
		[anView setCanShowCallout:YES];
	}
	
    UIImage * image=[IconGeneration stdIconForLearningLan:nil withFlag:0 andSpeakingLan:nil withFlag:0 writeText:YES withStatusDate:nil];
	[anView setImage: image];
	
	return anView;
}

@end
