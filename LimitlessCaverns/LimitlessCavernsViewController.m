//
//  LimitlessCavernsViewController.m
//  LimitlessCaverns
//
//  Created by Christopher Turney on 8/5/13.
//  Copyright (c) 2013 Dropbox. All rights reserved.
//

#import "AFJSONRequestOperation.h"
#import "LimitlessCavernsViewController.h"
#import "UIView+Dropbox.h"
#import <QuartzCore/QuartzCore.h>

@interface LimitlessCavernsViewController ()

@end

@implementation LimitlessCavernsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self.view setBackgroundColor:[UIColor whiteColor]];

    // Title label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    self.view.width,
                                                                    30)];
    titleLabel.centerY = self.view.height*.15;

    [titleLabel setText:@"Guess Who?"];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:35]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:titleLabel];

    // Welcome image
    int imageBuffer = 30;
    int imageHeight = 250;

    UIImageView *welcomeImage = [[UIImageView alloc] initWithFrame:CGRectMake(imageBuffer,
                                                                              CGRectGetMaxY(titleLabel.frame) + 20,
                                                                              (self.view.width - imageBuffer*2),
                                                                              imageHeight)];
    [welcomeImage.layer setBorderColor:[UIColor redColor].CGColor];
    [welcomeImage.layer setBorderWidth:3];
    [self.view addSubview:welcomeImage];

    // Start button

    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    [startButton setFrame:CGRectMake(titleLabel.origin.x,
                                     CGRectGetMaxY(welcomeImage.frame) + 20,
                                     200,
                                     40)];
    startButton.centerX = self.view.width/2;
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    [startButton addTarget:self
                    action:@selector(startButtonClicked)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSURL *url = [NSURL URLWithString:@"http://limitless-caverns-4433.herokuapp.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request

                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             NSLog(@"IP Address: %@", [JSON valueForKeyPath:@"origin"]);
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             NSLog(@"failed");
                                         }];
    [operation start];
}

- (void)startButtonClicked
{
    NSLog(@"Button Pressed!");
}

@end
