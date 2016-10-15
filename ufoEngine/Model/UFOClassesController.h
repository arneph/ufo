//
//  UFOClassesController.h
//  ufo
//
//  Created by Programmieren on 29.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UFOReader.h"
#import "UFOClass.h"
#import "UFOOutputClass.h"

@interface UFOClassesController : NSObject

@property (readonly) UFOReader *reader;

+ (instancetype)createClassesControllerWithReader: (UFOReader *)reader;

- (NSArray *)classes;
- (BOOL)hasClassNamed: (NSString *)className;
- (UFOClass *)classNamed: (NSString *)className;

- (UFOClass *)loadClassNamed: (NSString *)name
                    inFolder: (NSString *)folder
         failureExplaination: (NSString *__autoreleasing*)explaination;

- (UFOOutputClass *)outputClass;

@end
