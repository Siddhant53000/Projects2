//
//  LocationDBHandler.m
//  LextTalk
//
//  Created by Isaaca Hoglen on 12/4/16.
//
//

#import "LocationDBHandler.h"

static sqlite3 * _location;
static sqlite3_stmt *locStatement;
static LocationDBHandler *sharedInstance;


@implementation LocationDBHandler

+(LocationDBHandler *) getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

- (BOOL) installDatabase {
    NSString* docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"location.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if (![filemgr fileExistsAtPath:databasePath]) {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &_location) == SQLITE_OK) {
            char *errMsg;
            const char *sql_stmt = "create table if not exists location (usercounter integer primary key, userID integer, defaultLoc integer, loc text, visibilityLoc integer)";
            if (sqlite3_exec(_location, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                isSuccess = NO;
                NSLog(@"Failed to create location table1");
            }
            sqlite3_close(_location);
        } else {
            isSuccess = NO;
            NSLog(@"Failed to create location table2");
        }
    }
    NSLog(@"Success: location created %d", isSuccess);
    return isSuccess;
}


- (BOOL) setLocationInformation:(int)useDefault forLocation:(NSString *)location andIsVisible:(int)visibility {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &_location) == SQLITE_OK) {
        NSLog(@"UserID saveData: %d", (int)[LTDataSource sharedDataSource].localUser.userId);
        NSString *insertSQL = [NSString stringWithFormat:@"insert into location (userID,defaultLoc,loc,visibilityLoc) values (\"%d\",\"%d\",\"%@\",\"%d\")",(int)[LTDataSource sharedDataSource].localUser.userId, useDefault, location, visibility];
        NSLog(@"InsertSQL: %@", insertSQL);
        const char *insertStmt = [insertSQL UTF8String];
        NSLog(@"insertstmt: %s", insertStmt);
        
        sqlite3_prepare_v2(_location, insertStmt, -1, &locStatement, NULL);
        if (sqlite3_step(locStatement) == SQLITE_DONE) {
            NSLog(@"Successfully added location %@ to user %d", location, (int)[LTDataSource sharedDataSource].localUser.userId);
            sqlite3_reset(locStatement);
            return YES;
        } else {
            NSLog(@"Sql result: %d", sqlite3_step(locStatement));
            NSLog(@"1 Unsuccessfully added location %@ to user %d", location, (int)[LTDataSource sharedDataSource].localUser.userId);
            sqlite3_reset(locStatement);
            return NO;
        }
    }
    NSLog(@"2 Unsuccessfully added location %@ to user %d", location, (int)[LTDataSource sharedDataSource].localUser.userId);
    
    return NO;
}

- (int) getUseDefaultLocation {
    const char *dbpath = [databasePath UTF8String];
    int result = 0;
    if (sqlite3_open(dbpath, &_location) == SQLITE_OK) {
        NSLog(@"UserID: %d", (int)[LTDataSource sharedDataSource].localUser.userId);
        NSString *querySQL = [NSString stringWithFormat:@"select defaultLoc, loc, visibilityLoc from location where userID=\"%d\"", (int)[LTDataSource sharedDataSource].localUser.userId];
        NSLog(@"QuerySQL: %@", querySQL);
        const char* queryStmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(_location, queryStmt, -1, &locStatement, NULL) == SQLITE_OK) {
            while (sqlite3_step(locStatement) == SQLITE_ROW) {
                result = sqlite3_column_int(locStatement, 0);
                NSLog(@"default result: %d", result);
            }
            
        }
        sqlite3_reset(locStatement);
        return result;
    }
    return result;
}

- (NSString *) getUserLocation {
    const char *dbpath = [databasePath UTF8String];
    NSString *loc = @"Street Address, City, Country";
    if (sqlite3_open(dbpath, &_location) == SQLITE_OK) {
        NSLog(@"UserID: %d", (int)[LTDataSource sharedDataSource].localUser.userId);
        NSString *querySQL = [NSString stringWithFormat:@"select defaultLoc, loc, visibilityLoc from location where userID=\"%d\"", (int)[LTDataSource sharedDataSource].localUser.userId];
        NSLog(@"QuerySQL: %@", querySQL);
        const char* queryStmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(_location, queryStmt, -1, &locStatement, NULL) == SQLITE_OK) {
            while (sqlite3_step(locStatement) == SQLITE_ROW) {
                const char* char1 = (const char*)sqlite3_column_text(locStatement, 1);
                NSLog(@"char1 %s", char1);
                //            const char* char2 = (const char*)sqlite3_column_text(locStatement, 1);
                //            NSLog(@"char1 %s", char2);
                if (char1) {
                    loc = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(locStatement, 1)];
                }
                
                
                NSLog(@"Location from User: %@", loc);
            }
            
        }
        sqlite3_reset(locStatement);
//        return loc;
    }
    return loc;
}

- (int) getIsVisible {
    const char *dbpath = [databasePath UTF8String];
    int result = 0;
    if (sqlite3_open(dbpath, &_location) == SQLITE_OK) {
        NSLog(@"UserID: %d", (int)[LTDataSource sharedDataSource].localUser.userId);
        NSString *querySQL = [NSString stringWithFormat:@"select defaultLoc, loc, visibilityLoc from location where userID=\"%d\"", (int)[LTDataSource sharedDataSource].localUser.userId];
        NSLog(@"QuerySQL: %@", querySQL);
        const char* queryStmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(_location, queryStmt, -1, &locStatement, NULL) == SQLITE_OK) {
            while (sqlite3_step(locStatement) == SQLITE_ROW) {
                result = sqlite3_column_int(locStatement, 2);
                NSLog(@"Visible loc: %d", result);
            }
            
        }
        sqlite3_reset(locStatement);
        return result;
    }
    return result;
}



@end
