//
//  UFOObjectVariable.h
//  ufo
//
//  Created by Programmieren on 01.06.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UFOVariable.h"

@interface UFOObjectVariable : UFOVariable

@property (readonly) NSString *objectClassName;

- (id)initVariableNamed: (NSString *)name objectClassName: (NSString *)className;
- (id)initVariableNamed: (NSString *)name objectClassName: (NSString *)className public: (BOOL)pub static: (BOOL)stat;

@end
