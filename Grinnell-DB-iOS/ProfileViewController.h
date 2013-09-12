//
//  ProfileViewController.h
//  Grinnell-DB-iOS
//
//  Created by Colin Tremblay on 9/12/13.
//  Copyright (c) 2013 AppDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import "Person.h"

@interface ProfileViewController : UITableViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) Person *selectedPerson;

@end
