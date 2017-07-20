//
//  NotepadHandler.m
//  LextTalk
//
//  Created by Isaaca Hoglen on 10/19/16.
//
//

#import "NotepadHandler.h"

static sqlite3 * _notepad;
static sqlite3_stmt *statement;
static NotepadHandler* sharedInstance;

@implementation NotepadHandler

+(NotepadHandler*)getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL] init];
        //        [sharedInstance installDatabase];
    }
    return sharedInstance;
}

- (BOOL) installDatabase
{
    NSString* docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"notepad.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if (![filemgr fileExistsAtPath:databasePath]) {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &_notepad) == SQLITE_OK) {
            char *errMsg;
            const char *sql_stmt = "create table if not exists notepad (usercounter integer primary key, userID integer, note text)";
            if (sqlite3_exec(_notepad, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(_notepad);
        } else {
            isSuccess = NO;
            NSLog(@"Failed to create table");
        }
    }
    NSLog(@"Success: %d", isSuccess);
    return isSuccess;
}

- (BOOL)saveData: (NSString*) note {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &_notepad) == SQLITE_OK) {
        NSLog(@"UserID saveData: %d", (int)[LTDataSource sharedDataSource].localUser.userId);
        NSString *insertSQL = [NSString stringWithFormat:@"insert into notepad (userID,note) values (\"%d\",\"%@\")",(int)[LTDataSource sharedDataSource].localUser.userId, note];
        NSLog(@"InsertSQL: %@", insertSQL);
        const char *insertStmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_notepad, insertStmt, -1, &statement, NULL);
        if (statement) NSLog(@"I am a statement ");
        else NSLog(@"I am still null");
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"Successfully added note %@ to user %d", note, (int)[LTDataSource sharedDataSource].localUser.userId);
            sqlite3_reset(statement);
            return YES;
        } else {
            NSLog(@"1 Unsuccessfully added note %@ to user %d", note, (int)[LTDataSource sharedDataSource].localUser.userId);
            sqlite3_reset(statement);
            return NO;
        }
        
    }
    NSLog(@"2 Unsuccessfully added note %@ to user %d", note, (int)[LTDataSource sharedDataSource].localUser.userId);
    return NO;
}

- (NSMutableArray*) getUserNotepad {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &_notepad) == SQLITE_OK) {
        NSLog(@"UserID: %d", (int)[LTDataSource sharedDataSource].localUser.userId);
        NSString *querySQL = [NSString stringWithFormat:@"select note from notepad where userID=\"%d\"",(int)[LTDataSource sharedDataSource].localUser.userId];
        NSLog(@"Querysql: %@", querySQL);
        const char* queryStmt = [querySQL UTF8String];
        NSMutableArray *results = [[NSMutableArray alloc] init];
        if (sqlite3_prepare_v2(_notepad, queryStmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSString *note = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                [results addObject:note];
                
            }
            sqlite3_reset(statement);
            return results;
            
        }
    }
    return nil;
}

- (BOOL)deleteFromDatabase: (NSString*) note {
    const char* dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &_notepad) == SQLITE_OK) {
        NSString *deleteStatement = [NSString stringWithFormat:@"delete from notepad where userID=\"%d\" and note=\"%@\"", (int)[LTDataSource sharedDataSource].localUser.userId, note];
        NSLog(@"Delete statement: %@", deleteStatement);
        const char* deleteStmt = [deleteStatement UTF8String];
        if (sqlite3_prepare_v2(_notepad, deleteStmt, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) != 101) {
                NSLog(@"Delete failed");
                return false;
            } else {
                NSLog(@"Delete successful");
                return true;
            }
        } else {
            NSLog(@"Delete failed");
            return false;
        }
    } else {
        NSLog(@"Delete failed");
        return false;
    }
}
@end
