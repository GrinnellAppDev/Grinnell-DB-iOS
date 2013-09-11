//
//  ViewController.m
//  Grinnell-DB-iOS
//
//  Created by AppDev on 9/11/13.
//  Copyright (c) 2013 AppDev. All rights reserved.
//


#import "ViewController.h"
//#import "SearchViewController.h"
#import "BSKeyboardControls.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize lastNameField, firstNameField, usernameField, phoneField, campusAddressField, homeAddressField, majorField, concentrationField, sgaField, hiatusField, classField, facStaffField, searchButton, resetButton, majorsArray, thePicker, keyboardControls;

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.majorsArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects: @"Computer Science", @"Math", nil]];
    self.majorField.inputView = self.thePicker;
    self.thePicker.hidden = YES;
    // self.doneBar.hidden = YES;
    self.thePicker.showsSelectionIndicator = YES;
    
    
    NSArray *fields = @[lastNameField, firstNameField, usernameField, classField, phoneField, campusAddressField, majorField, concentrationField, hiatusField, homeAddressField, facStaffField, sgaField];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
    
}
- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyControls
{
    [keyControls.activeField resignFirstResponder];
}
- (void)keyboardControls:(BSKeyboardControls *)keyControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    UIView *view = keyControls.activeField.superview.superview;
    [tableView scrollRectToVisible:view.frame animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [keyboardControls setActiveField:textField];
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [keyboardControls setActiveField:textView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIPicker methods
-(IBAction)labDidBeginEditing{
    thePicker.hidden = NO;
    //  self.doneBar.hidden = NO;
    thePicker = [[UIPickerView alloc] init];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [majorsArray objectAtIndex:row];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return majorsArray.count;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    majorField.text = [self.majorsArray objectAtIndex:row];
}


- (void)search {
    //SearchViewController *searchView = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    //[self.navigationController pushViewController:searchView animated:YES];
}

@end
