//
//  UFOAppDelegate.h
//  ufo
//
//  Created by Programmieren on 24.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ufoEngine/ufo.h>

@interface UFOAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *urlField;
@property (assign) IBOutlet UFOConsole *console;
@property (assign) IBOutlet UFOViewer *viewer;

- (IBAction)run:(id)sender;

@end
