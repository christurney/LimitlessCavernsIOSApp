//
//  FunFactViewController.h
//  LimitlessCaverns
//
//  Created by Christopher Turney on 8/7/13.
//  Copyright (c) 2013 Dropbox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FunFactViewControllerDelegate;

@interface FunFactViewController : UIViewController <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>
@end
