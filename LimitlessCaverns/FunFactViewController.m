//
//  FunFactViewController.m
//  LimitlessCaverns
//
//  Created by Christopher Turney on 8/7/13.
//  Copyright (c) 2013 Dropbox. All rights reserved.
//

#import "FunFactViewController.h"
#import "UIView+Dropbox.h"
#import <QuartzCore/QuartzCore.h>
#import "AFHTTPClient.h"
#import "AppDelegate.h"
#import "AFHTTPRequestOperation.h"

@interface FunFactViewController ()

@property (nonatomic, strong) UITextField *funFactEntryField;

@end

@implementation FunFactViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    int imageBuffer = 30;

    // Title label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    self.view.width - 2 * imageBuffer,
                                                                    65)];
    titleLabel.centerY = self.view.height*.15;
    titleLabel.centerX = self.view.width / 2.0;
    [titleLabel setNumberOfLines:2];
    [titleLabel setText:@"Add a fun fact about yourself:"];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:titleLabel];

    // fun fact entry field
    self.funFactEntryField = [[UITextField alloc] initWithFrame:CGRectMake(0,
                                                                           CGRectGetMaxY(titleLabel.frame) + 20,
                                                                           self.view.width - 2 * imageBuffer,
                                                                           200)];
    self.funFactEntryField.centerX = self.view.width / 2.0;

    self.funFactEntryField.delegate = self;
    self.funFactEntryField.placeholder = @"Enter a fun fact";
    self.funFactEntryField.borderStyle = UITextBorderStyleRoundedRect;
    self.funFactEntryField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:self.funFactEntryField];

    int buttonWidth = 75;
    int buttonHeight = 40;

    // Go button
    UIButton *goButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    [goButton setFrame:CGRectMake(0,
                                  CGRectGetMaxY(self.funFactEntryField.frame) + 20,
                                  buttonWidth,
                                  buttonHeight)];
    goButton.centerX = self.view.width / 2.0;
    [goButton setTitle:@"Go" forState:UIControlStateNormal];
    [goButton addTarget:self
                 action:@selector(goButtonClicked)
       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goButton];

    // Skip button
    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    [skipButton setFrame:CGRectMake(0,
                                    CGRectGetMaxY(goButton.frame) + 15,
                                    buttonWidth,
                                    buttonHeight)];
    skipButton.centerX = self.view.width / 2.0;

    [skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    [skipButton addTarget:self
                   action:@selector(skipButtonClicked)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipButton];
}

- (void)goButtonClicked
{
    if (self.funFactEntryField.text.length > 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *userID = [defaults valueForKey:@"userID"];
        if(!userID) return;

        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:requestURLString]];
        [httpClient setParameterEncoding:AFFormURLParameterEncoding];
        NSURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                                path:[NSString stringWithFormat:@"%@/%@/facts", requestURLString, userID]
                                                          parameters:@{@"fact":self.funFactEntryField.text}];

        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];

        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if([self.navigationController.visibleViewController isKindOfClass:[FunFactViewController class]])
            {
                [self.navigationController.visibleViewController dismissViewControllerAnimated:YES completion:^{
                    nil;
                }];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:@"Your fun fact was not received."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }];
        
        [operation start];
    }
}

- (void)skipButtonClicked
{
    // I'm assuming this view was presented modally
    if([self.navigationController.visibleViewController isKindOfClass:[FunFactViewController class]])
    {
        [self.navigationController.visibleViewController dismissViewControllerAnimated:YES completion:^{
            nil;
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self goButtonClicked];
    return YES;
}



@end
