//
//  AppDelegate.m
//  LimitlessCaverns
//
//  Created by Christopher Turney on 8/5/13.
//  Copyright (c) 2013 Dropbox. All rights reserved.
//

NSString *const requestURLString = @"https://limitless-caverns-4433.herokuapp.com";

#import "AppDelegate.h"
#import "AFJSONRequestOperation.h"

#ifndef TARGET_IPHONE_SIMULATOR
#import "BumpClient.h"
#endif
#import "GetStartedViewController.h"
#import "RootViewController.h"

@implementation AppDelegate

- (void) configureBump {
#ifndef TARGET_IPHONE_SIMULATOR

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [BumpClient configureWithAPIKey:@"8990ba777c5340f98eb21033cfd9b06e" andUserID:[defaults objectForKey@"user_id"]];

    [[BumpClient sharedClient] setMatchBlock:^(BumpChannelID channel) {
        NSString *bumpedUserID = [[BumpClient sharedClient] userIDForChannel:channel];
        NSLog(@"Matched with user: %@", bumpedUserID);
        [[BumpClient sharedClient] confirmMatch:YES onChannel:channel];

        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:@"VerifySuccessFailureNotification"
                                          object:nil
                                        userInfo:[NSDictionary dictionaryWithObject:bumpedUserID forKey:@"bumped_user_id"]];
    }];

    [[BumpClient sharedClient] setChannelConfirmedBlock:^(BumpChannelID channel) {
        NSLog(@"Channel with %@ confirmed.", [[BumpClient sharedClient] userIDForChannel:channel]);
        [[BumpClient sharedClient] sendData:[[NSString stringWithFormat:@"12345"] dataUsingEncoding:NSUTF8StringEncoding]
                                  toChannel:channel];
    }];

    [[BumpClient sharedClient] setDataReceivedBlock:^(BumpChannelID channel, NSData *data) {
        NSLog(@"Data received from %@: %@",
              [[BumpClient sharedClient] userIDForChannel:channel],
              [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding]);
    }];


    // optional callback
    [[BumpClient sharedClient] setConnectionStateChangedBlock:^(BOOL connected) {
        if (connected) {
            NSLog(@"Bump connected...");
        } else {
            NSLog(@"Bump disconnected...");
        }
    }];

    // optional callback
    [[BumpClient sharedClient] setBumpEventBlock:^(bump_event event) {
        switch(event) {
            case BUMP_EVENT_BUMP:
                NSLog(@"Bump detected.");
                break;
            case BUMP_EVENT_NO_MATCH:
                NSLog(@"No match.");
                break;
        }
    }];
#endif
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    self.viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.navigationController.navigationBarHidden = YES;
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    [self configureBump];
    [self checkLoginState];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *urlString = [url absoluteString];
    NSRange range = [urlString rangeOfString:@"://"];
    NSString *userID = [urlString substringFromIndex:range.location+range.length];
    //todo - present loading indicator
    [self authenticateUserId:userID];

    return YES;
}


- (void)checkLoginState
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults valueForKey:@"userID"];
    
    if (!userID)
    {
        [self.navigationController presentViewController:[[GetStartedViewController alloc] init]
                                                animated:NO
                                              completion:^{
                                                  nil;
                                              }];
    }
    else
    {
        [self.viewController showUserInfo];
    }
}


-(void)authenticateUserId:(NSString *)userID
{
    NSURL *url = [NSURL URLWithString:[requestURLString stringByAppendingString:[@"/authenticate_user/" stringByAppendingString:userID]]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request

                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

                                             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                             [defaults setObject:userID forKey:@"userID"];
                                             [defaults synchronize];
                                             [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                             [self.viewController showUserInfo];
//                                             if([self.navigationController.presentingViewController isKindOfClass:[GetStartedViewController class]])
//                                             {
//                                                 [self.navigationController.visibleViewController dismissViewControllerAnimated:YES completion:^{
//                                                     nil;
//                                                 }];
//                                             }
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

@end
