//
//  IQStoreManager.h
//  deej
//
//  Created by David Romacho on 8/4/13.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "IQStoreTransactionValidator.h"

typedef enum {
    IQStoreManagerStatusLoading = 0,
    IQStoreManagerStatusNotAvailable = 1,
    IQStoreManagerStatusAvailable = 2
} IQStoreManagerStatus;

extern NSString *const IQStoreManagerStatusUpdatedNotification;
extern NSString *const IQStoreManagerProductDisabledNotification;
extern NSString *const IQStoreManagerProductEnabledNotification;

extern NSString *const IQStoreManagerProductEnabledProductIdKey; // use it to get the product id from userDict in notification
extern NSString *const IQStoreManagerProductEnabledIsPurchaseKey; // NSNumber boolean

@protocol IQStoreManagerDelegate;

@interface IQStoreManager : NSObject
@property (nonatomic, weak) id<IQStoreManagerDelegate>                  delegate;
@property (nonatomic, assign)           BOOL                            useKeychain;
@property (nonatomic, strong)           IQStoreTransactionValidator     *transactionValidator;
@property (nonatomic, assign, readonly) IQStoreManagerStatus            status;
@property (nonatomic, strong, readonly) NSArray                         *products;
@property (nonatomic, strong, readonly) NSArray                         *invalidProductIdentifiers;

- (void)startLoadingProducts;
- (void)startPurchaseProcessForProduct:(NSString*)productId;
- (void)startRestoreProcess;
- (void)enableProduct:(NSString*)productId;
- (void)disableProduct:(NSString*)productId;

- (BOOL)productIsEnabled:(NSString*)productId;
- (SKProduct*)productWithId:(NSString*)productId;

// custom data store methods
- (void)setString:(NSString*)val forKey:(NSString*)key;
- (NSString*)stringForKey:(NSString*)key;

- (void)setBool:(BOOL)val forKey:(NSString*)key;
- (BOOL)boolForKey:(NSString*)key;

- (void)setDouble:(double)val forKey:(NSString *)key;
- (double)doubleForKey:(NSString*)key;

- (void)setInteger:(int)val forKey:(NSString *)key;
- (double)integerForKey:(NSString*)key;

- (void)removeValueForKey:(NSString*)key;

@end

@protocol IQStoreManagerDelegate <NSObject>
@required

// data source
- (NSArray*)listOfProductsToValidateForStoreManager:(IQStoreManager*)mgr;

// downloads
- (void)storeManager:(IQStoreManager*)mgr didStartDownloadingHostedContent:(NSString *)productId;
- (void)storeManager:(IQStoreManager*)mgr didUpdateDownloadProgress:(CGFloat)val timeRemaining:(NSTimeInterval)time forHostedContent:(NSString*)productId;
- (void)storeManager:(IQStoreManager*)mgr didDownloadHostedContent:(NSString *)productId inDirectory:(NSString *)path;
- (void)storeManager:(IQStoreManager*)mgr didFailDownloadingHostedContent:(NSString *)productId error:(NSError*)error;

// transactions
- (void)storeManager:(IQStoreManager *)mgr transactionForProduct:(NSString*)productId failedWithError:(NSError*)error;
- (void)storeManager:(IQStoreManager *)mgr transactionForProduct:(NSString*)productId cancelledWithError:(NSError*)error;
- (void)storeManager:(IQStoreManager *)mgr transactionForProduct:(NSString*)productId notVerifiedWithError:(NSError*)error;
- (void)storeManager:(IQStoreManager *)mgr transactionFinishedForProduct:(NSString*)productId;

// restores
- (void)storeManager:(IQStoreManager *)mgr restoreTransactionsFailedWithError:(NSError*)error;
- (void)storeManager:(IQStoreManager *)mgr restoreTransactionsCancelledWithError:(NSError*)error;
- (void)restoreTransactionsDoneInStoreManager:(IQStoreManager*)mgr;

// product enable/disable
- (void)storeManager:(IQStoreManager*)mgr didEnableProduct:(NSString*)productId isPurchase:(BOOL)isPurchase;
- (void)storeManager:(IQStoreManager*)mgr didDisableProduct:(NSString*)productId;

// purchases are disabled
- (void)purchasesAreDisabledForStoreManager:(IQStoreManager*)mgr;
@end
