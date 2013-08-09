//
//  GuessWhoHalpersViewController.m
//  LimitlessCaverns
//
//  Created by Matthew Jaffe on 8/7/13.
//  Copyright (c) 2013 Dropbox. All rights reserved.
//

#import "GuessWhoHalpersViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Dropbox.h"
#import "UIImageView+AFNetworking.h"
#import "FunFactViewController.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "FunFactsView.h"

@interface GuessWhoHalpersViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) UIView *pointsBoxView;
@property (nonatomic, strong) UILabel *pointsBoxLabel;

@property (nonatomic, strong) UIView *mysteryPersonView;
@property (nonatomic, strong) UIImageView *mysteryPersonImageView;
@property (nonatomic, strong) FunFactsView *funFactsView;

@property (nonatomic, strong) UIView *meetTheseHalpersTitleView;
@property (nonatomic, strong) UILabel *meetTheseHalpersTitleLabel;

@property (nonatomic, strong) UIView *meetTheseHalpersView;
@property (nonatomic, strong) UIImageView *halper1ImageView;
@property (nonatomic, strong) UIImageView *halper2ImageView;
@property (nonatomic, strong) UIImageView *halper3ImageView;
@property (nonatomic, strong) UIImageView *halper4ImageView;

@property (nonatomic, strong) UIView *tableBottomView;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) UIButton *leaderboardButton;

@property (nonatomic, strong) UIAlertView *skipAlertView;
@property (nonatomic, strong) UIAlertView *failureAlertView;
@property (nonatomic, strong) UIAlertView *successAlertView;
@property (nonatomic, strong) NSMutableArray *views;

@property (nonatomic, strong) NSDictionary *userDataDictionary;
@property (nonatomic) BOOL handlingBump;
@property (nonatomic, strong) NSArray *funFacts;

@end

@implementation GuessWhoHalpersViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self){
        self.funFacts = dictionary[@"facts"];
        self.userDataDictionary = dictionary;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Add notification observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(verifySuccessFailure:) name:@"VerifySuccessFailureNotification" object:nil];

    // Set up loading indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.color = [UIColor blackColor];
    [self.view addSubview:activityIndicator];
    activityIndicator.center = [self.view convertPoint:self.view.center fromView:self.view.superview];
    activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator = activityIndicator;
    self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;

    self.views = [NSMutableArray array];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // Number of points box
    self.pointsBoxView = [[UIView alloc] initWithFrame:CGRectZero];
    self.pointsBoxView.backgroundColor = [UIColor colorWithRed:187/255.f green:220/255.f blue:241/255.f alpha:1];
    [self.views addObject:self.pointsBoxView];

    self.pointsBoxLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.pointsBoxLabel setText:@"Bump phones with this mystery Dropboxer to get 1 point:"];
    [self.pointsBoxLabel setFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]];
    [self.pointsBoxLabel setTextAlignment:NSTextAlignmentLeft];
    self.pointsBoxLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    self.pointsBoxLabel.numberOfLines = 2;
    self.pointsBoxLabel.backgroundColor = self.pointsBoxView.backgroundColor;
    [self.pointsBoxView addSubview:self.pointsBoxLabel];

    // Mystery person info
    self.mysteryPersonView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.views addObject:self.mysteryPersonView];

    self.mysteryPersonImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.mysteryPersonImageView setImage:[UIImage imageNamed:@"head_w_question_mark"]];
    self.mysteryPersonImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.mysteryPersonView addSubview:self.mysteryPersonImageView];

    self.funFactsView = [[FunFactsView alloc] initWithFrame:CGRectZero];
    [self.funFactsView setFunFacts:self.funFacts];
    [self.mysteryPersonView addSubview:self.funFactsView];

    // Meet these halpers title
    self.meetTheseHalpersTitleView = [[UIView alloc] initWithFrame:CGRectZero];
    self.meetTheseHalpersTitleView.backgroundColor = self.pointsBoxView.backgroundColor;
    [self.views addObject:self.meetTheseHalpersTitleView];

    self.meetTheseHalpersTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.meetTheseHalpersTitleLabel setText:@"Meet these HALPers to get clues:"];
    [self.meetTheseHalpersTitleLabel setFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]];
    [self.meetTheseHalpersTitleLabel setTextAlignment:NSTextAlignmentLeft];
    self.meetTheseHalpersTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    self.meetTheseHalpersTitleLabel.backgroundColor = self.pointsBoxView.backgroundColor;
    [self.meetTheseHalpersTitleView addSubview:self.meetTheseHalpersTitleLabel];

    // Meet these halpers
    self.meetTheseHalpersView = [[UIView alloc] initWithFrame:CGRectZero];
    self.meetTheseHalpersView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.views addObject:self.meetTheseHalpersView];

    self.halper1ImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.halper1ImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.halper1ImageView.layer setBorderColor:[UIColor colorWithWhite:0.8 alpha:1].CGColor];
    [self.halper1ImageView.layer setBorderWidth:1];

    self.halper2ImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.halper2ImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.halper2ImageView.layer setBorderColor:[UIColor colorWithWhite:0.8 alpha:1].CGColor];
    [self.halper2ImageView.layer setBorderWidth:1];

    self.halper3ImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.halper3ImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.halper3ImageView.layer setBorderColor:[UIColor colorWithWhite:0.8 alpha:1].CGColor];
    [self.halper3ImageView.layer setBorderWidth:1];

    self.halper4ImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.halper4ImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.halper4ImageView.layer setBorderColor:[UIColor colorWithWhite:0.8 alpha:1].CGColor];
    [self.halper4ImageView.layer setBorderWidth:1];

    [self.meetTheseHalpersView addSubview:self.halper1ImageView];
    [self.meetTheseHalpersView addSubview:self.halper2ImageView];
    [self.meetTheseHalpersView addSubview:self.halper3ImageView];
    [self.meetTheseHalpersView addSubview:self.halper4ImageView];

    // Skip / leaderboard button
    self.tableBottomView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableBottomView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self.views addObject:self.tableBottomView];

    self.skipButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    [self.skipButton addTarget:self
                        action:@selector(skipClicked)
              forControlEvents:UIControlEventTouchUpInside];
    [self.tableBottomView addSubview:self.skipButton];

    self.leaderboardButton = [[UIButton alloc] initWithFrame:CGRectZero];
    UIImage *leaderboardButtonImage = [UIImage imageNamed:@"leaderboard_button"];
    [self.leaderboardButton setBackgroundImage:leaderboardButtonImage forState:UIControlStateNormal];
    [self.leaderboardButton addTarget:self
                               action:@selector(leaderboardClicked)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.tableBottomView addSubview:self.leaderboardButton];

    self.tableView.backgroundColor = [UIColor clearColor];
    for (UIView *view in self.views){
        view.hidden = YES;
    }

}

- (void)viewWillLayoutSubviews
{
    int leftBuffer = 10;

    self.pointsBoxView.frame = CGRectMake(0,
                                          0,
                                          self.view.width,
                                          50);

    CGRect pointsBoxLabelFrame = self.pointsBoxView.frame;
    pointsBoxLabelFrame.origin.x += leftBuffer;
    pointsBoxLabelFrame.size.width -= leftBuffer;
    self.pointsBoxLabel.frame = pointsBoxLabelFrame;

    self.mysteryPersonView.frame = CGRectMake(0,
                                              0,
                                              self.view.width,
                                              100);

    self.mysteryPersonImageView.frame = CGRectMake(leftBuffer,
                                                   leftBuffer,
                                                   80,
                                                   80);

    self.funFactsView.frame = CGRectMake(CGRectGetMaxX(self.mysteryPersonImageView.frame) + leftBuffer,
                                         leftBuffer,
                                         self.mysteryPersonView.width - leftBuffer - CGRectGetMaxX(self.mysteryPersonImageView.frame),
                                         80);

    self.meetTheseHalpersTitleView.frame = CGRectMake(0,
                                                      0,
                                                      self.view.width,
                                                      30);

    CGRect meetTheseHalpersTitleLabelFrame = self.meetTheseHalpersTitleView.frame;
    meetTheseHalpersTitleLabelFrame.origin.x += leftBuffer;
    meetTheseHalpersTitleLabelFrame.size.width -= leftBuffer;
    self.meetTheseHalpersTitleLabel.frame = meetTheseHalpersTitleLabelFrame;

    int meetTheseHalpersViewHeight = 0;
    int halperImageHeightWidth = 0;

    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        if (IS_IPHONE5)
        {
            meetTheseHalpersViewHeight = 288;
            halperImageHeightWidth = 120;
        }
        else
        {
            meetTheseHalpersViewHeight = 200;
            halperImageHeightWidth = 80;
        }
    }
    else
    {
        meetTheseHalpersViewHeight = 200;
        halperImageHeightWidth = 80;
    }

    self.meetTheseHalpersView.frame = CGRectMake(0,
                                                 0,
                                                 self.view.width,
                                                 meetTheseHalpersViewHeight);

    // This is so pictures scale up both horizontally and vertically when iPhone 5 is used
    int halperImageTopBuffer = (self.meetTheseHalpersView.height - (halperImageHeightWidth)*2)/3;
    int halperImageBuffer = (self.meetTheseHalpersView.width - (halperImageHeightWidth)*2)/3;

    self.halper1ImageView.frame = CGRectMake(halperImageBuffer,
                                             halperImageTopBuffer,
                                             halperImageHeightWidth,
                                             halperImageHeightWidth);

    self.halper2ImageView.frame = CGRectMake(CGRectGetMaxX(self.halper1ImageView.frame) + halperImageBuffer,
                                             self.halper1ImageView.frame.origin.y,
                                             halperImageHeightWidth,
                                             halperImageHeightWidth);

    self.halper3ImageView.frame = CGRectMake(halperImageBuffer,
                                             CGRectGetMaxY(self.halper1ImageView.frame) + leftBuffer,
                                             halperImageHeightWidth,
                                             halperImageHeightWidth);

    self.halper4ImageView.frame = CGRectMake(CGRectGetMaxX(self.halper3ImageView.frame) + halperImageBuffer,
                                             self.halper3ImageView.frame.origin.y,
                                             halperImageHeightWidth,
                                             halperImageHeightWidth);

    self.tableBottomView.frame = CGRectMake(0,
                                            0,
                                            self.view.width,
                                            80);

    int buttonWidth = 60;

    self.leaderboardButton.frame = CGRectMake(self.tableBottomView.width - buttonWidth - leftBuffer,
                                              leftBuffer,
                                              60,
                                              60);

    self.skipButton.frame = CGRectMake(CGRectGetMinX(self.leaderboardButton.frame) - leftBuffer - buttonWidth,
                                       leftBuffer,
                                       buttonWidth,
                                       60);

    NSArray *halperImageViewsArray = @[self.halper1ImageView, self.halper2ImageView, self.halper3ImageView, self.halper4ImageView];
    NSArray *halpers = [self.userDataDictionary objectForKey:@"halpers"];

    for (NSDictionary *halperDictionary in halpers)
    {
        NSURL *url = [NSURL URLWithString:[halperDictionary objectForKey:@"image"]];
        [[halperImageViewsArray objectAtIndex:[halpers indexOfObject:halperDictionary]] setImageWithURL:url placeholderImage:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return self.pointsBoxView.height;
    }
    else if (indexPath.row == 1)
    {
        return self.mysteryPersonView.height;
    }
    else if (indexPath.row == 2)
    {
        return self.meetTheseHalpersTitleView.height;
    }
    else if (indexPath.row == 3)
    {
        return self.meetTheseHalpersView.height;
    }
    else if (indexPath.row == 4)
    {
        return self.tableBottomView.height;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        for (UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
    }

    if (indexPath.row == 0)
    {
        [cell.contentView addSubview:self.pointsBoxView];
    }
    else if (indexPath.row == 1)
    {
        [cell.contentView addSubview:self.mysteryPersonView];
    }
    else if (indexPath.row == 2)
    {
        [cell.contentView addSubview:self.meetTheseHalpersTitleView];
    }
    else if (indexPath.row == 3)
    {
        [cell.contentView addSubview:self.meetTheseHalpersView];
    }
    else if (indexPath.row == 4)
    {
        [cell.contentView addSubview:self.tableBottomView];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Button methods

- (void)skipClicked
{
    self.skipAlertView = [[UIAlertView alloc] initWithTitle:@"Giving up!?"
                                                    message:@"Are you SURE you want to give up and skip?"
                                                   delegate:self
                                          cancelButtonTitle:@"Keep Trying!"
                                          otherButtonTitles:@"Lamesauce", nil];
    [self.skipAlertView show];
}

- (void)leaderboardClicked
{
    [self.delegate guessWhoHalpersViewControllerPressedLeaderboardButton:self];
    NSLog(@"Leaderboard clicked!");
}

- (void)showSuccessAlertView
{
    NSString *titleString = @"YOU DID IT!!";
    NSString *messageString = @"+1 for finding the Mystery Dropboxer :-)";

    self.successAlertView = [[UIAlertView alloc] initWithTitle:titleString
                                                       message:messageString
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"Add Fun Fact", @"Next Challenge", nil];

    [self.successAlertView show];
}

- (void)showFailureAlertView
{
    self.failureAlertView = [[UIAlertView alloc] initWithTitle:@"Nice Try..."
                                                       message:@"Keep searching! Don't forget to ask your Halpers."
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];

    [self.failureAlertView show];
}

- (void)verifySuccessFailure:(NSNotification *)notification
{
    // Ensure that this isn't called when user has Leaderboard opened.
    if (!self.navigationController.presentedViewController && !self.handlingBump)
    {
        self.handlingBump = YES;
        NSDictionary *dict = [notification userInfo];
        NSString *bumpedUserID = [dict objectForKey:@"bumped_user_id"];

        if ([[self.userDataDictionary objectForKey:targetIdKey] isEqualToString:bumpedUserID])
        {
            [self userSucceeded];
        }
        else
        {
            [self showFailureAlertView];
        }
    }
}

- (void)userSucceeded
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults objectForKey:userIdKey];
    NSURL *url = [NSURL URLWithString:[requestURLString stringByAppendingString:[NSString stringWithFormat:@"/users/%@/complete_assignment", userID]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //TODO add a status overlay
    self.view.alpha = .5;
    self.view.userInteractionEnabled = NO;
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request

                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             self.view.userInteractionEnabled = YES;
                                             self.view.alpha = 1;
                                             [self.activityIndicator stopAnimating];
                                             [self showSuccessAlertView];
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
                                             [self.activityIndicator stopAnimating];
                                         }];
    [operation start];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (alertView == self.skipAlertView)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            [self.delegate guessWhoHalpersViewControllerPressedSkipButton:self];
        }
    }
    else if (alertView == self.successAlertView)
    {
        if (buttonIndex == 0 && alertView.numberOfButtons > 1)
        {
            //Open Add fun fact controller if user presses 'Add fun fact'
            NSLog(@"%d", buttonIndex);
            FunFactViewController *funFactVC = [[FunFactViewController alloc] init];
            [self presentViewController:funFactVC animated:YES completion:^(void){nil;}];
        }
        else
        {
            //Show next person
            [self.delegate guessWhoHalpersSucceeded:self];
        }
    }
    else if (alertView == self.failureAlertView){
        self.handlingBump = NO;
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
