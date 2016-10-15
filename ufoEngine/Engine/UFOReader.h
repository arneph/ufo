//
//  UFOReader.h
//  ufo
//
//  Created by Programmieren on 24.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UFOReader : NSObject

@property (readonly) NSURL *ufoLibraryFolder;
@property (readonly) NSURL *ufoFolder;

- (id)initForUFOFolder: (NSURL *)ufoFolder;

- (BOOL)containsFileNamed: (NSString *)name inFolder: (NSString *)folderPath;
- (NSString*)getContentsOfFileNamed: (NSString *)name inFolder: (NSString *)folderPath;

- (BOOL)containsFolder: (NSString *)folderName inFolder: (NSString *)folderPath;
- (NSArray*)getFilesInFolderNamed: (NSString *)folderName inFolder: (NSString *)folderPath;

@end
