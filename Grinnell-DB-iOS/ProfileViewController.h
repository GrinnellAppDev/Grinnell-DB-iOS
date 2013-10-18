//
//  ProfileViewController.h
//  Grinnell-DB-iOS
//
//  Created by Colin Tremblay on 9/12/13.
//  Copyright (c) 2013 AppDev. All rights reserved.
//

#import "Person.h"
#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import <WYPopoverController.h>

@interface ProfileViewController : UITableViewController <MFMailComposeViewControllerDelegate, WYPopoverControllerDelegate> {
        WYPopoverController *popoverController;
}

- (void)imageTapped:(id)sender;

@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) Person *selectedPerson;

@end
