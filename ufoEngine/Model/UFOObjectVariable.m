//
//  UFOObjectVariable.m
//  ufo
//
//  Created by Programmieren on 01.06.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "UFOObjectVariable.h"

@implementation UFOObjectVariable

- (id)initVariableNamed:(NSString *)name{
    self = [super initVariableNamed:name];
    if (self) {
        [super setCurrentValue: nil];
        
        _objectClassName = nil;
    }
    return self;
}

- (id)initVariableNamed:(NSString *)name objectClassName:(NSString *)className{
    if (!className
        || ![className isValidClassName]) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    
    self = [super initVariableNamed:name];
    if (self) {
        [super setCurrentValue: nil];
        
        _objectClassName = className;
    }
    return self;
}

- (id)initVariableNamed:(NSString *)name public:(BOOL)pub static:(BOOL)stat{
    self = [super initVariableNamed:name public:pub static:stat];
    if (self) {
        [super setCurrentValue: nil];
        
        _objectClassName = nil;
    }
    return self;
}
- (id)initVariableNamed:(NSString *)name objectClassName:(NSString *)className public:(BOOL)pub static:(BOOL)stat{
    if (!className
        || ![className isValidClassName]) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    
    self = [super initVariableNamed:name public:pub static:stat];
    if (self) {
        [super setCurrentValue: nil];
        
        _objectClassName = className;
    }
    return self;
}

+ (UFODataType)variableType{
    return UFODataTypeObject;
}

@end
