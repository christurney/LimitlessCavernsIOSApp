//
//  GuessWhoViewController.m
//  LimitlessCaverns
//
//  Created by Erik Hope on 8/6/13.
//  Copyright (c) 2013 Dropbox. All rights reserved.
//

#import "GuessWhoViewController.h"
#import "UIView+Dropbox.h"
#import <QuartzCore/QuartzCore.h>

@interface GuessWhoViewController ()
@property (nonatomic, strong) UIImageView *mysteryImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *funFactLabel;
@property (nonatomic, strong) UIButton *knowThemButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIImageView *leaderboard;

@end

@implementation GuessWhoViewController

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self){
        self.funFactString = dictionary[@"fun_fact"];
        self.titleString = @"Mystery Dropboxer";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.titleLabel setText:self.titleString];
    [self.titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.titleLabel];
    
    self.funFactLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.funFactLabel setTextAlignment:NSTextAlignmentCenter];
    self.funFactLabel.adjustsFontSizeToFitWidth = NO;
    self.funFactLabel.numberOfLines = 0;
    
    [self.view addSubview:self.funFactLabel];
    self.mysteryImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.mysteryImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.mysteryImageView.layer setBorderColor:[UIColor redColor].CGColor];
    [self.mysteryImageView.layer setBorderWidth:3];
    
    [self.mysteryImageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dabney" ofType:@"jpg"]]];
    [self.view addSubview:self.mysteryImageView];
    
    
    // know them button
    self.knowThemButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [self.knowThemButton setFrame:CGRectZero];
    [self.knowThemButton setTitle:@"Know Them" forState:UIControlStateNormal];
    [self.knowThemButton addTarget:self
                       action:@selector(knowThemClicked)
             forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.knowThemButton];
    
    // play button
    self.playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [self.playButton setFrame:CGRectZero];
    [self.playButton setTitle:@"Play!" forState:UIControlStateNormal];
    [self.playButton addTarget:self
                   action:@selector(playClicked)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
    
    // leaderboard picture
    
    self.leaderboard = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.leaderboard];
    [self.leaderboard.layer setBorderColor:[UIColor redColor].CGColor];
    [self.leaderboard.layer setBorderWidth:3];
}

- (void)knowThemClicked
{
    [self.delegate guessWhoViewControllerPressedAButton:self];
}

- (void)playClicked
{
    [self.delegate guessWhoViewControllerPressedAButton:self];
}

-(void)setFunFactString:(NSString *)str
{
    _funFactString = str;
    self.funFactLabel.text = str;
    
    CGRect funFactFrame = self.funFactLabel.frame;
    
    CGFloat fontSize = 30;
    while (fontSize > 0.0)
    {
        CGSize size = [_funFactString sizeWithFont:[UIFont systemFontOfSize:fontSize]
                                 constrainedToSize:CGSizeMake(funFactFrame.size.width, 10000)
                                     lineBreakMode:NSLineBreakByWordWrapping];
        
        if (size.height <= funFactFrame.size.height) break;
        
        fontSize -= 1.0;
    }
    
    //set font size
    self.funFactLabel.font = [UIFont systemFontOfSize:fontSize];
    
}

- (void)viewWillLayoutSubviews
{
    int imageBuffer = 30;
    int imageHeight = 175;
    int buttonHeight = 40;
    int buttonSize = 50;
    self.titleLabel.frame = CGRectMake(0, .05 * self.view.height, self.view.width, 30);

    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
                
        self.funFactLabel.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame) + 12, self.view.width - 60, 70);
        self.funFactLabel.centerX = self.view.width / 2;
        
        
        self.mysteryImageView.frame = CGRectMake(imageBuffer,
                                                 CGRectGetMaxY(self.funFactLabel.frame) + 12,
                                                 (self.view.width - imageBuffer*2),
                                                 imageHeight);
        
        
        // know them button
        
        self.knowThemButton.frame = CGRectMake(self.mysteryImageView.origin.x,
                                            CGRectGetMaxY(self.mysteryImageView.frame) + 15,
                                            CGRectGetWidth(self.mysteryImageView.frame)/2.0 - 5,
                                            buttonHeight);        
        // play button
        
        [self.playButton setFrame:CGRectMake(CGRectGetMaxX(self.knowThemButton.frame) + 10,
                                        CGRectGetMaxY(self.mysteryImageView.frame) + 15,
                                        CGRectGetWidth(self.mysteryImageView.frame)/2.0 - 5,
                                        buttonHeight)];
        
        self.leaderboard.frame = CGRectMake(CGRectGetMaxX(self.mysteryImageView.frame) - buttonSize,
                                                                                 CGRectGetMaxY(self.playButton.frame) + 15,
                                                                                 buttonSize,
                                                                                 buttonSize);
    } else {
        
        self.mysteryImageView.frame = CGRectMake(imageBuffer,
                                                 CGRectGetMaxY(self.titleLabel.frame) + 20,
                                                 (self.view.height - imageBuffer*2),
                                                 imageHeight);

        self.funFactLabel.frame = CGRectMake(CGRectGetMaxX(self.mysteryImageView.frame) + imageBuffer, CGRectGetMaxY(self.titleLabel.frame) + 12, self.view.height - 60, 70);
        
        
        
        
        // know them button
        
        self.knowThemButton.frame = CGRectMake(CGRectGetMaxX(self.mysteryImageView.frame) + imageBuffer,
                                               CGRectGetMaxY(self.funFactLabel.frame) + 15,
                                               CGRectGetWidth(self.mysteryImageView.frame)/2.0 - 5,
                                               buttonHeight);
        // play button
        
        [self.playButton setFrame:CGRectMake(CGRectGetMinX(self.knowThemButton.frame),
                                        CGRectGetMaxY(self.knowThemButton.frame) + 12,
                                        CGRectGetWidth(self.mysteryImageView.frame)/2.0 - 5,
                                        buttonHeight)];
        
        self.leaderboard.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame) + 40,
                                            CGRectGetMaxY(self.playButton.frame) - buttonSize,
                                            buttonSize,
                                            buttonSize);

        
    }
    [self setFunFactString:self.funFactString];
}

@end
