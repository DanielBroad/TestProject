//
//  TPLoginButton.m
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import "TPLoginButton.h"

@implementation TPLoginButton

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.isAccessibilityElement = NO;
    }
    return self;
}

-(void) drawRect:(CGRect)rect {
    UIBezierPath *outline = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 0.5, 0.5) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(4, 4)];
    if (!self.highlighted) {
        [self.tintColor setStroke];
        [outline stroke];
    } else {
        [[UIColor colorWithWhite:0.9 alpha:1.0] setFill];
        [outline fill];
    }
    
}

-(void) setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self setNeedsDisplay];
}

-(void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

@end

