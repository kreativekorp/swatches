//
//  RCPXView.h
//  ColorSwatches
//
//  Created by Rebecca Bettencourt on 6/8/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RCPX.h"

@interface RCPXView : NSView {
    RCPXPalette *_palette;
    NSColor *_color;
    id _target;
    SEL _action;
    NSColor *_locationColor;
    NSString *_locationName;
    // NSTrackingArea *_tracker;
}

- (RCPXPalette *)palette;
- (void)setPalette:(RCPXPalette *)palette;
- (NSColor *)color;
- (void)setColor:(NSColor *)color;

- (id)target;
- (void)setTarget:(id)anObject;
- (SEL)action;
- (void)setAction:(SEL)aSelector;

- (NSColor *)locationColor;
- (NSString *)locationName;

- (void)mouseDown:(NSEvent *)theEvent;
- (void)mouseDragged:(NSEvent *)theEvent;
// - (void)mouseMoved:(NSEvent *)theEvent;
// - (void)cursorUpdate:(NSEvent *)event;

@end
