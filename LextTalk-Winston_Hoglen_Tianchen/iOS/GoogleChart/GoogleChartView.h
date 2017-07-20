//
//  GoogleChartView.h
// LextTalk
//
//  Created by nacho on 12/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GoogleChartView : UIImageView {
	NSMutableData			*data;
    NSArray                 *points;
}

@property (retain) NSMutableData    *data;
@property (retain) NSArray          *points;

- (void) loadChart;

@end
