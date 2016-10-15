//
//  UFOSystemClass.h
//  ufo
//
//  Created by Programmieren on 31.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UFOClass.h"

@interface UFOSystemClass : UFOClass

- (void)performFunction: (NSString *)functionName
              arguments: (NSArray *)arguments
            returnValue: (NSString *__autoreleasing*)returnValue;

@end
