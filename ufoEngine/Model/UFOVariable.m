//
//  UFOVariable.m
//  ufo
//
//  Created by Programmieren on 01.06.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "UFOVariable.h"

@implementation UFOVariable

- (id)init{
    @throw NSInvalidArgumentException;
    return nil;
}

- (id)initVariableNamed: (NSString *)name {
    if (![name isValidVariableName]) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    
    self = [super init];
    if (self) {
        _name = name;
        _currentValue = nil;
        _variableType = [[self class] variableType];
        _publicVariable = NO;
        _staticVariable = NO;
    }
    return self;
}

- (id)initVariableNamed: (NSString *)name public:(BOOL)pub static:(BOOL)stat{
    if (![name isValidVariableName]) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    
    self = [super init];
    if (self) {
        _name = name;
        _currentValue = nil;
        _variableType = [[self class] variableType];
        _publicVariable = pub;
        _staticVariable = stat;
    }
    return self;
}

- (BOOL)setCurrentValue: (id)value {
    _currentValue = value;
    return YES;
}

+ (UFODataType)variableType{
    return UFODataTypeInteger;
}

@end
