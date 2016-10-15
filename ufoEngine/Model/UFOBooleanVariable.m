//
//  UFOBooleanVariable.m
//  ufo
//
//  Created by Programmieren on 01.06.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "UFOBooleanVariable.h"

@implementation UFOBooleanVariable

- (id)initVariableNamed:(NSString *)name{
    self = [super initVariableNamed:name];
    if (self) {
        [super setCurrentValue: @NO];
    }
    return self;
}

- (id)initVariableNamed:(NSString *)name public:(BOOL)pub static:(BOOL)stat{
    self = [super initVariableNamed:name public:pub static:stat];
    if (self) {
        [super setCurrentValue: @NO];
    }
    return self;
}

- (BOOL)setCurrentValue:(id)value{
    if (![value isKindOfClass:[NSString class]]) {
        @throw NSInvalidArgumentException;
        return NO;
    }
    NSString *stringValue = (NSString *)value;
    
    if ([stringValue isEqualToString:@"false"])
        return [super setCurrentValue: @NO];
    else if ([stringValue isEqualToString:@"true"])
        return [super setCurrentValue: @YES];
    
    return NO;
}

+ (UFODataType)variableType{
    return UFODataTypeBoolean;
}

@end
