//
//  ColorSwatches.m
//  ColorSwatches
//
//  Created by Rebecca Bettencourt on 6/8/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import "ColorSwatches.h"

@implementation ColorSwatches

- (id)initWithPickerMask:(NSUInteger)mask colorPanel:(NSColorPanel *)owningColorPanel {
    return [super initWithPickerMask:mask colorPanel:owningColorPanel];
}

- (void)dealloc {
    [_pickerView release];
    [_paletteArray release];
    [super dealloc];
}

- (BOOL)supportsMode:(NSColorPanelMode)mode {
    return (mode == NSRGBModeColorPanel) ? YES : NO;
}

- (NSColorPanelMode)currentMode {
    return NSRGBModeColorPanel;
}

- (NSView *)provideNewView:(BOOL)initialRequest {
    if (initialRequest) {
        if (![NSBundle loadNibNamed:@"ColorSwatches" owner:self]) {
            NSLog(@"ERROR: couldn't load ColorSwatches nib");
        }
        
        [_pickerPopup removeAllItems];
        _paletteArray = [[NSMutableArray array] retain];
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSArray *paths = [bundle pathsForResourcesOfType:@"rcpx" inDirectory:nil];
        paths = [paths sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        for (NSString *path in paths) {
            NSURL *url = [NSURL fileURLWithPath:path];
            RCPXParser *p = [RCPXParser parserWithContentsOfURL:url];
            RCPXPalette *palette = [p parse];
            if (palette) {
                NSString *name = [palette name];
                [_pickerPopup addItemWithTitle:name];
                [_paletteArray addObject:palette];
                if ([name isEqualToString:@"Resplendence"]) {
                    [_pickerPopup selectItemWithTitle:name];
                    [_pickerSwatches setPalette:palette];
                }
            } else {
                NSLog(@"ERROR: couldn't load palette from %@", path);
            }
        }
        
        [_pickerPopup setTarget:self];
        [_pickerPopup setAction:@selector(paletteSelected:)];
        [_pickerSwatches setTarget:self];
        [_pickerSwatches setAction:@selector(colorClicked:)];
    }
    return _pickerView;
}

- (void)paletteSelected:(id)sender {
    NSInteger i = [_pickerPopup indexOfSelectedItem];
    if (i >= 0 && i < [_paletteArray count]) {
        RCPXPalette *palette = [_paletteArray objectAtIndex:i];
        if (palette) [_pickerSwatches setPalette:palette];
    }
}

- (void)colorClicked:(id)sender {
    NSColor *color = [_pickerSwatches locationColor];
    if (color) {
        [self setColor:color];
        [[self colorPanel] setColor:color];
    }
}

- (void)setColor:(NSColor *)newColor {
    [_pickerSwatches setColor:newColor];
}

- (NSString *)buttonToolTip {
    return NSLocalizedString(@"Color Swatches", @"Tooltip for the color picker button");
}

- (NSImage *)provideNewButtonImage {
    return [NSImage imageNamed:@"NSColorPickerList"];
}

- (NSSize)minContentSize {
    return NSMakeSize(87.0f, 111.0f);
}

@end
