//
//  UFOOutputClass.m
//  ufo
//
//  Created by Programmieren on 29.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "UFOOutputClass.h"

@implementation UFOOutputClass

- (id)init{
    self = [super init];
    if (self) {
        NSDictionary *info;
        info = @{@"name" : @"println",
                 @"publicFunction" : @YES,
                 @"staticFunction" : @YES,
                 @"returnType" : @(UFODataTypeVoid),
                 @"parameterNames" : @[],
                 @"parameterTypes" : @[],
                 @"parameterObjectClassNames" : @[],
                 @"sourceCode" : @""};
        UFOFunction *printlnFunction = [UFOFunction createFunctionWithDictionary: info];
        [self addFunction:printlnFunction];
        
        info = @{@"name" : @"printInt",
                 @"publicFunction" : @YES,
                 @"staticFunction" : @YES,
                 @"returnType" : @(UFODataTypeVoid),
                 @"parameterNames" : @[@"int"],
                 @"parameterTypes" : @[@(UFODataTypeInteger)],
                 @"parameterObjectClassNames" : @[@""],
                 @"sourceCode" : @""};
        UFOFunction *printIntFunction = [UFOFunction createFunctionWithDictionary: info];
        [self addFunction:printIntFunction];
    }
    return self;
}

- (NSString *)className{
    return @"UFOOutput";
}

- (void)performFunction: (NSString *)functionName
              arguments: (NSArray *)arguments
            returnValue: (NSString *__autoreleasing *)returnValue{
    if (!_delegate) return;
    
    if ([functionName isEqualToString:@"println"] && arguments.count == 0) {
        [_delegate write:@"\n"];
        
    }else if ([functionName isEqualToString:@"printInt"] && arguments.count == 1) {
        NSString *string = arguments[0];
        NSNumber *integer = string.getNumber;
        
        [_delegate write:@(integer.intValue).stringValue];
        
    }else{
        @throw NSInvalidArgumentException;
    }
}

@end
