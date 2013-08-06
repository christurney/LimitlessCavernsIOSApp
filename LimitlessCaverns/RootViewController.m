//
//  RootViewController.m
//  LimitlessCaverns
//
//  Created by Christopher Turney on 8/6/13.
//  Copyright (c) 2013 Dropbox. All rights reserved.
//

#import "RootViewController.h"
#import "UIView+Dropbox.h"
#import "GetStartedViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface RootViewController ()

@property (nonatomic, strong) NSString *funFactString;
@property (nonatomic, strong) UILabel *funFactLabel;


@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self setupInitialUI];
    [self checkLoginState];
}

- (void)setupInitialUI
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                    .05 * self.view.height,
                                                                    self.view.width,
                                                                    30)];
    [titleLabel setText:@"Mystery Dropboxer"];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:titleLabel];

    self.funFactLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                  CGRectGetMaxY(titleLabel.frame) + 12,
                                                                  self.view.width - 60,
                                                                  70)];
    self.funFactLabel.centerX = self.view.width / 2;
    [self.funFactLabel setTextAlignment:NSTextAlignmentCenter];
    self.funFactLabel.adjustsFontSizeToFitWidth = NO;
    self.funFactLabel.numberOfLines = 0;
    self.funFactString = @"my family owns santa barbara honda";

    [self.view addSubview:self.funFactLabel];

    int imageBuffer = 30;
    int imageHeight = 175;

    UIImageView *mysteryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageBuffer,
                                                                                  CGRectGetMaxY(self.funFactLabel.frame) + 12,
                                                                                  (self.view.width - imageBuffer*2),
                                                                                  imageHeight)];
    [mysteryImageView.layer setBorderColor:[UIColor redColor].CGColor];
    [mysteryImageView.layer setBorderWidth:3];
    [self.view addSubview:mysteryImageView];

    int buttonHeight = 40;

    // know them button
    UIButton *knowThemButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    [knowThemButton setFrame:CGRectMake(mysteryImageView.origin.x,
                                        CGRectGetMaxY(mysteryImageView.frame) + 15,
                                        CGRectGetWidth(mysteryImageView.frame)/2.0 - 5,
                                        buttonHeight)];
    [knowThemButton setTitle:@"Know Them" forState:UIControlStateNormal];
    [knowThemButton addTarget:self
                       action:@selector(knowThemClicked)
             forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:knowThemButton];

    // play button
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    [playButton setFrame:CGRectMake(CGRectGetMaxX(knowThemButton.frame) + 10,
                                    CGRectGetMaxY(mysteryImageView.frame) + 15,
                                    CGRectGetWidth(mysteryImageView.frame)/2.0 - 5,
                                    buttonHeight)];
    [playButton setTitle:@"Play!" forState:UIControlStateNormal];
    [playButton addTarget:self
                   action:@selector(playClicked)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];

    // leaderboard picture

    int buttonSize = 50;
    UIImageView *leaderBoard = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(mysteryImageView.frame) - buttonSize,
                                                                             CGRectGetMaxY(playButton.frame) + 15,
                                                                             buttonSize,
                                                                             buttonSize)];
    [self.view addSubview:leaderBoard];
    [leaderBoard.layer setBorderColor:[UIColor redColor].CGColor];
    [leaderBoard.layer setBorderWidth:3];
}

- (void)checkLoginState
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (![defaults valueForKey:@"user_id"])
    {
        [self.navigationController presentViewController:[[GetStartedViewController alloc] init]
                                                animated:NO
                                              completion:^{
                                                  nil;
                                              }];
    }
}


@end
