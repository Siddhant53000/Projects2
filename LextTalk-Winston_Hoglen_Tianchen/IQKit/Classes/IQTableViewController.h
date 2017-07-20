//
//  IQTableViewController.h
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQBaseTableViewController.h"

@interface IQTableViewController : IQBaseTableViewController {
	NSArray								*_objectList;
}

@property (nonatomic, strong) NSArray *objectList;

@end
