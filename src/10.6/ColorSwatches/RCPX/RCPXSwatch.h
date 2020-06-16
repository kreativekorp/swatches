//
//  RCPXSwatch.h
//
//  Created by Rebecca Bettencourt on 6/10/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCPXBorder.h"
#import "RCPXLayoutOrSwatch.h"

enum {
    RCPXRGBChannelNone = 0,
    RCPXRGBChannelRed,
    RCPXRGBChannelGreen,
    RCPXRGBChannelBlue,
    RCPXRGBChannelAlpha
};
typedef NSInteger RCPXRGBChannel;


enum {
    RCPXHSVChannelNone = 0,
    RCPXHSVChannelHue,
    RCPXHSVChannelSaturation,
    RCPXHSVChannelValue,
    RCPXHSVChannelAlpha
};
typedef NSInteger RCPXHSVChannel;


@interface RCPXSwatch : RCPXLayoutOrSwatch

@end


@interface RCPXEmpty : RCPXSwatch {
    NSInteger _repeat;
}

+ (RCPXEmpty *)emptyWithRepeatCount:(NSInteger)repeat;
- (id)initWithRepeatCount:(NSInteger)repeat;

@end


@interface RCPXIndex : RCPXSwatch {
    NSInteger _index;
    NSInteger _repeat;
    RCPXBorder *_borderOnly;
    RCPXBorder *_borderFirst;
    RCPXBorder *_borderMiddle;
    RCPXBorder *_borderLast;
}

+ (RCPXIndex *)indexWithIndex:(NSInteger)i repeatCount:(NSInteger)repeat borderOnly:(RCPXBorder *)borderOnly borderFirst:(RCPXBorder *)borderFirst borderMiddle:(RCPXBorder *)borderMiddle borderLast:(RCPXBorder *)borderLast;
- (id)initWithIndex:(NSInteger)i repeatCount:(NSInteger)repeat borderOnly:(RCPXBorder *)borderOnly borderFirst:(RCPXBorder *)borderFirst borderMiddle:(RCPXBorder *)borderMiddle borderLast:(RCPXBorder *)borderLast;
- (RCPXBorder *)borderAtRepeatIndex:(NSInteger)ri;

@end


@interface RCPXRange : RCPXSwatch {
    NSInteger _start;
    NSInteger _end;
    RCPXBorder *_borderOnly;
    RCPXBorder *_borderFirst;
    RCPXBorder *_borderMiddle;
    RCPXBorder *_borderLast;
}

+ (RCPXRange *)rangeWithStart:(NSInteger)start end:(NSInteger)end borderOnly:(RCPXBorder *)borderOnly borderFirst:(RCPXBorder *)borderFirst borderMiddle:(RCPXBorder *)borderMiddle borderLast:(RCPXBorder *)borderLast;
- (id)initWithStart:(NSInteger)start end:(NSInteger)end borderOnly:(RCPXBorder *)borderOnly borderFirst:(RCPXBorder *)borderFirst borderMiddle:(RCPXBorder *)borderMiddle borderLast:(RCPXBorder *)borderLast;
- (RCPXBorder *)borderAtRepeatIndex:(NSInteger)ri;

@end


@interface RCPXSweep : RCPXSwatch {
    RCPXBorder *_border;
    NSSize _cacheSize;
    NSImage *_cacheImage;
}

- (BOOL)locateColor:(NSColor *)c atX:(CGFloat *)xv y:(CGFloat *)yv;

@end


@interface RCPXRGBSweep : RCPXSweep {
    RCPXRGBChannel _xchan;
    CGFloat _xmin, _xmax;
    RCPXRGBChannel _ychan;
    CGFloat _ymin, _ymax;
    CGFloat _r, _g, _b;
}

+ (RCPXRGBSweep *)rgbSweepWithXChannel:(RCPXRGBChannel)xchan xMin:(CGFloat)xmin xMax:(CGFloat)xmax yChannel:(RCPXRGBChannel)ychan yMin:(CGFloat)ymin yMax:(CGFloat)ymax red:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b border:(RCPXBorder *)border;
- (id)initWithXChannel:(RCPXRGBChannel)xchan xMin:(CGFloat)xmin xMax:(CGFloat)xmax yChannel:(RCPXRGBChannel)ychan yMin:(CGFloat)ymin yMax:(CGFloat)ymax red:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b border:(RCPXBorder *)border;

@end


@interface RCPXHSVSweep : RCPXSweep {
    RCPXHSVChannel _xchan;
    CGFloat _xmin, _xmax;
    RCPXHSVChannel _ychan;
    CGFloat _ymin, _ymax;
    CGFloat _h, _s, _v;
}

+ (RCPXHSVSweep *)hsvSweepWithXChannel:(RCPXHSVChannel)xchan xMin:(CGFloat)xmin xMax:(CGFloat)xmax yChannel:(RCPXHSVChannel)ychan yMin:(CGFloat)ymin yMax:(CGFloat)ymax hue:(CGFloat)h saturation:(CGFloat)s value:(CGFloat)v border:(RCPXBorder *)border;
- (id)initWithXChannel:(RCPXHSVChannel)xchan xMin:(CGFloat)xmin xMax:(CGFloat)xmax yChannel:(RCPXHSVChannel)ychan yMin:(CGFloat)ymin yMax:(CGFloat)ymax hue:(CGFloat)h saturation:(CGFloat)s value:(CGFloat)v border:(RCPXBorder *)border;

@end
