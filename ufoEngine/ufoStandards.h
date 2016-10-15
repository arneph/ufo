//
//  ufoStandards.h
//  ufo
//
//  Created by Programmieren on 29.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#ifndef __ufoStandards_h__
#define __ufoStandards_h__
#import <Foundation/Foundation.h>
#import "NSString+UFOString.h"

typedef enum{
    UFODataTypeVoid,
    UFODataTypeBoolean,
    UFODataTypeChar,
    UFODataTypeByte,
    UFODataTypeInteger,
    UFODataTypeUnsignedInteger,
    UFODataTypeLong,
    UFODataTypeFloat,
    UFODataTypeDouble,
    UFODataTypeObject,
    UFODataTypeUnknown
}UFODataType;

void runBlockOnMainQueue(void (^block)(void));

NSNumber * getNumberFromString(NSString *string);
NSNumberFormatter * getNumberFormatter();

UFODataType dataTypeFromString(NSString *dataTypeString, NSString *__autoreleasing* objectClassName);

#endif
