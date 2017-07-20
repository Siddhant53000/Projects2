//
//  IQStoreTransactionValidator.m
//  deej
//
//  Created by David Romacho on 8/4/13.
//
//

#import "IQStoreTransactionValidator.h"

#if (!__has_feature(objc_arc))
#error Compile using ARC!!
#endif

@implementation IQStoreTransactionValidator

- (void)validatePurchase:(SKPaymentTransaction *)transaction completionHandler:(IQStoreTransactionValidatorCompletionHandler)block {
    // reimplement
}
@end
