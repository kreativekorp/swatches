//
//  RCPXShape.m
//
//  Created by Rebecca Bettencourt on 6/9/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import "RCPXShape.h"

@implementation RCPXShape

- (NSBezierPath *)pathInRect:(NSRect)rect withLocalWidth:(CGFloat)lw height:(CGFloat)lh {
    return nil;
}

- (NSInteger)index {
    return _index;
}

@end


@implementation RCPXRect

+ (RCPXRect *)rectWithX:(CGFloat)x y:(CGFloat)y width:(CGFloat)w height:(CGFloat)h index:(NSInteger)i {
    return [[RCPXRect alloc]initWithX:x y:y width:w height:h index:i];
}

- (id)initWithX:(CGFloat)x y:(CGFloat)y width:(CGFloat)w height:(CGFloat)h index:(NSInteger)i {
    _x = x;
    _y = y;
    _width = w;
    _height = h;
    _index = i;
    return self;
}

- (NSBezierPath *)pathInRect:(NSRect)rect withLocalWidth:(CGFloat)lw height:(CGFloat)lh {
    CGFloat x1 = rect.origin.x + roundf((rect.size.width - 1) * _x / lw);
    CGFloat y1 = rect.origin.y + roundf((rect.size.height - 1) * _y / lh);
    CGFloat x2 = rect.origin.x + roundf((rect.size.width - 1) * (_x + _width) / lw);
    CGFloat y2 = rect.origin.y + roundf((rect.size.height - 1) * (_y + _height) / lh);
    NSRect r = NSMakeRect(x1 < x2 ? x1 : x2, y1 < y2 ? y1 : y2, fabsf(x2 - x1), fabsf(y2 - y1));
    return [NSBezierPath bezierPathWithRect:r];
}

@end


@implementation RCPXDiam

+ (RCPXDiam *)diamWithCenterX:(CGFloat)cx centerY:(CGFloat)cy width:(CGFloat)w height:(CGFloat)h index:(NSInteger)i {
    return [[RCPXDiam alloc]initWithCenterX:cx centerY:cy width:w height:h index:i];
}

- (id)initWithCenterX:(CGFloat)cx centerY:(CGFloat)cy width:(CGFloat)w height:(CGFloat)h index:(NSInteger)i {
    _cx = cx;
    _cy = cy;
    _width = w;
    _height = h;
    _index = i;
    return self;
}

- (NSBezierPath *)pathInRect:(NSRect)rect withLocalWidth:(CGFloat)lw height:(CGFloat)lh {
    CGFloat x1 = rect.origin.x + roundf((rect.size.width - 1) * (_cx - _width / 2) / lw);
    CGFloat y1 = rect.origin.y + roundf((rect.size.height - 1) * (_cy - _height / 2) / lh);
    CGFloat x2 = rect.origin.x + roundf((rect.size.width - 1) * _cx / lw);
    CGFloat y2 = rect.origin.y + roundf((rect.size.height - 1) * _cy / lh);
    CGFloat x3 = rect.origin.x + roundf((rect.size.width - 1) * (_cx + _width / 2) / lw);
    CGFloat y3 = rect.origin.y + roundf((rect.size.height - 1) * (_cy + _height / 2) / lh);
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(x2, y1)];
    [path lineToPoint:NSMakePoint(x3, y2)];
    [path lineToPoint:NSMakePoint(x2, y3)];
    [path lineToPoint:NSMakePoint(x1, y2)];
    [path closePath];
    [path setLineJoinStyle:NSRoundLineJoinStyle];
    return path;
}

@end


@implementation RCPXTri

+ (RCPXTri *)triWithBaseCenterX:(CGFloat)bcx baseCenterY:(CGFloat)bcy width:(CGFloat)w height:(CGFloat)h direction:(RCPXTriDirection)dir index:(NSInteger)i {
    return [[RCPXTri alloc]initWithBaseCenterX:bcx baseCenterY:bcy width:w height:h direction:dir index:i];
}

- (id)initWithBaseCenterX:(CGFloat)bcx baseCenterY:(CGFloat)bcy width:(CGFloat)w height:(CGFloat)h direction:(RCPXTriDirection)dir index:(NSInteger)i {
    _bcx = bcx;
    _bcy = bcy;
    _width = w;
    _height = h;
    _dir = dir;
    _index = i;
    return self;
}

- (NSBezierPath *)pathInRect:(NSRect)rect withLocalWidth:(CGFloat)lw height:(CGFloat)lh {
    CGFloat x1, y1, x2, y2, x3, y3;
    switch (_dir) {
        default:
            x1 = rect.origin.x + roundf((rect.size.width - 1) * (_bcx - _width / 2) / lw);
            x2 = rect.origin.x + roundf((rect.size.width - 1) * _bcx / lw);
            x3 = rect.origin.x + roundf((rect.size.width - 1) * (_bcx + _width / 2) / lw);
            y1 = y3 = rect.origin.y + roundf((rect.size.height - 1) * _bcy / lh);
            y2 = rect.origin.y + roundf((rect.size.height - 1) * (_bcy - _height) / lh);
            break;
        case RCPXTriDirectionDown:
            x1 = rect.origin.x + roundf((rect.size.width - 1) * (_bcx + _width / 2) / lw);
            x2 = rect.origin.x + roundf((rect.size.width - 1) * _bcx / lw);
            x3 = rect.origin.x + roundf((rect.size.width - 1) * (_bcx - _width / 2) / lw);
            y1 = y3 = rect.origin.y + roundf((rect.size.height - 1) * _bcy / lh);
            y2 = rect.origin.y + roundf((rect.size.height - 1) * (_bcy + _height) / lh);
            break;
        case RCPXTriDirectionLeft:
            y1 = rect.origin.y + roundf((rect.size.height - 1) * (_bcy + _height / 2) / lh);
            y2 = rect.origin.y + roundf((rect.size.height - 1) * _bcy / lh);
            y3 = rect.origin.y + roundf((rect.size.height - 1) * (_bcy - _height / 2) / lh);
            x1 = x3 = rect.origin.x + roundf((rect.size.width - 1) * _bcx / lw);
            x2 = rect.origin.x + roundf((rect.size.width - 1) * (_bcx - _width) / lw);
            break;
        case RCPXTriDirectionRight:
            y1 = rect.origin.y + roundf((rect.size.height - 1) * (_bcy - _height / 2) / lh);
            y2 = rect.origin.y + roundf((rect.size.height - 1) * _bcy / lh);
            y3 = rect.origin.y + roundf((rect.size.height - 1) * (_bcy + _height / 2) / lh);
            x1 = x3 = rect.origin.x + roundf((rect.size.width - 1) * _bcx / lw);
            x2 = rect.origin.x + roundf((rect.size.width - 1) * (_bcx + _width) / lw);
            break;
    }
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(x1, y1)];
    [path lineToPoint:NSMakePoint(x2, y2)];
    [path lineToPoint:NSMakePoint(x3, y3)];
    [path closePath];
    [path setLineJoinStyle:NSRoundLineJoinStyle];
    return path;
}

@end


@implementation RCPXHex

+ (RCPXHex *)hexWithCenterX:(CGFloat)cx centerY:(CGFloat)cy width:(CGFloat)w height:(CGFloat)h direction:(RCPXHexDirection)dir index:(NSInteger)i {
    return [[RCPXHex alloc]initWithCenterX:cx centerY:cy width:w height:h direction:dir index:i];
}

- (id)initWithCenterX:(CGFloat)cx centerY:(CGFloat)cy width:(CGFloat)w height:(CGFloat)h direction:(RCPXHexDirection)dir index:(NSInteger)i {
    _cx = cx;
    _cy = cy;
    _width = w;
    _height = h;
    _dir = dir;
    _index = i;
    return self;
}

- (NSBezierPath *)pathInRect:(NSRect)rect withLocalWidth:(CGFloat)lw height:(CGFloat)lh {
    CGFloat x1, y1, x2, y2, x3, y3, x4, y4, x5, y5, x6, y6;
    switch (_dir) {
        default:
            x1 = rect.origin.x + roundf((rect.size.width - 1) * (_cx - _width / 2) / lw);
            x2 = x6 = rect.origin.x + roundf((rect.size.width - 1) * (_cx - _width / 4) / lw);
            x3 = x5 = rect.origin.x + roundf((rect.size.width - 1) * (_cx + _width / 4) / lw);
            x4 = rect.origin.x + roundf((rect.size.width - 1) * (_cx + _width / 2) / lw);
            y1 = y4 = rect.origin.y + roundf((rect.size.height - 1) * _cy / lh);
            y2 = y3 = rect.origin.y + roundf((rect.size.height - 1) * (_cy - _height / 2) / lh);
            y5 = y6 = rect.origin.y + roundf((rect.size.height - 1) * (_cy + _height / 2) / lh);
            break;
        case RCPXHexDirectionVertical:
            y1 = rect.origin.y + roundf((rect.size.height - 1) * (_cy - _height / 2) / lh);
            y2 = y6 = rect.origin.y + roundf((rect.size.height - 1) * (_cy - _height / 4) / lh);
            y3 = y5 = rect.origin.y + roundf((rect.size.height - 1) * (_cy + _height / 4) / lh);
            y4 = rect.origin.y + roundf((rect.size.height - 1) * (_cy + _height / 2) / lh);
            x1 = x4 = rect.origin.x + roundf((rect.size.width - 1) * _cx / lw);
            x2 = x3 = rect.origin.x + roundf((rect.size.width - 1) * (_cx + _width / 2) / lw);
            x5 = x6 = rect.origin.x + roundf((rect.size.width - 1) * (_cx - _width / 2) / lw);
            break;
    }
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(x1, y1)];
    [path lineToPoint:NSMakePoint(x2, y2)];
    [path lineToPoint:NSMakePoint(x3, y3)];
    [path lineToPoint:NSMakePoint(x4, y4)];
    [path lineToPoint:NSMakePoint(x5, y5)];
    [path lineToPoint:NSMakePoint(x6, y6)];
    [path closePath];
    [path setLineJoinStyle:NSRoundLineJoinStyle];
    return path;
}

@end


@implementation RCPXPoly

+ (RCPXPoly *)polyWithXPoints:(NSArray *)xPoints yPoints:(NSArray *)yPoints nPoints:(NSInteger)nPoints index:(NSInteger)index {
    return [[RCPXPoly alloc]initWithXPoints:xPoints yPoints:yPoints nPoints:nPoints index:index];
}

+ (RCPXPoly *)polyWithPointsString:(NSString *)points index:(NSInteger)index {
    return [[RCPXPoly alloc]initWithPointsString:points index:index];
}

- (void)dealloc {
    [_xPoints release];
    [_yPoints release];
    [super dealloc];
}

- (id)initWithXPoints:(NSArray *)xPoints yPoints:(NSArray *)yPoints nPoints:(NSInteger)nPoints index:(NSInteger)index {
    _xPoints = [xPoints retain];
    _yPoints = [yPoints retain];
    _nPoints = nPoints;
    _index = index;
    return self;
}

- (id)initWithPointsString:(NSString *)points index:(NSInteger)index {
    NSMutableCharacterSet *delims = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [delims addCharactersInString:@","];
    NSArray *pa = [points componentsSeparatedByCharactersInSet:delims];
    NSMutableArray *xPoints = [NSMutableArray array];
    NSMutableArray *yPoints = [NSMutableArray array];
    NSInteger nPoints = 0;
    for (NSString *ps in pa) {
        if ([ps length] > 0) {
            if (nPoints & 1) {
                [yPoints addObject:[NSNumber numberWithFloat:[ps floatValue]]];
            } else {
                [xPoints addObject:[NSNumber numberWithFloat:[ps floatValue]]];
            }
            nPoints++;
        }
    }
    nPoints >>= 1;
    return [self initWithXPoints:xPoints yPoints:yPoints nPoints:nPoints index:index];
}

- (NSBezierPath *)pathInRect:(NSRect)rect withLocalWidth:(CGFloat)lw height:(CGFloat)lh {
    NSBezierPath *path = [NSBezierPath bezierPath];
    for (NSInteger i = 0; i < _nPoints; i++) {
        CGFloat x = rect.origin.x + roundf((rect.size.width - 1) * [[_xPoints objectAtIndex:i]floatValue] / lw);
        CGFloat y = rect.origin.y + roundf((rect.size.height - 1) * [[_yPoints objectAtIndex:i]floatValue] / lh);
        if (i) [path lineToPoint:NSMakePoint(x, y)];
        else [path moveToPoint:NSMakePoint(x, y)];
    }
    [path closePath];
    return path;
}

@end


@implementation RCPXEllipse

+ (RCPXEllipse *)ellipseWithCenterX:(CGFloat)cx centerY:(CGFloat)cy width:(CGFloat)w height:(CGFloat)h index:(NSInteger)i {
    return [[RCPXEllipse alloc]initWithCenterX:cx centerY:cy width:w height:h index:i];
}

- (id)initWithCenterX:(CGFloat)cx centerY:(CGFloat)cy width:(CGFloat)w height:(CGFloat)h index:(NSInteger)i {
    _cx = cx;
    _cy = cy;
    _width = w;
    _height = h;
    _index = i;
    return self;
}

- (NSBezierPath *)pathInRect:(NSRect)rect withLocalWidth:(CGFloat)lw height:(CGFloat)lh {
    CGFloat x1 = rect.origin.x + roundf((rect.size.width - 1) * (_cx - _width / 2) / lw);
    CGFloat y1 = rect.origin.y + roundf((rect.size.height - 1) * (_cy - _height / 2) / lh);
    CGFloat x2 = rect.origin.x + roundf((rect.size.width - 1) * (_cx + _width / 2) / lw);
    CGFloat y2 = rect.origin.y + roundf((rect.size.height - 1) * (_cy + _height / 2) / lh);
    NSRect r = NSMakeRect(x1 < x2 ? x1 : x2, y1 < y2 ? y1 : y2, fabsf(x2 - x1), fabsf(y2 - y1));
    return [NSBezierPath bezierPathWithOvalInRect:r];
}

@end
