//
//  ResultsViewController.h
//  Grinnell-DB-iOS
//
//  Created by Colin Tremblay on 9/12/13.
//  Copyright (c) 2013 AppDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsViewController : UITableViewController <UISplitViewControllerDelegate>

- (BOOL)networkCheck;

@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) NSMutableArray *searchDetails;
@property (nonatomic, assign) BOOL onCampusBool;

@end
