//
//  View.m
//  AHuntFirstDrawingApp
//
//  Created by Andrew Hunt on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CLLocation.h>	//for CLLocationCoordinate2D
#import "View.h"

#import <stdlib.h>

@implementation View

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code to dark grey
        self.backgroundColor = [UIColor colorWithRed:0.2 green:.2 blue:.2 alpha:1 ];
        atTop = NO;
    }
    
    return self;
}

// Touch? draw tree again
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setNeedsDisplay];
}


// Tree drawing code adapted from Seb Lee Delisle's JS version of 
// Jean-no's Processing example : http://www.openprocessing.org/visuals/?visualID=1758

- (void) drawRect: (CGRect) rect {
//    NSLog(@"drawRect called");    
	CGSize s = self.bounds.size;
    drawContext = UIGraphicsGetCurrentContext();

    
    // draw internationalized label, Centered! 1X only
    if (!haveDrawn){
        NSString *text = NSLocalizedString(@"TreeLabel", @"displayed below tree");
        UIFont *font = [UIFont systemFontOfSize: 24.0];
        CGSize size = [text sizeWithFont: font];
        
        CGRect f = CGRectMake((s.width-size.width)/2, s.height*0.92, size.width, s.height*0.08);
        
        label = [[UILabel alloc] initWithFrame: f];
        label.font = font;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = text;
        [self addSubview: label];
        
        haveDrawn = YES;
    }
    
    // set up to draw the tree
    
	// move tree to near bottom of screen
    CGContextTranslateCTM(drawContext, s.width / 2, s.height*0.85);
   	CGContextBeginPath(drawContext);
    CGContextMoveToPoint(drawContext, 0, 0);
    
    // set branch color to off white
    CGContextSetRGBStrokeColor(drawContext, .9, .9, .9, 1.0);
    CGContextSetLineCap(drawContext, kCGLineCapRound);
    
    // start recursive branch drawing
    [self drawBranchOfLength:s.height/5.0 angle:-90 * TO_RADIANS];
    
    // animate label
    CGPoint newTarget;
    if (atTop)
    {        
        newTarget = CGPointMake(
                                s.width - label.bounds.size.width/2,
                                s.height - label.bounds.size.height/2
                                );
    }
    else
    {
        newTarget = CGPointMake(
                             label.bounds.size.width/2,
                             label.bounds.size.height/2
                             );
    }
    atTop = !atTop;
    [UIView animateWithDuration: 1.5
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations: ^{
                         //Move the label to opposite vertical end of screen
                         label.center = newTarget;
                     }
                     completion: NULL
     ];
    
    

}

- (void) drawBranchOfLength: (float) length angle: (float) angle {

//    NSLog (@" Drawing branches with length = %g, angle = %g", length, angle * 180/M_PI);

    // save graphics context
    CGContextSaveGState(drawContext);
    
    // draw current branch
    CGContextSetLineWidth(drawContext, length * 0.02);
    CGContextRotateCTM (drawContext, angle);
    CGContextMoveToPoint(drawContext, 0, 0);
    CGContextAddLineToPoint(drawContext, length, 0.0);
    CGContextTranslateCTM(drawContext, length, 0.0);
    CGContextStrokePath(drawContext);

    // draw branches!
    if (length > 3.0) {
        // branch left
        [self drawBranchOfLength:length * [self randomRangeFromLow:0.55 toHigh:0.80] angle: ([self randomRangeFromLow:-30.0 toHigh:-15.0] * TO_RADIANS)];

        // middle branch
        if (rand()*1.0/RAND_MAX < 0.5) {
            [self drawBranchOfLength:length * [self randomRangeFromLow:0.55 toHigh:0.80] angle: ([self randomRangeFromLow:-10 toHigh:10.0] * TO_RADIANS)];
        }
        // branch right
        [self drawBranchOfLength:length * [self randomRangeFromLow:0.55 toHigh:0.80] angle: ([self randomRangeFromLow:30.0 toHigh:15.0] * TO_RADIANS)];
        
       // draw a "leaf" every once in a while 
    } else if (rand()/RAND_MAX < 0.1) {
        float radius = rand()%6;
        CGRect r = CGRectMake(
                              length,
                              0,
                              radius,
                              radius
                              );
        CGContextAddEllipseInRect(drawContext, r);
        
        // FLOWER APPROACH, fancy HSL variation
        
        float hue = [self randomRangeFromLow:250.0 toHigh:350.0]/360.0;
        // convert hsl to rgb
        
        UIColor *hsl = [self HSL2RGBWithHue:hue sat:0.8 light:0.8];
        CGContextSetFillColorWithColor(drawContext, hsl.CGColor);
        CGContextFillPath(drawContext);	

        // OR LEAF APPROACH
//        float green = [self randomRangeFromLow:0.4 toHigh:0.5];
//        CGContextSetRGBFillColor(drawContext, 0.0, green, 0.0, 0.2);
//        CGContextFillPath(drawContext);	

    }

    // restore graphics context
    CGContextRestoreGState(drawContext);
    
}


- (float) randomRangeFromLow: (float) low toHigh: (float) h{
    return ( (rand()*1.0 / RAND_MAX) *(h-low)   + low );
}

// method adapted from this dude: http://www.geekymonkey.com/Programming/CSharp/RGB2HSL_HSL2RGB.htm
- (UIColor *) HSL2RGBWithHue:(double) h sat:( double) sl light:(double) l {
    
    double v;
    double r,g,b;

    r = l;   // default to gray
    g = l;
    b = l;
    v = (l <= 0.5) ? (l * (1.0 + sl)) : (l + sl - l * sl);
    if (v > 0)
    {
        double m;
        double sv;
        int sextant;
        double fract, vsf, mid1, mid2;
        
        m = l + l - v;
        sv = (v - m ) / v;
        h *= 6.0;
        sextant = (int)h;
        fract = h - sextant;
        vsf = v * sv * fract;
        mid1 = m + vsf;
        mid2 = v - vsf;
        switch (sextant)
        {
            case 0:
                r = v;
                g = mid1;
                b = m;
                break;
            case 1:
                r = mid2;
                g = v;
                b = m;
                break;
            case 2:
                r = m;
                g = v;
                b = mid1;
                break;
            case 3:
                r = m;
                g = mid2;
                b = v;
                break;
            case 4:
                r = mid1;
                g = m;
                b = v;
                break;
            case 5:
                r = v;
                g = m;
                b = mid2;
                break;
        }
    }
    
    UIColor *rgb = [UIColor colorWithRed:r green:g blue:b alpha:0.2];
    return rgb;
    
}


- (void)dealloc
{
    [label dealloc];
    [super dealloc];
}

@end
