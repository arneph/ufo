//
//  ufoStandards.m
//  ufo
//
//  Created by Programmieren on 31.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "ufoStandards.h"

void runBlockOnMainQueue(void (^block)(void)) {
    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
    if (!currentQueue || currentQueue == [NSOperationQueue mainQueue]) {
        block();
    }else{
        [[NSOperationQueue mainQueue] addOperationWithBlock:block];
    }

}

UFODataType dataTypeFromString(NSString *dataTypeString, NSString *__autoreleasing*className) {
    dataTypeString = [dataTypeString whitespaceTrimmedString];
    if ([dataTypeString isEqualToString:@""] || [dataTypeString isEqualToString:@"void"]) {
        return UFODataTypeVoid;
    }else if ([dataTypeString isEqualToString:@"bool"]) {
        return UFODataTypeBoolean;
    }else if ([dataTypeString isEqualToString:@"char"]) {
        return UFODataTypeChar;
    }else if ([dataTypeString isEqualToString:@"byte"]) {
        return UFODataTypeByte;
    }else if ([dataTypeString isEqualToString:@"int"]) {
        return UFODataTypeInteger;
    }else if ([dataTypeString isEqualToString:@"uint"]) {
        return UFODataTypeUnsignedInteger;
    }else if ([dataTypeString isEqualToString:@"long"]) {
        return UFODataTypeLong;
    }else if ([dataTypeString isEqualToString:@"double"]) {
        return UFODataTypeDouble;
    }else if ([[dataTypeString substringFromIndex:dataTypeString.length - 1] isEqualToString:@"*"]) {
        if ([dataTypeString numberOfOccurencesOfString:@"*"] != 1)
            return UFODataTypeUnknown;
        *className = [dataTypeString substringToIndex:dataTypeString.length - 1];
        *className = [*className whitespaceTrimmedString];
        
        if (![*className isValidClassName]) {
            return UFODataTypeUnknown;
        }
        return UFODataTypeObject;
    }
    return UFODataTypeUnknown;
}
