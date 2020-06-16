//
//  RCPXSwatch.m
//
//  Created by Rebecca Bettencourt on 6/10/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import "RCPXSwatch.h"
#import "RCPXUtilities.h"

@implementation RCPXSwatch

@end


@implementation RCPXEmpty

+ (RCPXEmpty *)emptyWithRepeatCount:(NSInteger)repeat {
    return [[RCPXEmpty alloc]initWithRepeatCount:repeat];
}

- (id)initWithRepeatCount:(NSInteger)repeat {
    _repeat = repeat;
    return self;
}

- (NSInteger)repeatCount {
    return _repeat;
}

@end


@implementation RCPXIndex

+ (RCPXIndex *)indexWithIndex:(NSInteger)i repeatCount:(NSInteger)repeat borderOnly:(RCPXBorder *)borderOnly borderFirst:(RCPXBorder *)borderFirst borderMiddle:(RCPXBorder *)borderMiddle borderLast:(RCPXBorder *)borderLast {
    return [[RCPXIndex alloc]initWithIndex:i repeatCount:repeat borderOnly:borderOnly borderFirst:borderFirst borderMiddle:borderMiddle borderLast:borderLast];
}

- (void)dealloc {
    [_borderOnly release];
    [_borderFirst release];
    [_borderMiddle release];
    [_borderLast release];
    [super dealloc];
}

- (id)initWithIndex:(NSInteger)i repeatCount:(NSInteger)repeat borderOnly:(RCPXBorder *)borderOnly borderFirst:(RCPXBorder *)borderFirst borderMiddle:(RCPXBorder *)borderMiddle borderLast:(RCPXBorder *)borderLast {
    _index = i;
    _repeat = repeat;
    _borderOnly = [borderOnly retain];
    _borderFirst = [borderFirst retain];
    _borderMiddle = [borderMiddle retain];
    _borderLast = [borderLast retain];
    return self;
}

- (RCPXBorder *)borderAtRepeatIndex:(NSInteger)ri {
    if (_repeat <= 1) return _borderOnly;
    if (ri <= 0) return _borderFirst;
    if (ri >= (_repeat - 1)) return _borderLast;
    return _borderMiddle;
}

- (NSInteger)repeatCount {
    return _repeat;
}

- (NSColor *)colorAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)ri withColorList:(NSArray *)colors {
    return [[colors objectAtIndex:_index] color];
}

- (NSString *)nameAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)ri withColorList:(NSArray *)colors {
    return [[colors objectAtIndex:_index] name];
}

- (void)drawInRect:(NSRect)r withColor:(NSColor *)c atRepeatIndex:(NSInteger)ri withColorList:(NSArray *)colors {
    NSColor *_c = [[colors objectAtIndex:_index] color];
    RCPXSetCheckerboardFill(); NSRectFill(r);
    [_c setFill]; NSRectFillUsingOperation(r, NSCompositeSourceOver);
    [[self borderAtRepeatIndex:ri] drawInRect:r withColor:RCPXColorsEqual(_c, c) ? _c : nil];
}

@end


@implementation RCPXRange

+ (RCPXRange *)rangeWithStart:(NSInteger)start end:(NSInteger)end borderOnly:(RCPXBorder *)borderOnly borderFirst:(RCPXBorder *)borderFirst borderMiddle:(RCPXBorder *)borderMiddle borderLast:(RCPXBorder *)borderLast {
    return [[RCPXRange alloc]initWithStart:start end:end borderOnly:borderOnly borderFirst:borderFirst borderMiddle:borderMiddle borderLast:borderLast];
}

- (void)dealloc {
    [_borderOnly release];
    [_borderFirst release];
    [_borderMiddle release];
    [_borderLast release];
    [super dealloc];
}

- (id)initWithStart:(NSInteger)start end:(NSInteger)end borderOnly:(RCPXBorder *)borderOnly borderFirst:(RCPXBorder *)borderFirst borderMiddle:(RCPXBorder *)borderMiddle borderLast:(RCPXBorder *)borderLast {
    _start = start;
    _end = end;
    _borderOnly = [borderOnly retain];
    _borderFirst = [borderFirst retain];
    _borderMiddle = [borderMiddle retain];
    _borderLast = [borderLast retain];
    return self;
}

- (RCPXBorder *)borderAtRepeatIndex:(NSInteger)ri {
    NSInteger count = _end - _start;
    if (count <= 1) return _borderOnly;
    if (ri <= 0) return _borderFirst;
    if (ri >= (count - 1)) return _borderLast;
    return _borderMiddle;
}

- (NSInteger)repeatCount {
    return _end - _start;
}

- (NSColor *)colorAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)ri withColorList:(NSArray *)colors {
    return [[colors objectAtIndex:_start + ri] color];
}

- (NSString *)nameAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)ri withColorList:(NSArray *)colors {
    return [[colors objectAtIndex:_start + ri] name];
}

- (void)drawInRect:(NSRect)r withColor:(NSColor *)c atRepeatIndex:(NSInteger)ri withColorList:(NSArray *)colors {
    NSColor *_c = [[colors objectAtIndex:_start + ri] color];
    RCPXSetCheckerboardFill(); NSRectFill(r);
    [_c setFill]; NSRectFillUsingOperation(r, NSCompositeSourceOver);
    [[self borderAtRepeatIndex:ri] drawInRect:r withColor:RCPXColorsEqual(_c, c) ? _c : nil];
}

@end


@implementation RCPXSweep

- (BOOL)locateColor:(NSColor *)c atX:(CGFloat *)xv y:(CGFloat *)yv {
    return NO;
}

- (void)drawInRect:(NSRect)r withColor:(NSColor *)c atRepeatIndex:(NSInteger)ri withColorList:(NSArray *)colors {
    if (!_cacheImage || !NSEqualSizes(_cacheSize, r.size)) {
        NSBitmapImageRep *img = [[NSBitmapImageRep alloc]
                                 initWithBitmapDataPlanes:NULL
                                 pixelsWide:r.size.width pixelsHigh:r.size.height
                                 bitsPerSample:8 samplesPerPixel:3
                                 hasAlpha:NO isPlanar:YES
                                 colorSpaceName:NSCalibratedRGBColorSpace
                                 bytesPerRow:0 bitsPerPixel:0];
        NSPoint p;
        NSInteger x, y;
        for (p.y = r.origin.y, y = r.size.height - 1; y >= 0; y--, p.y += 1.0f) {
            for (p.x = r.origin.x, x = 0; x < r.size.width; x++, p.x += 1.0f) {
                NSColor *col = [self colorAtPoint:p inRect:r atRepeatIndex:ri withColorList:colors];
                [img setColor:col atX:x y:y];
            }
        }
        [_cacheImage release];
        _cacheImage = [[[NSImage alloc] initWithSize:r.size] retain];
        [_cacheImage addRepresentation:img];
        _cacheSize = r.size;
    }
    [_cacheImage drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    if (c) {
        CGFloat xv = 0.5f;
        CGFloat yv = 0.5f;
        if ([self locateColor:c atX:&xv y:&yv]) {
            CGFloat x = roundf(r.origin.x + (r.size.width - 1) * xv);
            CGFloat y = roundf(r.origin.y + (r.size.height - 1) * yv);
            NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(x-3, y-3, 7, 7)];
            [[NSGraphicsContext currentContext] saveGraphicsState];
            [[NSBezierPath bezierPathWithRect:r] addClip];
            [path addClip];
            [[NSColor whiteColor] setStroke];
            [path setLineWidth:4];
            [path stroke];
            [[NSColor blackColor] setStroke];
            [path setLineWidth:2];
            [path stroke];
            [[NSGraphicsContext currentContext] restoreGraphicsState];
        }
    }
    [_border drawInRect:r withColor:nil];
}

@end


@implementation RCPXRGBSweep

+ (RCPXRGBSweep *)rgbSweepWithXChannel:(RCPXRGBChannel)xchan xMin:(CGFloat)xmin xMax:(CGFloat)xmax yChannel:(RCPXRGBChannel)ychan yMin:(CGFloat)ymin yMax:(CGFloat)ymax red:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b border:(RCPXBorder *)border {
    return [[RCPXRGBSweep alloc]initWithXChannel:xchan xMin:xmin xMax:xmax yChannel:ychan yMin:ymin yMax:ymax red:r green:g blue:b border:border];
}

- (void)dealloc {
    [_border release];
    [_cacheImage release];
    [super dealloc];
}

- (id)initWithXChannel:(RCPXRGBChannel)xchan xMin:(CGFloat)xmin xMax:(CGFloat)xmax yChannel:(RCPXRGBChannel)ychan yMin:(CGFloat)ymin yMax:(CGFloat)ymax red:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b border:(RCPXBorder *)border {
    _xchan = xchan;
    _xmin = xmin;
    _xmax = xmax;
    _ychan = ychan;
    _ymin = ymin;
    _ymax = ymax;
    _r = r;
    _g = g;
    _b = b;
    _border = [border retain];
    _cacheSize = NSZeroSize;
    _cacheImage = nil;
    return self;
}

- (NSColor *)colorAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)ri withColorList:(NSArray *)colors {
    CGFloat cr = _r;
    CGFloat cg = _g;
    CGFloat cb = _b;
    CGFloat xv = (p.x - r.origin.x) / (r.size.width - 1);
    CGFloat yv = (p.y - r.origin.y) / (r.size.height - 1);
    xv = _xmax * xv + _xmin * (1 - xv);
    yv = _ymax * yv + _ymin * (1 - yv);
    switch (_xchan) {
        case RCPXRGBChannelRed: cr = xv; break;
        case RCPXRGBChannelGreen: cg = xv; break;
        case RCPXRGBChannelBlue: cb = xv; break;
    }
    switch (_ychan) {
        case RCPXRGBChannelRed: cr = yv; break;
        case RCPXRGBChannelGreen: cg = yv; break;
        case RCPXRGBChannelBlue: cb = yv; break;
    }
    return [NSColor colorWithCalibratedRed:cr green:cg blue:cb alpha:1];
}

- (BOOL)locateColor:(NSColor *)c atX:(CGFloat *)xv y:(CGFloat *)yv {
    CGFloat cr, cg, cb, ca;
    [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&cr green:&cg blue:&cb alpha:&ca];
    BOOL rok = fabsf(cr - _r) < e255;
    BOOL gok = fabsf(cg - _g) < e255;
    BOOL bok = fabsf(cb - _b) < e255;
    CGFloat xmin = _xmin < _xmax ? _xmin : _xmax;
    CGFloat xmax = _xmin > _xmax ? _xmin : _xmax;
    CGFloat ymin = _ymin < _ymax ? _ymin : _ymax;
    CGFloat ymax = _ymin > _ymax ? _ymin : _ymax;
    switch (_xchan) {
        case RCPXRGBChannelRed:
            rok = (cr >= xmin && cr <= xmax);
            *xv = (cr - _xmin) / (_xmax - _xmin);
            break;
        case RCPXRGBChannelGreen:
            gok = (cg >= xmin && cg <= xmax);
            *xv = (cg - _xmin) / (_xmax - _xmin);
            break;
        case RCPXRGBChannelBlue:
            bok = (cb >= xmin && cb <= xmax);
            *xv = (cb - _xmin) / (_xmax - _xmin);
            break;
    }
    switch (_ychan) {
        case RCPXRGBChannelRed:
            rok = (cr >= ymin && cr <= ymax);
            *yv = (cr - _ymin) / (_ymax - _ymin);
            break;
        case RCPXRGBChannelGreen:
            gok = (cg >= ymin && cg <= ymax);
            *yv = (cg - _ymin) / (_ymax - _ymin);
            break;
        case RCPXRGBChannelBlue:
            bok = (cb >= ymin && cb <= ymax);
            *yv = (cb - _ymin) / (_ymax - _ymin);
            break;
    }
    return (rok && gok && bok);
}

@end


@implementation RCPXHSVSweep

+ (RCPXHSVSweep *)hsvSweepWithXChannel:(RCPXHSVChannel)xchan xMin:(CGFloat)xmin xMax:(CGFloat)xmax yChannel:(RCPXHSVChannel)ychan yMin:(CGFloat)ymin yMax:(CGFloat)ymax hue:(CGFloat)h saturation:(CGFloat)s value:(CGFloat)v border:(RCPXBorder *)border {
    return [[RCPXHSVSweep alloc]initWithXChannel:xchan xMin:xmin xMax:xmax yChannel:ychan yMin:ymin yMax:ymax hue:h saturation:s value:v border:border];
}

- (void)dealloc {
    [_border release];
    [_cacheImage release];
    [super dealloc];
}

- (id)initWithXChannel:(RCPXHSVChannel)xchan xMin:(CGFloat)xmin xMax:(CGFloat)xmax yChannel:(RCPXHSVChannel)ychan yMin:(CGFloat)ymin yMax:(CGFloat)ymax hue:(CGFloat)h saturation:(CGFloat)s value:(CGFloat)v border:(RCPXBorder *)border {
    _xchan = xchan;
    _xmin = xmin;
    _xmax = xmax;
    _ychan = ychan;
    _ymin = ymin;
    _ymax = ymax;
    _h = h;
    _s = s;
    _v = v;
    _border = [border retain];
    _cacheSize = NSZeroSize;
    _cacheImage = nil;
    return self;
}

- (NSColor *)colorAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)ri withColorList:(NSArray *)colors {
    CGFloat ch = _h;
    CGFloat cs = _s;
    CGFloat cv = _v;
    CGFloat xv = (p.x - r.origin.x) / (r.size.width - 1);
    CGFloat yv = (p.y - r.origin.y) / (r.size.height - 1);
    xv = _xmax * xv + _xmin * (1 - xv);
    yv = _ymax * yv + _ymin * (1 - yv);
    switch (_xchan) {
        case RCPXHSVChannelHue: ch = xv; break;
        case RCPXHSVChannelSaturation: cs = xv; break;
        case RCPXHSVChannelValue: cv = xv; break;
    }
    switch (_ychan) {
        case RCPXHSVChannelHue: ch = yv; break;
        case RCPXHSVChannelSaturation: cs = yv; break;
        case RCPXHSVChannelValue: cv = yv; break;
    }
    return [NSColor colorWithCalibratedHue:ch saturation:cs brightness:cv alpha:1];
}

- (BOOL)locateColor:(NSColor *)c atX:(CGFloat *)xv y:(CGFloat *)yv {
    CGFloat ch, cs, cv, ca;
    [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getHue:&ch saturation:&cs brightness:&cv alpha:&ca];
    BOOL hok = fabsf(ch - _h) < e360 || fabsf(fabsf(ch - _h) - 1) < e360;
    BOOL sok = fabsf(cs - _s) < e100;
    BOOL vok = fabsf(cv - _v) < e100;
    CGFloat xmin = _xmin < _xmax ? _xmin : _xmax;
    CGFloat xmax = _xmin > _xmax ? _xmin : _xmax;
    CGFloat ymin = _ymin < _ymax ? _ymin : _ymax;
    CGFloat ymax = _ymin > _ymax ? _ymin : _ymax;
    switch (_xchan) {
        case RCPXHSVChannelHue:
            hok = (ch >= xmin && ch <= xmax);
            *xv = (ch - _xmin) / (_xmax - _xmin);
            break;
        case RCPXHSVChannelSaturation:
            sok = (cs >= xmin && cs <= xmax);
            *xv = (cs - _xmin) / (_xmax - _xmin);
            break;
        case RCPXHSVChannelValue:
            vok = (cv >= xmin && cv <= xmax);
            *xv = (cv - _xmin) / (_xmax - _xmin);
            break;
    }
    switch (_ychan) {
        case RCPXHSVChannelHue:
            hok = (ch >= ymin && ch <= ymax);
            *yv = (ch - _ymin) / (_ymax - _ymin);
            break;
        case RCPXHSVChannelSaturation:
            sok = (cs >= ymin && cs <= ymax);
            *yv = (cs - _ymin) / (_ymax - _ymin);
            break;
        case RCPXHSVChannelValue:
            vok = (cv >= ymin && cv <= ymax);
            *yv = (cv - _ymin) / (_ymax - _ymin);
            break;
    }
    return (hok && sok && vok);
}

@end
