//
//  RCPXShape.h
//
//  Created by Rebecca Bettencourt on 6/9/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    RCPXTriDirectionUp = 0,
    RCPXTriDirectionDown,
    RCPXTriDirectionLeft,
    RCPXTriDirectionRight
};
typedef NSInteger RCPXTriDirection;


enum {
    RCPXHexDirectionHorizontal = 0,
    RCPXHexDirectionVertical
};
typedef NSInteger RCPXHexDirection;


@interface RCPXShape : NSObject {
    NSInteger _index;
}

- (NSBezierPath *)pathInRect:(NSRect)rect withLocalWidth:(CGFloat)lw height:(CGFloat)lh;
- (NSInteger)index;

@end


@interface RCPXRect : RCPXShape {
    CGFloat _x, _y, _width, _height;
}

+ (RCPXRect *)rectWithX:(CGFloat)x y:(CGFloat)y width:(CGFloat)w height:(CGFloat)h index:(NSInteger)i;
- (id)initWithX:(CGFloat)x y:(CGFloat)y width:(CGFloat)w height:(CGFloat)h index:(NSInteger)i;

@end


@interface RCPXDiam : RCPXShape {
    CGFloat _cx, _cy, _width, _height;
}

+ (RCPXDiam *)diamWithCenterX:(CGFloat)cx centerY:(CGFloat)cy width:(CGFloat)w height:(CGFloat)h index:(NSInteger)i;
- (id)initWithCenterX:(CGFloat)cx centerY:(CGFloat)cy width:(CGFloat)w height:(CGFloat)h index:(NSInteger)i;

@end


@interface RCPXTri : RCPXShape {
    CGFloat _bcx, _bcy, _width, _height;
    RCPXTriDirection _dir;
}

+ (RCPXTri *)triWithBaseCenterX:(CGFloat)bcx baseCenterY:(CGFloat)bcy width:(CGFloat)w height:(CGFloat)h direction:(RCPXTriDirection)dir index:(NSInteger)i;
- (id)initWithBaseCenterX:(CGFloat)bcx baseCenterY:(CGFloat)bcy width:(CGFloat)w height:(CGFloat)h direction:(RCPXTriDirection)dir index:(NSInteger)i;

@end


@interface RCPXHex : RCPXShape {
    CGFloat _cx, _cy, _width, _height;
    RCPXHexDirection _dir;
}

+ (RCPXHex *)hexWithCenterX:(CGFloat)cx centerY:(CGFloat)cy width:(CGFloat)w height:(CGFloat)h direction:(RCPXHexDirection)dir index:(NSInteger)i;
- (id)initWithCenterX:(CGFloat)cx centerY:(CGFloat)cy width:(CGFloat)w height:(CGFloat)h direction:(RCPXHexDirection)dir index:(NSInteger)i;

@end


@interface RCPXPoly : RCPXShape {
    NSArray *_xPoints;
    NSArray *_yPoints;
    NSInteger _nPoints;
}

+ (RCPXPoly *)polyWithXPoints:(NSArray *)xPoints yPoints:(NSArray *)yPoints nPoints:(NSInteger)nPoints index:(NSInteger)index;
+ (RCPXPoly *)polyWithPointsString:(NSString *)points index:(NSInteger)index;
- (id)initWithXPoints:(NSArray *)xPoints yPoints:(NSArray *)yPoints nPoints:(NSInteger)nPoints index:(NSInteger)index;
- (id)initWithPointsString:(NSString *)points index:(NSInteger)index;

@end


@interface RCPXEllipse : RCPXShape {
    CGFloat _cx, _cy, _width, _height;
}

+ (RCPXEllipse *)ellipseWithCenterX:(CGFloat)cx centerY:(CGFloat)cy width:(CGFloat)w height:(CGFloat)h index:(NSInteger)i;
- (id)initWithCenterX:(CGFloat)cx centerY:(CGFloat)cy width:(CGFloat)w height:(CGFloat)h index:(NSInteger)i;

@end
