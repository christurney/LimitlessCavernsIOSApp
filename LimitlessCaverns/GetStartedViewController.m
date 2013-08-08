//
//  LimitlessCavernsViewController.m
//  LimitlessCaverns
//
//  Created by Christopher Turney on 8/5/13.
//  Copyright (c) 2013 Dropbox. All rights reserved.
//

#import "AppDelegate.h"
#import "AFJSONRequestOperation.h"
#import "GetStartedViewController.h"
#import "UIView+Dropbox.h"
#import <QuartzCore/QuartzCore.h>

@interface GetStartedViewController ()

@property (nonatomic, strong) UITextField *emailEntryField;

@end

@implementation GetStartedViewController

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
    int imageBuffer = 30;
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

    // email address entry field
    self.emailEntryField = [[UITextField alloc] initWithFrame:CGRectMake(imageBuffer,
                                                                         CGRectGetMaxY(titleLabel.frame) + 20,
                                                                         self.view.width - imageBuffer*2,
                                                                         40)];
    self.emailEntryField.delegate = self;
    self.emailEntryField.placeholder = @"Enter dropbox email address";
    self.emailEntryField.borderStyle = UITextBorderStyleRoundedRect;
    self.emailEntryField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.emailEntryField.returnKeyType = UIReturnKeyDone;
    self.emailEntryField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview:self.emailEntryField];


    // Start button

    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    [startButton setFrame:CGRectMake(titleLabel.origin.x,
                                     CGRectGetMaxY(self.emailEntryField.frame) + 20,
                                     self.view.width - imageBuffer*2,
                                     40)];
    startButton.centerX = self.view.width/2;
    [startButton setTitle:@"Login" forState:UIControlStateNormal];
    [startButton addTarget:self
                    action:@selector(startButtonClicked)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startButton];

    // Welcome image

    int imageHeight = 200;

    UIImageView *welcomeImage = [[UIImageView alloc] initWithFrame:CGRectMake(imageBuffer,
                                                                              CGRectGetMaxY(startButton
                                                                                            .frame) + 20,
                                                                              (self.view.width - imageBuffer*2),
                                                                              imageHeight)];
    [welcomeImage.layer setBorderColor:[UIColor redColor].CGColor];
    [welcomeImage.layer setBorderWidth:3];
    [self.view addSubview:welcomeImage];
}

- (void)startButtonClicked
{
    if (self.emailEntryField.text.length > 0)
    {
        NSURL *url = [NSURL URLWithString:[requestURLString stringByAppendingString:[@"/register/" stringByAppendingString:self.emailEntryField.text]]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];

        AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                             JSONRequestOperationWithRequest:request

                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                 if (JSON[@"error"]){
                                                     NSLog(@"%@", JSON);
                                                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                                                         message:[JSON valueForKeyPath:@"message"]
                                                                                                        delegate:self
                                                                                               cancelButtonTitle:@"OK"
                                                                                               otherButtonTitles:nil];
                                                     [alertView show];
                                                 } else {
                                                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Check Your E-mail"
                                                                                                         message:@"Check your e-mail to verify you're the owner of the email address you inputted."
                                                                                                        delegate:self
                                                                                               cancelButtonTitle:@"OK"
                                                                                               otherButtonTitles:nil];
                                                     [alertView show];
                                                 }
                                             }

                                             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                                                     message:[JSON valueForKeyPath:@"message"]
                                                                                                    delegate:self
                                                                                           cancelButtonTitle:@"OK"
                                                                                           otherButtonTitles:nil];
                                                 [alertView show];
                                             }];
        [operation start];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:@"You must enter an e-mail address!"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self startButtonClicked];
    return YES;
}

@end
