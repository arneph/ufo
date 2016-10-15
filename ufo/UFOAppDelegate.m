//
//  UFOAppDelegate.m
//  ufo
//
//  Created by Programmieren on 24.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "UFOAppDelegate.h"

@implementation UFOAppDelegate{
    UFOEngine *engine;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    
}

- (void)run:(id)sender{
    NSURL *url = [NSURL fileURLWithPath:_urlField.stringValue];
    if (!url) {
        [self showInvalidURLAlert];
        return;
    }
    
    engine = [[UFOEngine alloc] initWithURL:url
                                    console:_console
                                  viewer:_viewer];
    if (!engine) {
        [self showInvalidURLAlert];
        return;
    }
    
    if (engine.engineStatus == UFOEngineReady)
        [engine beginRunning];
}

- (void)showInvalidURLAlert{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"URL Error"];
    [alert setInformativeText:@"The entered URL isn't valid."];
    [alert addButtonWithTitle:@"Okay"];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert beginSheetModalForWindow:_window
                  completionHandler:NULL];
}

@end
