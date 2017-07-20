//
//  DictionaryHandler.m
//  BingTranslatorClass
//
//  Created by Raúl Martín Carbonell on 8/23/11.
//  Copyright 2011 Freelance. All rights reserved.
//

#import "DictionaryHandler.h"
#import "sqlite3.h"

#define kDatabaseFilename				@"dictionary.db"

@implementation DictionaryHandler

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (void) createDictionaryIfItDoesntExist
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"dictionary" ofType:@"db"];
    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSMutableString * docPath2=[NSMutableString stringWithString:docPath];
    [docPath2 appendFormat:@"/%@", kDatabaseFilename];
    NSFileManager * fileManager=[[NSFileManager alloc] init];
    //Solo la primera vez, si no lo estaria machacando
    if (![fileManager fileExistsAtPath:docPath2])
        [fileManager copyItemAtPath:filePath toPath:docPath2 error:NULL];
    //NSLog(@"%@", filePath);
    //NSLog(@"%@", docPath2);
}

+ (void) addEntry:(NSString *) original 
  withTranslation:(NSString *) translated 
          fromLan:(NSString *) fromLan 
            toLan:(NSString *) toLan
{
    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSMutableString * filePath=[NSMutableString stringWithString:docPath];
    [filePath appendFormat:@"/%@", kDatabaseFilename];
    
    sqlite3 *database;
    
	// Open the database from the users filessytem
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[1024];
        
        //Primero miro si el par de lenguajes existen en el diccionario, y si no existen lo creo
        BOOL dictionaryExists=NO;
        
		sprintf(sqlStatement, "SELECT fromLan, toLan FROM Dicts WHERE fromLan=\"%s\" AND toLan=\"%s\"",[fromLan UTF8String], [toLan UTF8String]);
        //NSLog(@"%s", sqlStatement);
        
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			if (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                dictionaryExists=YES;
			}
		}
        // Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
        
        if (!dictionaryExists) {
            sprintf(sqlStatement, "INSERT INTO Dicts VALUES (\"%s\", \"%s\")",[fromLan UTF8String], [toLan UTF8String]);
            //NSLog(@"%s", sqlStatement);
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
                if (sqlite3_step(compiledStatement)!=SQLITE_DONE)
                    NSLog(@"Insertion into Dicts failed");
            }
            // Release the compiled statement from memory
            sqlite3_finalize(compiledStatement);
        }
        
        //Por fin ya inserto la palabra y su definición
		sprintf(sqlStatement, "INSERT INTO Definitions VALUES (\"%s\", \"%s\", \"%s\", \"%s\")", [fromLan UTF8String], [toLan UTF8String],[original UTF8String], [translated UTF8String]);
        //NSLog(@"%s", sqlStatement);
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            if (sqlite3_step(compiledStatement)!=SQLITE_DONE)
                NSLog(@"Insertion into Definitions failed");
        }
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
}

+ (NSString *) getTranslation:(NSString *) original
                      fromLan:(NSString *) fromLan 
                        toLan:(NSString *) toLan
{
    NSString * result=nil;
    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSMutableString * filePath=[NSMutableString stringWithString:docPath];
    [filePath appendFormat:@"/%@", kDatabaseFilename];
    
    sqlite3 *database;
    
	// Open the database from the users filessytem
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[1024];
        
		sprintf(sqlStatement, "SELECT translated FROM Definitions WHERE fromLan=\"%s\" AND toLan=\"%s\" AND original=\"%s\"",[fromLan UTF8String], [toLan UTF8String], [original UTF8String]);
        //NSLog(@"%s", sqlStatement);
        
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			if (sqlite3_step(compiledStatement) == SQLITE_ROW) {
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

+ (NSArray *) getMatches:(NSString *) like
                 fromLan: (NSString *) fromLan 
                   toLan:(NSString *) toLan
{
    NSMutableArray * result=nil;
    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSMutableString * filePath=[NSMutableString stringWithString:docPath];
    [filePath appendFormat:@"/%@", kDatabaseFilename];
    
    sqlite3 *database;
    
	// Open the database from the users filessytem
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[1024];
        
		sprintf(sqlStatement, "SELECT translated FROM Definitions WHERE fromLan=\"%s\" AND toLan=\"%s\" AND original LIKE \"\%%%s%%\" ORDER BY original ASC",[fromLan UTF8String], [toLan UTF8String], [like UTF8String]);
        NSLog(@"%s", sqlStatement);
        
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                if (result==nil) {
                    result=[NSMutableArray arrayWithCapacity:5];
                }
                [result addObject: [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)]];
			}
		}
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    
    return result;
}

+ (void) getDictinariesFrom:(NSMutableArray *) fromArray andTo: (NSMutableArray* ) toArray;
{
    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSMutableString * filePath=[NSMutableString stringWithString:docPath];
    [filePath appendFormat:@"/%@", kDatabaseFilename];
    
    sqlite3 *database;
    
	// Open the database from the users filessytem
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[1024];
        
		sprintf(sqlStatement, "SELECT fromLan, toLan FROM Dicts ORDER BY fromLan ASC, toLan ASC");
        //NSLog(@"%s", sqlStatement);
        
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                [fromArray addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)]];
                [toArray addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)]];
			}
		}
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
}

+ (void) removeDictionaryFrom:(NSString *) fromLan andTo:(NSString *) toLan
{
    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSMutableString * filePath=[NSMutableString stringWithString:docPath];
    [filePath appendFormat:@"/%@", kDatabaseFilename];
    
    sqlite3 *database;
    
	// Open the database from the users filessytem
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[1024];
        
		sprintf(sqlStatement, "DELETE FROM Dicts WHERE fromLan=\"%s\" AND toLan=\"%s\" ",[fromLan UTF8String], [toLan UTF8String]);
        //NSLog(@"%s", sqlStatement);
        
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			
            //¿compararlo con alguna constante. En principio da igual, no devuelvo si el resultado está OK
            //y por el flujo de uso siempre debería ser correcto
            sqlite3_step(compiledStatement);
            /*
			while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
			}
             */
		}
        sqlite3_finalize(compiledStatement);
        
        //It works because this string is longer thatn the other, be careful
        sprintf(sqlStatement, "DELETE FROM Definitions WHERE fromLan=\"%s\" AND toLan=\"%s\" ",[fromLan UTF8String], [toLan UTF8String]);
        //NSLog(@"%s", sqlStatement);
        
        //sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			
            //¿compararlo con alguna constante. En principio da igual, no devuelvo si el resultado está OK
            //y por el flujo de uso siempre debería ser correcto
            sqlite3_step(compiledStatement);
            /*
             while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
             // Read the data from the result row
             }
             */
		}
        
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
}

+ (NSDictionary *) getWholeDictionaryFromLan: (NSString *) fromLan toLan: (NSString *) toLan
{
    NSMutableDictionary * result=nil;
    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSMutableString * filePath=[NSMutableString stringWithString:docPath];
    [filePath appendFormat:@"/%@", kDatabaseFilename];
    
    sqlite3 *database;
    
	// Open the database from the users filessytem
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[1024];
        
		sprintf(sqlStatement, "SELECT original, translated FROM Definitions WHERE fromLan=\"%s\" AND toLan=\"%s\"  ORDER BY original ASC",[fromLan UTF8String], [toLan UTF8String]);
        //NSLog(@"%s", sqlStatement);
        
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                if (result==nil) {
                    result=[NSMutableDictionary dictionaryWithCapacity:5];
                }
                [result setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)] 
                           forKey:[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)]];
			}
		}
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    
    return result;
}

+ (void) removeEntryFrom:(NSString *) fromLan toLan:(NSString *) toLan withEntry: (NSString *) entry
{
    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSMutableString * filePath=[NSMutableString stringWithString:docPath];
    [filePath appendFormat:@"/%@", kDatabaseFilename];
    
    sqlite3 *database;
    
	// Open the database from the users filessytem
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[1024];
        
		sprintf(sqlStatement, "DELETE FROM Definitions WHERE fromLan=\"%s\" AND toLan=\"%s\" AND original=\"%s\" ",[fromLan UTF8String], [toLan UTF8String], [entry UTF8String]);
        //NSLog(@"%s", sqlStatement);
        
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			
            //¿compararlo con alguna constante. En principio da igual, no devuelvo si el resultado está OK
            //y por el flujo de uso siempre debería ser correcto
            sqlite3_step(compiledStatement);
            /*
             while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
             // Read the data from the result row
             }
             */
		}
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
}

@end
