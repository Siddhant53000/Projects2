//
//  ImageCache.h
//  LextTalk
//
//  Created by Yo on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject
{
    
    NSMutableDictionary * smallDic;
    NSMutableDictionary * bigDic;
    
}

- (UIImage *) getImage:(NSString *) imageName withBigSize:(BOOL) big;
- (void) putImage:(UIImage *) image forName:(NSString *) imageName withBigSize:(BOOL) big;

- (void) fillInCache;

@end
