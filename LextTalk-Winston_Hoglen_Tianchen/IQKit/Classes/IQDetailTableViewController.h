//
//  IQDetailTableViewController.h
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQBaseTableViewController.h"
#import "IQObject.h"
#import "IQTableViewProtocol.h"

@interface IQDetailTableViewController : IQBaseTableViewController {
	
	IQObject <IQTableViewProtocol>			*_mainObject;
	NSArray									*_sectionList;
	NSArray									*_sectionTitleList;
}

@property (nonatomic, strong) IQObject <IQTableViewProtocol>	*mainObject;
@property (nonatomic, strong) NSArray *sectionList;
@property (nonatomic, strong) NSArray *sectionTitleList;

@end
