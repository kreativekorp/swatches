//
//  RCPXBorder.m
//
//  Created by Rebecca Bettencourt on 6/9/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import "RCPXBorder.h"
#import "RCPXUtilities.h"

@implementation RCPXBorder

+ (RCPXBorder *)borderWithAll {
    return [RCPXBorder borderWithTop:YES left:YES bottom:YES right:YES];
}

+ (RCPXBorder *)borderWithNone {
    return [RCPXBorder borderWithTop:NO left:NO bottom:NO right:NO];
}

+ (RCPXBorder *)borderWithTop:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right {
    return [[RCPXBorder alloc]initWithTop:top left:left bottom:bottom right:right];
}

- (id)initWithTop:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right {
    _top = top;
    _left = left;
    _bottom = bottom;
    _right = right;
    return self;
}

- (void)drawInRect:(NSRect)rect withColor:(NSColor *)color {
    // Inner border.
    if (color) {
        [RCPXContrastingColor(color) setFill];
        if (_top) NSRectFill(NSMakeRect(rect.origin.x, rect.origin.y+1, rect.size.width, 1));
        if (_left) NSRectFill(NSMakeRect(rect.origin.x+1, rect.origin.y, 1, rect.size.height));
        if (_bottom) NSRectFill(NSMakeRect(rect.origin.x, rect.origin.y+rect.size.height-2, rect.size.width, 1));
        if (_right) NSRectFill(NSMakeRect(rect.origin.x+rect.size.width-2, rect.origin.y, 1, rect.size.height));        
    }
    // Outer border.
    [[NSColor blackColor] setFill];
    if (_top) NSRectFill(NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width, 1));
    if (_left) NSRectFill(NSMakeRect(rect.origin.x, rect.origin.y, 1, rect.size.height));
    if (_bottom) NSRectFill(NSMakeRect(rect.origin.x, rect.origin.y+rect.size.height-1, rect.size.width, 1));
    if (_right) NSRectFill(NSMakeRect(rect.origin.x+rect.size.width-1, rect.origin.y, 1, rect.size.height));
}

@end
