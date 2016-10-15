//
//  UFOReader.m
//  ufo
//
//  Created by Programmieren on 24.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "UFOReader.h"

@implementation UFOReader

- (id)init{
    self = [super init];
    if (self) {
        _ufoLibraryFolder = [[NSBundle bundleForClass:[UFOReader class]] URLForResource:@"ufo" withExtension:@"ufo"];
        _ufoLibraryFolder = [NSURL URLWithString: [_ufoLibraryFolder path]];
        _ufoFolder = nil;
    }
    return self;
}

- (id)initForUFOFolder:(NSURL *)ufoFolder{
    self = [super init];
    if (self) {
        _ufoLibraryFolder = [[NSBundle bundleForClass:[UFOReader class]] URLForResource:@"ufo" withExtension:@"ufo"];
        _ufoLibraryFolder = [NSURL URLWithString: [_ufoLibraryFolder path]];
        _ufoFolder = ufoFolder;
        if (!self.isUFOFolderValid) {
            return nil;
        }
    }
    return self;
}

- (BOOL)isUFOFolderValid {
    if (!_ufoFolder) return NO;
    
    NSNumber *isDirectory;
    BOOL success = [_ufoFolder getResourceValue:&isDirectory
                                         forKey:NSURLIsDirectoryKey
                                          error:nil];
    if (!success || [isDirectory boolValue] == false) return NO;
    
    if (![_ufoFolder.pathExtension isEqual:@"ufo"]) return NO;
    return YES;
}

- (BOOL)containsFileNamed:(NSString *)name inFolder:(NSString *)folderPath{
    if (!name || [name isEqualToString:@""]) {
        @throw NSInvalidArgumentException;
        return NO;
    }
    NSURL *url = _ufoFolder.copy;
    if (folderPath && ![folderPath isEqualToString:@""]) {
        url = [url URLByAppendingPathComponent:folderPath];
    }
    if ((folderPath.length == 3 && [[folderPath substringToIndex:3] isEqualToString:@"ufo"])
        || (folderPath.length >= 4 && [[folderPath substringToIndex:4] isEqualToString:@"ufo/"])){
        url = _ufoLibraryFolder.copy;
        if (folderPath.length > 4) {
            url = [url URLByAppendingPathComponent:[folderPath substringFromIndex:4]];
        }
    }
    url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.ufo", name]];
    
    NSNumber *isDirectory;
    BOOL success = [url getResourceValue:&isDirectory
                                  forKey:NSURLIsDirectoryKey
                                   error:nil];
    if (!success || [isDirectory boolValue] == YES) return NO;
    return YES;
}

- (NSString *)getContentsOfFileNamed:(NSString *)name inFolder:(NSString *)folderPath{
    if (![self containsFileNamed:name inFolder:folderPath]) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    NSURL *url = _ufoFolder.copy;
    if (folderPath && ![folderPath isEqualToString:@""]) {
        url = [url URLByAppendingPathComponent:folderPath];
    }
    if ((folderPath.length == 3 && [[folderPath substringToIndex:3] isEqualToString:@"ufo"])
        || (folderPath.length >= 4 && [[folderPath substringToIndex:4] isEqualToString:@"ufo/"])){
        url = _ufoLibraryFolder.copy;
        if (folderPath.length > 4) {
            url = [url URLByAppendingPathComponent:[folderPath substringFromIndex:4]];
        }
    }
    url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.ufo", name]];
    
    NSString *contents;
    NSStringEncoding encoding;
    NSError *error;
    contents = [NSString stringWithContentsOfURL:url
                                    usedEncoding:&encoding
                                           error:&error];
    
    if (!contents || encoding == 0 || error) return nil;
    return contents;
}

- (BOOL)containsFolder:(NSString *)folderName inFolder:(NSString *)folderPath{
    if (!folderName) {
        @throw NSInvalidArgumentException;
        return NO;
    }
    NSURL *url = _ufoFolder.copy;
    if (folderPath && ![folderPath isEqualToString:@""]) {
        url = [url URLByAppendingPathComponent:folderPath];
    }
    url = [url URLByAppendingPathComponent:folderName];
    
    NSNumber *isDirectory;
    BOOL success = [url getResourceValue:&isDirectory
                                  forKey:NSURLIsDirectoryKey
                                   error:nil];
    if (!success || [isDirectory boolValue] == NO) return NO;
    return YES;
}

- (NSArray *)getFilesInFolderNamed:(NSString *)folderName inFolder:(NSString *)folderPath{
    if (![self containsFolder:folderName inFolder:folderPath]) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    
    NSMutableArray *fileNames = [[NSMutableArray alloc] init];
    
    NSURL *url = _ufoFolder.copy;
    if (folderPath && ![folderPath isEqualToString:@""]) {
        url = [url URLByAppendingPathComponent:folderPath];
    }
    url = [url URLByAppendingPathComponent:folderName];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:url
                                          includingPropertiesForKeys:@[NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                                   | NSDirectoryEnumerationSkipsPackageDescendants
                                                                   | NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^(NSURL *url, NSError *error) {
                                             return YES;
                                         }];
    
    for (NSURL *fileURL in enumerator.allObjects) {
        NSNumber *isDirectory;
        BOOL success = [fileURL getResourceValue:&isDirectory
                                          forKey:NSURLIsDirectoryKey
                                           error:nil];
        if (success && [isDirectory boolValue] == NO) {
            [fileNames addObject:fileURL.lastPathComponent.stringByDeletingPathExtension];
        }
    }
    
    return [NSArray arrayWithArray:fileNames];
}

@end
