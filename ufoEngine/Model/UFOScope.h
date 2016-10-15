//
//  UFOScope.h
//  ufo
//
//  Created by Programmieren on 01.06.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UFOVariable.h"

@interface UFOScope : NSObject

@property (readonly) UFOScope *superScope;

- (id)initWithSuperScope: (UFOScope *)superScope;

- (NSUInteger)deepestLevel;
- (void)addLevel;
- (void)removeLevel;

- (NSUInteger)levelOfVariable: (UFOVariable *)variable countFromHighestScope: (BOOL)flag;
- (NSUInteger)levelOfVariableNamed: (NSString *)variableName countFromHighestScope: (BOOL)flag;

- (BOOL)hasVariableNamed: (NSString *)variableName inSuperScopes: (BOOL)flag;
- (UFOVariable *)variableNamed: (NSString *)variableName inSuperScopes: (BOOL)flag;

- (BOOL)addNewVariable: (UFOVariable *)variable;

@end
