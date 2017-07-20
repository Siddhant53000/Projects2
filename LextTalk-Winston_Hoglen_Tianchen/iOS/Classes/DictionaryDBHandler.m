//
//  DictionaryDBHandler.m
//  LextTalk
//
//  Created by Isaaca Hoglen on 11/23/16.
//
//

#import "DictionaryDBHandler.h"

static sqlite3 * _dictionary;
static sqlite3_stmt *dictStatement;
static DictionaryDBHandler* sharedInstance;

@implementation DictionaryDBHandler

+(DictionaryDBHandler*)getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

- (BOOL) installDatabase
{
    NSString* docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"dictionary.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if (![filemgr fileExistsAtPath:databasePath]) {
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &_dictionary) == SQLITE_OK) {
            char *errMsg;
            const char *sql_stmt = "create table if not exists dictionary (usercounter integer primary key, userID integer, word text, definition text)";
            if (sqlite3_exec(_dictionary, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                isSuccess = NO;
                NSLog(@"Failed to create dictionary table");
            }
            sqlite3_close(_dictionary);
        } else {
            isSuccess = NO;
            NSLog(@"Failed to create dictionary table");
        }
    }
    NSLog(@"Success: dictionary created %d", isSuccess);
    return isSuccess;
}

- (BOOL)saveData: (NSString*) word forDefinition: (NSString*)definition {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &_dictionary) == SQLITE_OK) {
        NSLog(@"UserID saveData: %d", (int)[LTDataSource sharedDataSource].localUser.userId);
        NSString *insertSQL = [NSString stringWithFormat:@"insert into dictionary (userID,word,definition) values (\"%d\",\"%@\",\"%@\")",(int)[LTDataSource sharedDataSource].localUser.userId, word, definition];
        NSLog(@"InsertSQL: %@", insertSQL);
        const char *insertStmt = [insertSQL UTF8String];
        NSLog(@"insertstmt: %s", insertStmt);
        sqlite3_prepare_v2(_dictionary, insertStmt, -1, &dictStatement, NULL);
        if (dictStatement) NSLog(@"I am a statement ");
        else NSLog(@"I am still null");
        if (sqlite3_step(dictStatement) == SQLITE_DONE) {
            NSLog(@"Successfully added word %@ to user %d", word, (int)[LTDataSource sharedDataSource].localUser.userId);
            sqlite3_reset(dictStatement);
            return YES;
        } else {
            NSLog(@"Sql result: %d", sqlite3_step(dictStatement));
            NSLog(@"1 Unsuccessfully added word %@ to user %d", word, (int)[LTDataSource sharedDataSource].localUser.userId);
            sqlite3_reset(dictStatement);
            return NO;
        }
    }
    NSLog(@"2 Unsuccessfully added word %@ to user %d", word, (int)[LTDataSource sharedDataSource].localUser.userId);
    
    return NO;
}

- (NSMutableDictionary*) getUserDictionary {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &_dictionary) == SQLITE_OK) {
        NSLog(@"UserID: %d", (int)[LTDataSource sharedDataSource].localUser.userId);
        NSString *querySQL = [NSString stringWithFormat:@"select word, definition from dictionary where userID=\"%d\"",(int)[LTDataSource sharedDataSource].localUser.userId];
        NSLog(@"Querysql: %@", querySQL);
        const char* queryStmt = [querySQL UTF8String];
        NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
        if (sqlite3_prepare_v2(_dictionary, queryStmt, -1, &dictStatement, NULL) == SQLITE_OK) {
            while (sqlite3_step(dictStatement) == SQLITE_ROW) {
                NSString *word = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(dictStatement, 0)];
                NSString *definition = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(dictStatement, 1)];
                [results setValue:definition forKey:word];
                
            }
            sqlite3_reset(dictStatement);
            return results;
            
        }
    }
    return nil;
}

- (BOOL)deleteFromDatabase: (NSString*) word {
    const char* dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &_dictionary) == SQLITE_OK) {
        NSString *deleteStatement = [NSString stringWithFormat:@"delete from dictionary where userID=\"%d\" and word=\"%@\"", (int)[LTDataSource sharedDataSource].localUser.userId, word];
        NSLog(@"Delete statement: %@", deleteStatement);
        const char* deleteStmt = [deleteStatement UTF8String];
        if (sqlite3_prepare_v2(_dictionary, deleteStmt, -1, &dictStatement, NULL) == SQLITE_OK) {
            if (sqlite3_step(dictStatement) != 101) {
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
