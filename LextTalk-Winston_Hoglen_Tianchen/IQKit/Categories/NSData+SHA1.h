//
//  NSData+SHA1.h
//
//  Created by David on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NSData (SHA1)
+(NSString*) sha1Digest: (NSData*) keyData;
@end
