//
//  NSString+UFOString.h
//  ufo
//
//  Created by Programmieren on 31.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UFOString)

- (BOOL)isBeginningUppercase;
- (BOOL)isBeginningLowercase;
- (BOOL)containsOnlyLetters;
- (BOOL)containsOnlyLettersAndCharactersFromString: (NSString*)characters;
- (BOOL)containsString: (NSString *)obj;
- (NSUInteger)numberOfOccurencesOfString: (NSString *)obj;

- (NSUInteger)lineNumberForIndex: (NSUInteger)index;

- (NSNumber *)getNumber;

- (BOOL)isBasicDataTypeSpecifier;

- (BOOL)isValidClassName;
- (BOOL)isValidFunctionName;
- (BOOL)isValidVariableName;

- (BOOL)typeIsPublic: (BOOL *)pub isStatic: (BOOL *)stat;
- (NSArray *)getArguments;

- (NSUInteger)nextOccurenceOfString: (NSString *)obj
                          fromIndex: (NSUInteger)index;
- (NSUInteger)nextOccurenceOfString: (NSString *)obj
                          fromIndex: (NSUInteger)index
              outsideQuotationMarks: (BOOL)oqm;
- (NSUInteger)endOfQuotationFromIndex: (NSUInteger)index;
- (NSString *)substringFrom: (NSUInteger)start
                         to: (NSUInteger)end;
- (NSUInteger)endOfLineFromIndex: (NSUInteger)start;
- (NSString *)substringToEndOfLineFromIndex: (NSUInteger)start;
- (NSString *)stringByRemovingComments;
- (NSString *)whitespaceTrimmedString;

@end
