//
//  RCPXPalette.m
//
//  Created by Rebecca Bettencourt on 6/11/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import "RCPXPalette.h"

@implementation RCPXPalette

+ (RCPXPalette *)paletteWithName:(NSString *)name orientation:(RCPXOrientation)orient horizontalSize:(NSSize)hsize squareSize:(NSSize)ssize verticalSize:(NSSize)vsize colors:(NSArray *)colors ordered:(BOOL)ordered layout:(RCPXLayout *)layout {
    return [[RCPXPalette alloc]initWithName:name orientation:orient horizontalSize:hsize squareSize:ssize verticalSize:vsize colors:colors ordered:ordered layout:layout];
}

- (void)dealloc {
    [_name release];
    [_colors release];
    [_layout release];
    [super dealloc];
}

- (id)initWithName:(NSString *)name orientation:(RCPXOrientation)orient horizontalSize:(NSSize)hsize squareSize:(NSSize)ssize verticalSize:(NSSize)vsize colors:(NSArray *)colors ordered:(BOOL)ordered layout:(RCPXLayout *)layout {
    _name = [name retain];
    _orientation = orient;
    _hsize = hsize;
    _ssize = ssize;
    _vsize = vsize;
    _colors = [colors retain];
    _ordered = ordered;
    _layout = [layout retain];
    return self;
}

- (NSString *)name {
    return _name;
}

- (NSSize)sizeInRect:(NSRect)r {
    if (r.size.width > (r.size.height * 1.5f)) return _hsize;
    if (r.size.height > (r.size.width * 1.5f)) return _vsize;
    return _ssize;
}

- (NSColor *)colorAtPoint:(NSPoint)p inRect:(NSRect)r {
    return [_layout colorAtPoint:p inRect:r atRepeatIndex:0 withColorList:_colors];
}

- (NSString *)nameAtPoint:(NSPoint)p inRect:(NSRect)r {
    return [_layout nameAtPoint:p inRect:r atRepeatIndex:0 withColorList:_colors];
}

- (void)drawInRect:(NSRect)r withColor:(NSColor *)c {
    [_layout drawInRect:r withColor:c atRepeatIndex:0 withColorList:_colors];
}

@end
