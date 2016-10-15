//
//  UFOSystemClass.m
//  ufo
//
//  Created by Programmieren on 31.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "UFOSystemClass.h"

@implementation UFOSystemClass

- (id)initWithClassName: (NSString *)className
             superClass: (UFOClass *)superClass
      referencedClasses: (NSArray *)referencedClasses{
    @throw NSInvalidArgumentException;
    return nil;
}

- (NSString *)superClassName{
    return nil;
}

- (UFOClass *)superclass{
    return nil;
}

- (NSArray *)referencedClasses{
    return @[];
}

+ (BOOL)isSystemClass{
    return YES;
}

- (void)performFunction:(NSString *)functionName
              arguments:(NSArray *)arguments
            returnValue:(NSString *__autoreleasing *)returnValue{
    if (![self hasFunctionNamed:functionName]
        || ![self functionNamed:functionName].publicFunction
        || ![self functionNamed:functionName].staticFunction
        || [self functionNamed:functionName].parameterNames.count != arguments.count) {
        @throw NSInvalidArgumentException;
        return;
    }
}

@end
