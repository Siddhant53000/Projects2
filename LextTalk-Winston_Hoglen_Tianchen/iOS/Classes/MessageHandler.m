//
//  MessageHandler.m
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 08/02/14.
//
//

#import "MessageHandler.h"

@implementation MessageHandler

#pragma mark Init stuff

+ (void) installDatabase
{
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"messages" ofType:@"db"];
    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSMutableString * filePath=[NSMutableString stringWithString:docPath];
    [filePath appendFormat:@"/%@", @"messages.db"];
    
    NSFileManager * fileManager=[[NSFileManager alloc] init];
    
    if (![fileManager fileExistsAtPath:filePath])
    {
        [fileManager copyItemAtPath:resourcePath toPath:filePath error:NULL];
    }
}

+ (void) deleteDatabase
{
    //NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"messages" ofType:@"db"];
    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSMutableString * filePath=[NSMutableString stringWithString:docPath];
    [filePath appendFormat:@"/%@", @"messages.db"];
    
    NSFileManager * fileManager=[[NSFileManager alloc] init];
    
    [fileManager removeItemAtPath:filePath error:NULL];
}

+ (MessageHandler *) sharedInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (id) init
{
    self=[super init];
    if (self)
    {
        NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSMutableString * filePath=[NSMutableString stringWithString:docPath];
        [filePath appendFormat:@"/%@", @"messages.db"];
        if(sqlite3_open([filePath UTF8String], &_messages) != SQLITE_OK)
            _messages=NULL;
    }
    return self;
}

- (void) dealloc
{
    if (_messages!=NULL)
        sqlite3_close(_messages);
    
}

#pragma mark MessageHandler methods

- (void) beginTransaction
{
    if (_messages != NULL)
    {
        char sqlStatement[1024];
        sprintf(sqlStatement, "BEGIN TRANSACTION;");
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(_messages, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(compiledStatement)!=SQLITE_DONE)
                NSLog(@"BEGIN TRANSACTION Failed");
        }
        
        sqlite3_finalize(compiledStatement);
    }
}

- (void) commit
{
    if (_messages != NULL)
    {
        //Finalizar transacción
        char sqlStatement[1024];
        sprintf(sqlStatement, "COMMIT;");
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(_messages, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(compiledStatement)!=SQLITE_DONE)
                NSLog(@"COMMIT Failed");
        }
        sqlite3_finalize(compiledStatement);
    }
}

- (BOOL) userExists:(NSInteger) userId
{
    BOOL userExists=NO;
    //Test if the user already exists
    static char sqlStatement[1024];
    sprintf(sqlStatement, "SELECT COUNT(*) From Users WHERE userId=%ld AND localUserId=%ld", (long)userId, (long)[LTDataSource sharedDataSource].localUser.userId);
    sqlite3_stmt *compiledStatement;
    if(sqlite3_prepare_v2(_messages, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        
        // Loop through the results and add them to the feeds array
        if (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            // Read the data from the result row
            NSInteger number=sqlite3_column_int(compiledStatement, 0);
            if (number>0)
                userExists=YES;
        }
    }
    // Release the compiled statement from memory
    sqlite3_finalize(compiledStatement);
    
    return userExists;
}

- (void) insertUser:(LTChat *) chat withActivity:(NSDate *) date andUnread:(NSInteger) unread
{
    static char sqlStatement[1024];
    sprintf(sqlStatement, "INSERT INTO Users VALUES (%ld, %ld, ?, ?, %ld, ?, %ld, '', 0, 0, 0, 0, %f, %ld, 1)", (long)chat.userId, (long)[LTDataSource sharedDataSource].localUser.userId, (long)chat.learningFlag, (long)chat.speakingFlag, [date timeIntervalSince1970], (long)unread);
    sqlite3_stmt *compiledStatement;
    if(sqlite3_prepare_v2(_messages, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        
        //bind values
        sqlite3_bind_text(compiledStatement, 1, (chat.userName != nil) ? [chat.userName UTF8String] : [@"" UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(compiledStatement, 2, (chat.learningLang != nil) ? [chat.learningLang UTF8String] : [@"" UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(compiledStatement, 3, (chat.speakingLang != nil) ? [chat.speakingLang UTF8String] : [@"" UTF8String], -1, SQLITE_TRANSIENT);
        
        if (sqlite3_step(compiledStatement)!=SQLITE_DONE)
            NSLog(@"Insertion of 1 user into Users failed");
    }
    // Release the compiled statement from memory
    sqlite3_finalize(compiledStatement);
}

- (void) updateUser:(LTChat *) chat withActivity:(NSDate *) date andUnread:(NSInteger) unread
{
    if (([chat.learningLang length]>0) && ([chat.speakingLang length]>0) && ([chat.userName length]>0))
    {
        static char sqlStatement[1024];
        //, url='', badge=0
        sprintf(sqlStatement, "UPDATE Users SET name=?, learningLang=?, learningFlag=%ld, speakingLang=?, speakingFlag=%ld, lastDate = CASE WHEN %f > lastDate THEN %f ELSE lastDate END, unread=unread+%ld, totalNumber=totalNumber+1 WHERE userId=%ld AND localUserId=%ld", (long)chat.learningFlag, (long)chat.speakingFlag, [date timeIntervalSince1970], [date timeIntervalSince1970], (long)unread, (long)chat.userId, (long)[LTDataSource sharedDataSource].localUser.userId);
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(_messages, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            //bind values
            sqlite3_bind_text(compiledStatement, 1, (chat.userName != nil) ? [chat.userName UTF8String] : [@"" UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(compiledStatement, 2, (chat.learningLang != nil) ? [chat.learningLang UTF8String] : [@"" UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(compiledStatement, 3, (chat.speakingLang != nil) ? [chat.speakingLang UTF8String] : [@"" UTF8String], -1, SQLITE_TRANSIENT);
            
            if (sqlite3_step(compiledStatement)!=SQLITE_DONE)
                NSLog(@"Update of 1 user into Users failed");
        }
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
}

- (void) updateChatActivityVars:(LTChat *) chat
{
    if (_messages != NULL)
    {
        static char sqlStatement[1024];
        sprintf(sqlStatement, "UPDATE Users SET url=?, urlUpdateDate=%f, activityUpdateDate=%f, lastUpdateDate=%f, userDeleted=%d WHERE userId=%ld AND localUserId=%ld", [chat.urlUpdateDate timeIntervalSince1970], [chat.activityUpdateDate timeIntervalSince1970], [chat.lastUpdateDate timeIntervalSince1970], chat.userDeleted ? 1 : 0, (long)chat.userId, (long)[LTDataSource sharedDataSource].localUser.userId);
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(_messages, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            //bind values
            sqlite3_bind_text(compiledStatement, 1, (chat.url != nil) ? [chat.url UTF8String] : [@"" UTF8String], -1, SQLITE_TRANSIENT);
            
            if (sqlite3_step(compiledStatement)!=SQLITE_DONE)
                NSLog(@"Update of 1 user into Users failed");
        }
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
}

- (NSInteger) insertMessage:(LTMessage *) message
{
    NSInteger result = 0;
    if (_messages!=NULL)
    {
        //Para quitar le bug que introducje en la versión anterior
        if (message.destId == 0)
            message.destId = [LTDataSource sharedDataSource].localUser.userId;
        
        LTChat * chat = [[LTChat alloc] init];
        if ([LTDataSource sharedDataSource].localUser.userId == message.destId)
        {
            chat.userId = message.senderId;
            chat.userName = message.senderName;
            chat.learningLang = message.senderLearningLan;
            chat.learningFlag = message.senderLearningFlag;
            chat.speakingLang = message.senderSpeakingLan;
            chat.speakingFlag = message.senderSpeakingFlag;
        }
        else
        {
            chat.userId = message.destId;
            chat.userName = message.destName;
            chat.learningLang = message.destLearningLan;
            chat.learningFlag = message.destLearningFlag;
            chat.speakingLang = message.destSpeakingLan;
            chat.speakingFlag = message.destSpeakingFlag;
        }
        result = chat.userId;
        
        
        //Finalmente, inserto el mensaje
        static char sqlStatement[1024];
        sprintf(sqlStatement, "INSERT INTO Messages VALUES (%ld, %ld, ?, %f, ?, %lu, %ld, %ld)", (long)message.messageId, (long)[LTDataSource sharedDataSource].localUser.userId, [[LTMessage dateForUtcTime:message.timestamp] timeIntervalSince1970], (unsigned long)message.deliverStatus, (long)message.senderId, (long)message.destId);
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(_messages, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            //bind values
            sqlite3_bind_text(compiledStatement, 1, (message.body != nil) ? [message.body UTF8String] : [@"" UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(compiledStatement, 2, (message.timestamp != nil) ? [message.timestamp UTF8String] : [@"" UTF8String], -1, SQLITE_TRANSIENT);

            if (sqlite3_step(compiledStatement)!=SQLITE_DONE)
                NSLog(@"Insertion of 1 message into Messages failed");
            else
            {
                //Insert in chats. It must be done here. If insertion fails, chats are out of sync with messages
                //It seems that when a user taps on a notification with the app closed, messages are downloaded from the server
                //twice although they should be deleted when downloaded, it must happen because the 2 calls are done at almost the
                //same time.
                //Because of this, messages where out of sync with the Chats, and the badges were wrong
                if (![self userExists:chat.userId])
                    [self insertUser:chat withActivity:[LTMessage dateForUtcTime:message.timestamp] andUnread:(message.deliverStatus!=DELIVER_FINISHED) ? 1 : 0 ];
                else
                    [self updateUser:chat withActivity:[LTMessage dateForUtcTime:message.timestamp] andUnread:(message.deliverStatus!=DELIVER_FINISHED) ? 1 : 0];
            }
        }
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    return result;
}

- (void) insertMessages:(NSArray *) messages
{
    if (_messages != NULL)
    {
        [self beginTransaction];
        
        for (LTMessage * message in messages)
            [self insertMessage:message];
        
        [self commit];
    }
}

- (NSMutableArray *) chatLists
{
    NSMutableArray * result = [NSMutableArray array];
    
    if (_messages!=NULL)
    {
        static char sqlStatement[1024];
        sprintf(sqlStatement, "SELECT userId, name, learningLang, learningFlag, speakingLang, speakingFlag, url, urlUpdateDate, activityUpdateDate, lastUpdateDate, userDeleted, lastDate, unread, totalNumber FROM Users WHERE localUserId=%ld ORDER BY unread DESC, lastDate DESC", (long)[LTDataSource sharedDataSource].localUser.userId);
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(_messages, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                LTChat * chat = [[LTChat alloc] init];
                chat.userId = sqlite3_column_int(compiledStatement, 0);
                
                char * str = (char *)sqlite3_column_text(compiledStatement, 1);
                chat.userName = (str != NULL) ? [NSString stringWithUTF8String:str] : nil;
                
                str = (char *)sqlite3_column_text(compiledStatement, 2);
                chat.learningLang = (str != NULL) ? [NSString stringWithUTF8String:str] : nil;
                
                chat.learningFlag = sqlite3_column_int(compiledStatement, 3);
                
                str = (char *)sqlite3_column_text(compiledStatement, 4);
                chat.speakingLang = (str != NULL) ? [NSString stringWithUTF8String:str] : nil;
                
                chat.speakingFlag = sqlite3_column_int(compiledStatement, 5);
                
                str = (char *)sqlite3_column_text(compiledStatement, 6);
                chat.url = (str != NULL) ? [NSString stringWithUTF8String:str] : nil;
                
                chat.urlUpdateDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(compiledStatement, 7)];
                chat.activityUpdateDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(compiledStatement, 8)];
                chat.lastUpdateDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(compiledStatement, 9)];
                chat.userDeleted = sqlite3_column_int(compiledStatement, 10);
                chat.lastDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(compiledStatement, 11)];
                chat.unreadMessages = sqlite3_column_int(compiledStatement, 12);
                chat.totalNumber = sqlite3_column_int(compiledStatement, 13);
                
                [result addObject:chat];
            }
        }
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    
    return result;
}

- (LTChat *) chatListForUserId:(NSInteger) userId
{
    LTChat * chat = nil;
    
    if (_messages!=NULL)
    {
        static char sqlStatement[1024];
        sprintf(sqlStatement, "SELECT userId, name, learningLang, learningFlag, speakingLang, speakingFlag, url, urlUpdateDate, activityUpdateDate, lastUpdateDate, userDeleted, lastDate, unread, totalNumber FROM Users WHERE userId=%ld AND localUserId=%ld", (long)userId, (long)[LTDataSource sharedDataSource].localUser.userId);
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(_messages, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                chat = [[LTChat alloc] init];
                chat.userId = sqlite3_column_int(compiledStatement, 0);
                
                char * str = (char *)sqlite3_column_text(compiledStatement, 1);
                chat.userName = (str != NULL) ? [NSString stringWithUTF8String:str] : nil;
                
                str = (char *)sqlite3_column_text(compiledStatement, 2);
                chat.learningLang = (str != NULL) ? [NSString stringWithUTF8String:str] : nil;
                
                chat.learningFlag = sqlite3_column_int(compiledStatement, 3);
                
                str = (char *)sqlite3_column_text(compiledStatement, 4);
                chat.speakingLang = (str != NULL) ? [NSString stringWithUTF8String:str] : nil;
                
                chat.speakingFlag = sqlite3_column_int(compiledStatement, 5);
                
                str = (char *)sqlite3_column_text(compiledStatement, 6);
                chat.url = (str != NULL) ? [NSString stringWithUTF8String:str] : nil;
                
                chat.urlUpdateDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(compiledStatement, 7)];
                chat.activityUpdateDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(compiledStatement, 8)];
                chat.lastUpdateDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(compiledStatement, 9)];
                chat.userDeleted = sqlite3_column_int(compiledStatement, 10);
                chat.lastDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(compiledStatement, 11)];
                chat.unreadMessages = sqlite3_column_int(compiledStatement, 12);
                chat.totalNumber = sqlite3_column_int(compiledStatement, 13);
            }
        }
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    
    return chat;
}

- (NSMutableArray *) last:(NSInteger) number messagesForUser:(NSInteger) userId moreAvailable:(BOOL *) moreAvailable
{
    NSMutableArray * result=[NSMutableArray array];
    
    if (_messages!=NULL)
    {
        static char sqlStatement[1024];
        //Para coger los últimos debo hacer la query con DESC y luego darle la vuelta
        sprintf(sqlStatement, "SELECT messageId, body, utc, status, fromUser, toUser FROM Messages WHERE (localUserId=%ld AND ((fromUser=%ld AND toUser=%ld) OR (fromUser=%ld AND toUser=%ld))) ORDER BY date DESC LIMIT %ld", (long)[LTDataSource sharedDataSource].localUser.userId, (long)userId, (long)[LTDataSource sharedDataSource].localUser.userId, (long)[LTDataSource sharedDataSource].localUser.userId, (long)userId, (long)number);
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(_messages, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
			// Loop through the results and add them to the feeds array
			while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                LTMessage * message=[[LTMessage alloc] init];
                message.messageId = sqlite3_column_int(compiledStatement, 0);
                
                char * str = (char *)sqlite3_column_text(compiledStatement, 1);
                message.body=(str != NULL) ? [NSString stringWithUTF8String:str] : nil;
                
                str = (char *)sqlite3_column_text(compiledStatement, 2);
                message.timestamp=(str != NULL) ? [NSString stringWithUTF8String:str] : nil;
                
                message.deliverStatus = sqlite3_column_int(compiledStatement, 3);
                message.senderId = sqlite3_column_int(compiledStatement, 4);
                message.destId = sqlite3_column_int(compiledStatement, 5);
                
                [result addObject:message];
            }
		}
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
        
        //Le doy la vuelta a result
        if ([result count]>1)
        {
            NSSortDescriptor * sort=[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
            [result sortUsingDescriptors:[NSArray arrayWithObject:sort]];
        }
        
        //Calcular si hay más o no
        *moreAvailable=NO;
        sprintf(sqlStatement, "SELECT COUNT(*) From Messages WHERE (localUserId=%ld AND((fromUser=%ld AND toUser=%ld) OR (fromUser=%ld AND toUser=%ld)))", (long)[LTDataSource sharedDataSource].localUser.userId, (long)userId, (long)[LTDataSource sharedDataSource].localUser.userId, (long)[LTDataSource sharedDataSource].localUser.userId, (long)userId);
        //sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(_messages, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
			// Loop through the results and add them to the feeds array
			if (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                NSInteger total=sqlite3_column_int(compiledStatement, 0);
                if (total>number)
                    *moreAvailable=YES;
            }
		}
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    
    
    return result;
}

- (void) markMessagesAsRead:(NSArray *) array
{
    if (_messages != NULL)
    {
        if ([array count] > 0)
        {
            NSInteger userId = 0;
            NSInteger counter = 0;
            NSMutableString * str = [NSMutableString stringWithFormat:@"UPDATE Messages SET status=2 WHERE localUserId=%ld AND messageId IN (", (long)[LTDataSource sharedDataSource].localUser.userId];
            for (NSInteger i = 0; i < [array count]; i++)
            {
                counter ++;
                
                LTMessage * message = [array objectAtIndex:i];
                [str appendFormat:@"%ld", (long)message.messageId];
                if (i < [array count] -1)
                    [str appendString:@","];
                else
                {
                    if (message.senderId == [LTDataSource sharedDataSource].localUser.userId)
                        userId = message.destId;
                    else
                        userId = message.senderId;
                }
            }
            [str appendString:@")"];
            
            //static char sqlStatement[1024];
            //sprintf(sqlStatement, [str UTF8String]);
            sqlite3_stmt *compiledStatement;
            if(sqlite3_prepare_v2(_messages, /*sqlStatement*/ [str UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
                
                if (sqlite3_step(compiledStatement)!=SQLITE_DONE)
                    NSLog(@"Update of Message Status failed");
            }
            // Release the compiled statement from memory
            sqlite3_finalize(compiledStatement);
            
            //NSLog(@"Counter: %d", counter);
            //Ahora actualizo la otra tabla para que quede coherente.
            static char sqlStatement[1024];
            //sprintf(sqlStatement, "UPDATE Users SET unread=unread-%d WHERE userId=%d AND localUserId=%d", counter, userId, [LTDataSource sharedDataSource].localUser.userId);
            sprintf(sqlStatement, "UPDATE Users SET unread = CASE WHEN unread>=%ld THEN unread-%ld ELSE 0 END WHERE userId=%ld AND localUserId=%ld", (long)counter, (long)counter, (long)userId, (long)[LTDataSource sharedDataSource].localUser.userId);
            //sqlite3_stmt *compiledStatement;
            if(sqlite3_prepare_v2(_messages, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
                
                if (sqlite3_step(compiledStatement)!=SQLITE_DONE)
                    NSLog(@"Update of Message Status in Users failed");
            }
            // Release the compiled statement from memory
            sqlite3_finalize(compiledStatement);
        }
    }
}

- (void) deleteChatForUserId:(NSInteger) userId
{
    if (_messages != NULL)
    {
        static char sqlStatement[1024];
        sprintf(sqlStatement, "DELETE FROM Users WHERE userId=%ld AND localUserId=%ld", (long)userId, (long)[LTDataSource sharedDataSource].localUser.userId);
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(_messages, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement)!=SQLITE_DONE)
                NSLog(@"Delete of 1 user in Users failed");
        }
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
        
        
        
        sprintf(sqlStatement, "DELETE FROM Messages WHERE (localUserId=%ld AND ((fromUser=%ld AND toUser=%ld) OR (fromUser=%ld AND toUser=%ld)))", (long)[LTDataSource sharedDataSource].localUser.userId, (long)userId, (long)[LTDataSource sharedDataSource].localUser.userId, (long)[LTDataSource sharedDataSource].localUser.userId, (long)userId);
        //sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(_messages, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement)!=SQLITE_DONE)
                NSLog(@"Delete of 1 user in Messages failed");
        }
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
}

@end
