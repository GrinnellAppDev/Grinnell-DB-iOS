//
//  ResultsViewController.h
//  Grinnell-DB-iOS
//
//  Created by Colin Tremblay on 9/12/13.
//  Copyright (c) 2013 AppDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface ResultsViewController : UITableViewController <UISplitViewControllerDelegate>

- (BOOL)networkCheck;
- (void)parseProfilePage:(NSString *)urlString forPerson:(Person *)selected;
- (NSString *)extractFromString:(NSString *)str withRange:(NSRange)startRange andRange:(NSRange)endRange;

@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) NSMutableArray *searchDetails;
@property (nonatomic, assign) BOOL onCampusBool;

@end
