//
//  IQStoreTransactionValidator.h
//  deej
//
//  Created by David Romacho on 8/4/13.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef void (^IQStoreTransactionValidatorCompletionHandler)(BOOL success, NSError *error);

@interface IQStoreTransactionValidator : NSObject
- (void)validatePurchase:(SKPaymentTransaction *)transaction completionHandler:(IQStoreTransactionValidatorCompletionHandler)block;
@end


