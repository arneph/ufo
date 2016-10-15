//
//  UFOClassesController.m
//  ufo
//
//  Created by Programmieren on 29.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "UFOClassesController.h"

typedef enum{
    CodeContextOutsideClass,
    CodeContextInClassOutsideFunction,
    CodeContextInClassInFunction
}CodeContext;

@implementation UFOClassesController{
    NSMutableArray *classes;
}

+ (instancetype)createClassesControllerWithReader:(UFOReader *)reader{
    if (!reader) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    return [[UFOClassesController alloc] init];
}

- (id)initWithReader: (UFOReader *)reader {
    self = [super init];
    if (self) {
        _reader = reader;
        
        classes = [[NSMutableArray alloc] initWithCapacity:1];
        [classes addObject:[[UFOOutputClass alloc] init]];
    }
    return self;
}

- (NSArray *)classes{
    return [NSArray arrayWithArray:classes];
}

- (BOOL)hasClassNamed:(NSString *)className{
    for (UFOClass *class in classes) {
        if ([class.className isEqualToString:className])
            return YES;
    }
    return NO;
}

- (UFOClass *)classNamed:(NSString *)className{
    for (UFOClass *class in classes) {
        if ([class.className isEqualToString:className])
            return class;
    }
    return nil;
}

- (UFOClass *)loadClassNamed:(NSString *)name
                    inFolder:(NSString *)folder
         failureExplaination:(NSString *__autoreleasing *)explaination{
    if (!name || [name isEqualToString:@""] || ![_reader containsFileNamed:name inFolder:folder]) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    
    NSString *sourceCode = [_reader getContentsOfFileNamed:name inFolder:folder];
    
    if ([sourceCode isEqualToString:@""]) {
        *explaination = @"There is no source code.";
        return nil;
    }
    
    if ([self hasClassNamed:name]) {
        return [self classNamed:name];
    }
    
    NSString *className;
    NSString *superClassName;
    NSMutableArray *usedItems = [[NSMutableArray alloc] init];
    NSMutableArray *expectedItems = [[NSMutableArray alloc] init];
    
    UFOClass *superClass;
    NSMutableArray *referencedClasses = [[NSMutableArray alloc] init];
    
    NSMutableArray *functionNames = [[NSMutableArray alloc] init];
    NSMutableArray *functions = [[NSMutableArray alloc] init];
    
    CodeContext context = CodeContextOutsideClass;
    NSUInteger curlyBracesCount = 0;
    NSUInteger bracketsCount = 0;
    
    sourceCode = [sourceCode stringByRemovingComments];
    
    for (NSUInteger i = 0; i < sourceCode.length; i++) {
        NSString *character = [sourceCode substringWithRange:NSMakeRange(i, 1)];
        NSString *nextCharacter = (i < sourceCode.length - 1) ? [sourceCode substringWithRange:NSMakeRange(i + 1, 1)] : nil;
        NSUInteger lineNumber = [sourceCode lineNumberForIndex:i];
        
        if ([character isEqualToString:@"\""]) {
            NSUInteger endOfQuotation = [sourceCode endOfQuotationFromIndex:i];
            
            if (endOfQuotation == NSNotFound) {
                *explaination = [NSString stringWithFormat:@"A string (\"...\") in line %i is never closed.", (int)lineNumber];
                return nil;
            }else{
                i = endOfQuotation;
                continue;
            }
            
        }else if (context == CodeContextOutsideClass) {
            if ([character isEqualToString:@"u"] && i < sourceCode.length - 6) {
                if ([[sourceCode substringWithRange:NSMakeRange(i, 5)] isEqualToString:@"uses "]) {
                    NSString *usedItem = [sourceCode substringToEndOfLineFromIndex:i + 5];
                    usedItem = usedItem.whitespaceTrimmedString;
                    
                    if ([usedItem isEqualToString:@""]) {
                        *explaination = [NSString stringWithFormat:@"A uses statement in line %i has no argument.", (int)lineNumber];
                        return nil;
                    }else if (![usedItem containsOnlyLettersAndCharactersFromString:@"."]) {
                        *explaination = [NSString stringWithFormat:@"A uses statement in line %i has an invalid argument.", (int)lineNumber];
                        return nil;
                    }
                    
                    [usedItems addObject:usedItem];
                    i = [sourceCode endOfLineFromIndex:i + 5];
                    if (i == NSNotFound) break;
                }else{
                    *explaination = [NSString stringWithFormat:@"Syntax error in line %i.", (int)lineNumber];
                    return nil;
                }
            }else if ([character isEqualToString:@"c"] && i < sourceCode.length - 7) {
                if ([[sourceCode substringWithRange:NSMakeRange(i, 6)] isEqualToString:@"class "]) {
                    NSUInteger nextOpeningCurlyBraceIndex = [sourceCode nextOccurenceOfString:@"{"
                                                                                    fromIndex:i];
                    
                    if (nextOpeningCurlyBraceIndex == NSNotFound) {
                        *explaination = [NSString stringWithFormat:@"A class defined in line%i has no body.", (int)lineNumber];
                        return nil;
                    }
                    
                    NSString *classInformation = [sourceCode substringFrom:i + 6
                                                                        to:nextOpeningCurlyBraceIndex];
                    classInformation = [classInformation whitespaceTrimmedString];
                    
                    if ([classInformation isEqualToString:@""]) {
                        *explaination = [NSString stringWithFormat:@"A class defined in line%i has no name.", (int)lineNumber];
                        return nil;
                    }else if ([classInformation numberOfOccurencesOfString:@":"] > 1) {
                        *explaination = [NSString stringWithFormat:@"A class definition in line%i includes a syntax error.", (int)lineNumber];
                        return nil;
                    }
                    
                    if (![classInformation containsString:@":"]) {
                        className = classInformation;
                    }else{
                        className = [classInformation substringToIndex:[classInformation rangeOfString:@":"].location];
                        className = [className whitespaceTrimmedString];
                        
                        superClassName = [classInformation substringFromIndex:[classInformation rangeOfString:@":"].location + 1];
                        superClassName = [superClassName whitespaceTrimmedString];
                    }
                    
                    if (![className isValidClassName]) {
                        *explaination = [NSString stringWithFormat:@"A class defined in line %i has an invalid name.", (int)lineNumber];
                        return nil;
                    }else if (![className isEqualToString:name]) {
                        *explaination = [NSString stringWithFormat:@"The defined class doesn't match the file name."];
                        return nil;
                    }
                    if (superClassName) {
                        if (![superClassName isValidClassName]) {
                            *explaination = [NSString stringWithFormat:@"A class defined in line %i has an invalid super class name.", (int)lineNumber];
                            return nil;
                        }
                        
                        if (![expectedItems containsObject:superClassName])
                            [expectedItems addObject:superClassName];
                    }
                    
                    context = CodeContextInClassOutsideFunction;
                    curlyBracesCount = 1;
                    i = nextOpeningCurlyBraceIndex;
                }else{
                    *explaination = [NSString stringWithFormat:@"Syntax error in line %i.", (int)lineNumber];
                    return nil;
                }
            }else if (![character isEqualToString:@"\n"] && ![character isEqualToString:@" "]) {
                *explaination = [NSString stringWithFormat:@"Syntax error in line %i.", (int)lineNumber];
                return nil;
            }
            
        }else if (context == CodeContextInClassOutsideFunction) {
            if ([character isEqualToString:@"}"]) {
                curlyBracesCount--;
                context = CodeContextOutsideClass;
            }else if ([character isEqualToString:@"p"]
                      || [character isEqualToString:@"s"]
                      || [character isEqualToString:@"d"]
                      || [character isEqualToString:@"f"]) {
                BOOL publicFunc;
                BOOL staticFunc;
                if (i < sourceCode.length - 20 && [[sourceCode substringFrom:i to:i + 19] isEqualToString:@"public static func "]) {
                    publicFunc = YES;
                    staticFunc = YES;
                    i += 19;
                }else if (i < sourceCode.length - 21 && [[sourceCode substringFrom:i to:i + 20] isEqualToString:@"private static func "]) {
                    publicFunc = NO;
                    staticFunc = YES;
                    i += 20;
                }else if (i < sourceCode.length - 21 && [[sourceCode substringFrom:i to:i + 20] isEqualToString:@"public dynamic func "]) {
                    publicFunc = YES;
                    staticFunc = NO;
                    i += 20;
                }else if (i < sourceCode.length - 22 && [[sourceCode substringFrom:i to:i + 21] isEqualToString:@"private dynamic func "]) {
                    publicFunc = NO;
                    staticFunc = NO;
                    i += 21;
                }else if (i < sourceCode.length - 13 && [[sourceCode substringFrom:i to:i + 12] isEqualToString:@"public func "]) {
                    publicFunc = YES;
                    staticFunc = NO;
                    i += 12;
                }else if (i < sourceCode.length - 14 && [[sourceCode substringFrom:i to:i + 13] isEqualToString:@"private func "]) {
                    publicFunc = NO;
                    staticFunc = NO;
                    i += 13;
                }else if (i < sourceCode.length - 13 && [[sourceCode substringFrom:i to:i + 12] isEqualToString:@"static func "]) {
                    publicFunc = NO;
                    staticFunc = YES;
                    i += 12;
                }else if (i < sourceCode.length - 14 && [[sourceCode substringFrom:i to:i + 13] isEqualToString:@"dynamic func "]) {
                    publicFunc = NO;
                    staticFunc = NO;
                    i += 13;
                }else if (i < sourceCode.length - 6 && [[sourceCode substringFrom:i to:i + 5] isEqualToString:@"func "]) {
                    publicFunc = NO;
                    staticFunc = NO;
                    i += 5;
                }else{
                    *explaination = [NSString stringWithFormat:@"Syntax error in line %i.", (int)lineNumber];
                    return nil;
                }
                
                NSUInteger nextOpeningBracket = [sourceCode nextOccurenceOfString:@"("
                                                                        fromIndex:i];
                if (nextOpeningBracket == NSNotFound) {
                    *explaination = [NSString stringWithFormat:@"Syntax error in line %i.", (int)lineNumber];
                    return nil;
                }
                
                NSString *functionName = [sourceCode substringFrom:i
                                                                to:nextOpeningBracket];
                functionName = [functionName whitespaceTrimmedString];
                if (![functionName isValidFunctionName]) {
                    *explaination = [NSString stringWithFormat:@"A function declared in line %i has an invalid name.", (int)lineNumber];
                    return nil;
                }else if ([functionNames containsObject:functionName]) {
                    *explaination = [NSString stringWithFormat:@"The function named %@ is declared again in line %i.", functionName, (int)lineNumber];
                    return nil;
                }
                [functionNames addObject:functionName];
                
                NSUInteger nextClosingBracket = [sourceCode rangeOfString:@")"
                                                                  options:0
                                                                    range:NSMakeRange(nextOpeningBracket, sourceCode.length - nextOpeningBracket)].location;
                if (nextClosingBracket == NSNotFound) {
                    *explaination = [NSString stringWithFormat:@"Syntax error in line %i.", (int)lineNumber];
                    return nil;
                }
                
                NSString *parametersInformation = [sourceCode substringFrom:nextOpeningBracket + 1 to:nextClosingBracket];
                
                NSUInteger nextArrow = [sourceCode nextOccurenceOfString:@"->"
                                                               fromIndex:nextClosingBracket
                                                   outsideQuotationMarks:YES];
                NSUInteger nextOpeningCurlyBrace = [sourceCode nextOccurenceOfString:@"{"
                                                                           fromIndex:nextClosingBracket
                                                               outsideQuotationMarks:YES];
                
                BOOL hasReturnValue;
                NSString *returnType = nil;
                if (nextArrow == NSNotFound || nextArrow > nextOpeningBracket) {
                    hasReturnValue = NO;
                }else{
                    hasReturnValue = YES;
                    returnType = [sourceCode substringFrom:nextArrow + 2 to:nextOpeningCurlyBrace];
                    returnType = [returnType whitespaceTrimmedString];
                    
                    if ([returnType isEqualToString:@""] || ![returnType isValidClassName]) {
                        *explaination = [NSString stringWithFormat:@"A function declared in line %i has an invalid return value.", (int)lineNumber];
                        return nil;
                    }else if (![expectedItems containsObject: returnType]) {
                        [expectedItems addObject: returnType];
                    }
                }
                
                NSMutableArray *parameterNames = [[NSMutableArray alloc] init];
                NSMutableArray *parameterTypes = [[NSMutableArray alloc] init];
                
                for (NSString *param in [parametersInformation componentsSeparatedByString:@","]) {
                    NSString *parameter = [param whitespaceTrimmedString];
                    if ([parameter isEqualToString:@""]) {
                        if ([parametersInformation componentsSeparatedByString:@","].count < 2) {
                            break;
                        }else{
                            *explaination = [NSString stringWithFormat:@"A function defined in line %i has an invalid parameter.", (int)lineNumber];
                            return nil;
                        }
                    }else{
                        if ([param numberOfOccurencesOfString:@" "] != 1) {
                            *explaination = [NSString stringWithFormat:@"A function defined in line %i has an invalid parameter.", (int)lineNumber];
                            return nil;
                        }
                        
                        NSString *parameterName, *parameterType;
                        
                        parameterType = [param componentsSeparatedByString:@" "][0];
                        parameterName = [param componentsSeparatedByString:@" "][1];
                        
                        if (![parameterName isValidVariableName]
                            || [parameterNames containsObject:parameterName]) {
                            *explaination = [NSString stringWithFormat:@"A function defined in line %i has an invalid parameter name.", (int)lineNumber];
                            return nil;
                        }
                        if (![parameterType isValidClassName]) {
                            *explaination = [NSString stringWithFormat:@"A function defined in line %i has an invalid parameter type.", (int)lineNumber];
                            return nil;
                        }else if (![expectedItems containsObject:parameterType]) {
                            [expectedItems addObject: parameterType];
                        }
                        
                        [parameterNames addObject: parameterName];
                        [parameterTypes addObject: parameterType];
                    }
                }
                
                if (nextOpeningCurlyBrace == NSNotFound) {
                    *explaination = [NSString stringWithFormat:@"A function defined in line%i has no body.", (int)lineNumber];
                    return nil;
                }
                
                i = nextOpeningCurlyBrace + 1;
                context = CodeContextInClassInFunction;
                curlyBracesCount = 2;
                
                while (i < sourceCode.length) {
                    character = [sourceCode substringWithRange:NSMakeRange(i, 1)];
                    nextCharacter = (i < sourceCode.length - 1) ? [sourceCode substringWithRange:NSMakeRange(i + 1, 1)] : nil;
                    lineNumber = [[sourceCode substringToIndex:i] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]].count;
                    
                    if ([character isEqualToString:@"\""]) {
                        if (i == sourceCode.length - 1) {
                            *explaination = [NSString stringWithFormat:@"A string (\"...\") in line %i is never closed.", (int)lineNumber];
                            return nil;
                        }
                        NSUInteger closingQuoteMarkIndex = [sourceCode nextOccurenceOfString:@"\"" fromIndex:i + 1];
                        
                        while (closingQuoteMarkIndex != NSNotFound
                               &&[[sourceCode substringWithRange:NSMakeRange(closingQuoteMarkIndex - 1, 1)] isEqualToString:@"\\"]) {
                            
                            closingQuoteMarkIndex = [sourceCode nextOccurenceOfString:@"\""
                                                                            fromIndex:closingQuoteMarkIndex + 1];
                        }
                        
                        if (closingQuoteMarkIndex == NSNotFound) {
                            *explaination = [NSString stringWithFormat:@"A string (\"...\" in line %i is never closed.", (int)lineNumber];
                            return nil;
                        }else {
                            i = closingQuoteMarkIndex + 1;
                            continue;
                        }
                        
                    }else if ([character isEqualToString:@"("]) {
                        bracketsCount++;
                    }else if ([character isEqualToString:@")"]) {
                        bracketsCount--;
                    }else if ([character isEqualToString:@"{"]) {
                        curlyBracesCount++;
                    }else if ([character isEqualToString:@"}"]) {
                        curlyBracesCount--;
                        if (curlyBracesCount == 1 && bracketsCount == 0) {
                            context = CodeContextInClassOutsideFunction;
                            break;
                        }
                    }
                    i++;
                }
                if (context == CodeContextInClassInFunction) {
                    lineNumber = [sourceCode lineNumberForIndex:nextOpeningCurlyBrace];
                    *explaination = [NSString stringWithFormat:@"A function defined in line%i has body that is never closed.", (int)lineNumber];
                    return nil;
                }
                
                NSString *functionSourceCode = [sourceCode substringFrom:nextOpeningCurlyBrace + 1 to:i - 1];
                
                NSDictionary *info = @{@"name": functionName,
                                       @"publicFunction" : @(publicFunc),
                                       @"staticFunction" : @(staticFunc),
                                       @"returnType" : returnType,
                                       @"parameterNames" : [NSArray arrayWithArray:parameterNames],
                                       @"parameterTypes" : [NSArray arrayWithArray:parameterTypes],
                                       @"sourceCode" : functionSourceCode};
                UFOFunction *function = [UFOFunction createFunctionWithDictionary: info];
                [functions addObject: function];
                
            }else if (![character isEqualToString:@"\n"] && ![character isEqualToString:@" "]) {
                *explaination = [NSString stringWithFormat:@"Syntax error in line %i.", (int)lineNumber];
                return nil;
            }
        }
    }
    
    if (context == CodeContextInClassOutsideFunction) {
        *explaination = [NSString stringWithFormat:@"A class never gets closed."];
        return nil;
    }else if (context == CodeContextInClassInFunction) {
        *explaination = [NSString stringWithFormat:@"A function never gets closed."];
        return nil;
    }
    
    for (NSString *usedItem in usedItems) {
        NSString *item = [usedItem stringByReplacingOccurrencesOfString:@"." withString:@"/"];
        NSString *lastPathComponent = item.lastPathComponent;
        
        if (lastPathComponent.length > 0
            && [lastPathComponent isBeginningUppercase]) {
            for (NSInteger i = expectedItems.count - 1; i >= 0; i--) {
                if ([lastPathComponent isEqualToString:expectedItems[i]]) {
                    [expectedItems removeObjectAtIndex:i];
                }
            }
            
            UFOClass *referencedClass = [self classNamed:lastPathComponent];
            
            if (!referencedClass) {
                if (![_reader containsFileNamed:lastPathComponent
                                       inFolder:item.stringByDeletingLastPathComponent]) {
                    *explaination = [NSString stringWithFormat:@"A referenced item could't been loaded."];
                    return nil;
                }
                
                referencedClass = [self loadClassNamed:lastPathComponent
                                              inFolder:item.stringByDeletingLastPathComponent
                                   failureExplaination:explaination];
            }
            
            if (*explaination) {
                *explaination = [NSString stringWithFormat:@"The referenced class: %@ couldn't be loaded: %@", lastPathComponent, *explaination];
                return nil;
            }
            
            [referencedClasses addObject:referencedClass];
            if (superClassName && [referencedClass.className isEqualToString:superClassName]) {
                superClass = referencedClass;
            }
        }
    }
    
    if (expectedItems.count == 1) {
        *explaination = [NSString stringWithFormat:@"The expected object: %@ wasn't referenced.", expectedItems[0]];
        return nil;
    }else if (expectedItems.count > 1) {
        *explaination = [NSString stringWithFormat:@"The expected objects: %@ weren't referenced.",
                                                   [expectedItems componentsJoinedByString:@", "]];
        return nil;
    }
    
    UFOClass *newClass = [[UFOClass alloc] initWithClassName:className
                                                  superClass:superClass
                                           referencedClasses:[NSArray arrayWithArray: referencedClasses]];
    for (UFOFunction *function in functions) {
        [newClass addFunction:function];
    }
    
    [classes addObject:newClass];
    
    return newClass;
}

-(UFOOutputClass *)outputClass{
    return (UFOOutputClass*)[self classNamed:@"UFOOutput"];
}

@end
