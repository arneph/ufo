//
//  UFOOutputClass.h
//  ufo
//
//  Created by Programmieren on 29.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UFOSystemClass.h"

@protocol UFOOutputDelegate <NSObject>

- (void)write: (NSString *)write;

@end

@interface UFOOutputClass : UFOSystemClass

@property id<UFOOutputDelegate> delegate;

@end
