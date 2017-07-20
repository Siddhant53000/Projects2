//
//  IQSectionTableViewController.h
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQBaseTableViewController.h"

@interface IQSectionTableViewController : IQBaseTableViewController {
	NSArray								*_sectionList;
	NSArray								*_sectionTitleList;	
}

@property (nonatomic, strong) NSArray *sectionList;
@property (nonatomic, strong) NSArray *sectionTitleList;

@end
