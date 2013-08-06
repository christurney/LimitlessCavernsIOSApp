//
//  LimitlessCavernsViewController.m
//  LimitlessCaverns
//
//  Created by Christopher Turney on 8/5/13.
//  Copyright (c) 2013 Dropbox. All rights reserved.
//

#import "AFJSONRequestOperation.h"
#import "LimitlessCavernsViewController.h"

@interface LimitlessCavernsViewController ()

@end

@implementation LimitlessCavernsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    NSURL *url = [NSURL URLWithString:@"http://limitless-caverns-4433.herokuapp.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request

                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             NSLog(@"IP Address: %@", [JSON valueForKeyPath:@"origin"]);
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             NSLog(@"failed");
                                         }];
    [operation start];
}

@end
