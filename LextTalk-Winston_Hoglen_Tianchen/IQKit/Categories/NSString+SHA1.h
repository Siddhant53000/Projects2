//
//  SHA1.h

#import <Foundation/Foundation.h>

@interface NSString (SHA1)
+(NSString*) sha1Digest: (NSString*)input;
+(NSString *) stringToSha1: (NSString *)str;
@end
