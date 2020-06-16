//
//  RCPXBorder.h
//
//  Created by Rebecca Bettencourt on 6/9/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCPXBorder : NSObject {
    BOOL _top;
    BOOL _left;
    BOOL _bottom;
    BOOL _right;
}

+ (RCPXBorder *)borderWithAll;
+ (RCPXBorder *)borderWithNone;
+ (RCPXBorder *)borderWithTop:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right;
- (id)initWithTop:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right;
- (void)drawInRect:(NSRect)rect withColor:(NSColor *)color;

@end
