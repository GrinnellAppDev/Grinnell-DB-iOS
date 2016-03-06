#import <GADDirectory/GADDirectory.h>

#import <UIKit/UIKit.h>

@interface BADResultsViewController : UITableViewController <UISplitViewControllerDelegate>

- (BOOL)networkCheck;
- (void)parseProfilePage:(NSString *)urlString forPerson:(GADDirectoryPerson *)selected;
- (NSString *)extractFromString:(NSString *)str withRange:(NSRange)startRange andRange:(NSRange)endRange;
- (GADDirectoryPerson *)personForIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) NSMutableArray *searchDetails;
@property (nonatomic, assign) BOOL onCampusBool;
@property (nonatomic, strong) UIPopoverController *popover;
@end
