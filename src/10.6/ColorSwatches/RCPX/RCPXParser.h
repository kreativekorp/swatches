//
//  RCPXParser.h
//
//  Created by Rebecca Bettencourt on 6/11/20.
//  Copyright (c) 2020 Kreative Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCPXLayout.h"
#import "RCPXPalette.h"

enum {
    RCPXLayoutTypeNone = 0,
    RCPXLayoutTypeOriented,
    RCPXLayoutTypeRow,
    RCPXLayoutTypeColumn,
    RCPXLayoutTypeDiagonal,
    RCPXLayoutTypePolygonal,
    RCPXLayoutTypeOverlay
};
typedef NSInteger RCPXLayoutType;


@interface RCPXParser : NSXMLParser<NSXMLParserDelegate> {
    NSString *_name;
    RCPXOrientation _orientation;
    NSSize _hsize;
    NSSize _ssize;
    NSSize _vsize;
    NSMutableArray *_colors;
    BOOL _ordered;
    RCPXLayout *_layout;
    NSMutableArray *_layoutStack;
    NSMutableArray *_layoutNameStack;
    NSMutableArray *_layoutOrientStack;
    NSMutableArray *_layoutWeightStack;
}

+ (RCPXParser *)parserWithContentsOfURL:(NSURL *)url;
- (id)initWithContentsOfURL:(NSURL *)url;
- (RCPXPalette *)parse;

@end
