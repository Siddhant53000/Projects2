/*
 *  IQGoogleServicesDelegate.h
 *
 *  Created by David on 2/10/11.
 *  Copyright 2011 InQBarna. All rights reserved.
 *
 */
#import <CoreLocation/CoreLocation.h>

@protocol IQGoogleServicesDelegate<NSObject>

@optional
- (void) didGetGeocoderResponse: (CLLocationCoordinate2D) location forAddress: (NSString*) address;
- (void) didTranslate: (NSString*) originalText 
				 from: (NSString*) fromLanguage 
				   to: (NSString*) toLanguage
		   withResult: (NSString*) translatedText;

- (void) didConvert: (CGFloat) amount 
			   from: (NSString*) fromCurrency 
				 to: (NSString*) toCurrency
		 withResult: (CGFloat) result;

@required
- (void) didFailWithError: (NSError*) error;

@end
