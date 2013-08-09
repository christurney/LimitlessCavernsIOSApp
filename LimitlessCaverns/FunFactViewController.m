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
#import "AFJSONRequestOperation.h"

static NSString *cellIdentifier = @"Cell";

@interface FunFactViewController ()

@property (nonatomic, strong) UITextView *funFactEntryField;
@property (nonatomic, strong) NSMutableArray *funFacts;
@property (nonatomic, strong) UITableView *funFactsTableView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation FunFactViewController

- (id)init
{
    self = [super init];
    if (self){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
        self.title = @"Manage facts";
    }
    return self;
}

- (void)close
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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

    self.view.backgroundColor = [UIColor whiteColor];
    int imageBuffer = 30;

    // directionsLabel label
    UILabel *directionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         self.view.width - 2 * imageBuffer,
                                                                         45)];
    directionsLabel.centerY = self.view.height*.07;
    directionsLabel.centerX = self.view.width / 2.0;
    [directionsLabel setNumberOfLines:2];
    [directionsLabel setText:@"Select facts in list to edit, swipe across facts in list to delete, or add new facts:"];
    [directionsLabel setFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]];
    [directionsLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:directionsLabel];

    // fun fact entry field
    self.funFactEntryField = [[UITextView alloc] initWithFrame:CGRectMake(0,
                                                                          CGRectGetMaxY(directionsLabel.frame) + 15,
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

    int buttonWidth = 100;
    int buttonHeight = 40;
    int buttonOffset = 15;

    // add fact button
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    [addButton setFrame:CGRectMake(0,
                                   CGRectGetMaxY(self.funFactEntryField.frame) + buttonOffset,
                                   buttonWidth,
                                   buttonHeight)];
    addButton.centerX = self.view.centerX;

    [addButton setTitle:@"New Fact" forState:UIControlStateNormal];
    [addButton addTarget:self
                  action:@selector(addButtonClicked)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];

    // table view listing your fun facts
    self.funFactsTableView = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.funFactEntryField.frame), CGRectGetMaxY(addButton.frame) + 15, self.funFactEntryField.width, 150) style:UITableViewStylePlain];
    [self.funFactsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    self.funFactsTableView.delegate = self;
    self.funFactsTableView.dataSource = self;
    self.funFactsTableView.layer.borderColor = [[UIColor redColor] CGColor];

    self.funFactsTableView.layer.cornerRadius = 5;
    [self.funFactsTableView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.funFactsTableView.layer setBorderWidth:2.0];
    self.funFactsTableView.clipsToBounds = YES;



    
    self.funFactsTableView.layer.borderWidth = 3.0;
    [self.view addSubview:self.funFactsTableView];

    // fetch fun facts from the server
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults valueForKey:userIdKey];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%@", requestURLString, userID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.funFacts = [NSMutableArray array];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request

                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             [self stopActivityIndicator];
                                             if([JSON objectForKey:@"facts"] != [NSNull null]){
                                                 self.funFacts = [NSMutableArray array];
                                                 for(NSString *fact in [JSON objectForKey:@"facts"]){
                                                     [self.funFacts addObject:fact];
                                                 }
                                                 [self.funFactsTableView reloadData];
                                             }
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                                                 message:[JSON valueForKeyPath:@"message"]
                                                                                                delegate:self
                                                                                       cancelButtonTitle:@"OK"
                                                                                       otherButtonTitles:nil];
                                             [alertView show];
                                             [self stopActivityIndicator];
                                         }];
    [self startActivityIndicator];
    [operation start];
}

-(void)startActivityIndicator
{
    self.view.alpha = .5;
    self.view.userInteractionEnabled = NO;
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

-(void)stopActivityIndicator
{
    self.view.userInteractionEnabled = YES;
    self.view.alpha = 1;
    [self.activityIndicator stopAnimating];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.funFacts removeObjectAtIndex:indexPath.row];
        [self.funFactsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        self.funFactEntryField.text = @"";
    }
}

// when a row is selected make that fact editable in the textview
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.funFactEntryField.text = [self.funFacts objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numFacts = [self.funFacts count];
    if(indexPath.section != 0 || indexPath.row >= numFacts || indexPath.row < 0) return nil;

    NSString *fact = [self.funFacts objectAtIndex:indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.text = fact;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return [self.funFacts count];
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.funFactEntryField.text = @"";
}

-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.funFactEntryField.text = @"";
}

- (void)done
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults valueForKey:userIdKey];
    if(!userID) return;

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:requestURLString]];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];

    NSURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                     path:[NSString stringWithFormat:@"%@/users/%@/facts", requestURLString, userID]
                                               parameters:@{@"facts":self.funFacts}];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self stopActivityIndicator];
        [self close];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:@"Your fun facts were not received."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [self stopActivityIndicator];
    }];

    [self startActivityIndicator];
    [operation start];
}

- (void)addButtonClicked
{
    [self.funFactsTableView deselectRowAtIndexPath:[self.funFactsTableView indexPathForSelectedRow] animated:YES];
    self.funFactEntryField.text = @"";
    [self.funFactEntryField becomeFirstResponder];
}

/*
 when the user clicks Done don't treat it as if they typed a newline
 treat it as if they finished editing a fun fact and want to save their changes
 or they added a new fact
 */
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqual:@"\n"]) {
        [textView resignFirstResponder];
        // which row is selected indicates the fun fact they edited
        // if no row is selected then they added a fun fact
        BOOL validFunFact = [[self.funFactEntryField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] != 0;
        if(validFunFact)
        {
            NSIndexPath *selectedIndexPath = [self.funFactsTableView indexPathForSelectedRow];

            if(!selectedIndexPath){
                [self.funFacts addObject:self.funFactEntryField.text];
            } else {
                [self.funFacts replaceObjectAtIndex:selectedIndexPath.row withObject:self.funFactEntryField.text];
            }
            self.funFactEntryField.text = @"";
            [self.funFactsTableView reloadData];
            return NO;
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Fun Fact"
                                                                message:@"To delete a fun fact, swipe and delete in the fun facts table."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
    return YES;
}

@end
