//
//  UFONumberVariable.h
//  ufo
//
//  Created by Programmieren on 01.06.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UFOVariable.h"

@interface UFONumberVariable : UFOVariable

@property (readonly) NSNumber *currentValue;

+ (NSNumber *)maximum;
+ (NSNumber *)minimum;
+ (BOOL)allowsDecimals;

@end

@interface UFOCharVariable : UFONumberVariable

@end

@interface UFOByteVariable : UFONumberVariable

@end

@interface UFOIntegerVariable : UFONumberVariable

@end

@interface UFOUnsignedIntegerVariable : UFONumberVariable

@end

@interface UFOLongVariable : UFONumberVariable

@end

@interface UFOFloatVariable : UFONumberVariable

@end

@interface UFODoubleVariable : UFONumberVariable

@end
