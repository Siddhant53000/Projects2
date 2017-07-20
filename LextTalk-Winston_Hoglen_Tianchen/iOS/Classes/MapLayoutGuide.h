//
//  MapLayoutGuide.h
//  webControl
//
//  Created by Raúl Martín Carbonell on 26/07/14.
//  Copyright (c) 2014 Intermark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapLayoutGuide : NSObject <UILayoutSupport>

-(id)initWithLength:(CGFloat)length;

@property(nonatomic, readonly) CGFloat length;

@end
