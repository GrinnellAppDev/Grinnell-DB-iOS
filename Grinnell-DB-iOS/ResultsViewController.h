#import <UIKit/UIKit.h>
#import "Person.h"

@interface BADResultsViewController : UITableViewController <UISplitViewControllerDelegate>

- (BOOL)networkCheck;
- (void)parseProfilePage:(NSString *)urlString forPerson:(Person *)selected;
- (NSString *)extractFromString:(NSString *)str withRange:(NSRange)startRange andRange:(NSRange)endRange;
- (Person *)personForIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) NSMutableArray *searchDetails;
@property (nonatomic, assign) BOOL onCampusBool;
@property (nonatomic, strong) UIPopoverController *popover;
@end
