//
//  IQARCHelper.h
//  IQKit
//
//  Created by Héctor on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//
//  ARC Helper
//
//  Version 1.3
//
//  Created by Nick Lockwood on 05/01/2012.
//  Copyright 2012 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://gist.github.com/1563325
//

#ifndef IQ_RETAIN
#if __has_feature(objc_arc)
#define IQ_RETAIN(x) (x)
#define IQ_RELEASE(x) (void)(x)
#define IQ_RELEASE_AND_NIL(x) ((x) = nil)
#define IQ_AUTORELEASE(x) (x)
#define IQ_SUPER_DEALLOC (void)(0)
#define __IQ_BRIDGE __bridge
#else
#define __IQ_WEAK
#define IQ_WEAK assign
#define IQ_RETAIN(x) [(x) retain]
#define IQ_RELEASE(x) [(x) release]
#define IQ_RELEASE_AND_NIL(x) ([(x) release], (x) = nil)
#define IQ_AUTORELEASE(x) [(x) autorelease]
#define IQ_SUPER_DEALLOC [super dealloc]
#define __IQ_BRIDGE
#endif
#endif

//  Weak reference support

#ifndef IQ_WEAK
#if defined __IPHONE_OS_VERSION_MIN_REQUIRED
#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_4_3
#define __IQ_WEAK __weak
#define IQ_WEAK weak
#else
#define __IQ_WEAK __unsafe_unretained
#define IQ_WEAK unsafe_unretained
#endif
#elif defined __MAC_OS_X_VERSION_MIN_REQUIRED
#if __MAC_OS_X_VERSION_MIN_REQUIRED > __MAC_10_6
#define __IQ_WEAK __weak
#define IQ_WEAK weak
#else
#define __IQ_WEAK __unsafe_unretained
#define IQ_WEAK unsafe_unretained
#endif
#endif
#endif

// Singleton using block macro:

#if __has_feature(objc_arc)

#define IQ_ARC_DEFINE_SHARED_INSTANCE_USING_BLOCK_(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject;
#else

#define IQ_ARC_DEFINE_SHARED_INSTANCE_USING_BLOCK_(block) 

#endif

// Singleton with class name macro:

#if __has_feature(objc_arc)

#define IQ_ARC_SINGLETON_CUSTOM_(classname, methodname) \
+ (classname*) methodname \
{ \
IQ_ARC_DEFINE_SHARED_INSTANCE_USING_BLOCK_(^{ \
return [[self alloc] init]; \
}); \
}

#define IQ_ARC_SINGLETON_(classname) IQ_ARC_SINGLETON_CUSTOM_(classname,sharedInstance)

#else

#define IQ_ARC_SINGLETON_CUSTOM_(classname, methodname) 
#define IQ_ARC_SINGLETON_(classname) 

#endif

//  ARC Helper ends
