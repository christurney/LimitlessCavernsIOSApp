//
//  GuessWhoHalpersViewController.h
//  LimitlessCaverns
//
//  Created by Matthew Jaffe on 8/7/13.
//  Copyright (c) 2013 Dropbox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuessWhoHalpersViewController : UITableViewController

- (id)initWithDictionary:(NSDictionary*)dictionary;
- (void)verifySuccessFailure:(NSString *)bumpedUserID;

@property (nonatomic, copy) NSString *funFactString;
@property (nonatomic, weak) id delegate;

@end

@protocol  GuessWhoHalpersViewControllerDelegate
- (void)guessWhoHalpersViewControllerPressedSkipButton:(GuessWhoHalpersViewController *)guessWhoHalpersVC;
- (void)guessWhoHalpersViewControllerPressedLeaderboardButton:(GuessWhoHalpersViewController*)guessWhoHalpersVC;
- (void)guessWhoHalpersSucceeded:(GuessWhoHalpersViewController*)guessWhoHalpersVC;
@end