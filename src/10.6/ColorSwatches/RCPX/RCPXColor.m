//
//  RCPXColor.m
//
//  Created by Rebecca Bettencourt on 6/9/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import "RCPXColor.h"

@implementation RCPXColor

+ (RCPXColor *)colorWithColor:(NSColor *)color {
    return [[RCPXColor alloc]initWithColor:color];
}

+ (RCPXColor *)colorWithColor:(NSColor *)color name:(NSString *)name {
    return [[RCPXColor alloc]initWithColor:color name:name];
}

- (void)dealloc {
    [_color release];
    [_name release];
    [super dealloc];
}

- (id)initWithColor:(NSColor *)color {
    _color = [color retain];
    _name = nil;
    return self;
}

- (id)initWithColor:(NSColor *)color name:(NSString *)name {
    _color = [color retain];
    _name = [name retain];
    return self;
}

- (NSColor *)color {
    return _color;
}

- (NSString *)name {
    return _name;
}

@end
