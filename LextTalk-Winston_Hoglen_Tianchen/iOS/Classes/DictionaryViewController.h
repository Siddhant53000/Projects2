//
//  DictionaryViewController.h
//  LextTalk
//
//  Created by Yo on 11/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdInheritanceViewController.h"
//The arrays of languages contain masterLans, always

@interface DictionaryViewController : AdInheritanceViewController <UITableViewDelegate, UITableViewDataSource>
{
    
    NSMutableArray * fromArray;
    NSMutableArray * toArray;
}

@property (nonatomic, strong) UITableView * myTableView;

@end
