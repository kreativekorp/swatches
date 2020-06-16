//
//  RCPXColor.h
//
//  Created by Rebecca Bettencourt on 6/9/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCPXColor : NSObject {
    NSColor *_color;
    NSString *_name;
}

+ (RCPXColor *)colorWithColor:(NSColor *)color;
+ (RCPXColor *)colorWithColor:(NSColor *)color name:(NSString *)name;

- (id)initWithColor:(NSColor *)color;
- (id)initWithColor:(NSColor *)color name:(NSString *)name;

- (NSColor *)color;
- (NSString *)name;

@end
