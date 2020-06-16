//
//  RCPXUtilities.h
//
//  Created by Rebecca Bettencourt on 6/11/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const CGFloat e100;
extern const CGFloat e180;
extern const CGFloat e255;
extern const CGFloat e360;

BOOL RCPXColorsEqual(NSColor * c1, NSColor * c2);
NSColor * RCPXContrastingColor(NSColor * color);
void RCPXSetCheckerboardFill(void);
