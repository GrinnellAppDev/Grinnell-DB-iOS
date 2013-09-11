//
//  ViewController.h
//  Grinnell-DB-iOS
//
//  Created by AppDev on 9/11/13.
//  Copyright (c) 2013 AppDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"

@interface ViewController : UITableViewController <BSKeyboardControlsDelegate, UITextFieldDelegate, UITextViewDelegate>

- (void)search;

@property (nonatomic, strong) NSMutableArray *majorsArray;
@property (nonatomic, strong) IBOutlet UIPickerView *thePicker;
@property (nonatomic, strong) IBOutlet UITextField *lastNameField;
@property (nonatomic, strong) IBOutlet UITextField *firstNameField;
@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *phoneField;
@property (nonatomic, strong) IBOutlet UITextField *campusAddressField;
@property (nonatomic, strong) IBOutlet UITextField *homeAddressField;
@property (nonatomic, strong) IBOutlet UITextField *majorField;
@property (nonatomic, strong) IBOutlet UITextField *concentrationField;
@property (nonatomic, strong) IBOutlet UITextField *sgaField;
@property (nonatomic, strong) IBOutlet UITextField *hiatusField;
@property (nonatomic, strong) IBOutlet UITextField *classField;
@property (nonatomic, strong) IBOutlet UITextField *facStaffField;
@property (nonatomic, strong) IBOutlet UIButton *searchButton;
@property (nonatomic, strong) IBOutlet UIButton *resetButton;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@end
