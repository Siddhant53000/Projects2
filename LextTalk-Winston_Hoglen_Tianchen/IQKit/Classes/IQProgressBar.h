//
//  IQProgressBar.h
//
//  Created by Brian Harmann on 7/24/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IQProgressBar : UIView {
	float minValue, maxValue;
	float currentValue;
	UIColor *lineColor, *progressRemainingColor, *progressColor;
}

@property (readwrite) float minValue, maxValue, currentValue;
@property (nonatomic, strong) UIColor *lineColor, *progressRemainingColor, *progressColor;

-(void)setNewRect:(CGRect)newFrame;

@end
