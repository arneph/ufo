//
//  UFOFunction.h
//  ufo
//
//  Created by Programmieren on 29.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UFOFunction : NSObject

@property (readonly) NSString *name;

@property (readonly) BOOL publicFunction;
@property (readonly) BOOL staticFunction;

@property (readonly) UFODataType returnType;
@property (readonly) NSString *returnObjectClassName;

@property (readonly) NSArray *parameterNames;
@property (readonly) NSArray *parameterTypes;
@property (readonly) NSArray *parameterObjectClassNames;

@property (readonly) NSString *sourceCode;

+ (instancetype)createFunctionWithDictionary: (NSDictionary *)info;

- (BOOL)isValidMainFunction;

@end
