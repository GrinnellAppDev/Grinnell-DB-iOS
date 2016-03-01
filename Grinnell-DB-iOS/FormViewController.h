#import <UIKit/UIKit.h>

#import <WYPopoverController.h>

@interface BADFormViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate,WYPopoverControllerDelegate> {
    NSMutableArray *fields;
    WYPopoverController *popoverController;
}

- (BOOL)networkCheck;
- (NSString *)getAttributeValue:(NSString *)dataString;
- (NSString *)getEmailAttributeValue:(NSString *)dataString;
- (NSString *)extractFromString:(NSString *)str withRange:(NSRange)startRange andRange:(NSRange)endRange;
- (NSString *)cutString:(NSString *)str fromStartToEndOfRange:(NSRange)startRange;
- (void)load;
- (void)searchHelper;
- (void)clear;
- (void)searchUsingURL:(NSURL *)url forPage:(int)pageNum;
- (void)parseResults:(NSString *)dataString;
- (void)parseResultsOffCampus:(NSString *)dataString;
- (void)parseHTML:(NSRange)startRange :(NSRange)endRange :(NSMutableArray *)array :(NSString *)responseData;
- (void)iPadSearch:(id)sender;

@property (nonatomic, strong) NSMutableArray *majorsArray;
@property (nonatomic, strong) NSMutableArray *concentrationArray;
@property (nonatomic, strong) NSMutableArray *sgaArray;
@property (nonatomic, strong) NSMutableArray *classArray;
@property (nonatomic, strong) NSMutableArray *facStaffArray;
@property (nonatomic, strong) NSMutableArray *hiatusArray;
@property (nonatomic, strong) NSMutableArray *statesArray;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) IBOutlet UIPickerView *myPickerView;
@property (nonatomic, weak) IBOutlet UITextField *lastNameField;
@property (nonatomic, weak) IBOutlet UITextField *firstNameField;
@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UITextField *phoneField;
@property (nonatomic, weak) IBOutlet UITextField *campusAddressField;
@property (nonatomic, weak) IBOutlet UITextField *homeAddressField;
@property (nonatomic, weak) IBOutlet UITextField *majorField;
@property (nonatomic, weak) IBOutlet UITextField *concentrationField;
@property (nonatomic, weak) IBOutlet UITextField *sgaField;
@property (nonatomic, weak) IBOutlet UITextField *hiatusField;
@property (nonatomic, weak) IBOutlet UITextField *classField;
@property (nonatomic, weak) IBOutlet UITextField *facStaffField;
@property (nonatomic, assign) int textFieldIdentifier;
@property (nonatomic, assign) BOOL onCampusBool;
@property (nonatomic, assign) BOOL notFirstRun;
@property (nonatomic, assign) BOOL stateBeforeSettings;

@end
