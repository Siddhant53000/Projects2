//
//  IQUpdatableZipFile.m
//
//  Created by David Romacho on 5/3/10.
//  Copyright 2010 InQBarna. All rights reserved.
//

#import "IQUpdatableZipFile.h"
#import "IQKit.h"
#import "ZipArchive.h"

#define kBundleDatabaseVersion			2
#define kInstalledDatabaseVersionKey    @"reference.installedDatabaseVersion"
#define kDatabaseFilename				@"gf_teams.sqlite"
#define kZippedDatabaseFilename			@"gf_teams.zip"

#define API_URL							@"http://glocalfans.inqbarna.com/service/"
#define APP_VERSION						1


@interface IQUpdatableZipFile (PrivateMethods)
- (void) getRemoteVersion;
- (NSInteger) getInstalledVersion;
- (void) setInstalledVersion: (NSInteger) version;
- (void) installZipFileFromData: (NSData*) data;
+ (BOOL) unzipFile:(NSString*)filePath destinationPath:(NSString*)toPath;
@end

@implementation IQUpdatableZipFile
@synthesize filename = _filename;
@synthesize url = _url;
@synthesize delegate = _delegate;
@synthesize responseData = _responseData;
@synthesize upToDate = _upToDate;
@synthesize remoteVersion = _remoteVersion;
@synthesize installedVersion = _installedVersion;
@synthesize remoteSize = _remoteSize;

#pragma mark -
#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[self.responseData setLength:0];
	IQVerbose(VERBOSE_DEBUG,@"[%@] didReceiveResponse", [self class]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.responseData appendData:data];
    
	CGFloat percent = 100.0 * ((CGFloat)[self.responseData length]) / ((CGFloat) self.remoteSize);	
    
    if([self.delegate respondsToSelector: @selector(updatableZipFile:didUpdateDownloadProgress:)]) {
        [self.delegate updateableZipFile: self didUpdateDownloadProgress: percent];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    IQVerbose(VERBOSE_WARNING,@"[%@] Connection failed: %@", [self class], [error description]);
    
    if(self.delegate != nil) {
        [self.delegate updateableZipFile: self didFailWithError: error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	IQVerbose(VERBOSE_WARNING,@"[%@] connectionDidFinishLoading", [self class]);
	[self installZipFileFromData: self.responseData];
    [self setInstalledVersion: self.remoteVersion];
    IQVerbose(VERBOSE_DEBUG,@"[%@] Installed file %@ version %d from %@", [self class], self.filename, self.remoteVersion, self.url);
	self.responseData = nil;
    
    // we are done, call the delegate
    if(self.delegate !=nil) {
        [self.delegate updateableZipFileDidUpdate: self];
    }
}

#pragma mark -
#pragma mark IQUpdatableZipFile methods

- (NSInteger) getInstalledVersion {
	return [[NSUserDefaults standardUserDefaults] integerForKey: self.filename];
}

- (void) setInstalledVersion: (NSInteger) version {
    [[NSUserDefaults standardUserDefaults] setInteger: version forKey: self.filename];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) getRemoteVersion {

	NSString *reqUrl = [NSString stringWithFormat: @"%@/get_version.php", self.url];	
	NSString *encodedUrl = [reqUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodedUrl]];
	NSHTTPURLResponse* urlResponse = nil;
	NSError *error = [[NSError alloc] init];  
	NSData *localResponseData = [NSURLConnection sendSynchronousRequest: request 
													  returningResponse: &urlResponse 
																  error: &error];
	
	if(localResponseData == nil) {
		IQVerbose(VERBOSE_WARNING, @"[%@] Failed to get remote version for file %@", [self class], self.filename);		
        self.remoteVersion = -1;
        self.remoteSize = -1;
        return;
	}
	
    NSError *jsonerror = nil;
	NSString *json_string = [[NSString alloc] initWithData:localResponseData encoding:NSUTF8StringEncoding];
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:localResponseData
                                                                options:kNilOptions
                                                                  error:&jsonerror];
	
	NSString *status = [dict objectForKey: @"status"];
	
	if((dict != nil) && ([status compare: @"success"] == NSOrderedSame) ) {
		NSDictionary *result = [dict objectForKey: @"result"];
		self.remoteVersion = [[result objectForKey: @"version"] integerValue];
		self.remoteSize = [[result objectForKey: @"size"] integerValue];
		IQVerbose(VERBOSE_DEBUG, @"[%@] Remote zip file (%@) version: %d, size: %d bytes", [self class], self.filename, self.remoteVersion, self.remoteSize);	
	} else {
		IQVerbose(VERBOSE_WARNING, @"[%@] Failed to get remote version (%@): %@", [self class], self.filename, json_string);
        self.remoteVersion = -1;
        self.remoteSize = -1;
	}
    
}

+ (NSString*) getDocumentsDir {
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	
	return documentsDir;		
}

- (NSString*) getFilePath {
	return [[IQUpdatableZipFile getDocumentsDir] stringByAppendingPathComponent: self.filename];		
}

- (void) installZipFileFromBundle {
	NSString *filePath = [self getFilePath];
    
	// Check if the database has already been created in the users filesystem
	bool success = [[NSFileManager defaultManager] fileExistsAtPath: filePath];
    
	// If the database already exists and is up to date then return without doing anything
	if(success && ([self getInstalledVersion] >= kBundleDatabaseVersion) ) {
		IQVerbose(VERBOSE_DEBUG, @"[%@] Zip in bundle (%d) is already installed or outdated, not installing", [self class], [self getInstalledVersion]);					
		return;
	}
	
	// If not then proceed to copy the database from the application to the users filesystem
	// Get the path to the database in the application package
	NSString *zipFilePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: kZippedDatabaseFilename];
    
	// Copy the database from the package to the users filesystem
	if( ![IQUpdatableZipFile unzipFile: zipFilePathFromApp destinationPath: [IQUpdatableZipFile getDocumentsDir]] ) {
		IQVerbose(VERBOSE_WARNING,@"[%@] Problem while installing database (could not unzip file)", [self class]);			
		return; // problem unzipping file, abort
	}

	[self setInstalledVersion: 0];
	
	IQVerbose(VERBOSE_DEBUG,@"[%@] Installed Database version %d from app bundle", [self class], [self getInstalledVersion]);
}

- (void) startDownload {
	
	self.responseData = [NSMutableData dataWithLength:0];
	
	NSString *fileUrl = [NSString stringWithFormat: @"%@/%@",self.url, self.filename];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: fileUrl]];
	
	[[NSURLConnection alloc] initWithRequest:request delegate: self];
}

- (void) installZipFileFromData: (NSData*) data {
	
	// Get the path to the documents directory and append the databaseName
	NSString *zippedPath = [[IQUpdatableZipFile getDocumentsDir] stringByAppendingPathComponent: self.filename];
	
	if( ![data writeToFile:zippedPath atomically:YES] ) {
		IQVerbose(VERBOSE_WARNING,@"Problem while installing database (could not write data to zip file)");	
		return; // problem writting zip file, abort
	}
	
	if( ![IQUpdatableZipFile unzipFile: zippedPath destinationPath: [IQUpdatableZipFile getDocumentsDir]] ) {
		IQVerbose(VERBOSE_WARNING,@"Problem while installing database (could not unzip file)");			
		return; // problem unzipping file, abort
	}
}

- (BOOL) isLoaded {
    return self.upToDate;
}

- (void) checkForUpdates {	
    
    [self installZipFileFromBundle];

	self.installedVersion = [self getInstalledVersion];
	[self getRemoteVersion];

	if( (self.installedVersion < self.remoteVersion) && ( self.remoteVersion > 0) ) {
        IQVerbose(VERBOSE_DEBUG,@"[%@] Downloading new file (version %d). Installed version was %d", [self class], self.remoteVersion, self.installedVersion);
		self.upToDate = NO;
        [self startDownload];
	} else {
		IQVerbose(VERBOSE_DEBUG,@"[%@] Local file is already up to date (version %d)", [self class], self.installedVersion);
		self.upToDate = YES;        
	}
}

#pragma mark -
#pragma mark unzip stuff
+ (BOOL)unzipFile:(NSString*)filePath destinationPath:(NSString*)toPath {

	ZipArchive *zipArchive = [[ZipArchive alloc] init];
	
	if(![zipArchive UnzipOpenFile: filePath]) {
		IQVerbose(VERBOSE_WARNING,@"Error while opening file %@", filePath);
		return NO;
	}
	
	if(![zipArchive UnzipFileTo: toPath overWrite: YES]) {
		IQVerbose(VERBOSE_WARNING,@"Error while unzipping file %@ to %@", filePath, toPath);
		return NO;		
	}
	
	if(![zipArchive UnzipCloseFile]) {
		IQVerbose(VERBOSE_WARNING,@"Error while closing file");
		return NO;		
	}
	
	IQVerbose(VERBOSE_DEBUG,@"Unzipped file %@ to %@", filePath, toPath);
	
    return YES;
}

@end
