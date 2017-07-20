//
//  IQAlertView.h
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQSkin.h"

@interface IQAlertView : UIAlertView <IQSkinProtocol> {
	UIColor *fillColor;
	UIColor *borderColor;
}

+ (void) setBackgroundColor:(UIColor *) background 
			withStrokeColor:(UIColor *) stroke;

@end
