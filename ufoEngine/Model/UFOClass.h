//
//  UFOClass.h
//  ufo
//
//  Created by Programmieren on 27.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UFOFunction.h"

@interface UFOClass : NSObject

@property (readonly) NSString *className;
@property (readonly) NSString *superClassName;

@property (readonly) UFOClass *superClass;
@property (readonly) NSArray *referencedClasses;

@property (readonly) NSArray *functions;

- (id)initWithClassName: (NSString *)className
             superClass: (UFOClass *)superClass
      referencedClasses: (NSArray *)referencedClasses;

+ (BOOL)isSystemClass;

- (BOOL)hasFunctionNamed: (NSString *)functionName;
- (UFOFunction *)functionNamed: (NSString *)functionName;

- (void)addFunction: (UFOFunction*)function;

- (BOOL)hasReferencedClassNamed: (NSString *)className;
- (UFOClass *)referencedClassNamed: (NSString *)className;

@end
