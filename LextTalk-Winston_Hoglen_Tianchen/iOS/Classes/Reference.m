//
//  DatabaseHelper.m
//  hayTrafico
//
//  Created by nacho on 5/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Reference.h"
#import "ZipArchive.h"
#import "IQKit.h"
#import "UIDevice+IdentifierAddition.h"
#import "LTDataSource.h"

#define kBundleDatabaseVersion			5
#define kInstalledDatabaseVersionKey    @"reference.installedDatabaseVersion"
#define kDatabaseFilename				@"languages.db"
#define kZippedDatabaseFilename			@"languages.zip"

#define APP_VERSION						1


@interface Reference (PrivateMethods)
- (NSInteger) getRemoteDatabaseVersion;
+ (NSInteger) getInstalledDatabaseVersion;
+ (void) setInstalledDatabaseVersion: (NSInteger) version;
+ (void) installDatabaseFromBundle;
+ (void) installDatabaseFromData: (NSData*) data;
+ (BOOL) unzipFile:(NSString*)filePath destinationPath:(NSString*)toPath;
@end

static Reference *theReference = nil;

@implementation Reference
@synthesize delegate = _delegate;


#pragma mark -
#pragma mark Class methods
+ (NSInteger) getInstalledDatabaseVersion {
	return [[NSUserDefaults standardUserDefaults] integerForKey: kInstalledDatabaseVersionKey];
}

+ (void) setInstalledDatabaseVersion: (NSInteger) version {
    [[NSUserDefaults standardUserDefaults] setInteger: version forKey: kInstalledDatabaseVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger) getRemoteDatabaseVersion {

	NSString *udid = [UIDevice currentDevice].uniqueDeviceIdentifier;
	NSString *url = [NSString stringWithFormat: @"%@/get_version?appVersion=%d&udid=%@", LTBaseURL, APP_VERSION, udid];
	NSString *encodedUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodedUrl]];
	NSHTTPURLResponse* urlResponse = nil;
	NSError *error = [[NSError alloc] init];  
	NSData *localResponseData = [NSURLConnection sendSynchronousRequest: request 
													  returningResponse: &urlResponse 
																  error: &error];
	
	if(localResponseData == nil) {
		IQVerbose(VERBOSE_DEBUG,@"[%@] Failed to get remote DB version", [self class]);		
		return -1;
	}
	
	NSString *json_string = [[NSString alloc] initWithData:localResponseData encoding:NSUTF8StringEncoding];
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:localResponseData
                                                                options:kNilOptions
                                                                  error:&error];
	
	NSString *status = [dict objectForKey: @"status"];
	
	if((dict != nil) && ([status compare: @"success"] == NSOrderedSame) ) {
		NSDictionary *result = [dict objectForKey: @"result"];
		NSInteger version = [[result objectForKey: @"db_version"] integerValue];
		dbRemoteSize = [[result objectForKey: @"db_size"] intValue];
		IQVerbose(VERBOSE_DEBUG,@"[%@] Remote DB version: %d, size: %d bytes", [self class], version, dbRemoteSize);
		return version;
		
	} else {
		IQVerbose(VERBOSE_DEBUG,@"[%@] Failed to get remote DB version: %@", [self class], json_string);
		return -1;
	}
}

+ (NSString*) getDocumentsDir {
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	
	return documentsDir;		
}

+ (NSString*) getDatabasePath {
	return [[Reference getDocumentsDir] stringByAppendingPathComponent: kDatabaseFilename];		
}

+ (void) installDatabaseFromBundle {
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *databasePath = [Reference getDatabasePath];
    
	// Check if the database has already been created in the users filesystem
	bool success = [fileManager fileExistsAtPath: databasePath];
    
	// If the database already exists and is up to date then return without doing anything
	if(success && ([Reference getInstalledDatabaseVersion] >= kBundleDatabaseVersion) ) {
		IQVerbose(VERBOSE_DEBUG,@"[%@] Bundle DB (%d) is already installed or outdated, not installing", [self class], [Reference getInstalledDatabaseVersion]);					
		return;
	}
	
	// If not then proceed to copy the database from the application to the users filesystem
	// Get the path to the database in the application package
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: kZippedDatabaseFilename];
    
	// Copy the database from the package to the users filesystem
	if( ![Reference unzipFile: databasePathFromApp destinationPath: [Reference getDocumentsDir]] ) {
		IQVerbose(VERBOSE_DEBUG,@"[%@] Problem while installing database (could not unzip file)", [self class]);			
		return; // problem unzipping file, abort
	}

	[Reference setInstalledDatabaseVersion: kBundleDatabaseVersion];
	
	IQVerbose(VERBOSE_DEBUG,@"[%@] Installed Database version %d from app bundle", [self class], [Reference getInstalledDatabaseVersion]);
}

- (void) startDownload {
	
	if(responseData != nil) {
		responseData = nil;
	}
	
	responseData = [[NSMutableData alloc] init];
	
	NSString *dbUrl = [NSString stringWithFormat: @"%@/%@", LTLangURL, kZippedDatabaseFilename];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: dbUrl]];
	
	[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

+ (void) installDatabaseFromData: (NSData*) data {
	
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	NSString *zippedDBPath = [documentsDir stringByAppendingPathComponent: kZippedDatabaseFilename];
	
	if( ![data writeToFile:zippedDBPath atomically:YES] ) {
		IQVerbose(VERBOSE_DEBUG,@"[%@] Problem while installing database (could not write data to zip file)", [self class]);	
		return; // problem writting zip file, abort
	}
	
	if( ![Reference unzipFile: zippedDBPath destinationPath: [Reference getDocumentsDir]] ) {
		IQVerbose(VERBOSE_DEBUG,@"[%@] Problem while installing database (could not unzip file)", [self class]);			
		return; // problem unzipping file, abort
	}
}

- (BOOL) isLoaded {
    return upToDate;
}

- (void) installFromBundleIfNeeded {	
    
    [Reference installDatabaseFromBundle];
    upToDate = YES;

    //Deactivated, gives trouble, and it is not used
    /*
	dbInstalledVersion = [Reference getInstalledDatabaseVersion];
	dbRemoteVersion = [self getRemoteDatabaseVersion];

	if( (dbInstalledVersion < dbRemoteVersion) && (dbRemoteVersion > 0) ) {
        IQVerbose(VERBOSE_DEBUG,@"[%@] Downloading new database (version %d). Installed version was %d", [self class], dbRemoteVersion, dbInstalledVersion);
		upToDate = NO;
        [self startDownload];
	} else {
		IQVerbose(VERBOSE_DEBUG,@"[%@] Local database is already up to date (version %d)", [self class], dbInstalledVersion);
		upToDate = YES;
	}
     */
}

#pragma mark -
#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
	IQVerbose(VERBOSE_DEBUG,@"[%@] didReceiveResponse", [self class]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];

	CGFloat percent = 100.0 * ((CGFloat)[responseData length]) / ((CGFloat) dbRemoteSize);	

    if([self.delegate respondsToSelector: @selector(reference:didUpdateDownloadProgress:)]) {
        [self.delegate reference: self didUpdateDownloadProgress: percent];
    }
	
	//IQVerbose(VERBOSE_DEBUG,@"[%@] Connection did receive data: %d/%d", [self class], [responseData length], dbRemoteSize);	    	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    IQVerbose(VERBOSE_DEBUG,@"[%@] Connection failed: %@", [self class], [error description]);
    
    if(self.delegate != nil) {
        [self.delegate reference: self didFailWithError: error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	IQVerbose(VERBOSE_DEBUG,@"[%@] connectionDidFinishLoading", [self class]);
	[Reference installDatabaseFromData: responseData];
    [Reference setInstalledDatabaseVersion: dbRemoteVersion];
    IQVerbose(VERBOSE_DEBUG,@"[%@] Installed Database version %d from %@", [self class], dbRemoteVersion, LTLangURL);
    
    // we are done, call the delegate
    if(self.delegate !=nil) {
        [self.delegate referenceDidUpdate: self];
    }
}

#pragma mark unzip stuff
+ (BOOL)unzipFile:(NSString*)filePath destinationPath:(NSString*)toPath {

	ZipArchive *zipArchive = [[ZipArchive alloc] init];
	
	if(![zipArchive UnzipOpenFile: filePath]) {
		IQVerbose(VERBOSE_DEBUG,@"Error while opening file %@", filePath);
		return NO;
	}
	
	if(![zipArchive UnzipFileTo: toPath overWrite: YES]) {
		IQVerbose(VERBOSE_DEBUG,@"Error while unzipping file %@ to %@", filePath, toPath);
		return NO;		
	}
	
	if(![zipArchive UnzipCloseFile]) {
		IQVerbose(VERBOSE_DEBUG,@"Error while closing file");
		return NO;		
	}
	
	IQVerbose(VERBOSE_DEBUG,@"[%@] Unzipped file %@ to %@", [self class], filePath, toPath);
	
    return YES;
}

#pragma mark -
#pragma mark Singleton Methods
+ (id)sharedReference {
    @synchronized(self) {
        if(theReference == nil)
            theReference = [[super allocWithZone:NULL] init];
    }
    return theReference;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedReference];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}


@end
