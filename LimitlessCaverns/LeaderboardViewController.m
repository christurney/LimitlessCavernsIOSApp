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

static NSString *cellIdentifier = @"Cell";

@interface LeaderboardViewController ()

@property (nonatomic, strong) NSMutableArray *leaders;
@property (nonatomic, strong) UIImage *placeHolderImage;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation LeaderboardViewController

- (id)init
{
    self = [super init];
    if (self){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(closeLeaderboard)];
        self.title = @"Leaderboard";
    }
    return self;
}

- (void)closeLeaderboard
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(UIImage*)placeHolderImage
{
    if(_placeHolderImage) return _placeHolderImage;

    _placeHolderImage = [UIImage imageNamed:@"placeholderImage.jpg"];
    return _placeHolderImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];

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
    NSString *textForCell = [NSString stringWithFormat:@"%d points - %@", [[leader objectForKey:@"score"] intValue], [leader objectForKey:@"name"]];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.textLabel.text = textForCell;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    [cell.imageView setImageWithURL:[NSURL URLWithString:[leader objectForKey:@"image"]] placeholderImage:self.placeHolderImage];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.0;
}


@end
