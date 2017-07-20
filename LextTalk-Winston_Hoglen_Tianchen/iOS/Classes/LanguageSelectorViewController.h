//
//  LanguageSelectorViewController.h
// LextTalk
//
//  Created by Yo on 10/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdInheritanceViewController.h"
#import "LanguageSelectorController.h"

@protocol LanguageSelectorViewControllerDelegate <NSObject>
@optional

- (void) selectedItems: (NSArray *) selectedItems 
             withFlags: (NSArray *) flags 
           withTextTag:(NSString *) textTag;

- (void) selectedItem:(NSString *) selected withTextTag:(NSString *) textTag;

@end


@interface LanguageSelectorViewController : AdInheritanceViewController <LanguageSelectorControllerDelegate>
{
    NSArray * textArray;
    NSArray * selectedItems;
    NSArray * flagIndexForSelectedItems;
    NSDictionary * preferredFlagForLan;
	BOOL multiple;
    BOOL showFlats;
    
    NSString * textTag;
    
    LanguageSelectorController * controller;
	
	id<LanguageSelectorViewControllerDelegate> __weak delegate;
}

@property (nonatomic, strong) UITableView * myTableView;
@property (strong) NSArray * textArray;
@property (strong) NSArray * selectedItems;
@property (strong) NSArray * flagIndexForSelectedItems;
@property (nonatomic, strong) NSDictionary * preferredFlagForLan;
@property BOOL multiple;
@property BOOL showFlags;
@property (strong) NSString * textTag;
@property (weak) id<LanguageSelectorViewControllerDelegate> delegate;

@end
