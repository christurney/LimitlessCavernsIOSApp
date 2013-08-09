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

@end

@implementation FunFactsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.pagingEnabled = YES;
        self.labels = [NSMutableArray array];
        self.showsHorizontalScrollIndicator = NO;
    }
    return self;
}

-(void)setupLabel:(UILabel*)funFactLabel atIndex:(NSInteger)idx
{
    CGRect funFactFrame = CGRectOffset(CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height), idx*self.bounds.size.width, 0);
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
        [view removeFromSuperview];
    }
    [funFacts enumerateObjectsUsingBlock:^(NSString* fact, NSUInteger idx, BOOL *stop) {
        
        UILabel *funFactLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [funFactLabel setTextAlignment:NSTextAlignmentCenter];
        funFactLabel.adjustsFontSizeToFitWidth = NO;
        funFactLabel.numberOfLines = 0;
        funFactLabel.backgroundColor = [UIColor clearColor];
        
        funFactLabel.text = fact;
        [self addSubview:funFactLabel];
        [self.labels addObject:funFactLabel];
    }];
}

- (void)layoutSubviews
{
    __block CGSize contentSize = CGSizeMake(0, self.bounds.size.height);
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        [self setupLabel:label atIndex:idx];
        contentSize.width += self.bounds.size.width;
    }];
    self.contentSize = contentSize;
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
