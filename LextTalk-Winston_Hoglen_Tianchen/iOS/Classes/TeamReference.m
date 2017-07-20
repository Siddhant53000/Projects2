//
//  TeamReference.m
// LextTalk
//
//  Created by David on 11/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TeamReference.h"
#import "IQKit.h"
#import <sqlite3.h>
#import "GFGroup.h"

@implementation TeamReference

+ (UIImage*) newImageForGroupWithId: (NSInteger) gId {
    if(gId<0) gId = 0;
	
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	
	NSString *fileName = [NSString stringWithFormat: @"images/group%04d.png", gId];
	NSString *filePath = [documentsDir stringByAppendingPathComponent: fileName];
	if(![[NSFileManager defaultManager] fileExistsAtPath: filePath]) {
		IQVerbose(VERBOSE_WARNING, @"[%@] Group image with Id %d not found",[self class], gId);		
		if(gId == 0) {
			return nil;
		}
		return [TeamReference newImageForGroupWithId: 0];
	}
	UIImage *img = [[UIImage alloc] initWithContentsOfFile: filePath];
	return img; // receiver is responsable of releasing the image
}

+ (UIImage*) newImageForTeamWithId: (NSInteger) tId {
    if(tId<0) tId = 0;
    
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	
	NSString *fileName = [NSString stringWithFormat: @"images/g%04d.png", tId];
	
	NSString *filePath = [documentsDir stringByAppendingPathComponent: fileName];
	
	if(![[NSFileManager defaultManager] fileExistsAtPath: filePath]) {
		IQVerbose(VERBOSE_WARNING, @"[%@] Team image with Id %d not found",[self class], tId);		
		if(tId == 0) {
			return nil;
		}
		return [TeamReference newImageForTeamWithId: 0];
	}	
	UIImage *img = [[UIImage alloc] initWithContentsOfFile: filePath];
	return img; // receiver is responsable of releasing the image
}

+ (UIImage*) newPinForTeamWithId: (NSInteger) tId {
    if(tId<0) tId = 0;
    
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	
	NSString *fileName = [NSString stringWithFormat: @"images/p%04d.png", tId];
	NSString *filePath = [documentsDir stringByAppendingPathComponent: fileName];
	if(![[NSFileManager defaultManager] fileExistsAtPath: filePath]) {
		IQVerbose(VERBOSE_WARNING, @"[%@] Team pin with Id %d not found",[self class], tId);		
		if(tId == 0) {
			return nil;
		}
		return [TeamReference newPinForTeamWithId: 0];
	}	
	
	UIImage *img = [[UIImage alloc] initWithContentsOfFile: filePath];
	return img; // receiver is responsable of releasing the image	
}

+ (GFTeam*) newTeamWithId: (NSInteger) tId {
	// Setup the database object
	sqlite3 *database;

	GFTeam *result = nil;

	// Open the database from the users filessytem
	if(sqlite3_open([[TeamReference getDatabasePath] UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[255];
		sprintf(sqlStatement, "SELECT id,name,parent_id FROM teams WHERE id=%d",tId);
		
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                NSInteger teamId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)]integerValue];
                NSString  *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)]; 
                NSInteger pId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)]integerValue];
                
				// Create a new animal object with the data from the database
				result = [GFTeam newTeamWithName: name parentId: pId andId: teamId];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);	
	
	return result;
}

+ (void)readTeams:(NSMutableArray*)teams withParentId:(NSInteger)parentId {
	// Setup the database object
	sqlite3 *database;
	
	// Open the database from the users filessytem
	if(sqlite3_open([[TeamReference getDatabasePath] UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[255];
		sprintf(sqlStatement, "SELECT id,name,parent_id FROM teams WHERE parent_id=%d ORDER BY name",parentId);
		
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                NSInteger teamId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)]integerValue];
                NSString  *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)]; 
                NSInteger pId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)]integerValue];

				// Create a new animal object with the data from the database
				GFTeam *team = [GFTeam newTeamWithName: name parentId: pId andId: teamId];
				[teams addObject:team];
				[team release];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);	
}

+ (void)readGroups:(NSMutableArray*)groups withParentId:(NSInteger)parentId {
	// Setup the database object
	sqlite3 *database;
	
	// Open the database from the users filessytem
	if(sqlite3_open([[TeamReference getDatabasePath] UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        char sqlStatement[255];
		sprintf(sqlStatement, "SELECT id,name,parent_id FROM groups WHERE parent_id=%d ORDER BY name", parentId);
		
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                NSInteger groupId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)]integerValue];
                NSString  *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)]; 
                NSInteger pId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)]integerValue];

				// Create a new animal object with the data from the database
				GFGroup *group = [GFGroup newGroupWithName: name parentId: pId andId: groupId];
                
				[groups addObject:group];
				[group release];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);	
}

+ (void)readObjects:(NSMutableArray*)objects withParentId:(NSInteger)parentId {
	// remove any previous content
	[objects removeAllObjects];
	[TeamReference readGroups: objects withParentId: parentId];
	[TeamReference readTeams: objects withParentId: parentId];
}

@end
