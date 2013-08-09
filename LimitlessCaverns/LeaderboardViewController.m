//
//  LeaderboardViewController.m
//  LimitlessCaverns
//
//  Created by Christopher Turney on 8/7/13.
//  Copyright (c) 2013 Dropbox. All rights reserved.
//

#import "LeaderboardViewController.h"
#import "AppDelegate.h"
#import "AFJSONRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "UIView+Dropbox.h"
#import "GradientButton.h"

static NSString *cellIdentifier = @"leaderboardCell";

@interface LeaderboardViewController ()

@property (nonatomic, strong) NSMutableArray *leaders;
@property (nonatomic, strong) UIImage *placeHolderImage;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LeaderboardViewController

- (id)init
{
    self = [super init];
    if (self){

    }
    return self;
}

- (void)closeLeaderboard
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(UIImage*)placeHolderImage
{
    if(_placeHolderImage) return _placeHolderImage;

    _placeHolderImage = [UIImage imageNamed:@"placeHolderImage.png"];
    return _placeHolderImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat titleHeight = 60;
    CGFloat titleBuffer = 0;
    CGFloat titleCloseButtonMargin = 10;
    CGFloat buttonWidth = 60;
    CGFloat buttonHeight = 40;

    UIView *headerGrayView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     self.view.width,
                                                                     titleHeight)];
    headerGrayView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self.view addSubview:headerGrayView];

    UILabel *title = [[UILabel alloc] initWithFrame:headerGrayView.bounds];
    title.width = 150;
    title.centerX = headerGrayView.centerX;
    title.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = @"Leaderboard";
    title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25];
    title.numberOfLines = 1;
    [headerGrayView addSubview:title];
    title.textColor = [UIColor redColor];


    GrayGradientButton *closeButton = [[GrayGradientButton alloc] init];
    closeButton.frame = CGRectMake(CGRectGetMaxX(title.frame) + titleCloseButtonMargin,
                                   0,
                                   buttonWidth,
                                   buttonHeight);
    closeButton.centerY = headerGrayView.centerY;
    [closeButton configure];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton addTarget:self
                        action:@selector(closeLeaderboard)
              forControlEvents:UIControlEventTouchUpInside];
    [headerGrayView addSubview: closeButton];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, titleHeight + titleBuffer, self.view.width, self.view.height - titleHeight - titleBuffer) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];

    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.color = [UIColor blackColor];
    [self.view addSubview:activityIndicator];
    activityIndicator.center = [self.view convertPoint:self.view.center fromView:self.view.superview];
    activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator = activityIndicator;
    self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.view.userInteractionEnabled = NO;
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];

    self.leaders = [NSMutableArray array];
    NSURL *url = [NSURL URLWithString:[requestURLString stringByAppendingString:@"/leaderboard"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request

                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             // fill self.leaders with the leaderboard info
                                             for (NSDictionary *dict in JSON) {
                                                 [self.leaders addObject:dict];
                                             }
                                             // reload the data in the table view
                                             [self.tableView reloadData];
                                             self.view.userInteractionEnabled = YES;
                                             [self.activityIndicator stopAnimating];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return [self.leaders count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numLeaders = [self.leaders count];
    if(indexPath.section != 0 || indexPath.row >= numLeaders || indexPath.row < 0) return nil;

    NSDictionary *leader = [self.leaders objectAtIndex:indexPath.row];
    NSString *name = [leader objectForKey:@"name"];
    NSString *scoreText = [NSString stringWithFormat:@"%d points", [[leader objectForKey:@"score"] intValue]];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;

    cell.textLabel.text = name;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30];

    cell.detailTextLabel.text = scoreText;
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    cell.detailTextLabel.textColor = [UIColor redColor];
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:[leader objectForKey:@"image"]] placeholderImage:self.placeHolderImage];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.0;
}


@end
