//
//  GradientButton.m
//  LimitlessCaverns
//
//  Created by Erik Hope on 8/8/13.
//  Copyright (c) 2013 Dropbox. All rights reserved.
//

#import "GradientButton.h"

//
//  GradientButton.m
//
//  Created by Erik Hope on 9/12/12.
//
//

#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>


UIColor *colorFromRGB(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
    return     [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}


@implementation GradientButton
{
    CAGradientLayer *gradientLayer;
}

- (NSArray*)gradientColors
{
    return nil;
}

- (UIColor*)gradientBorderColor
{
    return nil;
}

- (UIColor*)buttonBorderColor
{
    return nil;
}

- (UIColor*)textShadowColor
{
    return nil;
}

- (CGFloat)buttonCornerRadius
{
    return 3;
}

- (void)configure
{
    CGFloat halfPixelInRetina = [[UIScreen mainScreen] scale] == 1 ? 1 : .5;
    gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.frame = CGRectInset(self.bounds, halfPixelInRetina, halfPixelInRetina);
    gradientLayer.cornerRadius = [self buttonCornerRadius];
    self.layer.cornerRadius = [self buttonCornerRadius];
    gradientLayer.locations = @[@0, @1];
    gradientLayer.colors = [self gradientColors];
    gradientLayer.borderColor = [self gradientBorderColor].CGColor;
    self.layer.borderColor = [self buttonBorderColor].CGColor;
    self.layer.borderWidth = halfPixelInRetina;
    gradientLayer.borderWidth = halfPixelInRetina;
    self.backgroundColor = [self gradientBorderColor];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:self.tag > 0 ? self.tag : 20];
    self.titleLabel.shadowColor = [self textShadowColor];
    self.titleLabel.shadowOffset = CGSizeMake(0, halfPixelInRetina);
    [self.layer insertSublayer:gradientLayer below:self.titleLabel.layer];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configure];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (highlighted){
        gradientLayer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
    } else {
        gradientLayer.transform = CATransform3DIdentity;
    }
    [CATransaction commit];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    gradientLayer.frame = self.bounds;
    [CATransaction commit];
    
}

@end


@implementation BlueGradientButton


- (NSArray*)gradientColors
{
    return @[(id)colorFromRGB(135, 215, 235, 1).CGColor,
             (id)colorFromRGB(90, 197, 225, 1).CGColor];
}

- (UIColor*)gradientBorderColor
{
    return colorFromRGB(135, 215, 235, 1);
}

- (UIColor*)buttonBorderColor
{
    return colorFromRGB(19, 105, 127, 1);
}

- (UIColor*)textShadowColor
{
    return colorFromRGB(18, 105, 127, 1);
}

@end

@implementation GrayGradientButton


- (NSArray*)gradientColors
{
    return @[(id)colorFromRGB(180, 180, 180, 1).CGColor,
             (id)colorFromRGB(149, 149, 149, 1).CGColor];
}

- (UIColor*)gradientBorderColor
{
    return colorFromRGB(70, 70, 70, 1);
}

- (UIColor*)buttonBorderColor
{
    return colorFromRGB(70, 70, 70, 1);
}

- (UIColor*)textShadowColor
{
    return colorFromRGB(18, 105, 127, 1);
}

@end


