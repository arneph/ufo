//
//  UFOViewer.m
//  ufo
//
//  Created by Programmieren on 24.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "UFOViewer.h"

@implementation UFOViewer

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)clear {
    
}

- (BOOL)isOpaque{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect{
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:dirtyRect];
}

@end
