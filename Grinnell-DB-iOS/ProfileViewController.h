#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <UIKit/UIKit.h>
#import <WYPopoverController.h>

#import "Person.h"

@interface ProfileViewController : UITableViewController <MFMailComposeViewControllerDelegate, WYPopoverControllerDelegate> {
  WYPopoverController *popoverController;
}

- (void)imageTapped:(id)sender;

@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) Person *selectedPerson;

@end
