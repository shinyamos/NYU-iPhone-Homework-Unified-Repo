//
//  View.h
//  AHuntFirstDrawingApp
//
//  Created by Andrew Hunt on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TO_RADIANS M_PI/180.0

@interface View : UIView {
    CGContextRef drawContext;
	UILabel *label;
    BOOL haveDrawn;
    BOOL atTop;
}

- (void) drawBranchOfLength: (float) length angle: (float) a;
- (float) randomRangeFromLow: (float) low toHigh: (float) h;
- (UIColor *) HSL2RGBWithHue:(double) h sat:( double) sl light:(double) l;


@end
