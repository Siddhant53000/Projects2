//
//  DictionaryDBHandler.h
//  LextTalk
//
//  Created by Isaaca Hoglen on 11/23/16.
//
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "LTDataSource.h"

@interface DictionaryDBHandler : NSObject
{
    NSString *databasePath;
}

+ (DictionaryDBHandler *) getSharedInstance;
- (BOOL) installDatabase;
- (BOOL)saveData: (NSString*) word forDefinition: (NSString*)definition;
- (NSMutableDictionary*) getUserDictionary;
- (BOOL)deleteFromDatabase: (NSString*) word;
@end
