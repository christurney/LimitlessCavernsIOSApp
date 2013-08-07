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
#import "AFJSONRequestOperation.h"
#import "AppDelegate.h"
#import "GuessWhoViewController.h"

@interface RootViewController ()

@property (nonatomic, strong) NSString *mysteryUserID;
@property (nonatomic, weak) GuessWhoViewController *currentGuessWhoController;
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


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
        
    [self setupInitialUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)setupInitialUI
{
    // TODO decide what the initial UI should be
}

- (void)showControllerForData:(NSDictionary*)userData
{
    GuessWhoViewController *controller = [[GuessWhoViewController alloc] initWithDictionary:userData];
    controller.delegate = self;
    if (self.currentGuessWhoController){
        // Animate a transition 
        [self.currentGuessWhoController willMoveToParentViewController:nil];
        [self addChildViewController:controller];
        [self.view addSubview:controller.view];
        controller.view.frame = CGRectOffset(self.view.bounds, self.view.width, 0);
        [UIView transitionWithView:self.view duration:.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.currentGuessWhoController.view.frame = CGRectOffset(self.view.bounds, -self.view.width, 0);
            controller.view.frame = self.view.bounds;
        } completion:^(BOOL finished) {
            [self.currentGuessWhoController.view removeFromSuperview];
            [self.currentGuessWhoController removeFromParentViewController];
            [controller didMoveToParentViewController:self];
            self.currentGuessWhoController = controller;
        }];
    } else {
        [self addChildViewController:controller];
        [self.view addSubview:controller.view];
        controller.view.frame = self.view.bounds;
        [controller didMoveToParentViewController:self];
        self.currentGuessWhoController = controller;
    }
}

- (void)showUserInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults valueForKey:@"userID"];
    if (![defaults valueForKey:@"mysteryUserData"])
    {
        NSLog(@"Make server request!");
        [self getMysteryUserInfo:userID];
    }
    else
    {
        [self showControllerForData:[defaults valueForKey:@"mysteryUserData"]];
    }
}

-(void)getMysteryUserInfo:(NSString *)userID
{
//    NSURL *url = [NSURL URLWithString:[requestURLString stringByAppendingString:[@"/mystery_user_info_for_user/" stringByAppendingString:userID]]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation
//                                         JSONRequestOperationWithRequest:request
//
//                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//                                             // store user info and update the text box
//
//                                             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//                                             
//                                             [defaults setObject:JSON forKey:@"msyteryUserData"];
//                                             [defaults synchronize];
//
//                                             [self showControllerForData:JSON];
//                                         }
//                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//                                             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
//                                                                                                 message:[JSON valueForKeyPath:@"message"]
//                                                                                                delegate:self
//                                                                                       cancelButtonTitle:@"OK"
//                                                                                       otherButtonTitles:nil];
//                                             [alertView show];
//                                         }];
//    [operation start];
//    
    NSDictionary *mysteryDictionary = @{@"fun_fact": @"my family owns santa barbara honda"};
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:mysteryDictionary forKey:@"msyteryUserData"];
    [defaults synchronize];
    [self showControllerForData:mysteryDictionary];
}

- (void)guessWhoViewControllerPressedAButton:(GuessWhoViewController *)guessWhoVC
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *data = [defaults valueForKey:@"myteryUserData"];
    [self showControllerForData:data];
}


@end
