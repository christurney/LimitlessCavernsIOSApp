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
#import "FunFactViewController.h"
#import "FunFactsView.h"


@interface GuessWhoViewController ()
@property (nonatomic, strong) UIImageView *mysteryImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *knowThemButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *leaderboardButton;
@property (nonatomic, strong) NSArray *views;
@property (nonatomic, strong) UIAlertView *knowThemAlertView;
@property (nonatomic, strong) UIButton *funFactButton;
@property (nonatomic, strong) FunFactsView *funFactsView;
@property (nonatomic, strong) NSArray *funFacts;

@end

@implementation GuessWhoViewController

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self){
        self.funFacts = dictionary[@"facts"];
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
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.titleLabel];
    
    self.funFactsView = [[FunFactsView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:self.funFactsView];
    self.mysteryImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.mysteryImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.mysteryImageView.layer setBorderColor:[UIColor redColor].CGColor];
    [self.mysteryImageView.layer setBorderWidth:3];
    self.mysteryImageView.layer.cornerRadius = 5;
    self.mysteryImageView.backgroundColor = [UIColor redColor];
    [self.mysteryImageView setImage:[UIImage imageNamed:@"head_w_question_mark"]];
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
    
    self.leaderboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leaderboardButtonImage = [UIImage imageNamed:@"leaderboard_button"];
    [self.leaderboardButton setBackgroundImage:leaderboardButtonImage forState:UIControlStateNormal];
    [self.view addSubview:self.leaderboardButton];

    [self.leaderboardButton addTarget:self action:@selector(leaderboardClicked)
                     forControlEvents:UIControlEventTouchUpInside];
    
    
    self.views = @[self.titleLabel, self.funFactsView, self.mysteryImageView, self.knowThemButton, self.playButton, self.leaderboardButton];
    for (UIView *view in self.views){
        view.hidden = YES;
    }
    
    self.funFactButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.funFactButton];
    [self.funFactButton.layer setBorderColor:[UIColor blueColor].CGColor];
    [self.funFactButton.layer setBorderWidth:3];
    [self.funFactButton addTarget:self action:@selector(funFactsClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.funFactsView setFunFacts:self.funFacts];
}

- (void)knowThemClicked
{
    self.knowThemAlertView = [[UIAlertView alloc] initWithTitle:@"Sure You Want To Skip?"
                                                        message:@"Get 1 point (and some exercise) by bumping phones with the Mystery Dropboxer!"
                                                       delegate:self
                                              cancelButtonTitle:@"Go Back"
                                              otherButtonTitles:@"Skip", nil];
    [self.knowThemAlertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (alertView == self.knowThemAlertView)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            [self.delegate guessWhoViewControllerPressedKnowThemButton:self];
        }
    }
}

- (void)playClicked
{
    [self.delegate guessWhoViewControllerPressedPlayButton:self];
}

- (void)leaderboardClicked
{
    [self.delegate guessWhoViewControllerPressedLeaderboardButton:self];
}

- (void)funFactsClicked
{
    [self.delegate guessWhoViewControllerPressedFunFactsButton:self];
}


- (void)viewWillLayoutSubviews
{
    int imageBuffer = 30;
    int imageHeight = 0;
    if (IS_IPHONE5)
    {
        imageHeight = 255;
    }
    else
    {
        imageHeight = 175;
    }
    int buttonHeight = 40;
    int buttonSize = 50;
    self.titleLabel.frame = CGRectMake(0, .05 * self.view.height, self.view.width, 30);

    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
                
        self.funFactsView.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame) + 12, self.view.width - 60, 70);
        self.funFactsView.centerX = self.view.width / 2;
        
        
        self.mysteryImageView.frame = CGRectMake(imageBuffer,
                                                 CGRectGetMaxY(self.funFactsView.frame) + 12,
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
        
        self.leaderboardButton.frame = CGRectMake(CGRectGetMaxX(self.mysteryImageView.frame) - buttonSize,
                                                                                 CGRectGetMaxY(self.playButton.frame) + 15,
                                                                                 60,
                                                                                 60);
        
        self.funFactButton.frame = CGRectMake(CGRectGetMinX(self.leaderboardButton.frame) - 2*buttonSize, CGRectGetMinY(self.leaderboardButton.frame), buttonSize, buttonSize);
    } else {

        int imageHeight = 175;

        self.mysteryImageView.frame = CGRectMake(imageBuffer,
                                                 CGRectGetMaxY(self.titleLabel.frame) + 20,
                                                 (self.view.height - imageBuffer*2),
                                                 imageHeight);

        self.funFactsView.frame = CGRectMake(CGRectGetMaxX(self.mysteryImageView.frame) + imageBuffer, CGRectGetMaxY(self.titleLabel.frame) + 12, self.view.width - CGRectGetMaxX(self.mysteryImageView.frame) - imageBuffer, 70);
        
        
        
        
        // know them button
        
        self.knowThemButton.frame = CGRectMake(CGRectGetMaxX(self.mysteryImageView.frame) + imageBuffer,
                                               CGRectGetMaxY(self.funFactsView.frame) + 15,
                                               CGRectGetWidth(self.mysteryImageView.frame)/2.0 - 5,
                                               buttonHeight);
        // play button
        
        [self.playButton setFrame:CGRectMake(CGRectGetMinX(self.knowThemButton.frame),
                                        CGRectGetMaxY(self.knowThemButton.frame) + 12,
                                        CGRectGetWidth(self.mysteryImageView.frame)/2.0 - 5,
                                        buttonHeight)];
        
        self.leaderboardButton.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame) + 40,
                                            CGRectGetMaxY(self.playButton.frame) - buttonSize,
                                            buttonSize,
                                            buttonSize);

        
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    if (parent){
        CGFloat duration = .1;
        for (UIView *view in self.views){
            view.frame = CGRectOffset(view.frame, self.view.width, 0);
            view.hidden = NO;
        }
        [self.views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            [UIView animateWithDuration:duration delay:duration*idx options:UIViewAnimationOptionCurveEaseInOut animations:^{
                view.frame = CGRectOffset(view.frame, -self.view.width, 0);
            } completion:^(BOOL finished) {
                
            }];
        }];

    }
}


@end
