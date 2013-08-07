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

@property (nonatomic, copy) NSString *funFactString;

@end
