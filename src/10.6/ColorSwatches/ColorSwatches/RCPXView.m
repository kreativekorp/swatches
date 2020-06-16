//
//  RCPXView.m
//  ColorSwatches
//
//  Created by Rebecca Bettencourt on 6/8/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import "RCPXView.h"

@implementation RCPXView

- (void)dealloc {
    [_palette release];
    [_color release];
    [_locationColor release];
    [_locationName release];
    // [_tracker release];
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
    if (_palette) {
        NSRect bounds = [self bounds];
        NSSize size = [_palette sizeInRect:bounds];
        CGFloat x = floorf(bounds.origin.x + (bounds.size.width - size.width) / 2);
        CGFloat y = floorf(bounds.origin.y + (bounds.size.height - size.height) / 2);
        NSRect r = NSMakeRect(x, y, size.width, size.height);
        [_palette drawInRect:r withColor:_color];
    }
}

- (RCPXPalette *)palette {
    return _palette;
}

- (void)setPalette:(RCPXPalette *)palette {
    [_palette release];
    _palette = [palette retain];
    [self setNeedsDisplay:YES];
}

- (NSColor *)color {
    return _color;
}

- (void)setColor:(NSColor *)color {
    [_color release];
    _color = [color retain];
    [self setNeedsDisplay:YES];
}

- (id)target {
    return _target;
}

- (void)setTarget:(id)anObject {
    _target = anObject;
}

- (SEL)action {
    return _action;
}

- (void)setAction:(SEL)aSelector {
    _action = aSelector;
}

- (NSColor *)locationColor {
    return _locationColor;
}

- (NSString *)locationName {
    return _locationName;
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (_palette) {
        NSRect bounds = [self bounds];
        NSSize size = [_palette sizeInRect:bounds];
        CGFloat x = floorf(bounds.origin.x + (bounds.size.width - size.width) / 2);
        CGFloat y = floorf(bounds.origin.y + (bounds.size.height - size.height) / 2);
        NSRect r = NSMakeRect(x, y, size.width, size.height);
        NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        if (p.x < x) p.x = x; if (p.x > x + size.width - 1) p.x = x + size.width - 1;
        if (p.y < y) p.y = y; if (p.y > y + size.height - 1) p.y = y + size.height - 1;
        [_locationColor release];
        [_locationName release];
        _locationColor = [[_palette colorAtPoint:p inRect:r] retain];
        _locationName = [[_palette nameAtPoint:p inRect:r] retain];
        [[NSApplication sharedApplication] sendAction:_action to:_target from:self];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {
    if (_palette) {
        NSRect bounds = [self bounds];
        NSSize size = [_palette sizeInRect:bounds];
        CGFloat x = floorf(bounds.origin.x + (bounds.size.width - size.width) / 2);
        CGFloat y = floorf(bounds.origin.y + (bounds.size.height - size.height) / 2);
        NSRect r = NSMakeRect(x, y, size.width, size.height);
        NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        if (p.x < x) p.x = x; if (p.x > x + size.width - 1) p.x = x + size.width - 1;
        if (p.y < y) p.y = y; if (p.y > y + size.height - 1) p.y = y + size.height - 1;
        [_locationColor release];
        [_locationName release];
        _locationColor = [[_palette colorAtPoint:p inRect:r] retain];
        _locationName = [[_palette nameAtPoint:p inRect:r] retain];
        [[NSApplication sharedApplication] sendAction:_action to:_target from:self];
    }
}

/*

- (void)mouseMoved:(NSEvent *)theEvent {
    if (_palette) {
        NSRect bounds = [self bounds];
        NSSize size = [_palette sizeInRect:bounds];
        CGFloat x = floorf(bounds.origin.x + (bounds.size.width - size.width) / 2);
        CGFloat y = floorf(bounds.origin.y + (bounds.size.height - size.height) / 2);
        NSRect r = NSMakeRect(x, y, size.width, size.height);
        NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        NSString *name = [_palette nameAtPoint:p inRect:r];
        [self setToolTip:name];
    }
}

- (void)cursorUpdate:(NSEvent *)event {
    [[NSCursor crosshairCursor] set];
}

*/

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
    return YES;
}

- (BOOL)isFlipped {
    return YES;
}

/*

- (void)updateTrackingAreas {
    if (_tracker) {
        [self removeTrackingArea:_tracker];
        [_tracker release];
        _tracker = nil;
    }
    if (_palette) {
        NSRect bounds = [self bounds];
        NSSize size = [_palette sizeInRect:bounds];
        CGFloat x = floorf(bounds.origin.x + (bounds.size.width - size.width) / 2);
        CGFloat y = floorf(bounds.origin.y + (bounds.size.height - size.height) / 2);
        NSRect r = NSMakeRect(x, y, size.width, size.height);
        NSTrackingAreaOptions o = NSTrackingMouseMoved | NSTrackingCursorUpdate | NSTrackingActiveInActiveApp;
        _tracker = [[[NSTrackingArea alloc] initWithRect:r options:o owner:self userInfo:NULL] retain];
        [self addTrackingArea:_tracker];
    }
}

*/

@end
