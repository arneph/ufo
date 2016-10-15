//
//  UFOClass.m
//  ufo
//
//  Created by Programmieren on 27.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "UFOClass.h"

@implementation UFOClass

- (id)init{
    self = [super init];
    if (self) {
        _className = nil;
        _superClassName = nil;
        _superClass = nil;
        _referencedClasses = @[];
        _functions = @[];
    }
    return (self = [super init]);
}

- (id)initWithClassName:(NSString *)className
             superClass:(UFOClass *)superClass
      referencedClasses:(NSArray *)referencedClasses{
    if (!className || [className isEqualToString:@""] || !referencedClasses){
        @throw NSInvalidArgumentException;
        return nil;
    }
    
    self = [super init];
    if (self) {
        _className = className;
        _superClassName = superClass.className;
        _superClass = superClass;
        _referencedClasses = referencedClasses;
        _functions = @[];
    }
    return self;
}

+ (BOOL)isSystemClass{
    return NO;
}

- (BOOL)hasFunctionNamed:(NSString *)functionName{
    for (UFOFunction *f in _functions)
        if ([f.name isEqualToString:functionName])
            return YES;
    return NO;
}

- (UFOFunction *)functionNamed:(NSString *)functionName{
    for (UFOFunction *f in _functions)
        if ([f.name isEqualToString:functionName])
            return f;
    return nil;
}

- (void)addFunction:(UFOFunction *)function{
    if (!function || [self hasFunctionNamed:function.name]) {
        @throw NSInvalidArgumentException;
        return;
    }
    _functions = [_functions arrayByAddingObject:function];
}

- (BOOL)hasReferencedClassNamed:(NSString *)className{
    if (!className || [className isEqualToString:@""]) return NO;
    for (UFOClass *referencedClass in _referencedClasses) {
        if ([referencedClass.className isEqualToString:className])
            return YES;
    }
    return NO;
}

- (UFOClass *)referencedClassNamed:(NSString *)className{
    if (![self hasReferencedClassNamed:className]) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    for (UFOClass *referencedClass in _referencedClasses) {
        if ([referencedClass.className isEqualToString:className])
            return referencedClass;
    }
    return nil;
}

@end
