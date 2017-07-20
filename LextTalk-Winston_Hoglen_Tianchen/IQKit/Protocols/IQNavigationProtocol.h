/*
 *  IQNavigationProtocol.h
 *
 *  Created by David on 1/12/11.
 *  Copyright 2011 InQbarna. All rights reserved.
 *
 */
@protocol IQNavigationProtocol
@optional
- (void) selectedInViewController: (UIViewController*) viewController;
- (void) selectedInViewController: (UIViewController*) viewController withContext: (id) context;
@end



