//
//  UFOEngine.m
//  ufo
//
//  Created by Programmieren on 24.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "UFOEngine.h"
#import "UFOSubEngine.h"
#import "UFOReader.h"
#import "UFOClassesController.h"
#import "UFOClass.h"
#import "UFOFunction.h"

@interface UFOEngine () <UFOSubEngineDelegate, UFOOutputDelegate>

@end

@implementation UFOEngine{
    UFOReader *reader;
    UFOClassesController *classesController;
    
    UFOSubEngine *mainSubEngine;
    NSMutableArray *subEngines;
    NSMutableArray *subEngineOperationQueues;
}

- (id)init{
    @throw NSInvalidArgumentException;
    return nil;
}

- (id)initWithURL:(NSURL *)ufoFolder console: (UFOConsole *)console viewer:(UFOViewer *)viewer{
    if (!ufoFolder) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    self = [super init];
    if (self) {
        _engineStatus = UFOEnginePreparing;
        _ufoFolder = ufoFolder;
        _programName = [ufoFolder lastPathComponent].stringByDeletingPathExtension;
        if (_programName.length > 0) {
            _programName = [NSString stringWithFormat:@"%@%@", [_programName substringToIndex:1].uppercaseString,
                                                               [_programName substringFromIndex:1]];
        }
        _console = console;
        _viewer = viewer;
        
        reader = [[UFOReader alloc] initForUFOFolder:ufoFolder];
        classesController = [UFOClassesController createClassesControllerWithReader: reader];
        classesController.outputClass.delegate = self;
        subEngines = [[NSMutableArray alloc] init];
        subEngineOperationQueues = [[NSMutableArray alloc] init];
        
        if (!_console) {
            _console = [[UFOConsole alloc] initWithFrame:NSMakeRect(0, 0, 800, 200)];
        }
        if (!_viewer) {
            _viewer = [[UFOViewer alloc] initWithFrame:NSMakeRect(0, 0, 800, 800)];
        }
        if (!reader) {
            return nil;
        }
        
        _console.inputDelegate = self;
        [_console clear];
        [_console writeByEngine:@"Successfully created engine"];
        
        [_viewer clear];
        
        if (![reader containsFileNamed:_programName inFolder:nil]) {
            [_console writeByEngine:[NSString stringWithFormat:@"Couldn't find '%@.ufo' file. Program isn't runable.", _programName]];
        }else{
            UFOClass *programClass;
            NSString *failureExplaination;
            
            programClass = [classesController loadClassNamed:_programName
                                                    inFolder:nil
                                         failureExplaination:&failureExplaination];
            
            if (failureExplaination) {
                [_console writeByEngine:[NSString stringWithFormat:@"The class %@ couldn't be loaded: %@", _programName, failureExplaination]];
                [_console writeByEngine:@"The program crashed due to a class load failure."];
                _engineStatus = UFOEngineProgramCrashed;
            }else{
                UFOFunction *mainFunction = [programClass functionNamed:@"main"];
                
                if (!mainFunction) {
                    [_console writeByEngine:[NSString stringWithFormat: @"The program crashed because the %@ class has no main function.", _programName]];
                    _engineStatus = UFOEngineProgramCrashed;
                }else if (!mainFunction.isValidMainFunction) {
                    [_console writeByEngine: @"The program crashed because the main function doesn't follow the standards for main functions."];
                    _engineStatus = UFOEngineProgramCrashed;
                }else{
                    _engineStatus = UFOEngineReady;
                }
            }
        }
    }
    return self;
}

- (void)enteredText: (NSString *)text;{
    if (text.length == 0) return;
    if ([[text substringToIndex:1] isEqual:@"/"]) {
        if (text.length == 1) return;
        if ([[text substringToIndex:2] isEqual:@"//"]) {
            
        }else{
            [self interpretCommand:[text substringFromIndex:1]];
        }
    }
}

- (void)interpretCommand: (NSString *)command{
    if ([command.lowercaseString isEqualToString:@"ping"]) {
        [_console writeByEngine:@"Ping"];
    }else if ([command.lowercaseString isEqualToString:@"processescount"]) {
        [_console writeByEngine:[NSString stringWithFormat:@"Number of Processes: %i",
                                                           (int) subEngineOperationQueues.count]];
    }else if ([command.lowercaseString isEqualToString:@"killall"]) {
        _engineStatus = UFOEngineProgramTerminated;
        
        [self killAllSubEngines];
        [_console writeByEngine: @"All threads were killed."];
    }
}

- (void)beginRunning{
    if (_engineStatus != UFOEngineReady) return;
    
    UFOClass *programClass = [classesController classNamed:_programName];
    UFOFunction *mainFunction = [programClass functionNamed:@"main"];
    
    mainSubEngine = [self newSubEngineForFunction:mainFunction inClass:programClass];
    
    [self startSubEngine:mainSubEngine];
}

- (UFOSubEngine *)newSubEngineForFunction: (UFOFunction *)function inClass: (UFOClass *)class{
    NSOperationQueue *subEngineOperationQueue = [[NSOperationQueue alloc] init];
    [subEngineOperationQueue setMaxConcurrentOperationCount:1];
    
    __block UFOEngine *engine = self;
    __block UFOClass *cl = class;
    __block UFOFunction *fn = function;
    __block UFOSubEngine *subEngine;
    
    NSArray *operations = @[[NSBlockOperation blockOperationWithBlock:^{
        subEngine = [[UFOSubEngine alloc] initWithFunction:fn inClass:cl arguments:@[]];
        subEngine.delegate = engine;
    }]];
    
    [subEngineOperationQueue addOperations:operations
                         waitUntilFinished:YES];
    [subEngines addObject:subEngine];
    [subEngineOperationQueues addObject:subEngineOperationQueue];
    
    return subEngine;
}

- (void)startSubEngine: (UFOSubEngine *)se{
    NSUInteger index = [subEngines indexOfObject: se];
    
    NSOperationQueue *subEngineOperationQueue = subEngineOperationQueues[index];
    __block UFOSubEngine *subEngine = se;
    
    __block NSBlockOperation *startOperation = [NSBlockOperation blockOperationWithBlock:^{
        [subEngine start];
    }];
    NSBlockOperation *prestartOperation = [NSBlockOperation blockOperationWithBlock:^{
        [subEngine setOperation:startOperation];
    }];
                                           
    [subEngineOperationQueue addOperations:@[prestartOperation]
                         waitUntilFinished:YES];
    [subEngineOperationQueue addOperation:startOperation];
}

- (void)killAllSubEngines{    
    for (NSOperationQueue *subEngineOperationQueue in subEngineOperationQueues) {
        [subEngineOperationQueue cancelAllOperations];
    }
    for (NSOperationQueue *subEngineOperationQueue in subEngineOperationQueues) {
        [subEngineOperationQueue waitUntilAllOperationsAreFinished];
    }
    subEngineOperationQueues = [[NSMutableArray alloc] init];
}

- (void)subEngineStatusChanged: (UFOSubEngine *)subEngine {
    __block UFOSubEngineStatus status = subEngine.subEngineStatus;
    __block NSString *startFunctionName = subEngine.startFunction.name;
    
    runBlockOnMainQueue(^{
        if (status == UFOSubEngineCrashed) {
            if (subEngine == mainSubEngine) {
                [_console writeByEngine:@"The main thread crashed."];
            }else{
                [_console writeByEngine:[NSString stringWithFormat:@"A thread with the start function: %@ crashed.", startFunctionName]];
            }
            [_console writeByEngine: [NSString stringWithFormat: @"   Class: %@", subEngine.currentClass.className]];
            [_console writeByEngine: [NSString stringWithFormat: @"Function: %@", subEngine.currentFunction.name]];
            if (subEngine.crashMessage)
                [_console writeByEngine: [NSString stringWithFormat: @"  Reason: %@", subEngine.crashMessage]];
            _engineStatus = UFOEngineProgramCrashed;
            
            [self killAllSubEngines];
            [_console writeByEngine:@"All threads were killed."];
        }
    });
}

- (void)write:(NSString *)string{
    __block NSString *msg = string;
    runBlockOnMainQueue(^{
        [_console write: msg];
    });
}

@end
