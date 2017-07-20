//
//  LanguageDB.m
//  BingTranslatorClass
//
//  Created by Raúl Martín Carbonell on 8/21/11.
//  Copyright 2011 Freelance. All rights reserved.
//

#import "LanguageReference.h"
#import "sqlite3.h"

@implementation LanguageReference

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (NSString *) appLan
{
    NSString * locale=[[NSLocale preferredLanguages] objectAtIndex:0];
    if ([locale isEqualToString:@"es"])
        return locale;
    else if ([locale isEqualToString:@"fr"])
        return locale;
    if ([locale isEqualToString:@"ca"])
        return locale;
    else 
        return @"English";
}

+ (NSArray *) availableLangsForAppLan: (NSString *) appLan
{
    NSMutableArray * result=nil;
    //Cambiar a cuando herede de Reference
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"db"];
    NSString *filePath = [Reference getDatabasePath];
    
    sqlite3 *database;
    
	// Open the database from the users filessytem
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[255];
		sprintf(sqlStatement, "SELECT lan_name FROM Languages WHERE app_lan=\"%s\" ORDER BY lan_name ASC",[appLan UTF8String]);
        
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                NSString * lan = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
                if (result==nil)
                    result=[NSMutableArray arrayWithCapacity:sqlite3_column_count(compiledStatement)];
                [result addObject:lan];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
    
    return result;
}

+ (NSString *) getMasterLanForAppLan: (NSString *) appLan andLanName:(NSString *) lanName
{
    NSString * result=nil;
    //Cambiar a cuando herede de Reference
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"db"];
    NSString *filePath = [Reference getDatabasePath];
    
    sqlite3 *database;
    
	// Open the database from the users filessytem
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[255];
		sprintf(sqlStatement, "SELECT master_lan FROM Languages WHERE app_lan=\"%s\" AND lan_name=\"%s\"",[appLan UTF8String], [lanName UTF8String]);
        
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
    
    return result;
}

+ (NSString *) getLocaleForMasterLan: (NSString *) masterLan
{
    NSString * result=nil;
    //Cambiar a cuando herede de Reference
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"db"];
    NSString *filePath = [Reference getDatabasePath];
    
    sqlite3 *database;
    
	// Open the database from the users filessytem
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[255];
		sprintf(sqlStatement, "SELECT locale FROM Locales WHERE master_lan=\"%s\"",[masterLan UTF8String]);
        
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
    
    return result;
}

+ (NSString *) getLanForAppLan:(NSString *) appLan andMasterLan: (NSString *) masterLan
{
    NSString * result=nil;
    //Cambiar a cuando herede de Reference
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"db"];
    NSString *filePath = [Reference getDatabasePath];
    
    sqlite3 *database;
    
	// Open the database from the users filessytem
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[255];
		sprintf(sqlStatement, "SELECT lan_name FROM Languages WHERE app_lan=\"%s\" AND master_lan=\"%s\"",[appLan UTF8String], [masterLan UTF8String]);
        
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
    
    return result;
}

+ (NSData *) flagForMasterLan:(NSString *) masterLan andId:(NSInteger) identifier
{
    NSData * result=nil;

    //Cambiar a cuando herede de Reference
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"db"];
    NSString *filePath = [Reference getDatabasePath];
    
    sqlite3 *database;
    
	// Open the database from the users filessytem
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[255];
		sprintf(sqlStatement, "SELECT flag FROM Flags WHERE master_lan=\"%s\" AND id=%li",[masterLan UTF8String], (long)identifier);
        
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                result=[NSData dataWithBytes:sqlite3_column_blob(compiledStatement, 0) length:sqlite3_column_bytes(compiledStatement, 0)];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
    
    return result;
}

+ (NSArray *) flagsForMasterLan:(NSString *) masterLan
{
    NSMutableArray * result=nil;
    
    //Cambiar a cuando herede de Reference
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"db"];
    NSString *filePath = [Reference getDatabasePath];
    
    sqlite3 *database;
    
	// Open the database from the users filessytem
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[255];
		sprintf(sqlStatement, "SELECT flag FROM Flags WHERE master_lan=\"%s\" ORDER BY id ASC",[masterLan UTF8String]);
        
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
            NSData * data;
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                data=[NSData dataWithBytes:sqlite3_column_blob(compiledStatement, 0) length:sqlite3_column_bytes(compiledStatement, 0)];
                
                if (result==nil)
                    result=[NSMutableArray arrayWithCapacity:sqlite3_column_count(compiledStatement)];
                [result addObject:data];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
    
    return result;
}






+ (NSArray *) availableSpeakLangsForAppLan: (NSString *) appLan andMasterLan:(NSString *) masterLan
{
    NSMutableArray * result=nil;
    //Cambiar a cuando herede de Reference
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"db"];
    NSString *filePath = [Reference getDatabasePath];
    
    sqlite3 *database;
    
	// Open the database from the users filessytem
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[255];
		sprintf(sqlStatement, "SELECT speak_name FROM SpeakLanguages WHERE app_lan=\"%s\" AND master_lan=\"%s\" ORDER BY id ASC",[appLan UTF8String], [masterLan UTF8String]);
        
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                NSString * lan = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
                if (result==nil)
                    result=[NSMutableArray arrayWithCapacity:sqlite3_column_count(compiledStatement)];
                [result addObject:lan];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
    
    return result;
}


+ (NSInteger) getIdForAppLan: (NSString *) appLan andLanSpeak:(NSString *) lanName andMasterLan:(NSString *) masterLan
{
    NSInteger result=-1;
    //Cambiar a cuando herede de Reference
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"db"];
    NSString *filePath = [Reference getDatabasePath];
    
    sqlite3 *database;
    
	// Open the database from the users filessytem
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[255];
		sprintf(sqlStatement, "SELECT id FROM SpeakLanguages WHERE app_lan=\"%s\" AND speak_name=\"%s\" AND master_lan=\"%s\"",[appLan UTF8String], [lanName UTF8String], [masterLan UTF8String]);
        
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                result=sqlite3_column_int(compiledStatement, 0);
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
    
    return result;
}

+ (NSString *) getSpeakLocaleForMasterLan: (NSString *) masterLan withId:(NSInteger) number
{
    NSString * result=nil;
    //Cambiar a cuando herede de Reference
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"db"];
    NSString *filePath = [Reference getDatabasePath];
    
    sqlite3 *database;
    
	// Open the database from the users filessytem
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[255];
		sprintf(sqlStatement, "SELECT locale FROM SpeakLocales WHERE master_lan=\"%s\" AND id=%li",[masterLan UTF8String], (long)number);
        
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
    
    return result;
}

+ (NSString *) getSpeakLanForAppLan:(NSString *) appLan andMasterLan: (NSString *) masterLan withId:(NSInteger) number
{
    NSString * result=nil;
    //Cambiar a cuando herede de Reference
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"db"];
    NSString *filePath = [Reference getDatabasePath];;
    
    sqlite3 *database;
    
	// Open the database from the users filessytem
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[255];
		sprintf(sqlStatement, "SELECT speak_name FROM SpeakLanguages WHERE app_lan=\"%s\" AND master_lan=\"%s\" AND id=%li",[appLan UTF8String], [masterLan UTF8String], (long)number);
        
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
    
    return result;
}

@end
