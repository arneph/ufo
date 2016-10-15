//
//  UFOSubEngine.h
//  ufo
//
//  Created by Programmieren on 30.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UFOClass.h"
#import "UFOSystemClass.h"
#import "UFOFunction.h"
#import "UFOScope.h"
#import "UFOBooleanVariable.h"
#import "UFONumberVariable.h"
#import "UFOObjectVariable.h"
#import "UFOVariable.h"

typedef enum {
    UFOSubEngineReady,
    UFOSubEngineRunning,
    UFOSubEngineCrashed,
    UFOSubEngineTerminated
}UFOSubEngineStatus;

@class UFOSubEngine;

@protocol UFOSubEngineDelegate <NSObject>

- (void)subEngineStatusChanged: (UFOSubEngine *)subEngine;

@end

@interface UFOSubEngine : NSObject

@property UFOClass *startClass;
@property UFOFunction *startFunction;
@property NSArray *startArguments;

@property UFOClass *currentClass;
@property UFOFunction *currentFunction;
@property NSArray *currentArguments;

@property NSOperation *operation;

@property UFOSubEngineStatus subEngineStatus;
@property NSString *crashMessage;
@property id<UFOSubEngineDelegate> delegate;

- (id)initWithFunction: (UFOFunction *)startFunction
               inClass: (UFOClass *)startClass
             arguments: (NSArray *)arguments;

- (void)start;

@end
