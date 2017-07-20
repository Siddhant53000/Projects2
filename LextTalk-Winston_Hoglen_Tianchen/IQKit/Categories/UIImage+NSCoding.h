//
//  UIImage+NSCoding.h
//
//  Created by David on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImageNSCoding <NSCoding>
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;
@end
