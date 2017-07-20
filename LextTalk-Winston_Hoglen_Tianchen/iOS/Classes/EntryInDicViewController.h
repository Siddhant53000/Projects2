//
//  EntryInDicViewController.h
//  LextTalk
//
//  Created by Yo on 11/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdInheritanceViewController.h"

@interface EntryInDicViewController : AdInheritanceViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UIPopoverControllerDelegate>
{
    NSString * fromLan;
    NSString * toLan;
    NSMutableArray * keyArray;
    NSMutableDictionary * currentDictionary;
    
    NSMutableArray * searchArray;
    NSString * savedSearchTerm;
    BOOL searchWasActive;
    
    UIPopoverController * popoverController;
}

@property (nonatomic, strong) UITableView * myTableView;
@property (nonatomic, strong) NSString * fromLan;
@property (nonatomic, strong) NSString * toLan;

@property (nonatomic, strong) UIPopoverController * popoverController;


@end
