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

@property (nonatomic, strong) UITextView *funFactEntryField;

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
    titleLabel.centerY = self.view.height*.12;
    titleLabel.centerX = self.view.width / 2.0;
    [titleLabel setNumberOfLines:2];
    [titleLabel setText:@"Add a fun fact about yourself:"];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:titleLabel];

    // fun fact entry field
    self.funFactEntryField = [[UITextView alloc] initWithFrame:CGRectMake(0,
                                                                           CGRectGetMaxY(titleLabel.frame) + 15,
                                                                           self.view.width - 2 * imageBuffer,
                                                                           80)];
    self.funFactEntryField.centerX = self.view.width / 2.0;

    self.funFactEntryField.delegate = self;
    self.funFactEntryField.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    self.funFactEntryField.layer.cornerRadius = 5;
    [self.funFactEntryField.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.funFactEntryField.layer setBorderWidth:2.0];
    self.funFactEntryField.clipsToBounds = YES;
    self.funFactEntryField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:self.funFactEntryField];

    int buttonWidth = 75;
    int buttonHeight = 40;
    int buttonInset = 40;
    int buttonOffset = 15;

    // Go button
    UIButton *goButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    [goButton setFrame:CGRectMake(buttonInset + CGRectGetMinX(self.funFactEntryField.frame),
                                  CGRectGetMaxY(self.funFactEntryField.frame) + buttonOffset,
                                  buttonWidth,
                                  buttonHeight)];
    [goButton setTitle:@"Go" forState:UIControlStateNormal];
    [goButton addTarget:self
                 action:@selector(goButtonClicked)
       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goButton];

    // Skip button
    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    [skipButton setFrame:CGRectMake(CGRectGetMaxX(self.funFactEntryField.frame) - buttonInset - buttonWidth,
                                    CGRectGetMaxY(self.funFactEntryField.frame) + buttonOffset,
                                    buttonWidth,
                                    buttonHeight)];

    [skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    [skipButton addTarget:self
                   action:@selector(skipButtonClicked)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipButton];
}

- (void)goButtonClicked
{
    if ([self.funFactEntryField hasText]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *userID = [defaults valueForKey:@"userID"];
        if(!userID) return;

        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:requestURLString]];
        [httpClient setParameterEncoding:AFFormURLParameterEncoding];
        NSURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                                path:[NSString stringWithFormat:@"%@/users/%@/facts", requestURLString, userID]
                                                          parameters:@{@"fact":self.funFactEntryField.text}];

        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];

        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if([self.delegate respondsToSelector:@selector(funFactViewControllerFinished:)]){
                [self.delegate funFactViewControllerFinished:self];
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
    if([self.delegate respondsToSelector:@selector(funFactViewControllerFinished:)]){
        [self.delegate funFactViewControllerFinished:self];
    }
}

// when the user clicks Done don't treat it as if they typed a newline
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqual:@"\n"]) {
        [textView resignFirstResponder];
        [self goButtonClicked];
        return NO;
    }
    return YES;
}


@end
