//
//  FormViewController.m
//  Grinnell-DB-iOS
//
//  Created by Colin Tremblay on 1/28/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import "FormViewController.h"
#import "BSKeyboardControls.h"
#import "ResultsViewController.h"

@interface FormViewController ()

@end

@implementation FormViewController
@synthesize lastNameField, firstNameField, usernameField, phoneField, campusAddressField, homeAddressField, majorField, concentrationField, sgaField, hiatusField, classField, facStaffField, searchButton, resetButton, majorsArray, keyboardControls;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up clear button in top left corner
    UIBarButtonItem *clear = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clear:)];
    [self.navigationItem setLeftBarButtonItem:clear animated:YES];
    
    // Set up Picker view
	self.majorsArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects: @"Computer Science", @"Math", @"Physics", nil]];
    /*self.majorField.inputView = self.thePicker;
    self.thePicker.hidden = YES;
    self.thePicker.showsSelectionIndicator = YES;*/
    
    
    // Set up previous/next/done buttons
    fields = [[NSMutableArray alloc] initWithObjects:firstNameField, lastNameField, usernameField, classField, phoneField, campusAddressField, majorField, concentrationField, hiatusField, homeAddressField, facStaffField, sgaField, nil];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyControls {
    [keyControls.activeField resignFirstResponder];
}

- (void)keyboardControls:(BSKeyboardControls *)keyControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction {
    UIView *view = keyControls.activeField.superview.superview;
    [self.tableView scrollRectToVisible:view.frame animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [keyboardControls setActiveField:textField];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [keyboardControls setActiveField:textView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self search];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark UIPicker methods
-(IBAction)labDidBeginEditing{
    self.thePicker.hidden = NO;
    // self.doneBar.hidden = NO;
    self.thePicker = [[UIPickerView alloc] init];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.majorsArray objectAtIndex:row];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.majorsArray.count;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.majorField.text = [self.majorsArray objectAtIndex:row];
}*/

- (void)search {
    [self performSegueWithIdentifier:@"searchSegue" sender:self];
}

- (void)clear:(id)sender{
    for (int i=0; i < fields.count; i++){
        UITextField *field = [fields objectAtIndex:i];
        field.text = @"";
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"searchSegue"]) {
        
        ResultsViewController *destViewController = segue.destinationViewController;
     
        NSMutableArray *searchDetails = [[NSMutableArray alloc] init];
        for (int i=0; i < fields.count; i++){
            UITextField *field = [fields objectAtIndex:i];
            [searchDetails addObject:field.text];
        }
        
        destViewController.searchDetails = searchDetails;
    }
}


@end
