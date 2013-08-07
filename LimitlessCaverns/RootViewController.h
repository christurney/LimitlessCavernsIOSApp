//
//  RootViewController.h
//  LimitlessCaverns
//
//  Created by Christopher Turney on 8/6/13.
//  Copyright (c) 2013 Dropbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuessWhoViewController.h"

@interface RootViewController : UIViewController <GuessWhoViewControllerDelegate>
- (void)getMysteryUserInfo:(NSString *)userID;
- (void)showUserInfo;
@end


