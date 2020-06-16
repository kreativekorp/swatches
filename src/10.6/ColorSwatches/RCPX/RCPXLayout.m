//
//  RCPXLayout.m
//
//  Created by Rebecca Bettencourt on 6/10/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import "RCPXLayout.h"
#import "RCPXUtilities.h"

@implementation RCPXLayout

@end


@implementation RCPXOriented

+ (RCPXOriented *)oriented {
    return [[RCPXOriented alloc]init];
}

+ (RCPXOriented *)orientedWithHorizontal:(RCPXLayoutOrSwatch *)h square:(RCPXLayoutOrSwatch *)s vertical:(RCPXLayoutOrSwatch *)v {
    return [[RCPXOriented alloc]initWithHorizontal:h square:s vertical:v];
}

- (void)dealloc {
    [_horizontal release];
    [_square release];
    [_vertical release];
    [super dealloc];
}

- (id)init {
    _horizontal = nil;
    _square = nil;
    _vertical = nil;
    return self;
}

- (id)initWithHorizontal:(RCPXLayoutOrSwatch *)h square:(RCPXLayoutOrSwatch *)s vertical:(RCPXLayoutOrSwatch *)v {
    _horizontal = [h retain];
    _square = [s retain];
    _vertical = [v retain];
    return self;
}

- (void)setHorizontal:(RCPXLayoutOrSwatch *)h {
    [_horizontal release];
    _horizontal = [h retain];
}

- (void)setSquare:(RCPXLayoutOrSwatch *)s {
    [_square release];
    _square = [s retain];
}

- (void)setVertical:(RCPXLayoutOrSwatch *)v {
    [_vertical release];
    _vertical = [v retain];
}

- (RCPXLayoutOrSwatch *)layoutOrSwatchInRect:(NSRect)rect {
    if (rect.size.width > (rect.size.height * 1.5f)) return _horizontal;
    if (rect.size.height > (rect.size.width * 1.5f)) return _vertical;
    return _square;
}

- (NSColor *)colorAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)_ withColorList:(NSArray *)colors {
    return [[self layoutOrSwatchInRect:r] colorAtPoint:p inRect:r atRepeatIndex:0 withColorList:colors];
}

- (NSString *)nameAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)_ withColorList:(NSArray *)colors {
    return [[self layoutOrSwatchInRect:r] nameAtPoint:p inRect:r atRepeatIndex:0 withColorList:colors];
}

- (void)drawInRect:(NSRect)r withColor:(NSColor *)c atRepeatIndex:(NSInteger)_ withColorList:(NSArray *)colors {
    [[self layoutOrSwatchInRect:r] drawInRect:r withColor:c atRepeatIndex:0 withColorList:colors];
}

@end


@implementation RCPXRowOrColumn

- (void)addLayoutOrSwatch:(RCPXLayoutOrSwatch *)e {
    [self addLayoutOrSwatch:e withWeight:1];
}

- (void)addLayoutOrSwatch:(RCPXLayoutOrSwatch *)e withWeight:(NSInteger)w {
    [_children addObject:e];
    [_weights addObject:[NSNumber numberWithInteger:w]];
    _totalWeight += [e repeatCount] * w;
}

- (NSRect)rectInRect:(NSRect)r fromStartIndex:(NSInteger)i toEndIndex:(NSInteger)j ofMaxIndex:(NSInteger)max {
    return r;
}

- (NSColor *)colorAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)_ withColorList:(NSArray *)colors {
    NSInteger currentWeight = 0;
    for (NSInteger i = 0; i < [_children count]; i++) {
        RCPXLayoutOrSwatch *child = [_children objectAtIndex:i];
        NSInteger repeat = [child repeatCount];
        NSInteger weight = [[_weights objectAtIndex:i] integerValue];
        for (NSInteger j = 0; j < repeat; j++) {
            NSInteger nextWeight = currentWeight + weight;
            NSRect rect = [self rectInRect:r fromStartIndex:currentWeight toEndIndex:nextWeight ofMaxIndex:_totalWeight];
            if (NSPointInRect(p, rect)) return [child colorAtPoint:p inRect:rect atRepeatIndex:j withColorList:colors];
            currentWeight = nextWeight;
        }
    }
    return nil;
}

- (NSString *)nameAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)_ withColorList:(NSArray *)colors {
    NSInteger currentWeight = 0;
    for (NSInteger i = 0; i < [_children count]; i++) {
        RCPXLayoutOrSwatch *child = [_children objectAtIndex:i];
        NSInteger repeat = [child repeatCount];
        NSInteger weight = [[_weights objectAtIndex:i] integerValue];
        for (NSInteger j = 0; j < repeat; j++) {
            NSInteger nextWeight = currentWeight + weight;
            NSRect rect = [self rectInRect:r fromStartIndex:currentWeight toEndIndex:nextWeight ofMaxIndex:_totalWeight];
            if (NSPointInRect(p, rect)) return [child nameAtPoint:p inRect:rect atRepeatIndex:j withColorList:colors];
            currentWeight = nextWeight;
        }
    }
    return nil;
}

- (void)drawInRect:(NSRect)r withColor:(NSColor *)c atRepeatIndex:(NSInteger)_ withColorList:(NSArray *)colors {
    NSInteger currentWeight = 0;
    for (NSInteger i = 0; i < [_children count]; i++) {
        RCPXLayoutOrSwatch *child = [_children objectAtIndex:i];
        NSInteger repeat = [child repeatCount];
        NSInteger weight = [[_weights objectAtIndex:i] integerValue];
        for (NSInteger j = 0; j < repeat; j++) {
            NSInteger nextWeight = currentWeight + weight;
            NSRect rect = [self rectInRect:r fromStartIndex:currentWeight toEndIndex:nextWeight ofMaxIndex:_totalWeight];
            [child drawInRect:rect withColor:c atRepeatIndex:j withColorList:colors];
            currentWeight = nextWeight;
        }
    }
}

@end


@implementation RCPXRow

+ (RCPXRow *)row {
    return [[RCPXRow alloc]init];
}

- (void)dealloc {
    [_children release];
    [_weights release];
    [super dealloc];
}

- (id)init {
    _children = [[NSMutableArray array] retain];
    _weights = [[NSMutableArray array] retain];
    _totalWeight = 0;
    return self;
}

- (NSRect)rectInRect:(NSRect)r fromStartIndex:(NSInteger)i toEndIndex:(NSInteger)j ofMaxIndex:(NSInteger)max {
    CGFloat x1 = roundf(r.origin.x + (r.size.width - 1) * i / max);
    CGFloat x2 = roundf(r.origin.x + (r.size.width - 1) * j / max) + 1;
    return NSMakeRect(x1, r.origin.y, x2 - x1, r.size.height);
}

@end


@implementation RCPXColumn

+ (RCPXColumn *)column {
    return [[RCPXColumn alloc]init];
}

- (void)dealloc {
    [_children release];
    [_weights release];
    [super dealloc];
}

- (id)init {
    _children = [[NSMutableArray array] retain];
    _weights = [[NSMutableArray array] retain];
    _totalWeight = 0;
    return self;
}

- (NSRect)rectInRect:(NSRect)r fromStartIndex:(NSInteger)i toEndIndex:(NSInteger)j ofMaxIndex:(NSInteger)max {
    CGFloat y1 = roundf(r.origin.y + (r.size.height - 1) * i / max);
    CGFloat y2 = roundf(r.origin.y + (r.size.height - 1) * j / max) + 1;
    return NSMakeRect(r.origin.x, y1, r.size.width, y2 - y1);
}

@end


@implementation RCPXDiagonal

+ (RCPXDiagonal *)diagonalWithColumns:(NSInteger)cols rows:(NSInteger)rows square:(BOOL)square {
    return [[RCPXDiagonal alloc]initWithColumns:cols rows:rows square:square];
}

- (void)dealloc {
    [_children release];
    [_swatches release];
    [_repeatIndices release];
    [super dealloc];
}

- (id)initWithColumns:(NSInteger)cols rows:(NSInteger)rows square:(BOOL)square {
    _cols = cols;
    _rows = rows;
    _square = square;
    _children = [[NSMutableArray array] retain];
    _swatches = [[NSMutableArray array] retain];
    _repeatIndices = [[NSMutableArray array] retain];
    _swatchCount = 0;
    _bp = NSMakePoint(1, 1);
    _br = NSMakeRect(0, 0, 2, 2);
    return self;
}

- (void)addSwatch:(RCPXSwatch *)swatch {
    [_children addObject:swatch];
    NSInteger n = [swatch repeatCount];
    for (NSInteger i = 0; i < n; i++) {
        [_swatches addObject:swatch];
        [_repeatIndices addObject:[NSNumber numberWithInteger:i]];
    }
    _swatchCount += n;
}

- (void)calculateInRect:(NSRect)rect rect:(NSRect *)r width:(CGFloat *)w height:(CGFloat *)h {
    if (_square) {
        CGFloat _w = floorf((rect.size.width - 1) / (_cols + 1));
        CGFloat _h = floorf((rect.size.height - 1) / (_rows + 1));
        if (_w < _h) _h = _w; else if (_h < _w) _w = _h;
        rect.origin.x = floorf(rect.origin.x + (rect.size.width - (_w * (_cols + 1) + 1)) / 2);
        rect.origin.y = floorf(rect.origin.y + (rect.size.height - (_h * (_rows + 1) + 1)) / 2);
        rect.size.width = (_w * (_cols + 1) + 1);
        rect.size.height = (_h * (_rows + 1) + 1);
        *r = rect;
        *w = _w;
        *h = _h;
    } else {
        *r = rect;
        *w = (rect.size.width - 1) / (_cols + 1);
        *h = (rect.size.height - 1) / (_rows + 1);
    }
}

- (NSInteger)calculateIndexAtPoint:(NSPoint)p inRect:(NSRect)r withWidth:(CGFloat)w height:(CGFloat)h {
    NSInteger x = floorf((_cols + 1) * (p.x - r.origin.x) / r.size.width);
    NSInteger y = floorf((_rows + 1) * (p.y - r.origin.y) / r.size.height);
    if (x < 0) x = 0; else if (x > _cols) x = _cols;
    if (y < 0) y = 0; else if (y > _rows) y = _rows;
    NSInteger cw = floorf(w * (x+1)) - floorf(w * x);
    NSInteger ch = floorf(h * (y+1)) - floorf(h * y);
    NSInteger cx = floorf(w * x);
    NSInteger cy = floorf(h * y);
    NSRect cr = NSMakeRect(r.origin.x + cx, r.origin.y + cy, cw + 1, ch + 1);
    NSInteger i1 = ((_cols + 3) / 2) * (y + ((x + y) % 2)) + (x / 2);
    NSInteger i2 = ((_cols + 3) / 2) * (y + ((x + y + 1) % 2)) + ((x + 1) / 2);
    BOOL tlbr = !!((x + y) % 2);
    CGFloat mxf = (p.x - cr.origin.x) / cr.size.width;
    CGFloat myf = (p.y - cr.origin.y) / cr.size.height;
    return ((tlbr ? (mxf >= myf) : (mxf + myf >= 1)) ? i2 : i1);
}

- (void)drawDiagonalInRect:(NSRect)r withColor:(NSColor *)c tlbr:(BOOL)tlbr
        index1:(NSInteger)i1 index2:(NSInteger)i2 colorList:(NSArray *)colors
        appendingToLatticePath:(NSBezierPath *)latp
        selectionPath:(NSBezierPath *)selp
        selectionColor:(NSColor **)selc {
    NSColor *c1 = nil;
    NSColor *c2 = nil;
    if (i1 >= 0 && i1 < _swatchCount) {
        RCPXSwatch *sw = [_swatches objectAtIndex:i1];
        NSInteger ri = [[_repeatIndices objectAtIndex:i1] integerValue];
        if ((c1 = [sw colorAtPoint:_bp inRect:_br atRepeatIndex:ri withColorList:colors])) {
            NSBezierPath *s1 = [NSBezierPath bezierPath];
            if (tlbr) {
                // ◣
                [s1 moveToPoint:NSMakePoint(r.origin.x, r.origin.y)];
                [s1 lineToPoint:NSMakePoint(r.origin.x, r.origin.y + r.size.height)];
                [s1 lineToPoint:NSMakePoint(r.origin.x + r.size.width, r.origin.y + r.size.height)];
            } else {
                // ◤
                [s1 moveToPoint:NSMakePoint(r.origin.x, r.origin.y + r.size.height)];
                [s1 lineToPoint:NSMakePoint(r.origin.x, r.origin.y)];
                [s1 lineToPoint:NSMakePoint(r.origin.x + r.size.width, r.origin.y)];
            }
            [s1 closePath];
            [c1 setFill];
            [s1 fill];
            if (RCPXColorsEqual(c1, c)) {
                *selc = RCPXContrastingColor(c1);
                if (tlbr) {
                    // 🮢
                    [selp moveToPoint:NSMakePoint(r.origin.x + 0.5f, r.origin.y + 1.5f)];
                    [selp lineToPoint:NSMakePoint(r.origin.x + r.size.width - 1.5f, r.origin.y + r.size.height - 0.5f)];
                } else {
                    // 🮠
                    [selp moveToPoint:NSMakePoint(r.origin.x + r.size.width - 1.5f, r.origin.y + 0.5f)];
                    [selp lineToPoint:NSMakePoint(r.origin.x + 0.5f, r.origin.y + r.size.height - 1.5f)];
                }
            }
        }
    }
    if (i2 >= 0 && i2 < _swatchCount) {
        RCPXSwatch *sw = [_swatches objectAtIndex:i2];
        NSInteger ri = [[_repeatIndices objectAtIndex:i2] integerValue];
        if ((c2 = [sw colorAtPoint:_bp inRect:_br atRepeatIndex:ri withColorList:colors])) {
            NSBezierPath *s2 = [NSBezierPath bezierPath];
            if (tlbr) {
                // ◥
                [s2 moveToPoint:NSMakePoint(r.origin.x, r.origin.y)];
                [s2 lineToPoint:NSMakePoint(r.origin.x + r.size.width, r.origin.y)];
                [s2 lineToPoint:NSMakePoint(r.origin.x + r.size.width, r.origin.y + r.size.height)];
            } else {
                // ◢
                [s2 moveToPoint:NSMakePoint(r.origin.x, r.origin.y + r.size.height)];
                [s2 lineToPoint:NSMakePoint(r.origin.x + r.size.width, r.origin.y + r.size.height)];
                [s2 lineToPoint:NSMakePoint(r.origin.x + r.size.width, r.origin.y)];
            }
            [s2 closePath];
            [c2 setFill];
            [s2 fill];
            if (RCPXColorsEqual(c2, c)) {
                *selc = RCPXContrastingColor(c2);
                if (tlbr) {
                    // 🮡
                    [selp moveToPoint:NSMakePoint(r.origin.x + 1.5f, r.origin.y + 0.5f)];
                    [selp lineToPoint:NSMakePoint(r.origin.x + r.size.width - 0.5f, r.origin.y + r.size.height - 1.5f)];
                } else {
                    // 🮣
                    [selp moveToPoint:NSMakePoint(r.origin.x + r.size.width - 0.5f, r.origin.y + 1.5f)];
                    [selp lineToPoint:NSMakePoint(r.origin.x + 1.5f, r.origin.y + r.size.height - 0.5f)];
                }
            }
        }
    }
    if (c1 || c2) {
        if (tlbr) {
            // ╲
            [latp moveToPoint:NSMakePoint(r.origin.x + 0.5f, r.origin.y + 0.5f)];
            [latp lineToPoint:NSMakePoint(r.origin.x + r.size.width - 0.5f, r.origin.y + r.size.height - 0.5f)];
        } else {
            // ╱
            [latp moveToPoint:NSMakePoint(r.origin.x + r.size.width - 0.5f, r.origin.y + 0.5f)];
            [latp lineToPoint:NSMakePoint(r.origin.x + 0.5f, r.origin.y + r.size.height - 0.5f)];
        }
    }
}

- (NSColor *)colorAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)_ withColorList:(NSArray *)colors {
    CGFloat w, h;
    [self calculateInRect:r rect:&r width:&w height:&h];
    if (!NSPointInRect(p, r)) return nil;
    NSInteger i = [self calculateIndexAtPoint:p inRect:r withWidth:w height:h];
    if (i < 0 || i >= _swatchCount) return nil;
    RCPXSwatch *sw = [_swatches objectAtIndex:i];
    NSInteger ri = [[_repeatIndices objectAtIndex:i] integerValue];
    return [sw colorAtPoint:_bp inRect:_br atRepeatIndex:ri withColorList:colors];
}

- (NSString *)nameAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)_ withColorList:(NSArray *)colors {
    CGFloat w, h;
    [self calculateInRect:r rect:&r width:&w height:&h];
    if (!NSPointInRect(p, r)) return nil;
    NSInteger i = [self calculateIndexAtPoint:p inRect:r withWidth:w height:h];
    if (i < 0 || i >= _swatchCount) return nil;
    RCPXSwatch *sw = [_swatches objectAtIndex:i];
    NSInteger ri = [[_repeatIndices objectAtIndex:i] integerValue];
    return [sw nameAtPoint:_bp inRect:_br atRepeatIndex:ri withColorList:colors];
}

- (void)drawInRect:(NSRect)r withColor:(NSColor *)c atRepeatIndex:(NSInteger)_ withColorList:(NSArray *)colors {
    NSBezierPath *latp = [NSBezierPath bezierPath];
    NSBezierPath *selp = [NSBezierPath bezierPath];
    NSColor *selc = nil;
    CGFloat w, h;
    [self calculateInRect:r rect:&r width:&w height:&h];
    for (NSInteger y = 0; y <= _rows; y++) {
        for (NSInteger x = 0; x <= _cols; x++) {
            NSInteger cw = floorf(w * (x + 1)) - floorf(w * x);
            NSInteger ch = floorf(h * (y + 1)) - floorf(h * y);
            NSInteger cx = floorf(w * x);
            NSInteger cy = floorf(h * y);
            NSRect cr = NSMakeRect(r.origin.x + cx, r.origin.y + cy, cw + 1, ch + 1);
            NSInteger i1 = ((_cols + 3) / 2) * (y + ((x + y) % 2)) + (x / 2);
            NSInteger i2 = ((_cols + 3) / 2) * (y + ((x + y + 1) % 2)) + ((x + 1) / 2);
            BOOL tlbr = !!((x + y) % 2);
            [self drawDiagonalInRect:cr withColor:c tlbr:tlbr
                  index1:i1 index2:i2 colorList:colors
                  appendingToLatticePath:latp
                  selectionPath:selp
                  selectionColor:&selc];
        }
    }
    [[NSColor blackColor] setStroke];
    [latp setLineCapStyle:NSRoundLineCapStyle];
    [latp stroke];
    if (selc) {
        [selc setStroke];
        [selp setLineCapStyle:NSRoundLineCapStyle];
        [selp stroke];
    }
}

@end


@implementation RCPXPolygonal

+ (RCPXPolygonal *)polygonalWithColumns:(NSInteger)cols rows:(NSInteger)rows {
    return [[RCPXPolygonal alloc]initWithColumns:cols rows:rows];
}

- (void)dealloc {
    [_children release];
    [super dealloc];
}

- (id)initWithColumns:(NSInteger)cols rows:(NSInteger)rows {
    _cols = cols;
    _rows = rows;
    _children = [[NSMutableArray array] retain];
    return self;
}

- (void)addShape:(RCPXShape *)shape {
    [_children addObject:shape];
}

- (NSColor *)colorAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)_ withColorList:(NSArray *)colors {
    NSColor *ret = nil;
    NSColor *tmp;
    for (RCPXShape *child in _children) {
        if ([[child pathInRect:r withLocalWidth:_cols height:_rows] containsPoint:p]) {
            if ((tmp = [[colors objectAtIndex:[child index]] color])) {
                ret = tmp;
            }
        }
    }
    return ret;
}

- (NSString *)nameAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)_ withColorList:(NSArray *)colors {
    NSString *ret = nil;
    NSString *tmp;
    for (RCPXShape *child in _children) {
        if ([[child pathInRect:r withLocalWidth:_cols height:_rows] containsPoint:p]) {
            if ((tmp = [[colors objectAtIndex:[child index]] name])) {
                ret = tmp;
            }
        }
    }
    return ret;
}

- (void)drawInRect:(NSRect)r withColor:(NSColor *)c atRepeatIndex:(NSInteger)_ withColorList:(NSArray *)colors {
    NSAffineTransform *tx = [NSAffineTransform transform];
    [tx translateXBy:0.5f yBy:0.5f];
    for (RCPXShape *child in _children) {
        NSColor *_c = [[colors objectAtIndex:[child index]] color];
        NSBezierPath *path = [child pathInRect:r withLocalWidth:_cols height:_rows];
        [path transformUsingAffineTransform:tx];
        RCPXSetCheckerboardFill(); [path fill];
        [_c setFill]; [path fill];
        if (RCPXColorsEqual(_c, c)) {
            [[NSGraphicsContext currentContext] saveGraphicsState];
            [RCPXContrastingColor(_c) setStroke];
            [path addClip];
            [path setLineWidth:3];
            [path stroke];
            [[NSGraphicsContext currentContext] restoreGraphicsState];
        }
        [[NSColor blackColor] setStroke];
        [path setLineWidth:1];
        [path stroke];
    }
}

@end


@implementation RCPXOverlay

+ (RCPXOverlay *)overlay {
    return [[RCPXOverlay alloc]init];
}

- (void)dealloc {
    [_children release];
    [super dealloc];
}

- (id)init {
    _children = [[NSMutableArray array] retain];
    return self;
}

- (void)addLayoutOrSwatch:(RCPXLayoutOrSwatch *)e {
    [_children addObject:e];
}

- (NSColor *)colorAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)_ withColorList:(NSArray *)colors {
    NSColor *ret = nil;
    NSColor *tmp;
    for (RCPXLayoutOrSwatch *child in _children) {
        if ((tmp = [child colorAtPoint:p inRect:r atRepeatIndex:0 withColorList:colors])) {
            ret = tmp;
        }
    }
    return ret;
}

- (NSString *)nameAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)_ withColorList:(NSArray *)colors {
    NSString *ret = nil;
    NSString *tmp;
    for (RCPXLayoutOrSwatch *child in _children) {
        if ((tmp = [child nameAtPoint:p inRect:r atRepeatIndex:0 withColorList:colors])) {
            ret = tmp;
        }
    }
    return ret;
}

- (void)drawInRect:(NSRect)r withColor:(NSColor *)c atRepeatIndex:(NSInteger)_ withColorList:(NSArray *)colors {
    for (RCPXLayoutOrSwatch *child in _children) {
        [child drawInRect:r withColor:c atRepeatIndex:0 withColorList:colors];
    }
}

@end
