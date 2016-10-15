//
//  UFONumberVariable.m
//  ufo
//
//  Created by Programmieren on 01.06.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "UFONumberVariable.h"

@implementation UFONumberVariable

- (id)initVariableNamed:(NSString *)name{
    self = [super initVariableNamed:name];
    if (self) {
        [super setCurrentValue:@0];
    }
    return self;
}

- (id)initVariableNamed:(NSString *)name public:(BOOL)pub static:(BOOL)stat{
    self = [super initVariableNamed:name public:pub static:stat];
    if (self) {
        [super setCurrentValue:@0];
    }
    return self;
}

- (BOOL)setCurrentValue:(id)value{
    if (![value isKindOfClass:[NSString class]]) {
        @throw NSInvalidArgumentException;
        return NO;
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximum: [[self class] maximum]];
    [formatter setMinimum: [[self class] minimum]];
    [formatter setNumberStyle: ([[self class] allowsDecimals]) ? NSNumberFormatterDecimalStyle :
                                                                 NSNumberFormatterNoStyle];
    [formatter setRoundingMode: NSNumberFormatterRoundDown];
    
    NSNumber *numberValue = [formatter numberFromString: (NSString *)value];
    
    if (!numberValue)
        return NO;
    
    return [super setCurrentValue: numberValue];
}

+ (UFODataType)variableType{
    return UFODataTypeInteger;
}

+ (NSNumber *)maximum{
    return @(INT_MAX);
}

+ (NSNumber *)minimum{
    return @(INT_MIN);
}

+ (BOOL)allowsDecimals{
    return NO;
}

@end

@implementation UFOCharVariable

+ (UFODataType)variableType{
    return UFODataTypeChar;
}

+ (NSNumber *)maximum{
    return @127;
}

+ (NSNumber *)minimum{
    return @(-128);
}

@end

@implementation UFOByteVariable

+ (UFODataType)variableType{
    return UFODataTypeByte;
}

+ (NSNumber *)maximum{
    return @255;
}

+ (NSNumber *)minimum{
    return @0;
}

@end

@implementation UFOIntegerVariable

+ (UFODataType)variableType{
    return UFODataTypeInteger;
}

+ (NSNumber *)maximum{
    return @(INT_MAX);
}

+ (NSNumber *)minimum{
    return @(INT_MIN);
}

@end

@implementation UFOUnsignedIntegerVariable

+ (UFODataType)variableType{
    return UFODataTypeUnsignedInteger;
}

+ (NSNumber *)maximum{
    return @(UINT_MAX);
}

+ (NSNumber *)minimum{
    return @0;
}

@end

@implementation UFOLongVariable

+ (UFODataType)variableType{
    return UFODataTypeLong;
}

+ (NSNumber *)maximum{
    return @(LONG_MAX);
}

+ (NSNumber *)minimum{
    return @(LONG_MIN);
}

@end

@implementation UFOFloatVariable

+ (UFODataType)variableType{
    return UFODataTypeFloat;
}

+ (NSNumber *)maximum{
    return @(FLT_MAX);
}

+ (NSNumber *)minimum{
    return @(FLT_MIN);
}

+ (BOOL)allowsDecimals{
    return YES;
}

@end

@implementation UFODoubleVariable

+ (UFODataType)variableType{
    return UFODataTypeDouble;
}

+ (NSNumber *)maximum{
    return @(DBL_MAX);
}

+ (NSNumber *)minimum{
    return @(DBL_MIN);
}

+ (BOOL)allowsDecimals{
    return YES;
}

@end
