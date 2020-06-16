//
//  RCPXPalette.h
//
//  Created by Rebecca Bettencourt on 6/11/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCPXLayout.h"

@interface RCPXPalette : NSObject {
    NSString *_name;
    RCPXOrientation _orientation;
    NSSize _hsize;
    NSSize _ssize;
    NSSize _vsize;
    NSArray *_colors;
    BOOL _ordered;
    RCPXLayout *_layout;
}

+ (RCPXPalette *)paletteWithName:(NSString *)name orientation:(RCPXOrientation)orient horizontalSize:(NSSize)hsize squareSize:(NSSize)ssize verticalSize:(NSSize)vsize colors:(NSArray *)colors ordered:(BOOL)ordered layout:(RCPXLayout *)layout;
- (id)initWithName:(NSString *)name orientation:(RCPXOrientation)orient horizontalSize:(NSSize)hsize squareSize:(NSSize)ssize verticalSize:(NSSize)vsize colors:(NSArray *)colors ordered:(BOOL)ordered layout:(RCPXLayout *)layout;

- (NSString *)name;
- (NSSize)sizeInRect:(NSRect)r;
- (NSColor *)colorAtPoint:(NSPoint)p inRect:(NSRect)r;
- (NSString *)nameAtPoint:(NSPoint)p inRect:(NSRect)r;
- (void)drawInRect:(NSRect)r withColor:(NSColor *)c;

@end
