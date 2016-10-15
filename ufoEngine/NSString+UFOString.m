//
//  NSString+UFOString.m
//  ufo
//
//  Created by Programmieren on 31.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "NSString+UFOString.h"

@implementation NSString (UFOString)
const NSNumberFormatter *formatter;

- (BOOL)isBeginningUppercase{
    if (self.length < 1) return NO;
    return [[self substringToIndex:1] isEqualToString:[self substringToIndex:1].uppercaseString];
}

- (BOOL)isBeginningLowercase{
    if (self.length < 1) return NO;
    return [[self substringToIndex:1] isEqualToString:[self substringToIndex:1].lowercaseString];
}

- (BOOL)containsOnlyLetters{
    return [self rangeOfCharacterFromSet:[[NSCharacterSet letterCharacterSet] invertedSet]].location == NSNotFound;
}

- (BOOL)containsOnlyLettersAndCharactersFromString: (NSString*)characters{
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet characterSetWithCharactersInString:characters];
    [characterSet formUnionWithCharacterSet:[NSCharacterSet letterCharacterSet]];
    return [self rangeOfCharacterFromSet:[characterSet invertedSet]].location == NSNotFound;
}

- (BOOL)containsString: (NSString *)obj{
    if (!obj || obj.length < 1) return NO;
    return [self rangeOfString:obj].location != NSNotFound;
}

- (NSUInteger)numberOfOccurencesOfString: (NSString *)obj{
    if (!obj || obj.length < 1) return NSNotFound;
    return [self componentsSeparatedByString:obj].count - 1;
}

- (NSUInteger)lineNumberForIndex:(NSUInteger)index{
    return [[self substringToIndex:index] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]].count;
}

- (NSNumber *)getNumber{
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
        [formatter setRoundingMode:NSNumberFormatterRoundDown];
    }

    return [formatter numberFromString:self];
}

- (BOOL)isBasicDataTypeSpecifier{
    if ([self.whitespaceTrimmedString isEqualToString:@"bool"]
        || [self.whitespaceTrimmedString isEqualToString:@"char"]
        || [self.whitespaceTrimmedString isEqualToString:@"byte"]
        || [self.whitespaceTrimmedString isEqualToString:@"int"]
        || [self.whitespaceTrimmedString isEqualToString:@"uint"]
        || [self.whitespaceTrimmedString isEqualToString:@"long"]
        || [self.whitespaceTrimmedString isEqualToString:@"float"]
        || [self.whitespaceTrimmedString isEqualToString:@"double"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isValidClassName{
    if ([self isEqualToString:@""]
        || ![self containsOnlyLetters]
        || ![self isBeginningUppercase]) {
        return NO;
    }
    return YES;
}

- (BOOL)isValidFunctionName{
    if ([self isEqualToString:@""]
        || ![self containsOnlyLetters]
        || ![self isBeginningLowercase]) {
        return NO;
    }
    return YES;
}

- (BOOL)isValidVariableName{
    if ([self isEqualToString:@""]
        || ![self containsOnlyLetters]
        || ![self isBeginningLowercase]
        || [self isBasicDataTypeSpecifier]) {
        return NO;
    }
    return YES;
}

- (BOOL)typeIsPublic:(BOOL *)pub isStatic:(BOOL *)stat{
    if ([self.whitespaceTrimmedString isEqualToString:@">+"]) {
        *pub = YES;
        *stat = YES;
    }else if ([self.whitespaceTrimmedString isEqualToString:@">-"]) {
        *pub = YES;
        *stat = NO;
    }else if ([self.whitespaceTrimmedString isEqualToString:@"+"]) {
        *pub = NO;
        *stat = YES;
    }else if ([self.whitespaceTrimmedString isEqualToString:@"-"]) {
        *pub = NO;
        *stat = NO;
    }else{
        return NO;
    }
    return YES;
}

- (NSArray *)getArguments{
    if ([self.whitespaceTrimmedString isEqualToString:@""]) return @[];
    if ([self numberOfOccurencesOfString:@","] < 1) return @[self.whitespaceTrimmedString];
    
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSInteger lastCommaIndex = -1;
    NSUInteger nextCommaIndex = [self nextOccurenceOfString:@","
                                                  fromIndex:0
                                      outsideQuotationMarks:YES];
    while (nextCommaIndex != NSNotFound) {
        NSString *argument = [self substringFrom:lastCommaIndex + 1 to:nextCommaIndex];
        [arguments addObject: argument.whitespaceTrimmedString];
        
        lastCommaIndex = nextCommaIndex;
        nextCommaIndex = [self nextOccurenceOfString:@","
                                           fromIndex:nextCommaIndex + 1
                               outsideQuotationMarks:YES];
    }
    [arguments addObject:[self substringFromIndex: lastCommaIndex + 1].whitespaceTrimmedString];
    
    return [NSArray arrayWithArray:arguments];
}

- (NSUInteger)nextOccurenceOfString: (NSString *)obj
                          fromIndex: (NSUInteger)index{
    if (index > self.length - obj.length) return NSNotFound;
    return [self rangeOfString:obj
                       options:0
                         range:NSMakeRange(index, self.length - index)].location;
}

- (NSUInteger)nextOccurenceOfString:(NSString *)obj fromIndex:(NSUInteger)index outsideQuotationMarks:(BOOL)oqm{
    if (!oqm) return [self nextOccurenceOfString:obj fromIndex:index];
    if (index > self.length  - obj.length || [obj numberOfOccurencesOfString:@"\""] > 0) return NSNotFound;
    
    BOOL inQuotation = NO;
    for (NSUInteger i = 0; i < self.length - obj.length; i++) {
        if ([[self substringWithRange:NSMakeRange(i, obj.length)] isEqualToString:obj]
            && i >= index && !inQuotation) {
            return i;
        }
        if ([[self substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"\""]
            && ![[self substringWithRange:NSMakeRange(i - 1, 1)] isEqualToString:@"\\"]) {
            inQuotation = !inQuotation;
        }
    }
    
    return NSNotFound;
}

- (NSUInteger)endOfQuotationFromIndex:(NSUInteger)index{
    if (index == self.length - 1) {
        return NSNotFound;
    }
    NSUInteger closingQuoteMarkIndex = [self nextOccurenceOfString:@"\"" fromIndex:index + 1];
    
    while (closingQuoteMarkIndex != NSNotFound
           &&[[self substringWithRange:NSMakeRange(closingQuoteMarkIndex - 1, 1)] isEqualToString:@"\\"]) {
        
        closingQuoteMarkIndex = [self nextOccurenceOfString:@"\""
                                                  fromIndex:closingQuoteMarkIndex + 1];
    }
    return closingQuoteMarkIndex;
}

- (NSString *)substringFrom: (NSUInteger)start to: (NSUInteger)end{
    if (start > end || end > self.length) return nil;
    return [self substringWithRange:NSMakeRange(start, end - start)];
}

- (NSUInteger)endOfLineFromIndex:(NSUInteger)start{
    return [self nextOccurenceOfString:@"\n"
                             fromIndex:start
                 outsideQuotationMarks:YES];
}

- (NSString *)substringToEndOfLineFromIndex:(NSUInteger)start{
    NSUInteger nextLineBreakIndex = [self endOfLineFromIndex:start];
    if (nextLineBreakIndex == NSNotFound) {
        return [self substringFromIndex:start];
    }else{
        return [self substringFrom:start to:nextLineBreakIndex - 1];
    }
}

- (NSString *)stringByRemovingComments{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < self.length; i++) {
        NSString *character = [self substringWithRange:NSMakeRange(i, 1)];
        NSString *nextCharacter = (i < self.length - 1) ? [self substringWithRange:NSMakeRange(i + 1, 1)] : nil;
        
        if ([character isEqualToString:@"/"]) {
            if (i < self.length - 1 && [nextCharacter isEqualToString:@"/"]) {
                NSUInteger nextLineBreakIndex = [self nextOccurenceOfString:@"\n"
                                                                  fromIndex:i];
                if (nextLineBreakIndex == NSNotFound) {
                    break;
                }else {
                    i = nextLineBreakIndex - 1;
                    continue;
                }
            }else if (i < self.length - 1 && [nextCharacter isEqualToString:@"*"]) {
                if (i == self.length - 2) {
                    return nil;
                }
                NSUInteger endOfMutlilineCommentIndex = [self nextOccurenceOfString:@"*/"
                                                                          fromIndex:i + 2];
                if (endOfMutlilineCommentIndex == NSNotFound) {
                    return nil;
                }else {
                    NSString *commentString = [self substringFrom:i to:endOfMutlilineCommentIndex + 2];
                    NSUInteger lineBreaksInComment = [commentString numberOfOccurencesOfString:@"\n"];
                    
                    for (NSUInteger i = 0; i < lineBreaksInComment; i++) {
                        [resultString appendString:@"\n"];
                    }
                    
                    i = endOfMutlilineCommentIndex + 1;
                    continue;
                }
            }else{
                [resultString appendString:character];
            }
        }else if ([character isEqualToString:@"\""]) {
            if (i == self.length - 1) {
                [resultString appendString:character];
                break;
            }
            NSUInteger closingQuoteMarkIndex = [self nextOccurenceOfString:@"\"" fromIndex:i + 1];
            
            while (closingQuoteMarkIndex != NSNotFound
                   &&[[self substringWithRange:NSMakeRange(closingQuoteMarkIndex - 1, 1)] isEqualToString:@"\\"]) {
                
                closingQuoteMarkIndex = [self nextOccurenceOfString:@"\""
                                                          fromIndex:closingQuoteMarkIndex + 1];
            }
            
            if (closingQuoteMarkIndex == NSNotFound) {
                [resultString appendString:[self substringFromIndex:i]];
            }else {
                [resultString appendString:[self substringFrom:i to:closingQuoteMarkIndex + 1]];
                i = closingQuoteMarkIndex;
                continue;
            }
        }else{
            [resultString appendString:character];
        }
    }
    
    return [NSString stringWithString:resultString];
}

- (NSString *)whitespaceTrimmedString{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
