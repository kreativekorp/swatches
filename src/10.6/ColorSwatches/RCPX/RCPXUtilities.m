//
//  RCPXUtilities.m
//
//  Created by Rebecca Bettencourt on 6/11/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import "RCPXUtilities.h"

const CGFloat e100 = 1.0f / 100.0f;
const CGFloat e180 = 1.0f / 180.0f;
const CGFloat e255 = 1.0f / 255.0f;
const CGFloat e360 = 1.0f / 360.0f;

BOOL RCPXColorsEqual(NSColor * c1, NSColor * c2) {
    if (!c1 || !c2) return NO;
    CGFloat r1, g1, b1, a1;
    CGFloat r2, g2, b2, a2;
    [[c1 colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [[c2 colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    return (fabsf(r1-r2) < e255 && fabsf(g1-g2) < e255 && fabsf(b1-b2) < e255 && fabsf(a1-a2) < e255);
}

NSColor * RCPXContrastingColor(NSColor * color) {
    CGFloat r, g, b, a;
    [[color colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&r green:&g blue:&b alpha:&a];
    if (a < 0.5f) return [NSColor blackColor];
    CGFloat gray = r*0.3f + g*0.59f + b*0.11f;
    if (gray < 0.5f) return [NSColor whiteColor];
    return [NSColor blackColor];
}

static void rcpxCheckerboardCallback(void * info, CGContextRef context) {
    CGContextSetGrayFillColor(context, 1.0f, 1.0f);
    CGContextFillRect(context, NSMakeRect(0, 0, 8, 8));
    CGContextFillRect(context, NSMakeRect(8, 8, 8, 8));
    CGContextSetGrayFillColor(context, 0.8f, 1.0f);
    CGContextFillRect(context, NSMakeRect(8, 0, 8, 8));
    CGContextFillRect(context, NSMakeRect(0, 8, 8, 8));
}

void RCPXSetCheckerboardFill(void) {
    static const CGPatternCallbacks callbacks = { 0, &rcpxCheckerboardCallback, NULL };
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(NULL);
    CGContextSetFillColorSpace(context, patternSpace);
    CGColorSpaceRelease(patternSpace);
    
    CGRect bounds = CGRectMake(0, 0, 16, 16);
    CGAffineTransform tx = CGAffineTransformIdentity;
    CGPatternTiling tiling = kCGPatternTilingConstantSpacing;
    
    CGPatternRef pattern = CGPatternCreate(NULL, bounds, tx, 16, 16, tiling, true, &callbacks);
    CGFloat alpha = 1;
    CGContextSetFillPattern(context, pattern, &alpha);
    CGPatternRelease(pattern);
}
