//
//  RCPXParser.m
//
//  Created by Rebecca Bettencourt on 6/11/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import "RCPXParser.h"
#import "RCPXColor.h"

@implementation RCPXParser

+ (RCPXParser *)parserWithContentsOfURL:(NSURL *)url {
    return [[RCPXParser alloc]initWithContentsOfURL:url];
}

- (void)dealloc {
    [_name release];
    [_colors release];
    [_layout release];
    [_layoutStack release];
    [_layoutNameStack release];
    [_layoutOrientStack release];
    [_layoutWeightStack release];
    [super dealloc];
}

- (id)initWithContentsOfURL:(NSURL *)url {
    [super initWithContentsOfURL:url];
    [super setShouldProcessNamespaces:NO];
    [super setShouldReportNamespacePrefixes:NO];
    [super setShouldResolveExternalEntities:NO];
    [super setDelegate:self];
    _name = [[url lastPathComponent] retain];
    _orientation = RCPXOrientationHorizontal;
    _hsize = NSMakeSize(289, 73);
    _ssize = NSMakeSize(145, 145);
    _vsize = NSMakeSize(73, 289);
    _colors = [[NSMutableArray array] retain];
    _ordered = NO;
    _layout = nil;
    _layoutStack = [[NSMutableArray array] retain];
    _layoutNameStack = [[NSMutableArray array] retain];
    _layoutOrientStack = [[NSMutableArray array] retain];
    _layoutWeightStack = [[NSMutableArray array] retain];
    return self;
}

- (void)addSwatch:(RCPXSwatch *)s {
    RCPXLayout *layout = [_layoutStack lastObject];
    RCPXLayoutType type = [[_layoutNameStack lastObject] integerValue];
    RCPXOrientation orient = [[_layoutOrientStack lastObject] integerValue];
    NSInteger weight = [[_layoutWeightStack lastObject] integerValue];
    switch (type) {
        case RCPXLayoutTypeOriented:
            switch (orient) {
                case RCPXOrientationHorizontal: [(RCPXOriented *)layout setHorizontal:s]; break;
                case RCPXOrientationSquare:     [(RCPXOriented *)layout setSquare:s];     break;
                case RCPXOrientationVertical:   [(RCPXOriented *)layout setVertical:s];   break;
            }
            break;
        case RCPXLayoutTypeRow:
        case RCPXLayoutTypeColumn:
            [(RCPXRowOrColumn *)layout addLayoutOrSwatch:s withWeight:weight];
            break;
        case RCPXLayoutTypeDiagonal:
            [(RCPXDiagonal *)layout addSwatch:s];
            break;
        case RCPXLayoutTypeOverlay:
            [(RCPXOverlay *)layout addLayoutOrSwatch:s];
            break;
    }
}

- (void)addShape:(RCPXShape *)s {
    RCPXLayout *layout = [_layoutStack lastObject];
    RCPXLayoutType type = [[_layoutNameStack lastObject] integerValue];
    switch (type) {
        case RCPXLayoutTypePolygonal:
            [(RCPXPolygonal *)layout addShape:s];
            break;
    }
}

- (void)addLayout:(RCPXLayout *)l {
    RCPXLayout *layout = [_layoutStack lastObject];
    RCPXLayoutType type = [[_layoutNameStack lastObject] integerValue];
    RCPXOrientation orient = [[_layoutOrientStack lastObject] integerValue];
    NSInteger weight = [[_layoutWeightStack lastObject] integerValue];
    switch (type) {
        case RCPXLayoutTypeOriented:
            switch (orient) {
                case RCPXOrientationHorizontal: [(RCPXOriented *)layout setHorizontal:l]; break;
                case RCPXOrientationSquare:     [(RCPXOriented *)layout setSquare:l];     break;
                case RCPXOrientationVertical:   [(RCPXOriented *)layout setVertical:l];   break;
            }
            break;
        case RCPXLayoutTypeRow:
        case RCPXLayoutTypeColumn:
            [(RCPXRowOrColumn *)layout addLayoutOrSwatch:l withWeight:weight];
            break;
        case RCPXLayoutTypeOverlay:
            [(RCPXOverlay *)layout addLayoutOrSwatch:l];
            break;
    }
}

- (void)pushLayout:(RCPXLayout *)layout ofType:(RCPXLayoutType)type {
    if (_layout) [self addLayout:layout];
    else _layout = [layout retain];
    [_layoutStack addObject:layout];
    [_layoutNameStack addObject:[NSNumber numberWithInteger:type]];
    [_layoutOrientStack addObject:[NSNumber numberWithInteger:RCPXOrientationHorizontal]];
    [_layoutWeightStack addObject:[NSNumber numberWithInteger:1]];
}

- (void)popLayoutOfType:(RCPXLayoutType)type {
    while ([_layoutStack count]) {
        RCPXLayoutType pt = [[_layoutNameStack lastObject] integerValue];
        [_layoutStack removeLastObject];
        [_layoutNameStack removeLastObject];
        [_layoutOrientStack removeLastObject];
        [_layoutWeightStack removeLastObject];
        if (pt == type) return;
    }
}

- (RCPXPalette *)parse {
    if ([super parse]) {
        [self popLayoutOfType:RCPXLayoutTypeNone];
        return [RCPXPalette paletteWithName:_name
                            orientation:_orientation
                            horizontalSize:_hsize
                            squareSize:_ssize
                            verticalSize:_vsize
                            colors:_colors
                            ordered:_ordered
                            layout:_layout];
    } else {
        return nil;
    }
}

- (void)parser:(NSXMLParser *)p didStartElement:(NSString *)e namespaceURI:(NSString *)n
        qualifiedName:(NSString *)q attributes:(NSDictionary *)a {
    NSString *ne = [e stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"startElement_%@:", ne]);
    if ([self respondsToSelector:sel]) [self performSelector:sel withObject:a];
}

- (void)parser:(NSXMLParser *)p didEndElement:(NSString *)e namespaceURI:(NSString *)n
        qualifiedName:(NSString *)q {
    NSString *ne = [e stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"endElement_%@", ne]);
    if ([self respondsToSelector:sel]) [self performSelector:sel];
}

// **** UTILITY METHODS FOR ATTRIBUTES **** //

static NSString * getString(NSDictionary * attr, NSString * key) {
    NSCharacterSet * cs = [NSCharacterSet whitespaceCharacterSet];
    return [[attr objectForKey:key] stringByTrimmingCharactersInSet:cs];
}

static NSInteger getInteger(NSDictionary * attr, NSString * key, NSInteger def) {
    NSString * s = getString(attr, key);
    if (s && [s length]) return [s integerValue];
    return def;
}

static CGFloat getFloat(NSDictionary * attr, NSString * key, CGFloat def) {
    NSString * s = getString(attr, key);
    if (s && [s length]) return [s floatValue];
    return def;
}

static BOOL getBoolean(NSDictionary * attr, NSString * key, NSString * t, NSString * f, BOOL def) {
    NSString * s = getString(attr, key);
    if (s && [s length]) {
        if ([s caseInsensitiveCompare:t] == NSOrderedSame) return YES;
        if ([s caseInsensitiveCompare:f] == NSOrderedSame) return NO;
    }
    return def;
}

static RCPXOrientation getOrientation(NSDictionary * attr, NSString * key) {
    NSString * s = getString(attr, key);
    if (s && [s length]) {
        if ([s caseInsensitiveCompare:@"h"] == NSOrderedSame) return RCPXOrientationHorizontal;
        if ([s caseInsensitiveCompare:@"horiz"] == NSOrderedSame) return RCPXOrientationHorizontal;
        if ([s caseInsensitiveCompare:@"horizontal"] == NSOrderedSame) return RCPXOrientationHorizontal;
        if ([s caseInsensitiveCompare:@"s"] == NSOrderedSame) return RCPXOrientationSquare;
        if ([s caseInsensitiveCompare:@"square"] == NSOrderedSame) return RCPXOrientationSquare;
        if ([s caseInsensitiveCompare:@"v"] == NSOrderedSame) return RCPXOrientationVertical;
        if ([s caseInsensitiveCompare:@"vert"] == NSOrderedSame) return RCPXOrientationVertical;
        if ([s caseInsensitiveCompare:@"vertical"] == NSOrderedSame) return RCPXOrientationVertical;
    }
    return RCPXOrientationHorizontal;
}

static RCPXRGBChannel getRGBChannel(NSDictionary * attr, NSString * key) {
    NSString * s = getString(attr, key);
    if (s && [s length]) {
        if ([s caseInsensitiveCompare:@"r"] == NSOrderedSame) return RCPXRGBChannelRed;
        if ([s caseInsensitiveCompare:@"red"] == NSOrderedSame) return RCPXRGBChannelRed;
        if ([s caseInsensitiveCompare:@"g"] == NSOrderedSame) return RCPXRGBChannelGreen;
        if ([s caseInsensitiveCompare:@"green"] == NSOrderedSame) return RCPXRGBChannelGreen;
        if ([s caseInsensitiveCompare:@"b"] == NSOrderedSame) return RCPXRGBChannelBlue;
        if ([s caseInsensitiveCompare:@"blue"] == NSOrderedSame) return RCPXRGBChannelBlue;
        if ([s caseInsensitiveCompare:@"a"] == NSOrderedSame) return RCPXRGBChannelAlpha;
        if ([s caseInsensitiveCompare:@"alpha"] == NSOrderedSame) return RCPXRGBChannelAlpha;
    }
    return RCPXRGBChannelNone;
}

static RCPXHSVChannel getHSVChannel(NSDictionary * attr, NSString * key) {
    NSString * s = getString(attr, key);
    if (s && [s length]) {
        if ([s caseInsensitiveCompare:@"h"] == NSOrderedSame) return RCPXHSVChannelHue;
        if ([s caseInsensitiveCompare:@"hue"] == NSOrderedSame) return RCPXHSVChannelHue;
        if ([s caseInsensitiveCompare:@"s"] == NSOrderedSame) return RCPXHSVChannelSaturation;
        if ([s caseInsensitiveCompare:@"saturation"] == NSOrderedSame) return RCPXHSVChannelSaturation;
        if ([s caseInsensitiveCompare:@"v"] == NSOrderedSame) return RCPXHSVChannelValue;
        if ([s caseInsensitiveCompare:@"value"] == NSOrderedSame) return RCPXHSVChannelValue;
        if ([s caseInsensitiveCompare:@"a"] == NSOrderedSame) return RCPXHSVChannelAlpha;
        if ([s caseInsensitiveCompare:@"alpha"] == NSOrderedSame) return RCPXHSVChannelAlpha;
    }
    return RCPXHSVChannelNone;
}

static CGFloat getFraction(NSDictionary * attr, NSString * key, CGFloat def) {
    NSString * s = getString(attr, key);
    if (s && [s length]) {
        NSArray * nd = [s componentsSeparatedByString:@"/"];
        if ([nd count] == 2) {
            NSCharacterSet * cs = [NSCharacterSet whitespaceCharacterSet];
            CGFloat n = [[[nd objectAtIndex:0] stringByTrimmingCharactersInSet:cs] floatValue];
            CGFloat d = [[[nd objectAtIndex:1] stringByTrimmingCharactersInSet:cs] floatValue];
            return n / d;
        }
        if ([s hasSuffix:@"%"]) {
            NSMutableCharacterSet *cs = [NSMutableCharacterSet whitespaceCharacterSet];
            [cs addCharactersInString:@"%"];
            CGFloat p = [[s stringByTrimmingCharactersInSet:cs] floatValue];
            return p / 100.0f;
        }
        return [s floatValue];
    }
    return def;
}

static RCPXBorder * getBorder(NSDictionary * attr, NSString * key, RCPXBorder * def) {
    NSString * s = getString(attr, key);
    if (s && [s length]) {
        BOOL t = NO, l = NO, b = NO, r = NO;
        for (NSInteger i = 0; i < [s length]; i++) {
            switch ([s characterAtIndex:i]) {
                case 'T': case 't': case 'N': case 'n': case '~': t = YES; break;
                case 'L': case 'l': case 'W': case 'w': case '[': l = YES; break;
                case 'B': case 'b': case 'S': case 's': case '_': b = YES; break;
                case 'R': case 'r': case 'E': case 'e': case ']': r = YES; break;
                case 'H': case 'h': case '=': t = b = YES; break;
                case 'V': case 'v': case '|': l = r = YES; break;
                case 'D': case 'd': case '*': return def;
                case 'A': case 'a': case '#': return [RCPXBorder borderWithAll];
                case 'Z': case 'z': case '0': return [RCPXBorder borderWithNone];
            }
        }
        return [RCPXBorder borderWithTop:t left:l bottom:b right:r];
    }
    return def;
}

// **** ELEMENT EVENT HANDLERS **** //

- (void)startElement_palette:(NSDictionary *)attr {
    NSString *name = getString(attr, @"name");
    if (name && [name length]) _name = [name retain];
    _orientation = getOrientation(attr, @"orientation");
    _hsize.width = getFloat(attr, @"hwidth", 289);
    _hsize.height = getFloat(attr, @"hheight", 73);
    _ssize.width = getFloat(attr, @"swidth", 145);
    _ssize.height = getFloat(attr, @"sheight", 145);
    _vsize.width = getFloat(attr, @"vwidth", 73);
    _vsize.height = getFloat(attr, @"vheight", 289);
}

- (void)startElement_colors:(NSDictionary *)attr {
    _ordered = getBoolean(attr, @"ordered", @"ordered", @"unordered", NO);
}

// **** COLORS **** //

- (void)startElement_rgb:(NSDictionary *)attr {
    CGFloat r = getFloat(attr, @"r", 0) / 255.0f;
    CGFloat g = getFloat(attr, @"g", 0) / 255.0f;
    CGFloat b = getFloat(attr, @"b", 0) / 255.0f;
    NSColor *c = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:1];
    NSString *n = getString(attr, @"name");
    [_colors addObject:[RCPXColor colorWithColor:c name:n]];
}

- (void)startElement_rgb16:(NSDictionary *)attr {
    CGFloat r = getFloat(attr, @"r", 0) / 65535.0f;
    CGFloat g = getFloat(attr, @"g", 0) / 65535.0f;
    CGFloat b = getFloat(attr, @"b", 0) / 65535.0f;
    NSColor *c = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:1];
    NSString *n = getString(attr, @"name");
    [_colors addObject:[RCPXColor colorWithColor:c name:n]];
}

- (void)startElement_rgbd:(NSDictionary *)attr {
    CGFloat r = getFraction(attr, @"r", 0);
    CGFloat g = getFraction(attr, @"g", 0);
    CGFloat b = getFraction(attr, @"b", 0);
    NSColor *c = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:1];
    NSString *n = getString(attr, @"name");
    [_colors addObject:[RCPXColor colorWithColor:c name:n]];
}

- (void)startElement_rgba:(NSDictionary *)attr {
    CGFloat r = getFloat(attr, @"r", 0) / 255.0f;
    CGFloat g = getFloat(attr, @"g", 0) / 255.0f;
    CGFloat b = getFloat(attr, @"b", 0) / 255.0f;
    CGFloat a = getFloat(attr, @"a", 0) / 255.0f;
    NSColor *c = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a];
    NSString *n = getString(attr, @"name");
    [_colors addObject:[RCPXColor colorWithColor:c name:n]];
}

- (void)startElement_rgba16:(NSDictionary *)attr {
    CGFloat r = getFloat(attr, @"r", 0) / 65535.0f;
    CGFloat g = getFloat(attr, @"g", 0) / 65535.0f;
    CGFloat b = getFloat(attr, @"b", 0) / 65535.0f;
    CGFloat a = getFloat(attr, @"a", 0) / 65535.0f;
    NSColor *c = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a];
    NSString *n = getString(attr, @"name");
    [_colors addObject:[RCPXColor colorWithColor:c name:n]];
}

- (void)startElement_rgbad:(NSDictionary *)attr {
    CGFloat r = getFraction(attr, @"r", 0);
    CGFloat g = getFraction(attr, @"g", 0);
    CGFloat b = getFraction(attr, @"b", 0);
    CGFloat a = getFraction(attr, @"a", 0);
    NSColor *c = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a];
    NSString *n = getString(attr, @"name");
    [_colors addObject:[RCPXColor colorWithColor:c name:n]];
}

- (void)startElement_hsv:(NSDictionary *)attr {
    CGFloat h = getFloat(attr, @"h", 0) / 360.0f;
    CGFloat s = getFloat(attr, @"s", 0) / 100.0f;
    CGFloat v = getFloat(attr, @"v", 0) / 100.0f;
    NSColor *c = [NSColor colorWithCalibratedHue:h saturation:s brightness:v alpha:1];
    NSString *n = getString(attr, @"name");
    [_colors addObject:[RCPXColor colorWithColor:c name:n]];
}

- (void)startElement_hsva:(NSDictionary *)attr {
    CGFloat h = getFloat(attr, @"h", 0) / 360.0f;
    CGFloat s = getFloat(attr, @"s", 0) / 100.0f;
    CGFloat v = getFloat(attr, @"v", 0) / 100.0f;
    CGFloat a = getFloat(attr, @"a", 0) / 100.0f;
    NSColor *c = [NSColor colorWithCalibratedHue:h saturation:s brightness:v alpha:a];
    NSString *n = getString(attr, @"name");
    [_colors addObject:[RCPXColor colorWithColor:c name:n]];
}

- (void)startElement_gray:(NSDictionary *)attr {
    CGFloat v = getFloat(attr, @"v", 0) / 100.0f;
    NSColor *c = [NSColor colorWithCalibratedWhite:v alpha:1];
    NSString *n = getString(attr, @"name");
    [_colors addObject:[RCPXColor colorWithColor:c name:n]];
}

- (void)startElement_grayalpha:(NSDictionary *)attr {
    CGFloat v = getFloat(attr, @"v", 0) / 100.0f;
    CGFloat a = getFloat(attr, @"a", 0) / 100.0f;
    NSColor *c = [NSColor colorWithCalibratedWhite:v alpha:a];
    NSString *n = getString(attr, @"name");
    [_colors addObject:[RCPXColor colorWithColor:c name:n]];
}

- (void)startElement_cmyk:(NSDictionary *)attr {
    CGFloat c = getFloat(attr, @"c", 0) / 100.0f;
    CGFloat m = getFloat(attr, @"m", 0) / 100.0f;
    CGFloat y = getFloat(attr, @"y", 0) / 100.0f;
    CGFloat k = getFloat(attr, @"k", 0) / 100.0f;
    NSColor *col = [NSColor colorWithDeviceCyan:c magenta:m yellow:y black:k alpha:1];
    NSString *n = getString(attr, @"name");
    [_colors addObject:[RCPXColor colorWithColor:col name:n]];
}

- (void)startElement_cmyka:(NSDictionary *)attr {
    CGFloat c = getFloat(attr, @"c", 0) / 100.0f;
    CGFloat m = getFloat(attr, @"m", 0) / 100.0f;
    CGFloat y = getFloat(attr, @"y", 0) / 100.0f;
    CGFloat k = getFloat(attr, @"k", 0) / 100.0f;
    CGFloat a = getFloat(attr, @"a", 0) / 100.0f;
    NSColor *col = [NSColor colorWithDeviceCyan:c magenta:m yellow:y black:k alpha:a];
    NSString *n = getString(attr, @"name");
    [_colors addObject:[RCPXColor colorWithColor:col name:n]];
}

// **** LAB COLOR **** //

// D65 illuminant
static const CGFloat X = 0.95047f;
static const CGFloat Y = 1.0f;
static const CGFloat Z = 1.08883f;

// CIELab -> CIEXYZ
static const CGFloat T1 = 6.0f / 29.0f;
static const CGFloat M1 = 108.0f / 841.0f;
static const CGFloat B1 = 4.0f / 29.0f;
static CGFloat f1(CGFloat t) {
    if (t > T1) return t * t * t;
    else return M1 * (t - B1);
}

// linear RGB -> sRGB
static const CGFloat ST1 = 0.0031308f;
static const CGFloat SL1 = 12.92f;
static const double SM1 = 1.055;
static const double SG1 = 1.0 / 2.4;
static const double SB1 = 0.055;
static CGFloat sf1(CGFloat t) {
    if (t <= ST1) return SL1 * t;
    else return SM1 * pow(t, SG1) - SB1;
}

static CGFloat min4(CGFloat a, CGFloat b, CGFloat c, CGFloat d) {
    CGFloat e = a < b ? a : b;
    CGFloat f = c < d ? c : d;
    return e < f ? e : f;
}

static CGFloat max4(CGFloat a, CGFloat b, CGFloat c, CGFloat d) {
    CGFloat e = a > b ? a : b;
    CGFloat f = c > d ? c : d;
    return e > f ? e : f;
}

- (void)startElement_lab:(NSDictionary *)attr {
    // Get components
    CGFloat l = getFloat(attr, @"l", 0);
    CGFloat a = getFloat(attr, @"a", 0);
    CGFloat b = getFloat(attr, @"b", 0);
    // CIELab -> CIEXYZ
    CGFloat w = (l + 16.0f) / 116.0f;
    CGFloat x = X * f1(w + a / 500.0f);
    CGFloat y = Y * f1(w);
    CGFloat z = Z * f1(w - b / 200.0f);
    // CIEXYZ -> linear RGB
    CGFloat lr = +3.2406f * x -1.5372f * y -0.4986f * z;
    CGFloat lg = -0.9689f * x +1.8758f * y +0.0415f * z;
    CGFloat lb = +0.0557f * x -0.2040f * y +1.0570f * z;
    // linear RGB -> sRGB
    CGFloat sr = sf1(lr), sg = sf1(lg), sb = sf1(lb);
    CGFloat min = min4(sr, sg, sb, 0);
    CGFloat max = max4(sr, sg, sb, 1);
    sr = (sr - min) / (max - min);
    sg = (sg - min) / (max - min);
    sb = (sb - min) / (max - min);
    NSColor *c = [NSColor colorWithCalibratedRed:sr green:sg blue:sb alpha:1];
    NSString *n = getString(attr, @"name");
    [_colors addObject:[RCPXColor colorWithColor:c name:n]];
}

// **** LAYOUTS **** //

- (void)startElement_oriented:(NSDictionary *)attr {
    RCPXOriented *layout = [RCPXOriented oriented];
    [self pushLayout:layout ofType:RCPXLayoutTypeOriented];
}

- (void)startElement_horizontal:(NSDictionary *)attr {
    if ([_layoutOrientStack count]) {
        [_layoutOrientStack removeLastObject];
        [_layoutOrientStack addObject:[NSNumber numberWithInteger:RCPXOrientationHorizontal]];
    }
}

- (void)startElement_square:(NSDictionary *)attr {
    if ([_layoutOrientStack count]) {
        [_layoutOrientStack removeLastObject];
        [_layoutOrientStack addObject:[NSNumber numberWithInteger:RCPXOrientationSquare]];
    }
}

- (void)startElement_vertical:(NSDictionary *)attr {
    if ([_layoutOrientStack count]) {
        [_layoutOrientStack removeLastObject];
        [_layoutOrientStack addObject:[NSNumber numberWithInteger:RCPXOrientationVertical]];
    }
}

- (void)endElement_oriented {
    [self popLayoutOfType:RCPXLayoutTypeOriented];
}

- (void)startElement_row:(NSDictionary *)attr {
    RCPXRow *layout = [RCPXRow row];
    [self pushLayout:layout ofType:RCPXLayoutTypeRow];
}

- (void)startElement_column:(NSDictionary *)attr {
    RCPXColumn *layout = [RCPXColumn column];
    [self pushLayout:layout ofType:RCPXLayoutTypeColumn];
}

- (void)startElement_weighted:(NSDictionary *)attr {
    if ([_layoutWeightStack count]) {
        [_layoutWeightStack removeLastObject];
        [_layoutWeightStack addObject:[NSNumber numberWithInteger:getInteger(attr, @"weight", 1)]];
    }
}

- (void)endElement_weighted {
    if ([_layoutWeightStack count]) {
        [_layoutWeightStack removeLastObject];
        [_layoutWeightStack addObject:[NSNumber numberWithInteger:1]];
    }
}

- (void)endElement_row {
    [self popLayoutOfType:RCPXLayoutTypeRow];
}

- (void)endElement_column {
    [self popLayoutOfType:RCPXLayoutTypeColumn];
}

- (void)startElement_diagonal:(NSDictionary *)attr {
    NSInteger cols = getInteger(attr, @"cols", 2);
    NSInteger rows = getInteger(attr, @"rows", 2);
    BOOL square = getBoolean(attr, @"aspect", @"square", @"auto", NO);
    RCPXDiagonal *layout = [RCPXDiagonal diagonalWithColumns:cols rows:rows square:square];
    [self pushLayout:layout ofType:RCPXLayoutTypeDiagonal];
}

- (void)endElement_diagonal {
    [self popLayoutOfType:RCPXLayoutTypeDiagonal];
}

- (void)startElement_polygonal:(NSDictionary *)attr {
    NSInteger cols = getInteger(attr, @"cols", 2);
    NSInteger rows = getInteger(attr, @"rows", 2);
    RCPXPolygonal *layout = [RCPXPolygonal polygonalWithColumns:cols rows:rows];
    [self pushLayout:layout ofType:RCPXLayoutTypePolygonal];
}

- (void)endElement_polygonal {
    [self popLayoutOfType:RCPXLayoutTypePolygonal];
}

- (void)startElement_overlay:(NSDictionary *)attr {
    RCPXOverlay *layout = [RCPXOverlay overlay];
    [self pushLayout:layout ofType:RCPXLayoutTypeOverlay];
}

- (void)endElement_overlay {
    [self popLayoutOfType:RCPXLayoutTypeOverlay];
}

// **** SWATCHES **** //

- (void)startElement_empty:(NSDictionary *)attr {
    NSInteger repeat = getInteger(attr, @"repeat", 1);
    RCPXEmpty *swatch = [RCPXEmpty emptyWithRepeatCount:repeat];
    [self addSwatch:swatch];
}

- (void)startElement_index:(NSDictionary *)attr {
    NSInteger i = getInteger(attr, @"i", 0);
    NSInteger repeat = getInteger(attr, @"repeat", 1);
    RCPXBorder *border = getBorder(attr, @"border", [RCPXBorder borderWithAll]);
    RCPXBorder *borderOnly = getBorder(attr, @"border-only", border);
    RCPXBorder *borderFirst = getBorder(attr, @"border-first", border);
    RCPXBorder *borderMiddle = getBorder(attr, @"border-middle", border);
    RCPXBorder *borderLast = getBorder(attr, @"border-last", border);
    RCPXIndex *swatch = [RCPXIndex indexWithIndex:i
                                   repeatCount:repeat
                                   borderOnly:borderOnly
                                   borderFirst:borderFirst
                                   borderMiddle:borderMiddle
                                   borderLast:borderLast];
    [self addSwatch:swatch];
}

- (void)startElement_range:(NSDictionary *)attr {
    NSInteger start = getInteger(attr, @"start", 0);
    NSInteger end = getInteger(attr, @"end", 0);
    RCPXBorder *border = getBorder(attr, @"border", [RCPXBorder borderWithAll]);
    RCPXBorder *borderOnly = getBorder(attr, @"border-only", border);
    RCPXBorder *borderFirst = getBorder(attr, @"border-first", border);
    RCPXBorder *borderMiddle = getBorder(attr, @"border-middle", border);
    RCPXBorder *borderLast = getBorder(attr, @"border-last", border);
    RCPXRange *swatch = [RCPXRange rangeWithStart:start end:end
                                   borderOnly:borderOnly
                                   borderFirst:borderFirst
                                   borderMiddle:borderMiddle
                                   borderLast:borderLast];
    [self addSwatch:swatch];
}

- (void)startElement_rgb_sweep:(NSDictionary *)attr {
    RCPXRGBChannel xchan = getRGBChannel(attr, @"xchan");
    CGFloat xmin = getFloat(attr, @"xmin", 0) / 255.0f;
    CGFloat xmax = getFloat(attr, @"xmax", 255) / 255.0f;
    RCPXRGBChannel ychan = getRGBChannel(attr, @"ychan");
    CGFloat ymin = getFloat(attr, @"ymin", 0) / 255.0f;
    CGFloat ymax = getFloat(attr, @"ymax", 255) / 255.0f;
    CGFloat r = getFloat(attr, @"r", 0) / 255.0f;
    CGFloat g = getFloat(attr, @"g", 0) / 255.0f;
    CGFloat b = getFloat(attr, @"b", 0) / 255.0f;
    RCPXBorder *border = getBorder(attr, @"border", [RCPXBorder borderWithAll]);
    RCPXRGBSweep *swatch = [RCPXRGBSweep rgbSweepWithXChannel:xchan xMin:xmin xMax:xmax
                                                     yChannel:ychan yMin:ymin yMax:ymax
                                                     red:r green:g blue:b border:border];
    [self addSwatch:swatch];
}

- (void)startElement_hsv_sweep:(NSDictionary *)attr {
    RCPXHSVChannel xchan = getHSVChannel(attr, @"xchan");
    CGFloat xdenom = ((xchan == RCPXHSVChannelHue) ? 360 : 100);
    CGFloat xmin = getFloat(attr, @"xmin", 0) / xdenom;
    CGFloat xmax = getFloat(attr, @"xmax", xdenom) / xdenom;
    RCPXHSVChannel ychan = getHSVChannel(attr, @"ychan");
    CGFloat ydenom = ((ychan == RCPXHSVChannelHue) ? 360 : 100);
    CGFloat ymin = getFloat(attr, @"ymin", 0) / ydenom;
    CGFloat ymax = getFloat(attr, @"ymax", ydenom) / ydenom;
    CGFloat h = getFloat(attr, @"h", 0) / 360.0f;
    CGFloat s = getFloat(attr, @"s", 0) / 100.0f;
    CGFloat v = getFloat(attr, @"v", 0) / 100.0f;
    RCPXBorder *border = getBorder(attr, @"border", [RCPXBorder borderWithAll]);
    RCPXHSVSweep *swatch = [RCPXHSVSweep hsvSweepWithXChannel:xchan xMin:xmin xMax:xmax
                                                     yChannel:ychan yMin:ymin yMax:ymax
                                                     hue:h saturation:s value:v border:border];
    [self addSwatch:swatch];
}

// **** SHAPES **** //

- (void)startElement_rect:(NSDictionary *)attr {
    CGFloat x = getFloat(attr, @"x", 0);
    CGFloat y = getFloat(attr, @"y", 0);
    CGFloat w = getFloat(attr, @"w", 1);
    CGFloat h = getFloat(attr, @"h", 1);
    NSInteger i = getInteger(attr, @"i", 0);
    RCPXShape *shape = [RCPXRect rectWithX:x y:y width:w height:h index:i];
    [self addShape:shape];
}

- (void)startElement_rectangle:(NSDictionary *)attr {
    [self startElement_rect:attr];
}

- (void)startElement_diam:(NSDictionary *)attr {
    CGFloat cx = getFloat(attr, @"cx", 0);
    CGFloat cy = getFloat(attr, @"cy", 0);
    CGFloat w = getFloat(attr, @"w", 2);
    CGFloat h = getFloat(attr, @"h", 2);
    NSInteger i = getInteger(attr, @"i", 0);
    RCPXShape *shape = [RCPXDiam diamWithCenterX:cx centerY:cy width:w height:h index:i];
    [self addShape:shape];
}

- (void)startElement_diamond:(NSDictionary *)attr {
    [self startElement_diam:attr];
}

- (void)startElement_tri:(NSDictionary *)attr {
    RCPXTriDirection dir = RCPXTriDirectionUp;
    NSString *dirs = getString(attr, @"dir");
    if (dirs && [dirs length]) {
        if ([dirs caseInsensitiveCompare:@"d"] == NSOrderedSame) dir = RCPXTriDirectionDown;
        if ([dirs caseInsensitiveCompare:@"l"] == NSOrderedSame) dir = RCPXTriDirectionLeft;
        if ([dirs caseInsensitiveCompare:@"r"] == NSOrderedSame) dir = RCPXTriDirectionRight;
        if ([dirs caseInsensitiveCompare:@"down"] == NSOrderedSame) dir = RCPXTriDirectionDown;
        if ([dirs caseInsensitiveCompare:@"left"] == NSOrderedSame) dir = RCPXTriDirectionLeft;
        if ([dirs caseInsensitiveCompare:@"right"] == NSOrderedSame) dir = RCPXTriDirectionRight;
    }
    CGFloat bcx = getFloat(attr, @"bcx", 0);
    CGFloat bcy = getFloat(attr, @"bcy", 0);
    CGFloat w = getFloat(attr, @"w", 2);
    CGFloat h = getFloat(attr, @"h", 2);
    NSInteger i = getInteger(attr, @"i", 0);
    RCPXShape *shape = [RCPXTri triWithBaseCenterX:bcx
                                       baseCenterY:bcy
                                       width:w height:h
                                       direction:dir index:i];
    [self addShape:shape];
}

- (void)startElement_triangle:(NSDictionary *)attr {
    [self startElement_tri:attr];
}

- (void)startElement_hex:(NSDictionary *)attr {
    RCPXHexDirection dir = RCPXHexDirectionHorizontal;
    NSString *dirs = getString(attr, @"dir");
    if (dirs && [dirs length]) {
        if ([dirs caseInsensitiveCompare:@"v"] == NSOrderedSame) dir = RCPXHexDirectionVertical;
        if ([dirs caseInsensitiveCompare:@"vert"] == NSOrderedSame) dir = RCPXHexDirectionVertical;
        if ([dirs caseInsensitiveCompare:@"vertical"] == NSOrderedSame) dir = RCPXHexDirectionVertical;
    }
    CGFloat cx = getFloat(attr, @"cx", 0);
    CGFloat cy = getFloat(attr, @"cy", 0);
    CGFloat w = getFloat(attr, @"w", 2);
    CGFloat h = getFloat(attr, @"h", 2);
    NSInteger i = getInteger(attr, @"i", 0);
    RCPXShape *shape = [RCPXHex hexWithCenterX:cx centerY:cy
                                width:w height:h
                                direction:dir index:i];
    [self addShape:shape];
}

- (void)startElement_hexagon:(NSDictionary *)attr {
    [self startElement_hex:attr];
}

- (void)startElement_poly:(NSDictionary *)attr {
    NSString *pts = getString(attr, @"p");
    NSInteger i = getInteger(attr, @"i", 0);
    RCPXShape *shape = [RCPXPoly polyWithPointsString:(pts ? pts : @"") index:i];
    [self addShape:shape];
}

- (void)startElement_polygon:(NSDictionary *)attr {
    [self startElement_poly:attr];
}

- (void)startElement_ellipse:(NSDictionary *)attr {
    CGFloat cx = getFloat(attr, @"cx", 0);
    CGFloat cy = getFloat(attr, @"cy", 0);
    CGFloat w = getFloat(attr, @"w", 2);
    CGFloat h = getFloat(attr, @"h", 2);
    NSInteger i = getInteger(attr, @"i", 0);
    RCPXShape *shape = [RCPXEllipse ellipseWithCenterX:cx centerY:cy width:w height:h index:i];
    [self addShape:shape];
}

@end
