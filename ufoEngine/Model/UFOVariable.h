//
//  UFOVariable.h
//  ufo
//
//  Created by Programmieren on 01.06.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UFOVariable : NSObject

@property (readonly) NSString *name;

@property (readonly) id currentValue;
@property (readonly) UFODataType variableType;

@property (readonly) BOOL publicVariable;
@property (readonly) BOOL staticVariable;

- (id)initVariableNamed: (NSString *)name;
- (id)initVariableNamed: (NSString *)name public: (BOOL)pub static: (BOOL)stat;

- (BOOL)setCurrentValue: (id)value;

+ (UFODataType)variableType;

@end
