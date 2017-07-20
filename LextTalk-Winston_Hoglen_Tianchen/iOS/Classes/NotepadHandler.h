//
//  NotepadHandler.h
//  LextTalk
//
//  Created by Isaaca Hoglen on 10/19/16.
//
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "LTDataSource.h"

@interface NotepadHandler : NSObject
{
    NSString *databasePath;
}

+ (NotepadHandler *) getSharedInstance;
- (BOOL) installDatabase;
- (BOOL)saveData: (NSString*) note;
- (NSMutableArray*) getUserNotepad;
- (BOOL)deleteFromDatabase: (NSString*) note;
@end
