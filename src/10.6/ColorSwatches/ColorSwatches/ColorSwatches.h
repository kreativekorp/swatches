//
//  ColorSwatches.h
//  ColorSwatches
//
//  Created by Rebecca Bettencourt on 6/8/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import "RCPXView.h"

@interface ColorSwatches : NSColorPicker<NSColorPickingCustom> {
    IBOutlet NSView *_pickerView;
    IBOutlet NSPopUpButton *_pickerPopup;
    IBOutlet RCPXView *_pickerSwatches;
    NSMutableArray *_paletteArray;
}

@end
