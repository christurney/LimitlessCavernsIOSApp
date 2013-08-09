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
#import "GradientButton.h"

static NSString *cellIdentifier = @"Cell";

@interface FunFactViewController ()

@property (nonatomic, strong) UITextView *funFactEntryField;
@property (nonatomic, strong) UILabel *funFactEntryPlaceholderLabel;
@property (nonatomic, strong) NSMutableArray *funFacts;
@property (nonatomic, strong) UITableView *funFactsTableView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIView *headerGrayView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) GrayGradientButton *cancelButton;
@property (nonatomic, strong) GrayGradientButton *doneButton;

@end

@implementation FunFactViewController

- (id)init
{
    self = [super init];
    if (self){
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

    self.headerGrayView = [[UIView alloc] initWithFrame:CGRectZero];
    self.headerGrayView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self.view addSubview:self.headerGrayView];

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"Manage facts";
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25];
    self.titleLabel.textColor = [UIColor redColor];
    self.titleLabel.numberOfLines = 1;
    [self.headerGrayView addSubview:self.titleLabel];

    self.cancelButton = [[GrayGradientButton alloc] initWithFrame:CGRectZero];
    [self.cancelButton configure];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton addTarget:self
                     action:@selector(close)
           forControlEvents:UIControlEventTouchUpInside];
    [self.headerGrayView addSubview: self.cancelButton];

    self.doneButton = [[GrayGradientButton alloc] initWithFrame:CGRectZero];
    [self.doneButton configure];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.doneButton addTarget:self
                   action:@selector(done)
         forControlEvents:UIControlEventTouchUpInside];
    [self.headerGrayView addSubview: self.doneButton];
    
    CGFloat corderRadius = 5.0;
    CGFloat borderWidth = 2.0;
    UIColor *borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];

    // fun fact entry field
    self.funFactEntryField = [[UITextView alloc] initWithFrame:CGRectZero];
    self.funFactEntryField.delegate = self;
    self.funFactEntryField.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.funFactEntryField.layer.cornerRadius = corderRadius;
    [self.funFactEntryField.layer setBorderColor:[borderColor CGColor]];
    [self.funFactEntryField.layer setBorderWidth:borderWidth];
    self.funFactEntryField.clipsToBounds = YES;
    self.funFactEntryField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:self.funFactEntryField];

    // directionsLabel label
    self.funFactEntryPlaceholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.funFactEntryPlaceholderLabel setNumberOfLines:1];
    [self.funFactEntryPlaceholderLabel setText:@"Type new fact or select existing to edit"];
    [self.funFactEntryPlaceholderLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
    self.funFactEntryPlaceholderLabel.textColor = [UIColor lightGrayColor];
    [self.funFactEntryPlaceholderLabel setTextAlignment:NSTextAlignmentLeft];
    [self.funFactEntryField addSubview:self.funFactEntryPlaceholderLabel];

    // table view listing your fun facts
    self.funFactsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.funFactsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    self.funFactsTableView.delegate = self;
    self.funFactsTableView.dataSource = self;
    self.funFactsTableView.layer.borderColor = [borderColor CGColor];
    self.funFactsTableView.layer.cornerRadius = corderRadius;
    self.funFactsTableView.clipsToBounds = YES;
    self.funFactsTableView.layer.borderWidth = borderWidth;
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
                                                 if([self.funFacts count] == 0){
                                                     [self.funFactEntryField becomeFirstResponder];
                                                 }
                                                 
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

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGFloat titleHeight = 60;
    CGFloat titleBuffer = 10;
    CGFloat buttonBuffer = 7.5;
    CGFloat cancelButtonWidth = 70;
    CGFloat doneButtonWidth = 70;
    CGFloat buttonHeight = 30;
    CGFloat buffer = 30.0;

    self.headerGrayView.frame = CGRectMake(0,
                                           0,
                                           self.view.bounds.size.width,
                                           titleHeight);
    self.titleLabel.frame = self.headerGrayView.bounds;
    self.titleLabel.width = 150;
    self.titleLabel.centerX = self.headerGrayView.centerX;
    self.cancelButton.frame = CGRectMake(buttonBuffer,
                                         0,
                                         cancelButtonWidth,
                                         buttonHeight);
    self.cancelButton.centerY = self.headerGrayView.centerY;

    self.doneButton.frame = CGRectMake(CGRectGetMaxX(self.headerGrayView.bounds) - buttonBuffer - doneButtonWidth,
                                       0,
                                       doneButtonWidth,
                                       buttonHeight);
    self.doneButton.centerY = self.headerGrayView.centerY;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {

        int tableViewHeight = 0;
        if (IS_IPHONE5)
        {
            tableViewHeight = 370;
        }
        else
        {
            tableViewHeight = 280;
        }

        self.funFactEntryField.frame = CGRectMake(0,
                                                  titleHeight + titleBuffer,
                                                  self.view.bounds.size.width - 2 * buffer,
                                                  80);

        self.funFactEntryField.centerX = self.headerGrayView.centerX;

        self.funFactEntryPlaceholderLabel.frame = CGRectMake(5,
                                                             0,
                                                             self.funFactEntryField.bounds.size.width,
                                                             30);

        self.funFactsTableView.frame = CGRectMake(CGRectGetMinX(self.funFactEntryField.frame),
                                                  CGRectGetMaxY(self.funFactEntryField.frame) + 15,
                                                  self.funFactEntryField.bounds.size.width,
                                                  tableViewHeight);
    }
    else
    {

        self.funFactEntryField.frame = CGRectMake(0,
                                                  titleHeight + titleBuffer,
                                                  self.view.bounds.size.width - 2 * buffer,
                                                  80);

        self.funFactEntryField.centerX = self.headerGrayView.centerX;

        self.funFactEntryPlaceholderLabel.frame = CGRectMake(5,
                                                             0,
                                                             self.funFactEntryField.bounds.size.width,
                                                             30);

        self.funFactsTableView.frame = CGRectMake(CGRectGetMinX(self.funFactEntryField.frame),
                                                  CGRectGetMaxY(self.funFactEntryField.frame) + 15,
                                                  self.funFactEntryField.bounds.size.width,
                                                  CGRectGetMaxY(self.view.bounds) - (CGRectGetMaxY(self.funFactEntryField.frame) + 15) - 10);
    }
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return indexPath.section == 0 && indexPath.row >= 0 && indexPath.row < [self.funFacts count] && !self.funFactEntryField.isFirstResponder;
}

// when a row is selected make that fact editable in the textview
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.funFactEntryField.text = [self.funFacts objectAtIndex:indexPath.row];
    [self.funFactEntryField becomeFirstResponder];
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.funFactsTableView.allowsSelection = NO;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    self.funFactsTableView.allowsSelection = YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numFacts = [self.funFacts count];
    if(indexPath.section != 0 || indexPath.row >= numFacts || indexPath.row < 0) return nil;

    NSString *fact = [self.funFacts objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.text = fact;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
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
        NSIndexPath *selectedIndexPath = [self.funFactsTableView indexPathForSelectedRow];

        if(validFunFact && !selectedIndexPath) {
            [self.funFacts insertObject:self.funFactEntryField.text atIndex:0];

        } else if(validFunFact && selectedIndexPath) {
            [self.funFacts replaceObjectAtIndex:selectedIndexPath.row withObject:self.funFactEntryField.text];

        } else if(!validFunFact && selectedIndexPath){
            [self.funFacts removeObjectAtIndex:selectedIndexPath.row];

        }

        self.funFactEntryField.text = @"";
        self.funFactEntryPlaceholderLabel.hidden = NO;
        [self.funFactsTableView reloadData];
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.funFactEntryPlaceholderLabel.hidden = YES;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (self.funFactEntryField.text.length == 0)
    {
        self.funFactEntryPlaceholderLabel.hidden = NO;
    }
    return YES;
}

@end
