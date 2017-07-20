//
//  IQStoreManager.m
//  deej
//
//  Created by David Romacho on 8/4/13.
//
//

#import "IQStoreManager.h"
#import "PDKeychainBindings.h"

#if (!__has_feature(objc_arc))
#error Compile using ARC!!
#endif

NSString *const IQStoreManagerStatusUpdatedNotification = @"kIQStoreManagerStatusUpdatedNotification";
NSString *const IQStoreManagerProductDisabledNotification = @"kIQStoreManagerProductDisabledNotification";
NSString *const IQStoreManagerProductEnabledNotification = @"kIQStoreManagerProductEnabledNotification";
NSString *const IQStoreManagerProductEnabledProductIdKey = @"kIQStoreManagerProductEnabledProductIdKey";
NSString *const IQStoreManagerProductEnabledIsPurchaseKey = @"kIQStoreManagerProductEnabledIsPurchaseKey";


@interface IQStoreManager()<SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic, assign) IQStoreManagerStatus    status;
@property (nonatomic, strong) NSArray                 *products;
@property (nonatomic, strong) NSArray                 *invalidProductIdentifiers;
@property (nonatomic, strong) SKProductsRequest       *productsRequest;
@property (nonatomic, assign) BOOL                    validationProcessStarted;

@end

@implementation IQStoreManager
@synthesize status = _status;

#pragma mark -
#pragma mark NSObject methods

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    self = [super init];
    if(self) {
        self.useKeychain = YES;
        self.validationProcessStarted = NO;
        _status = IQStoreManagerStatusNotAvailable;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleForegroundNotification)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark -
#pragma mark IQStoreManager methods

- (void)setStatus:(IQStoreManagerStatus)status {
    if(status != _status) {
        _status = status;
        [[NSNotificationCenter defaultCenter] postNotificationName:IQStoreManagerStatusUpdatedNotification object:nil];
    }
}

- (void)startLoadingProducts {
    if(self.productsRequest) {
        self.productsRequest.delegate = nil;
        self.productsRequest = nil;
    }
    if(self.status != IQStoreManagerStatusAvailable) {
        NSArray *array = [self.delegate listOfProductsToValidateForStoreManager:self];
        NSSet *productIdentifiers = [NSSet setWithArray:array];
        self.status = IQStoreManagerStatusLoading;
        self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
        self.productsRequest.delegate = self;
        [self.productsRequest start];
        
        self.validationProcessStarted = YES;
    }
}

- (void)startPurchaseProcessForProduct:(NSString*)productId {
    
    // can we make payments ?
    if(![SKPaymentQueue canMakePayments]) {
        if ([self.delegate respondsToSelector:@selector(purchasesAreDisabledForStoreManager:)]) {
            [self.delegate purchasesAreDisabledForStoreManager:self];
        }
        return;
    }
    
    SKProduct *product = [self productWithId:productId];
    // does the product exist ?
    if(!product) {
        if([self.delegate respondsToSelector:@selector(storeManager:transactionForProduct:failedWithError:)]) {
            [self.delegate storeManager:self
                  transactionForProduct:productId
                        failedWithError:[NSError errorWithDomain:@"com.inqbarna"
                                                            code:0
                                                        userInfo:@{NSLocalizedDescriptionKey:
                                                                   NSLocalizedString(@"Invalid product", nil)}]];
        }
        return;
    }
    
    // start purchase process
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)startRestoreProcess {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)enableProduct:(NSString*)productId {
    [self setBool:YES forKey:productId];
    if([self.delegate respondsToSelector:@selector(storeManager:didEnableProduct:isPurchase:)]) {
        [self.delegate storeManager:self didEnableProduct:productId isPurchase:NO];
    }
    NSDictionary *userInfo = @{IQStoreManagerProductEnabledProductIdKey:productId,
                               IQStoreManagerProductEnabledIsPurchaseKey:[NSNumber numberWithBool:NO]};
    NSNotification *n = [NSNotification notificationWithName:IQStoreManagerProductEnabledNotification
                                                      object:nil
                                                    userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (void)disableProduct:(NSString*)productId {
    [self removeValueForKey:productId];
    if([self.delegate respondsToSelector:@selector(storeManager:didDisableProduct:)]) {
        [self.delegate storeManager:self didDisableProduct:productId];
    }
    
    NSDictionary *userInfo = @{IQStoreManagerProductEnabledProductIdKey:productId};
    NSNotification *n = [NSNotification notificationWithName:IQStoreManagerProductDisabledNotification
                                                      object:nil
                                                    userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:n]; 
}

- (BOOL)productIsEnabled:(NSString*)productId {
    return [self boolForKey:productId];
}

- (SKProduct*)productWithId:(NSString*)productId {
    for(SKProduct *p in self.products) {
        if([p.productIdentifier isEqualToString:productId]) {
            return p;
        }
    }
    return nil;
}


- (void)handleCompletedTransaction:(SKPaymentTransaction*)transaction {
    NSString *productId = transaction.originalTransaction.payment.productIdentifier;
    if(productId == nil) {
        productId = transaction.payment.productIdentifier;
    }
    
    if([self.delegate respondsToSelector:@selector(storeManager:transactionFinishedForProduct:)]) {
        [self.delegate storeManager:self transactionFinishedForProduct:productId];
    }
    
    [self setBool:YES forKey:productId];
    if([self.delegate respondsToSelector:@selector(storeManager:didEnableProduct:isPurchase:)]) {
        [self.delegate storeManager:self didEnableProduct:productId isPurchase:YES];
    }
    
    NSDictionary *userInfo = @{IQStoreManagerProductEnabledProductIdKey:productId,
                               IQStoreManagerProductEnabledIsPurchaseKey:[NSNumber numberWithBool:YES]};
    NSNotification *n = [NSNotification notificationWithName:IQStoreManagerProductEnabledNotification
                                                      object:nil
                                                    userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:n];
    
    // Finish the transaction
    if([transaction respondsToSelector:@selector(downloads)]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloadState = %d", SKDownloadStateWaiting];
        NSArray *waitingDownloads = [transaction.downloads filteredArrayUsingPredicate:predicate];
        if(transaction.downloads && waitingDownloads.count) {
            [[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];
            
            if([self.delegate respondsToSelector:@selector(storeManager:didStartDownloadingHostedContent:)]) {
                [self.delegate storeManager:self didStartDownloadingHostedContent:productId];
            }
            return;
        }
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)handleDownload:(SKDownload *)download {
    NSString *path = [download.contentURL.path stringByAppendingPathComponent:@"Contents"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:&error];
    NSString *dir = [IQStoreManager downloadableContentPathForProductId:download.contentIdentifier];
    
    for(NSString *file in files) {
        NSString *fullPathSrc = [path stringByAppendingPathComponent:file];
        NSString *fullPathDst = [dir stringByAppendingPathComponent:file];
        
        [fileManager removeItemAtPath:fullPathDst error:NULL];
        
        if ([fileManager moveItemAtPath:fullPathSrc toPath:fullPathDst error:&error] == NO) {
            NSLog(@"Error: unable to move item: %@", error);
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(storeManager:didDownloadHostedContent:inDirectory:)]) {
        [self.delegate storeManager:self didDownloadHostedContent:download.contentIdentifier inDirectory:dir];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:download.transaction];
}

- (void)handleFailedTransaction:(SKPaymentTransaction*)transaction {
    NSString *productId = transaction.originalTransaction.payment.productIdentifier;
    if(productId == nil) {
        productId = transaction.payment.productIdentifier;
    }
    
    if(transaction.error.code != SKErrorPaymentCancelled) {
        // Optionally, display an error here.
        if ([self.delegate respondsToSelector:@selector(storeManager:transactionForProduct:failedWithError:)]) {
            [self.delegate storeManager:self
                  transactionForProduct:productId
                        failedWithError:transaction.error];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Transaction failed"
                                        message:@"Don't worry, you have not been charged."
                                       delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Close", nil] show];
        }
    } else if([self.delegate respondsToSelector:@selector(storeManager:transactionForProduct:cancelledWithError:)]) {
        [self.delegate storeManager:self
              transactionForProduct:productId
                 cancelledWithError:transaction.error];
    }
    
    // remove from queue
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)handleForegroundNotification {
    if(self.validationProcessStarted) {
        [self startLoadingProducts];
    }
}

#pragma mark -
#pragma mark SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.products = response.products;
    self.invalidProductIdentifiers = response.invalidProductIdentifiers;
    self.productsRequest = nil;
    self.status = IQStoreManagerStatusAvailable;
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
                // For now do exactly the same for a restored purchase and a regular transaction
                // When transaction finishes a different delegate call will be used based on the transactionStatus
                [self handleCompletedTransaction:transaction];
                
//                if(self.transactionValidator) {
//                    [self.transactionValidator validatePurchase:transaction completionHandler:^(BOOL success, NSError *error)
//                     {
//                         if(success) {
//                             NSLog(@"Successfully verified receipt!");
//                             [self handleCompletedTransaction:transaction];
//                         } else {
//                             NSLog(@"Failed to validate receipt.");
//                             
//                             if([self.delegate
//                                 respondsToSelector:@selector(storeManager:transactionForProduct:notVerifiedWithError:)])
//                             {
//                                 [self.delegate storeManager:self
//                                       transactionForProduct:transaction.payment.productIdentifier
//                                        notVerifiedWithError:error];
//                             }
//                             // TODO, check if the transaction should be removed
//                             [[SKPaymentQueue defaultQueue] finishTransaction:transaction]; 
//                         }
//                     }];
//                } else {
//                    [self handleCompletedTransaction:transaction];
//                }
                break;
                
            case SKPaymentTransactionStateFailed:
                [self handleFailedTransaction:transaction];
                break;
                
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStateDeferred:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    if (error.code == SKErrorPaymentCancelled) {
        if ([self.delegate respondsToSelector:@selector(storeManager:restoreTransactionsCancelledWithError:)]) {
            [self.delegate storeManager:self restoreTransactionsCancelledWithError:error];
        }
    } else {
        if([self.delegate respondsToSelector:@selector(storeManager:restoreTransactionsFailedWithError:)]) {
            [self.delegate storeManager:self restoreTransactionsFailedWithError:error];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Restore failed"
                                        message:@"Don't worry, you have not been charged."
                                       delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Close", nil] show];
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    if([self.delegate respondsToSelector:@selector(restoreTransactionsDoneInStoreManager:)]) {
        [self.delegate restoreTransactionsDoneInStoreManager:self];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
    NSLog(@"IQStoreObserver:: paymentQueue:removedTransactions:");
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads {
    for (SKDownload *download in downloads) {
        switch (download.downloadState) {
            case SKDownloadStateFinished:
                [self handleDownload:download];
                break;
                
            case SKDownloadStateCancelled:
            case SKDownloadStateFailed:
                NSLog(@"Download failed %@", download.contentIdentifier);
                
                if ([self.delegate respondsToSelector:@selector(storeManager:didFailDownloadingHostedContent:error:)]) {
                    [self.delegate storeManager:self
                didFailDownloadingHostedContent:download.contentIdentifier
                                          error:download.error];
                }
                break;
                
            case SKDownloadStateActive:                
                if([self.delegate respondsToSelector:@selector(storeManager:didUpdateDownloadProgress:timeRemaining:forHostedContent:)]) {
                    [self.delegate storeManager:self
                      didUpdateDownloadProgress:download.progress
                                  timeRemaining:download.timeRemaining
                               forHostedContent:download.contentIdentifier];
                }
                
                break;
                
            default:
                // FIXME: Pause or waiting
                NSLog(@"Download waiting or paused %@", download.contentIdentifier);
                break;
        }
    }
}

#pragma mark -
#pragma mark Helper methods

+ (NSString *)downloadableContentPathForProductId:(NSString *)productId {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    
    directory = [directory stringByAppendingPathComponent:@"Downloads"];
    directory = [directory stringByAppendingPathComponent:productId];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:directory] == NO) {
        NSError *error;
        
        if ([fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error] == NO) {
            NSLog(@"Error: Unable to create directory: %@", error);
        }
        
        NSURL *url = [NSURL fileURLWithPath:directory];
        
        // exclude downloads from iCloud backup
        if ([url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error] == NO) {
            NSLog(@"Error: Unable to exclude directory from backup: %@", error);
        }
    }
    
    return directory;
}

#pragma mark -
#pragma mark Data storage methods

- (void)setString:(NSString*)val forKey:(NSString*)key {
    if(self.useKeychain) {
        [[PDKeychainBindings sharedKeychainBindings] setString:val forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:val forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString*)stringForKey:(NSString*)key {
    if(self.useKeychain) {
        return [[PDKeychainBindings sharedKeychainBindings] stringForKey:key];
    } else {
        return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    }
}

- (void)setBool:(BOOL)val forKey:(NSString*)key {
    if(self.useKeychain) {
        [[PDKeychainBindings sharedKeychainBindings] setString:val?@"YES":@"NO" forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:val forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL)boolForKey:(NSString*)key {
    if(self.useKeychain) {
        return [[[PDKeychainBindings sharedKeychainBindings] stringForKey:key] isEqualToString:@"YES"];
    } else {
        return [[NSUserDefaults standardUserDefaults] boolForKey:key];
    }
}

- (void)setDouble:(double)val forKey:(NSString *)key {
    if(self.useKeychain) {
        [[PDKeychainBindings sharedKeychainBindings] setString:[NSString stringWithFormat:@"%f",val] forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] setDouble:val forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (double)doubleForKey:(NSString*)key {
    if(self.useKeychain) {
        return [[[PDKeychainBindings sharedKeychainBindings] stringForKey:key] doubleValue];
    } else {
        return [[NSUserDefaults standardUserDefaults] doubleForKey:key];
    }
}

- (void)setInteger:(int)val forKey:(NSString *)key {
    if(self.useKeychain) {
        [[PDKeychainBindings sharedKeychainBindings] setString:[NSString stringWithFormat:@"%d",val] forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] setInteger:val forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (double)integerForKey:(NSString*)key {
    if(self.useKeychain) {
        return [[[PDKeychainBindings sharedKeychainBindings] stringForKey:key] integerValue];
    } else {
        return [[NSUserDefaults standardUserDefaults] integerForKey:key];
    }
}

- (void)removeValueForKey:(NSString*)key {
    if(self.useKeychain) {
        return [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:key];
    } else {
        return [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
}

@end
