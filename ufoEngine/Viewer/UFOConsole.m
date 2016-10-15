//
//  UFOConsole.m
//  ufo
//
//  Created by Programmieren on 24.05.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "UFOConsole.h"

@interface UFOConsole ()

@property IBOutlet NSScrollView *outputViewScrollView;
@property IBOutlet NSTextView *outputView;
@property NSTextField *inputField;

@end

@implementation UFOConsole{
    NSMutableAttributedString *string;
    BOOL lastWriteByEngine;
}
@synthesize inputDelegate = _inputDelegate;

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        string = [[NSMutableAttributedString alloc] init];
        
        [[NSBundle bundleForClass:[UFOConsole class]] loadNibNamed:@"ConsoleOutputTextView"
                                                             owner:self
                                                   topLevelObjects:NULL];
        
        _inputField = [[NSTextField alloc] initWithFrame:NSMakeRect(-1, -1, NSWidth(frame) + 2, 23)];
        [_inputField setFont: [NSFont fontWithName:@"Menlo" size:12]];
        [_inputField setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin];
        [_inputField setFocusRingType:NSFocusRingTypeNone];
        [_inputField setEnabled:NO];
        [_inputField setTarget:self];
        [_inputField setAction:@selector(enteredText:)];
        [self addSubview:_inputField];
    }
    return self;
}

- (void)awakeFromNib{
    if (_outputView && [self.subviews indexOfObject:_outputView] == NSNotFound) {
        [self updateOutputText];
        
        [_outputView setFrame:NSMakeRect(0, 22, NSWidth(self.bounds), NSHeight(self.bounds) - 22)];
        [self addSubview:_outputView];
    }
}

#pragma mark -
#pragma mark Output

- (void)clear{
    runBlockOnMainQueue(^{
        string = [[NSMutableAttributedString alloc] init];
        
        [self updateOutputText];
    });
}

- (void)write:(NSString *)msg{
    __block NSString *message = msg;
    
    runBlockOnMainQueue(^{
        NSAttributedString *attributedMessage;
        attributedMessage = [[NSAttributedString alloc] initWithString:message
                                                            attributes:@{NSFontAttributeName : [NSFont fontWithName:@"Menlo" size:12]}];
        [string appendAttributedString:attributedMessage];
        lastWriteByEngine = NO;
        
        [self updateOutputText];
    });
}

- (void)writeByEngine:(NSString *)msg{
    __block NSString *message = msg;
    
    runBlockOnMainQueue(^{
        NSAttributedString *attributedMessage;
        attributedMessage = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"UFOEngine: %@\n", message]
                                                            attributes:@{NSFontAttributeName : [NSFont fontWithName:@"Menlo Bold" size:12]}];
        
        if (string.length > 0 && !lastWriteByEngine) {
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
        
        [string appendAttributedString:attributedMessage];
        lastWriteByEngine = YES;
        
        [self updateOutputText];
    });
}

- (void)updateOutputText{
    [_outputView.textStorage setAttributedString:string];
}

#pragma mark -
#pragma mark Input

- (void)enteredText: (id)sender{
    if ([_inputField.stringValue isEqual:@""]) return;
    if (_inputDelegate) [_inputDelegate enteredText:_inputField.stringValue];
    [_inputField setStringValue:@""];
}

- (id<UFOConsoleInputDelegate>)inputDelegate{
    return _inputDelegate;
}

- (void)setInputDelegate: (id<UFOConsoleInputDelegate>)inputDelegate{
    _inputDelegate = inputDelegate;
    [_inputField setEnabled:(_inputDelegate != nil)];
}

#pragma mark -
#pragma mark Drawing

- (BOOL)isOpaque{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect{
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:dirtyRect];
}

@end
