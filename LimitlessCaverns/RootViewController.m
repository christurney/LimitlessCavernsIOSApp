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
#import "GuessWhoViewController.h"
#import "GuessWhoHalpersViewController.h"
#import "LeaderboardViewController.h"
#import "AppDelegate.h"

@interface RootViewController ()

@property (nonatomic, strong) NSString *mysteryUserID;
@property (nonatomic, weak) UIViewController *currentlyDisplayedController;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
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
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.color = [UIColor blackColor];
    [self.view addSubview:activityIndicator];
    activityIndicator.center = [self.view convertPoint:self.view.center fromView:self.view.superview];
    activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator = activityIndicator;
    self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    //0, 133, 242
    //0, 116, 212

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
        [self getMysteryUserInfo:userID userDidSkip:NO];
    }
    else
    {
        [self showControllerForData:[defaults valueForKey:@"mysteryUserData"] showHalpers:NO];
    }
}

- (void)showLeaderBoard
{
    [self.navigationController presentViewController:[[UINavigationController alloc]
                                                      initWithRootViewController:[[LeaderboardViewController alloc] init]]
                                            animated:YES completion:nil];
}

-(void)getMysteryUserInfo:(NSString *)userID userDidSkip:(BOOL)userDidSkip
{
    NSURL *url = nil;

    if (userDidSkip)
    {
        url = [NSURL URLWithString:[requestURLString stringByAppendingString:[NSString stringWithFormat:@"/users/%@/skip_assignment", userID]]];
    }
    else
    {
        url = [NSURL URLWithString:[requestURLString stringByAppendingString:[NSString stringWithFormat:@"/users/%@/current_assignment", userID]]];
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//TODO add a status overlay
    self.currentlyDisplayedController.view.alpha = .5;
    self.view.userInteractionEnabled = NO;
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request

                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             // store user info and update the text box

                                             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                             
                                             [defaults setObject:JSON forKey:@"mysteryUserData"];
                                             [defaults synchronize];

                                             [self showControllerForData:JSON showHalpers:NO];
                                             self.view.userInteractionEnabled = YES;
                                             self.currentlyDisplayedController.view.alpha = 1;
                                             [self.activityIndicator stopAnimating];
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                                                 message:[JSON valueForKeyPath:@"message"]
                                                                                                delegate:self
                                                                                       cancelButtonTitle:@"OK"
                                                                                       otherButtonTitles:nil];
                                             [alertView show];
                                             self.view.userInteractionEnabled = YES;
                                             self.view.alpha = 1;
                                             self.currentlyDisplayedController.view.alpha = 1;
                                             [self.activityIndicator stopAnimating];

                                         }];
    [operation start];

//    NSDictionary *mysteryDictionary = @{@"fact": @"my family owns santa barbara honda", @"id": @"abcdefg", @"halpers":@[@"http://onesentencereview.com/images/avatar_placeholder_large.png?1301662607", @"http://developersdevelopersdevelopersdevelopers.org/assets/icons/avatar-placeholder-1729c5f2a2b4e35e1bf1f04606895af4.png"]};
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:mysteryDictionary forKey:@"mysteryUserData"];
//    [defaults synchronize];
//    [self showControllerForData:mysteryDictionary showHalpers:FALSE];
}

- (void)guessWhoViewControllerPressedKnowThemButton:(GuessWhoViewController *)guessWhoVC
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults valueForKey:@"userID"];
    [self getMysteryUserInfo:userID userDidSkip:YES];
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
    NSString *userID = [defaults valueForKey:@"userID"];
    [self getMysteryUserInfo:userID userDidSkip:YES];
}

- (void)guessWhoViewControllerPressedLeaderboardButton:(GuessWhoViewController *)guessWhoVC
{
    [self showLeaderBoard];
}

- (void)guessWhoHalpersViewControllerPressedLeaderboardButton:(GuessWhoHalpersViewController *)guessWhoHalpersVC
{
    [self showLeaderBoard];
}

- (void)viewWillLayoutSubviews
{
}

@end
