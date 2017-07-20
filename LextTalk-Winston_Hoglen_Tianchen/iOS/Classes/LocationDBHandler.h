//
//  LocationDBHandler.h
//  LextTalk
//
//  Created by Isaaca Hoglen on 12/4/16.
//
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "LTDataSource.h"

@interface LocationDBHandler : NSObject
{
    NSString *databasePath;
}

+ (LocationDBHandler *) getSharedInstance;
- (BOOL) installDatabase;
- (BOOL) setLocationInformation: (int) useDefault forLocation: (NSString *) location andIsVisible: (int) visibility;
- (int) getUseDefaultLocation;
- (NSString *) getUserLocation;
- (int) getIsVisible;
@end
