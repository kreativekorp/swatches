//
//  RCPXLayoutOrSwatch.h
//
//  Created by Rebecca Bettencourt on 6/10/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCPXLayoutOrSwatch : NSObject

- (NSInteger)repeatCount;
- (NSColor *)colorAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)ri withColorList:(NSArray *)colors;
- (NSString *)nameAtPoint:(NSPoint)p inRect:(NSRect)r atRepeatIndex:(NSInteger)ri withColorList:(NSArray *)colors;
- (void)drawInRect:(NSRect)r withColor:(NSColor *)c atRepeatIndex:(NSInteger)ri withColorList:(NSArray *)colors;

@end
