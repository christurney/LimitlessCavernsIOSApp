//
//  GuessWhoViewController.h
//  LimitlessCaverns
//
//  Created by Erik Hope on 8/6/13.
//  Copyright (c) 2013 Dropbox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GuessWhoViewController : UIViewController

- (id)initWithDictionary:(NSDictionary*)dictionary;

@property (nonatomic, copy) NSString *funFactString;
@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, weak) id delegate;

@end


@protocol  GuessWhoViewControllerDelegate
- (void)guessWhoViewControllerPressedKnowThemButton:(GuessWhoViewController *)guessWhoVC;
- (void)guessWhoViewControllerPressedPlayButton:(GuessWhoViewController *)guessWhoVC;
- (void)guessWhoViewControllerPressedLeaderboardButton:(GuessWhoViewController*)guessWhoVC;
@end