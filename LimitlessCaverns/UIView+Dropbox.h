//
//  UIView+Dropbox.h
//  Dropbox
//
//  Created by Brian Smith on 6/10/11.
//  Copyright 2011 Dropbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Dropbox)

@property(nonatomic) CGFloat left;
@property(nonatomic) CGFloat top;
@property(nonatomic) CGFloat right;
@property(nonatomic) CGFloat bottom;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;
@property(nonatomic) CGFloat centerX;
@property(nonatomic) CGFloat centerY;
@property(nonatomic) CGPoint origin;
@property(nonatomic) CGSize size;

- (UIViewController*)viewController;

- (void)centerSubview:(UIView *)subview withOffset:(CGPoint)offset;
- (UIResponder *)firstResponder;

@end
