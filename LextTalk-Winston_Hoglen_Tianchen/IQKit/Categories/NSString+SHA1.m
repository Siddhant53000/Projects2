//
//  SHA1.m

#include <CommonCrypto/CommonDigest.h>
#import "NSString+SHA1.h"


@implementation NSString (SHA1)

+ (NSString*) sha1Digest: (NSString*)input{
	
	return [NSString stringToSha1: input];
}

+(NSString *) stringToSha1: (NSString *)str{

	const char *s = [str cStringUsingEncoding:NSASCIIStringEncoding];
	if(s == nil) return nil;
	
	NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
	
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
	
	//NSLog(@"Hash is %@ for string %@", hash, str);		
    	
    return hash;
}


+ (NSString *)sha1:(NSString *)str {
	const char *cStr = [str UTF8String];
	unsigned char result[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(cStr, strlen(cStr), result);
	NSString *s = [NSString  stringWithFormat:
				   @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
				   result[0], result[1], result[2], result[3], result[4],
				   result[5], result[6], result[7],
				   result[8], result[9], result[10], result[11], result[12],
				   result[13], result[14], result[15],
				   result[16], result[17], result[18], result[19]
				   ];
	
	return [s lowercaseString];
}

+ (NSData *)dataOfSHA1Hash:(NSData*)data {
    unsigned char hashBytes[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([data bytes], CC_SHA1_DIGEST_LENGTH, hashBytes);
	
    return [NSData dataWithBytes:hashBytes length:CC_SHA1_DIGEST_LENGTH];
}

@end
