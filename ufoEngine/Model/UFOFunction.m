//
//  UFOFunction.m
//  ufo
//
//  Created by Programmieren on 29.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "UFOFunction.h"

@implementation UFOFunction

+ (instancetype)createFunctionWithDictionary:(NSDictionary *)info{
    return [[UFOFunction alloc] initWithDictionary: info];
}

- (id)init{
    @throw NSInvalidArgumentException;
    return nil;
}

- (id)initWithDictionary: (NSDictionary *)info{
    self = [super init];
    if (self) {
        _name = (NSString*)info[@"name"];
        if (!_name || [_name isEqualToString:@""]) {
            @throw NSInvalidArgumentException;
            return nil;
        }
        
        _publicFunction = ((NSNumber*)info[@"publicFunction"]).boolValue;
        _staticFunction = ((NSNumber*)info[@"staticFunction"]).boolValue;
        
        _returnType = (UFODataType)((NSNumber*)info[@"returnType"]).unsignedIntegerValue;
        _returnObjectClassName = (NSString*)info[@"returnObjectClassName"];
        if ([_returnObjectClassName isEqualToString:@""])
            _returnObjectClassName = nil;
        
        _parameterNames = (NSArray*)info[@"parameterNames"];
        _parameterTypes = (NSArray*)info[@"parameterTypes"];
        _parameterObjectClassNames = (NSArray*)info[@"parameterObjectClassNames"];
        
        if (_parameterNames.count != _parameterTypes.count || _parameterNames.count != _parameterObjectClassNames.count) {
            @throw NSInvalidArgumentException;
            return nil;
        }
        
        _sourceCode = (NSString*)info[@"sourceCode"];
    }
    return self;
}

- (BOOL)isValidMainFunction{
    if (![_name isEqualToString:@"main"]) return NO;
    if (!_publicFunction) return NO;
    if (!_staticFunction) return NO;
    if (_returnType != UFODataTypeVoid) return NO;
    if (_parameterNames.count > 0 || _parameterTypes.count > 0) return NO;
    return YES;
}

@end
