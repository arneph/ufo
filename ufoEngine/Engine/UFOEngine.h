//
//  UFOEngine.h
//  ufo
//
//  Created by Programmieren on 24.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UFOConsole.h"
#import "UFOViewer.h"

typedef enum{
    UFOEnginePreparing,
    UFOEngineReady,
    UFOEngineRunning,
    UFOEnginePaused,
    UFOEngineProgramCrashed,
    UFOEngineProgramTerminated
}UFOEngineStatus;

@interface UFOEngine : NSObject <UFOConsoleInputDelegate>

@property (readonly) UFOEngineStatus engineStatus;

@property (readonly) NSURL *ufoFolder;
@property (readonly) NSString *programName;
@property (readonly) UFOConsole *console;
@property (readonly) UFOViewer *viewer;

- (id)initWithURL: (NSURL *)ufoFolder console: (UFOConsole *)console viewer: (UFOViewer *)viewer;

- (void)beginRunning;

@end
