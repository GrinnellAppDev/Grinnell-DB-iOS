//
//  FormViewController.h
//  Grinnell-DB-iOS
//
//  Created by Colin Tremblay on 1/28/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"

@interface FormViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, BSKeyboardControlsDelegate> {
    NSMutableArray *fields;
}

- (void)search;
- (void)clear:(id)sender;

@property (nonatomic, strong) NSMutableArray *majorsArray;
//@property (nonatomic, strong) IBOutlet UIPickerView *thePicker;
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
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@end
