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
// This is just so I can trigger the transition...
- (void)guessWhoViewControllerPressedAButton:(GuessWhoViewController*)guessWhoVC;

@end