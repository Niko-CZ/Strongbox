//
//  PreferencesTableViewController.h
//  StrongBox
//
//  Created by Mark on 22/07/2017.
//  Copyright © 2014-2021 Mark McGuill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreferencesTableViewController : UITableViewController

@property (nonatomic, copy) void (^onDone)(void);

@end
