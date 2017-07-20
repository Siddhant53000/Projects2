//
//  IQTableObject.h
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IQObject.h"
#import "IQTableViewProtocol.h"
#import "IQAsyncImage.h"

@interface IQTableObject : IQObject <IQAsyncImageDelegate> {
	UITableViewCell			*_cell;		
	UITableView				*__weak _showingTable;
	id<IQTableViewProtocol>	__weak _updateDelegate;
}

@property (nonatomic, strong) IBOutlet UITableViewCell *cell;
@property (nonatomic, weak) id<IQTableViewProtocol> updateDelegate;
@property (nonatomic, weak) UITableView *showingTable;

- (BOOL)loadNibFile:(NSString *)nibName;
- (void) cancelUpdateDelegates;

@end
