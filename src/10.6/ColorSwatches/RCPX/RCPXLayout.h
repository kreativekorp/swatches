//
//  RCPXLayout.h
//
//  Created by Rebecca Bettencourt on 6/10/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCPXLayoutOrSwatch.h"
#import "RCPXShape.h"
#import "RCPXSwatch.h"

enum {
    RCPXOrientationHorizontal = 0,
    RCPXOrientationSquare,
    RCPXOrientationVertical
};
typedef NSInteger RCPXOrientation;


@interface RCPXLayout : RCPXLayoutOrSwatch

@end


@interface RCPXOriented : RCPXLayout {
    RCPXLayoutOrSwatch *_horizontal;
    RCPXLayoutOrSwatch *_square;
    RCPXLayoutOrSwatch *_vertical;
}

+ (RCPXOriented *)oriented;
+ (RCPXOriented *)orientedWithHorizontal:(RCPXLayoutOrSwatch *)h square:(RCPXLayoutOrSwatch *)s vertical:(RCPXLayoutOrSwatch *)v;
- (id)init;
- (id)initWithHorizontal:(RCPXLayoutOrSwatch *)h square:(RCPXLayoutOrSwatch *)s vertical:(RCPXLayoutOrSwatch *)v;
- (void)setHorizontal:(RCPXLayoutOrSwatch *)h;
- (void)setSquare:(RCPXLayoutOrSwatch *)s;
- (void)setVertical:(RCPXLayoutOrSwatch *)v;
- (RCPXLayoutOrSwatch *)layoutOrSwatchInRect:(NSRect)rect;

@end


@interface RCPXRowOrColumn : RCPXLayout {
    NSMutableArray *_children;
    NSMutableArray *_weights;
    NSInteger _totalWeight;
}

- (void)addLayoutOrSwatch:(RCPXLayoutOrSwatch *)e;
- (void)addLayoutOrSwatch:(RCPXLayoutOrSwatch *)e withWeight:(NSInteger)w;
- (NSRect)rectInRect:(NSRect)r fromStartIndex:(NSInteger)i toEndIndex:(NSInteger)j ofMaxIndex:(NSInteger)max;

@end


@interface RCPXRow : RCPXRowOrColumn

+ (RCPXRow *)row;
- (id)init;

@end


@interface RCPXColumn : RCPXRowOrColumn

+ (RCPXColumn *)column;
- (id)init;

@end


@interface RCPXDiagonal : RCPXLayout {
    NSInteger _cols;
    NSInteger _rows;
    BOOL _square;
    NSMutableArray *_children;
    NSMutableArray *_swatches;
    NSMutableArray *_repeatIndices;
    NSInteger _swatchCount;
    NSPoint _bp;
    NSRect _br;
}

+ (RCPXDiagonal *)diagonalWithColumns:(NSInteger)cols rows:(NSInteger)rows square:(BOOL)square;
- (id)initWithColumns:(NSInteger)cols rows:(NSInteger)rows square:(BOOL)square;
- (void)addSwatch:(RCPXSwatch *)swatch;

@end


@interface RCPXPolygonal : RCPXLayout {
    NSInteger _cols;
    NSInteger _rows;
    NSMutableArray *_children;
}

+ (RCPXPolygonal *)polygonalWithColumns:(NSInteger)cols rows:(NSInteger)rows;
- (id)initWithColumns:(NSInteger)cols rows:(NSInteger)rows;
- (void)addShape:(RCPXShape *)shape;

@end


@interface RCPXOverlay : RCPXLayout {
    NSMutableArray *_children;
}

+ (RCPXOverlay *)overlay;
- (id)init;
- (void)addLayoutOrSwatch:(RCPXLayoutOrSwatch *)e;

@end
