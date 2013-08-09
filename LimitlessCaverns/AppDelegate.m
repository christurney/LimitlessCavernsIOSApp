//
//  AppDelegate.m
//  LimitlessCaverns
//
//  Created by Christopher Turney on 8/5/13.
//  Copyright (c) 2013 Dropbox. All rights reserved.
//

NSString *const requestURLString = @"https://limitless-caverns-4433.herokuapp.com";
NSString *const userIdKey = @"user_id";
NSString *const targetIdKey = @"target_id";

#import "AppDelegate.h"
#import "AFJSONRequestOperation.h"

#if TARGET_IPHONE_SIMULATOR == 0
#import "BumpClient.h"
#endif
#import "GetStartedViewController.h"
#import "RootViewController.h"

@implementation AppDelegate

- (void) configureBump {
#if TARGET_IPHONE_SIMULATOR == 0
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults objectForKey:userIdKey];
    if (!userId){
        userId = @"default";
    }
    [BumpClient configureWithAPIKey:@"8990ba777c5340f98eb21033cfd9b06e" andUserID:userId];

    [[BumpClient sharedClient] setMatchBlock:^(BumpChannelID channel) {
        [[BumpClient sharedClient] confirmMatch:YES onChannel:channel];

    }];

    [[BumpClient sharedClient] setChannelConfirmedBlock:^(BumpChannelID channel) {
        NSData *sendData = [userId dataUsingEncoding:NSUTF8StringEncoding];
        
        if (sendData){
            [[BumpClient sharedClient] sendData:sendData
                                  toChannel:channel];
        } else {
            NSLog(@"NO DATA TO SEND");
        }
    }];

    [[BumpClient sharedClient] setDataReceivedBlock:^(BumpChannelID channel, NSData *data) {
        
        NSString *bumpedUserID = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];

        NSLog(@"Data received from %@: data:%@ %@",
              [[BumpClient sharedClient] userIDForChannel:channel], data, 
              bumpedUserID);
        
        if (bumpedUserID){
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:@"VerifySuccessFailureNotification"
                                              object:nil
                                            userInfo:[NSDictionary dictionaryWithObject:bumpedUserID forKey:@"bumped_user_id"]];
        }

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
    NSString *userID = [defaults valueForKey:userIdKey];
    
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
        [self configureBump];
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
                                             [defaults setObject:userID forKey:userIdKey];
                                             [defaults synchronize];
                                             [self configureBump];
                                             [self.navigationController dismissViewControllerAnimated:NO completion:nil];
                                             [self.viewController showUserInfo];
                                             
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
