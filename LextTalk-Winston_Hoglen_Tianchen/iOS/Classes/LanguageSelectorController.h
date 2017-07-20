//
//  LanguageSelectorController.h
// LextTalk
//
//  Created by Yo on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MySegmentedControl : UISegmentedControl {
    
    NSInteger current;
    
}

@end

@protocol LanguageSelectorControllerDelegate <NSObject>
@optional

- (void) selectedItems: (NSArray *) selectedItems 
             withFlags: (NSArray *) flags 
           withTextTag:(NSString *) textTag;

- (void) selectedItem:(NSString *) selected withTextTag:(NSString *) textTag;

@end


@interface LanguageSelectorController : NSObject <UITableViewDelegate, UITableViewDataSource>

{
    UITableView * myTableView;
    
    NSArray * textArray;
    NSArray * selectedItems;
    NSArray * flagIndexForSelectedItems;
    NSDictionary * preferredFlagForLan;
    
	BOOL multiple;
    BOOL showFlags;
    
    NSMutableArray * selected;
    NSMutableDictionary * selectedFlags;
    
    NSString * textTag;
	
	id<LanguageSelectorControllerDelegate> __weak delegate;
}

@property (nonatomic, strong) UITableView * myTableView;
@property (nonatomic, strong) NSArray * textArray;
@property (nonatomic, strong) NSArray * selectedItems;
@property (nonatomic, strong) NSArray * flagIndexForSelectedItems;
@property (nonatomic, strong) NSDictionary * preferredFlagForLan;
@property (nonatomic, strong) NSString * textTag;
@property (weak) id<LanguageSelectorControllerDelegate> delegate;

/*
- (id) initWithTableView:(UITableView *) myTableView2 
               textArray:(NSArray *) textArray2 
           selectedItems:(NSArray *) selectedItems2
flagIndexForSelectedItems:(NSArray *) flagIndexForSelectedItems2
                multiple:(BOOL) multiple2
showFlagInSingleSelection:(BOOL) showFlags2
                 textTag:(NSString *) textTag2
                delegate:(id<LanguageSelectorControllerDelegate>) delegate2;
*/


- (id) initWithMultipleSelectionTableView:(UITableView *) myTableView2 
                                textArray:(NSArray *) textArray2 
                            selectedItems:(NSArray *) selectedItems2
                flagIndexForSelectedItems:(NSArray *) flagIndexForSelectedItems2
                                  textTag:(NSString *) textTag2
                                 delegate:(id<LanguageSelectorControllerDelegate>) delegate2;

- (id) initWithSingleSelectionTableView:(UITableView *) myTableView2 
                              textArray:(NSArray *) textArray2 
                          selectedItems:(NSArray *) selectedItems2
                    preferredFlagForLan:(NSDictionary *) preferredFlagForLan2
                              showFlags: (BOOL) showFlags2
                                textTag:(NSString *) textTag2
                               delegate:(id<LanguageSelectorControllerDelegate>) delegate2;

- (void) resetSelections;
- (void) selectAndScrollToItem:(NSString *) item;

@end
