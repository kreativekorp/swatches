//
//  RCPXLayoutOrSwatch.m
//
//  Created by Rebecca Bettencourt on 6/10/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import "RCPXLayoutOrSwatch.h"

@implementation RCPXLayoutOrSwatch

- (NSInteger)repeatCount {
    return 1;
}

- (NSColor *)colorAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)ri withColorList:(NSArray *)colors {
    return nil;
}

- (NSString *)nameAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)ri withColorList:(NSArray *)colors {
    return nil;
}

- (void)drawInRect:(NSRect)r withColor:(NSColor *)c atRepeatIndex:(NSInteger)ri withColorList:(NSArray *)colors {
    return;
}

@end
