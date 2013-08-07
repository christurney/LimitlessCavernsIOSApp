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
#import "GuessWhoHalpersViewController.h"

@interface RootViewController ()

@property (nonatomic, strong) NSString *mysteryUserID;
@property (nonatomic, weak) UIViewController *currentlyDisplayedController;
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

- (UIViewController *)viewControllerForData:(NSDictionary*)userData showHalpers:(BOOL)showHalpers
{
    if (showHalpers)
    {
        GuessWhoHalpersViewController *controller = [[GuessWhoHalpersViewController alloc] initWithDictionary:userData];
        controller.delegate = self;
        return controller;
    }
    else
    {
        GuessWhoViewController *controller = [[GuessWhoViewController alloc] initWithDictionary:userData];
        controller.delegate = self;
        return controller;
    }
}

- (void)showControllerForData:(NSDictionary*)userData showHalpers:(BOOL)showHalpers
{
    if (self.currentlyDisplayedController){
        // Animate a transition 
        [self.currentlyDisplayedController willMoveToParentViewController:nil];

        UIViewController *controller = [self viewControllerForData:userData showHalpers:showHalpers];

        [self addChildViewController:controller];
        [self.view addSubview:controller.view];
        controller.view.frame = CGRectOffset(self.view.bounds, self.view.width, 0);
        [UIView transitionWithView:self.view duration:.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.currentlyDisplayedController.view.frame = CGRectOffset(self.view.bounds, -self.view.width, 0);
            controller.view.frame = self.view.bounds;
        } completion:^(BOOL finished) {
            [self.currentlyDisplayedController.view removeFromSuperview];
            [self.currentlyDisplayedController removeFromParentViewController];
            [controller didMoveToParentViewController:self];
            self.currentlyDisplayedController = controller;
        }];
    } else {
        GuessWhoViewController *controller = [[GuessWhoViewController alloc] initWithDictionary:userData];
        controller.delegate = self;
        [self addChildViewController:controller];
        [self.view addSubview:controller.view];
        controller.view.frame = self.view.bounds;
        [controller didMoveToParentViewController:self];
        self.currentlyDisplayedController = controller;
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
        [self showControllerForData:[defaults valueForKey:@"mysteryUserData"] showHalpers:NO];
    }
}

-(void)getMysteryUserInfo:(NSString *)userID
{
//    NSURL *url = [NSURL URLWithString:[requestURLString stringByAppendingString:[@"/get_new_assignment/" stringByAppendingString:userID]]];
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
    [defaults setObject:mysteryDictionary forKey:@"mysteryUserData"];
    [defaults synchronize];
    [self showControllerForData:mysteryDictionary showHalpers:FALSE];
}

- (void)guessWhoViewControllerPressedKnowThemButton:(GuessWhoViewController *)guessWhoVC
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *data = [defaults valueForKey:@"mysteryUserData"];
    [self showControllerForData:data showHalpers:NO];
}

- (void)guessWhoViewControllerPressedPlayButton:(GuessWhoViewController *)guessWhoVC
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *data = [defaults valueForKey:@"mysteryUserData"];
    [self showControllerForData:data showHalpers:YES];
}

- (void)guessWhoHalpersViewControllerPressedSkipButton:(GuessWhoHalpersViewController *)guessWhoHalpersVC
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *data = [defaults valueForKey:@"mysteryUserData"];
    [self showControllerForData:data showHalpers:NO];
}

@end
