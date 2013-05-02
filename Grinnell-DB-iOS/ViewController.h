//
//  ViewController.h
//  Grinnell-DB-iOS
//
//  Created by Colin Tremblay on 1/28/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (void)registerForKeyboardNotifications;

@property (nonatomic, strong) NSMutableArray *majorsArray;
@property (nonatomic, weak) IBOutlet UITextView *activeView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIToolbar *doneBar;
@property (nonatomic, strong) IBOutlet UIPickerView *thePicker;
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
@property (nonatomic, weak) IBOutlet UIButton *searchButton;
@property (nonatomic, weak) IBOutlet UIButton *resetButton;
@end
