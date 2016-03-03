#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <UIKit/UIKit.h>
#import <WYPopoverController.h>

// Forward declare class to register from Swift (only needed for .h)
@class GADDirectoryPerson;

@interface ProfileViewController : UITableViewController <MFMailComposeViewControllerDelegate, WYPopoverControllerDelegate> {
        WYPopoverController *popoverController;
}

- (void)imageTapped:(id)sender;

@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) GADDirectoryPerson *selectedPerson;

@end
