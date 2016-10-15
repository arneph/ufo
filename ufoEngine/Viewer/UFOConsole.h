//
//  UFOConsole.h
//  ufo
//
//  Created by Programmieren on 24.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol UFOConsoleInputDelegate <NSObject>

- (void)enteredText: (NSString *)text;

@end

@interface UFOConsole : NSView

@property id<UFOConsoleInputDelegate> inputDelegate;

- (void)clear;
- (void)write: (NSString *)message;
- (void)writeByEngine: (NSString *)message;

@end
