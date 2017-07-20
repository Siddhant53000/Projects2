//
//  IQAppStoreTransactionValidator.h
//  deej
//
//  Created by David Romacho on 8/4/13.
//
//

#import "IQStoreTransactionValidator.h"

@interface IQAppStoreTransactionValidator : IQStoreTransactionValidator
- (id)initWithContentProviderSharedSecret:(NSString*)secret;
@end
