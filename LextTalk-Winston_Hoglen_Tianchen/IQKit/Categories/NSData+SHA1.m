//
//  NSData+SHA1.m
//  hayTrafico
//
//  Created by David on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#include <CommonCrypto/CommonDigest.h>
#import "NSData+SHA1.h"


@implementation NSData (SHA1)

+ (NSString*) sha1Digest:(NSData*)keyData {
	// This is the destination
	uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
	// This one function does an unkeyed SHA1 hash of your hash data
	CC_SHA1(keyData.bytes, keyData.length, digest);
	
	// Now convert to NSData structure to make it usable again
	NSData *out = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
	// description converts to hex but puts <> around it and spaces every 4 bytes
	NSString *hash = [out description];
	hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
	hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
	hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
	
    return hash;
}

@end
