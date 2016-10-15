//
//  UFOScope.m
//  ufo
//
//  Created by Programmieren on 01.06.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "UFOScope.h"

@implementation UFOScope{
    NSUInteger currentLevel;
    
    NSMutableArray *variables;
    NSMutableArray *levels;
}

- (id)init{
    self = [super init];
    if (self) {
        _superScope = nil;
        
        currentLevel = 0;
        
        variables = [[NSMutableArray alloc] init];
        levels = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithSuperScope: (UFOScope *)superScope{
    self = [super init];
    if (self) {
        _superScope = superScope;
        
        currentLevel = 0;
        
        variables = [[NSMutableArray alloc] init];
        levels = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger)deepestLevel{
    return currentLevel;
}

- (void)addLevel{
    currentLevel++;
}

- (void)removeLevel{
    if (currentLevel == 0) {
        variables = [[NSMutableArray alloc] init];
        levels = [[NSMutableArray alloc] init];
        return;
    }
    
    for (NSInteger i = variables.count - 1; i >= 0; i--) {
        NSUInteger level = ((NSNumber*)levels[i]).unsignedIntegerValue;
        
        if (level == currentLevel) {
            [variables removeObjectAtIndex: i];
            [levels removeObjectAtIndex: i];
        }
    }
    
    currentLevel--;
}

- (NSUInteger)levelOfVariable: (UFOVariable *)variable
        countFromHighestScope: (BOOL)flag{
    NSUInteger index = [variables indexOfObject:variable];
    if (index == NSNotFound)
        return NSNotFound;
    
    NSUInteger level = ((NSNumber*)levels[index]).unsignedIntegerValue;
    
    if (flag) {
        UFOScope *superScope = _superScope;
        while (superScope) {
            level += superScope.deepestLevel + 1;
            superScope = superScope.superScope;
        }
    }
    
    return level;
}

- (NSUInteger)levelOfVariableNamed: (NSString *)variableName
             countFromHighestScope: (BOOL)flag{
    if (![self hasVariableNamed:variableName inSuperScopes:NO])
        return NSNotFound;
    
    return [self levelOfVariable: [self variableNamed:variableName]
           countFromHighestScope: flag];
}

- (BOOL)hasVariableNamed: (NSString *)variableName inSuperScopes:(BOOL)flag{
    for (UFOVariable *variable in variables)
        if ([variable.name isEqualToString: variableName])
            return YES;
    if (flag && _superScope)
        return [_superScope hasVariableNamed: variableName
                               inSuperScopes: YES];
    return NO;
}

- (UFOVariable *)variableNamed: (NSString *)variableName{
    NSMutableArray *resultVariables = [[NSMutableArray alloc] init];
    for (UFOVariable *variable in variables)
        if ([variable.name isEqualToString:variableName])
            [resultVariables addObject:variable];
    
    if (resultVariables.count < 1)
        return nil;
    
    NSInteger deepestLevel = -1;
    UFOVariable *variableWithDeepestLevel = nil;
    for (UFOVariable *variable in resultVariables) {
        if (deepestLevel < [self levelOfVariable:variable
                           countFromHighestScope:NO]) {
            deepestLevel = [self levelOfVariable:variable
                           countFromHighestScope:NO];
            variableWithDeepestLevel = variable;
        }
    }
    return variableWithDeepestLevel;
}

- (BOOL)addNewVariable: (UFOVariable *)variable{
    if ([self hasVariableNamed:variable.name inSuperScopes:NO]) {
        NSUInteger level = [self levelOfVariableNamed:variable.name
                                countFromHighestScope:NO];
        if (currentLevel == level)
            return NO;
    }
    
    [variables addObject:variable];
    [levels addObject:@(currentLevel)];
    return YES;
}

@end
