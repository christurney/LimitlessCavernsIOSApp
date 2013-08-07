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

@end

@implementation LeaderboardViewController

-(UIImage*)placeHolderImage
{
    if(_placeHolderImage) return _placeHolderImage;
    
    _placeHolderImage = [UIImage imageNamed:@"placeholderImage.jpg"];
    return _placeHolderImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];

    self.leaders = [NSMutableArray array];

    [self.leaders addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             @"person A", @"name", @"http://wdfw.wa.gov/conservation/fisher/graphics/fisher_fullbody.jpg", @"image_url", nil]];
    [self.leaders addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             @"person B", @"name", @"http://wdfw.wa.gov/conservation/fisher/graphics/fisher_fullbody.jpg", @"image_url", nil]];
    [self.leaders addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             @"person C", @"name", @"http://wdfw.wa.gov/conservation/fisher/graphics/fisher_fullbody.jpg", @"image_url", nil]];
    [self.leaders addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             @"person D", @"name", @"http://wdfw.wa.gov/conservation/fisher/graphics/fisher_fullbody.jpg", @"image_url", nil]];
    [self.leaders addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             @"person E", @"name", @"http://wdfw.wa.gov/conservation/fisher/graphics/fisher_fullbody.jpg", @"image_url", nil]];
    [self.leaders addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             @"person F", @"name", @"http://wdfw.wa.gov/conservation/fisher/graphics/fisher_fullbody.jpg", @"image_url", nil]];
    [self.leaders addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             @"person G", @"name", @"http://wdfw.wa.gov/conservation/fisher/graphics/fisher_fullbody.jpg", @"image_url", nil]];
    [self.leaders addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             @"person H", @"name", @"http://wdfw.wa.gov/conservation/fisher/graphics/fisher_fullbody.jpg", @"image_url", nil]];

    // TODO - actually make a server request to populate the self.leaders array
    /*
    NSURL *url = [NSURL URLWithString:[requestURLString stringByAppendingString:@"/leaderboard"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             // fill self.leaders with the leaderboard info
                                             for (NSDictionary *dict in JSON) {
                                                 [self.leaders addObject:dict];
                                             }
                                             // reload the data in the table view???
                                             [self.tableView reloadData];
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
     */
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return @"Leaderboard";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numLeaders = [self.leaders count];
    if(indexPath.section != 0 || indexPath.row >= numLeaders || indexPath.row < 0) return nil;

    NSDictionary *leader = [self.leaders objectAtIndex:indexPath.row];
    NSString *positionInLeaderboard = [NSString stringWithFormat:@"#%ld - ", (long)indexPath.row + 1];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.textLabel.text = [positionInLeaderboard stringByAppendingString: [leader objectForKey:@"name"]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:[leader objectForKey:@"image_url"]] placeholderImage:self.placeHolderImage];    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.0;
}


@end
