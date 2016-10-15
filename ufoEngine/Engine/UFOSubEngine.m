//
//  UFOSubEngine.m
//  ufo
//
//  Created by Programmieren on 30.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "UFOSubEngine.h"

@implementation UFOSubEngine

- (id)init{
    self = [super init];
    if (self) {
        _startClass = nil;
        _startFunction = nil;
        _startArguments = nil;
        
        _currentClass = nil;
        _currentFunction = nil;
        _currentArguments = nil;
        
        _subEngineStatus = UFOSubEngineReady;
        _crashMessage = nil;
    }
    return self;
}

- (id)initWithFunction:(UFOFunction *)startFunction
               inClass:(UFOClass *)startClass
             arguments:(NSArray *)arguments{
    self = [super init];
    if (self) {
        _startClass = startClass;
        _startFunction = startFunction;
        _startArguments = arguments;
        
        _currentClass = nil;
        _currentFunction = nil;
        _currentArguments = nil;
        
        _subEngineStatus = UFOSubEngineReady;
        _crashMessage = nil;
    
        if (!_startClass || !_startFunction || !_startArguments) {
            @throw NSInvalidArgumentException;
            return nil;
        }
    }
    return self;
}

- (void)start{
    if (!_startClass || !_startFunction || !_startArguments) return;
    
    _subEngineStatus = UFOSubEngineRunning;
    [self notifyDelegateAboutStatusChange];
    
    id returnValue;
    
    [self executeFunction:_startFunction
                  inClass:_startClass
          parameterValues:@[]
              returnValue:&returnValue];
    if ([_operation isCancelled]) {
        return;
    }
    
    if (_subEngineStatus == UFOSubEngineRunning) {
        _subEngineStatus = UFOSubEngineTerminated;
        [self notifyDelegateAboutStatusChange];
    }
}

- (void)notifyDelegateAboutStatusChange{
    if (!_delegate) return;
    [_delegate subEngineStatusChanged: self];
}

- (void)crashed: (NSString *)message{
    _crashMessage = message;
    
    [_operation cancel];
    
    _subEngineStatus = UFOSubEngineCrashed;
    [self notifyDelegateAboutStatusChange];
}

- (void)executeFunction: (UFOFunction *)function
                inClass: (UFOClass *)class
        parameterValues: (NSArray *)parameterValues
            returnValue: (id *)returnValue {
    if ([[NSThread currentThread] isCancelled]) {
        return;
    }
    
    _currentClass = class;
    _currentFunction = function;
    _currentArguments = parameterValues;
    
    if ([[class class] isSystemClass]
        && function.staticFunction) {
        UFOSystemClass *systemClass = (UFOSystemClass *)class;
        
        [systemClass performFunction: function.name
                           arguments: parameterValues
                         returnValue: returnValue];
        return;
    }
    
    UFOScope *functionScope = [[UFOScope alloc] init];
    
    NSString *sourceCode = function.sourceCode;
    
    for (NSUInteger i = 0; i < sourceCode.length; i++) {
        NSString *Byteacter = [sourceCode substringWithRange:NSMakeRange(i, 1)];
        NSString *nextCharacter = (i < sourceCode.length - 1) ? [sourceCode substringWithRange:NSMakeRange(i + 1, 1)] : nil;
        
        if ([_operation isCancelled]) {
            return;
        }
        
        if ([[Byteacter stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
            continue;
        
        if ([Byteacter isBeginningLowercase]) {
            NSUInteger nextSpaceIndex = [sourceCode nextOccurenceOfString:@" "
                                                                 fromIndex:i
                                                    outsideQuotationMarks:YES];
            if (nextSpaceIndex != NSNotFound) {
                NSString *firstElement = [sourceCode substringFrom:i
                                                                to:nextSpaceIndex];
                if ([firstElement isBasicDataTypeSpecifier]) {
                    NSUInteger nextSemicolonIndex = [sourceCode nextOccurenceOfString:@";"
                                                                            fromIndex:i
                                                                outsideQuotationMarks:YES];
                    if (nextSemicolonIndex == NSNotFound) {
                        [self crashed: @"A variable definition statement doesn't end with a semicolon."];
                        return;
                    }else{
                        [self defineVariable: [sourceCode substringFrom:i
                                                                     to:nextSemicolonIndex]
                                     inScope: functionScope
                          classNameValidated: ^BOOL (NSString *className){
                              if (![className isValidClassName])
                                  return NO;
                              if (![class referencedClassNamed:className])
                                  return NO;
                              return YES;
                          }];
                        i = nextSemicolonIndex;
                        continue;
                    }
                }
            }
        }
        
        
        if ([Byteacter isBeginningUppercase]) {
            NSUInteger nextDotIndex = [sourceCode nextOccurenceOfString:@"."
                                                              fromIndex:i];
            if (nextDotIndex == NSNotFound) {
                [self crashed: @"A class function call has no specified function."];
                return;
            }
            
            NSString *className = [sourceCode substringFrom:i to:nextDotIndex];
            if (![class hasReferencedClassNamed:className]) {
                [self crashed: @"A class function of an unknown class is called."];
                return;
            }
            UFOClass *referencedClass = [class referencedClassNamed:className];
            
            NSUInteger nextOpeningBracketIndex = [sourceCode nextOccurenceOfString:@"(" fromIndex:i];
            if (nextOpeningBracketIndex == NSNotFound) {
                [self crashed: @"A class function call has no arguments."];
                return;
            }
            NSString *functionName = [sourceCode substringFrom:nextDotIndex + 1
                                                            to:nextOpeningBracketIndex];
            if (![referencedClass hasFunctionNamed:functionName]) {
                [self crashed: @"A class function call is made to an unknown function."];
                return;
            }
            UFOFunction *referencedFunction = [referencedClass functionNamed:functionName];
            if (!referencedFunction.publicFunction || !referencedFunction.staticFunction) {
                [self crashed: @"A class function call is made to a function that's not public and static."];
                return;
            }
            
            NSUInteger nextClosingBracketIndex = [sourceCode nextOccurenceOfString:@")"
                                                                         fromIndex:i
                                                             outsideQuotationMarks:YES];
            if (nextClosingBracketIndex == NSNotFound) {
                [self crashed: @"A class function call has no arguments."];
                return;
            }
            NSArray *arguments = [sourceCode substringFrom:nextOpeningBracketIndex + 1
                                                        to:nextClosingBracketIndex].getArguments;
            if (arguments.count != referencedFunction.parameterNames.count) {
                [self crashed: @"The amount of arguments passed to a class function is invalid."];
                return;
            }
            
            NSUInteger nextSemicolonIndex = [sourceCode nextOccurenceOfString:@";"
                                                                    fromIndex:nextClosingBracketIndex];
            if (nextSemicolonIndex == NSNotFound
                || ![[sourceCode substringFrom:nextClosingBracketIndex + 1
                                            to:nextSemicolonIndex].whitespaceTrimmedString isEqualToString:@""]) {
                [self crashed: @"A class function call is not closed as expected by a semicolon."];
                return;
            }
            
            if (referencedFunction.parameterNames.count < 1) {
                [self executeFunction: referencedFunction
                              inClass: referencedClass
                      parameterValues: @[]
                          returnValue: NULL];
            }else{
                arguments = [self validateArguments:arguments
                                     parameterTypes:referencedFunction.parameterTypes
                          parameterObjectClassNames:referencedFunction.parameterObjectClassNames
                                 replacingVariables:^NSString * (NSString *varName) {
                    return nil;
                }];
                if (!arguments) {
                    [self crashed: @"The arguments passed to a class function arn't valid."];
                    return;
                }
                
                [self executeFunction: referencedFunction
                              inClass: referencedClass
                      parameterValues: arguments
                          returnValue: NULL];
            }
            _currentClass = class;
            _currentFunction = function;
            _currentArguments = arguments;
            
            i = nextSemicolonIndex;
        }
    }
}

- (NSArray *)validateArguments: (NSArray *)arguments
                parameterTypes: (NSArray *)parameterTypes
     parameterObjectClassNames: (NSArray *)parameterObjectClassNames
            replacingVariables: (NSString* (^)(NSString *varName))varReplacer{
    NSMutableArray *resultArguments = [[NSMutableArray alloc] initWithCapacity:arguments.count];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    [formatter setRoundingMode:NSNumberFormatterRoundDown];
    
    for (NSUInteger i = 0; i < arguments.count; i++) {
        NSString *argument = arguments[i];
        argument = [argument whitespaceTrimmedString];
        if ([argument isEqualToString:@""])
            return nil;
        
        NSNumber *argumentAsNumber = [formatter numberFromString:argument];
        
        UFODataType parameterType = (UFODataType)((NSNumber *)parameterTypes[i]).unsignedIntegerValue;
        if (parameterType == UFODataTypeVoid || parameterType == UFODataTypeUnknown)
            return nil;
        if (parameterType == UFODataTypeBoolean) {
            if ([argument isEqualToString:@"false"]
                || [argument isEqualToString:@"true"]) {
                [resultArguments addObject:argument];
            }else if (argumentAsNumber) {
                if ([argumentAsNumber isEqualToNumber:@0]) {
                    [resultArguments addObject:@"false"];
                }else{
                    [resultArguments addObject:@"true"];
                }
            }else{
                argument = varReplacer(argument);
                if (!argument)
                    return nil;
                [resultArguments addObject:argument];
            }
        }else if (parameterType == UFODataTypeInteger) {
            if (argumentAsNumber) {
                [resultArguments addObject:argument];
            }else{
                argument = varReplacer(argument);
                if (!argument)
                    return nil;
                [resultArguments addObject:argument];
            }
        }
    }
    
    return [NSArray arrayWithArray: resultArguments];
}

- (void)defineVariable: (NSString *)definitionStatement
               inScope: (UFOScope *)scope
    classNameValidated: (BOOL (^)(NSString *className))validator {
    NSUInteger firstSpaceIndex = [definitionStatement nextOccurenceOfString:@" "
                                                                  fromIndex:0
                                                      outsideQuotationMarks:YES];
    if (firstSpaceIndex == NSNotFound) {
        [self crashed: @"A variable definiton failed."];
        return;
    }
    
    NSString *typeString = [definitionStatement substringFrom:0 to:firstSpaceIndex];
    UFODataType variableType;
    NSString *objectClassName;
    
    variableType = dataTypeFromString(typeString, &objectClassName);
    
    if (variableType == UFODataTypeUnknown) {
        [self crashed: @"A variable gets defined with an unknown type."];
        return;
    }else if (variableType == UFODataTypeVoid) {
        [self crashed: @"Attemted to define a variable of type void."];
        return;
    }else if (variableType == UFODataTypeObject
              && (![objectClassName isValidClassName]
                  || !validator(objectClassName))) {
        [self crashed: @"Attemted to define an instance variable of an unknown class."];
        return;
    }
    
    NSUInteger equalSignIndex = [definitionStatement nextOccurenceOfString:@"="
                                                                 fromIndex:0
                                                     outsideQuotationMarks:YES];
    NSString *variableName;
    if (equalSignIndex == NSNotFound) {
        variableName = [definitionStatement substringFromIndex:firstSpaceIndex + 1];
    }else{
        variableName = [definitionStatement substringFrom:firstSpaceIndex + 1
                                                       to:equalSignIndex];
    }
    variableName = [variableName whitespaceTrimmedString];
    
    if (![variableName isValidVariableName]) {
        [self crashed: @"Attemted to define a variable with an invalid name."];
        return;
    }else if ([scope hasVariableNamed:variableName inSuperScopes:NO]
              && [scope levelOfVariableNamed:variableName countFromHighestScope:NO] == scope.deepestLevel){
        [self crashed: @"Attemted to define two variables with the same name in the same scope."];
        return;
    }
    
    UFOVariable *variable;
    if (variableType == UFODataTypeBoolean) {
        variable = [[UFOBooleanVariable alloc] initVariableNamed:variableName];
    }else if (variableType == UFODataTypeChar) {
        variable = [[UFOCharVariable alloc] initVariableNamed:variableName];
    }else if (variableType == UFODataTypeByte) {
        variable = [[UFOByteVariable alloc] initVariableNamed:variableName];
    }else if (variableType == UFODataTypeInteger) {
        variable = [[UFOIntegerVariable alloc] initVariableNamed:variableName];
    }else if (variableType == UFODataTypeUnsignedInteger) {
        variable = [[UFOUnsignedIntegerVariable alloc] initVariableNamed:variableName];
    }else if (variableType == UFODataTypeLong) {
        variable = [[UFOLongVariable alloc] initVariableNamed:variableName];
    }else if (variableType == UFODataTypeFloat) {
        variable = [[UFOFloatVariable alloc] initVariableNamed:variableName];
    }else if (variableType == UFODataTypeDouble) {
        variable = [[UFODoubleVariable alloc] initVariableNamed:variableName];
    }else if (variableType == UFODataTypeObject) {
        variable = [[UFOObjectVariable alloc] initVariableNamed:variableName
                                                objectClassName:objectClassName];
    }
    
    [scope addNewVariable: variable];
    
    if ([scope levelOfVariable:variable countFromHighestScope:NO] == NSNotFound) {
        [self crashed: @"Couldn't define variable."];
        return;
    }
}

@end
