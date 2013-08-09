//
//  FunFactsView.m
//  LimitlessCaverns
//
//  Created by Erik Hope on 8/8/13.
//  Copyright (c) 2013 Dropbox. All rights reserved.
//

#import "FunFactsView.h"

@interface FunFactsView()

@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic, strong) UIButton *moreFactsLeftButton;
@property (nonatomic, strong) UIButton *moreFactsRightButton;

@end

@implementation FunFactsView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self setButtonsEnabled:NO];
    [UIView animateWithDuration:.1 animations:^{
        self.moreFactsRightButton.alpha = 0;
        self.moreFactsLeftButton.alpha = 0;
    } completion:^(BOOL finished) {
        [self setButtonsEnabled:YES];
    }];
}

- (void)setButtonsEnabled:(BOOL)enabled
{
    self.moreFactsRightButton.enabled = enabled;
    self.moreFactsLeftButton.enabled = enabled;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    BOOL animated = NO;
    if (self.contentOffset.x >= self.contentSize.width - self.bounds.size.width){
        animated = YES;
        [UIView animateWithDuration:.05 animations:^{
            self.moreFactsRightButton.alpha = 0;
            self.moreFactsLeftButton.alpha = 1;
        }completion:^(BOOL finished) {
            [self setButtonsEnabled:YES]; 
        }];
    } else if (self.contentOffset.x <= 0){
        animated = YES;
        [UIView animateWithDuration:.05 animations:^{
            self.moreFactsRightButton.alpha = 1;
            self.moreFactsLeftButton.alpha = 0;
        }completion:^(BOOL finished) {
            [self setButtonsEnabled:YES];
        }];
    }
    if (self.contentOffset.x > 0){
        animated = YES;
        [UIView animateWithDuration:.05 animations:^{
            self.moreFactsLeftButton.alpha = 1;
        }completion:^(BOOL finished) {
            [self setButtonsEnabled:YES];
        }];
    }
    if (self.contentOffset.x < self.contentSize.width - self.bounds.size.width){
        animated = YES;
        [UIView animateWithDuration:.05 animations:^{
            self.moreFactsRightButton.alpha = 1;
        }completion:^(BOOL finished) {
            [self setButtonsEnabled:YES];
        }];
    }
    [self setButtonsEnabled:!animated];
}

- (void)pageLeft
{
    CGFloat page = floorf(self.contentOffset.x / self.bounds.size.width);

    if (self.contentOffset.x < self.contentSize.width - self.bounds.size.width){
        [self setButtonsEnabled:NO];

        [UIView animateWithDuration:.2 animations:^{
            self.contentOffset = CGPointMake((page+1)*self.bounds.size.width, 0);
            self.moreFactsLeftButton.alpha = 1;
            if (page+1 == self.labels.count - 1){
                self.moreFactsRightButton.alpha = 0;
            }
        }completion:^(BOOL finished) {
            [self setButtonsEnabled:YES];
        }];
    }
}

- (void)pageRight
{
    CGFloat page = floorf(self.contentOffset.x / self.bounds.size.width);

    if (self.contentOffset.x > 0){
        [self setButtonsEnabled:NO];
        
        [UIView animateWithDuration:.2 animations:^{
            self.contentOffset = CGPointMake((page-1)*self.bounds.size.width, 0);
            self.moreFactsRightButton.alpha = 1;
            if (page-1 == 0){
                self.moreFactsLeftButton.alpha = 0;
            }
        }completion:^(BOOL finished) {
            [self setButtonsEnabled:YES];
        }];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.pagingEnabled = YES;
        self.labels = [NSMutableArray array];
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = self;
        self.moreFactsRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.moreFactsLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.moreFactsRightButton setImage:[UIImage imageNamed:@"more_facts_right"] forState:UIControlStateNormal];
        [self.moreFactsLeftButton setImage:[UIImage imageNamed:@"more_facts_left"] forState:UIControlStateNormal];
        self.moreFactsLeftButton.alpha = 0;
        self.moreFactsRightButton.alpha = 0;
        [self.moreFactsLeftButton addTarget:self action:@selector(pageRight) forControlEvents:UIControlEventTouchUpInside];
        [self.moreFactsRightButton addTarget:self action:@selector(pageLeft) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.moreFactsLeftButton];
        [self addSubview:self.moreFactsRightButton];
    }
    return self;
}

-(void)setupLabel:(UILabel*)funFactLabel atIndex:(NSInteger)idx
{
    CGRect funFactFrame = CGRectOffset(CGRectMake(35, 0, self.bounds.size.width - 70, self.bounds.size.height), idx*self.bounds.size.width, 0);
    funFactLabel.frame = funFactFrame;
    CGFloat fontSize = 30;
    while (fontSize > 0.0)
    {
        CGSize size = [funFactLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize]
                                 constrainedToSize:CGSizeMake(funFactFrame.size.width, 10000)
                                     lineBreakMode:NSLineBreakByWordWrapping];
        
        if (size.height <= funFactFrame.size.height) break;
        
        fontSize -= 1.0;
    }
    
    //set font size
    //funFactLabel.font = [UIFont systemFontOfSize:fontSize];
    funFactLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
    [self addSubview:funFactLabel];
}


- (void)setFunFacts:(NSArray *)funFacts
{
    for (UIView *view in self.subviews){
        if ([view isKindOfClass:[UILabel class]]){
            [view removeFromSuperview];
        }
    }
    [funFacts enumerateObjectsUsingBlock:^(NSString* fact, NSUInteger idx, BOOL *stop) {
        
        UILabel *funFactLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [funFactLabel setTextAlignment:NSTextAlignmentCenter];
        funFactLabel.adjustsFontSizeToFitWidth = NO;
        funFactLabel.numberOfLines = 0;
        funFactLabel.backgroundColor = [UIColor clearColor];
        
        funFactLabel.text = fact;
        [self insertSubview:funFactLabel belowSubview:self.moreFactsLeftButton];
        [self.labels addObject:funFactLabel];
    }];
    if (self.labels.count > 1){
        self.moreFactsRightButton.alpha = 1;
    }
}

- (void)layoutSubviews
{
    __block CGSize contentSize = CGSizeMake(0, self.bounds.size.height);
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        [self setupLabel:label atIndex:idx];
        contentSize.width += self.bounds.size.width;
    }];
    self.contentSize = contentSize;
    CGFloat y = self.frame.size.height/2 - 15;
    CGRect moreFactsLeftButtonFrame = CGRectMake(self.contentOffset.x, y, 30, 30);
    CGRect moreFactsRightButtonFrame = CGRectMake(self.contentOffset.x + self.bounds.size.width - 30, y, 30, 30);
    self.moreFactsLeftButton.frame = moreFactsLeftButtonFrame;
    self.moreFactsRightButton.frame = moreFactsRightButtonFrame;
    [self bringSubviewToFront:self.moreFactsRightButton];
    [self bringSubviewToFront:self.moreFactsLeftButton];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
