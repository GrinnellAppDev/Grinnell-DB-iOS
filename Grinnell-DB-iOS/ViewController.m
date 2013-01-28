//
//  ViewController.m
//  Grinnell-DB-iOS
//
//  Created by Colin Tremblay on 1/28/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize lastNameField, firstNameField, usernameField, phoneField, campusAddressField, homeAddressField, majorField, concentrationField, sgaField, hiatusField, classField, facStaffField, searchButton, resetButton, majorsArray, thePicker, doneBar, activeView, scrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.majorsArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects: @"Copmuter Science", @"Math", nil]];
    self.majorField.inputView = self.thePicker;
    self.thePicker.hidden = YES;
    self.doneBar.hidden = YES;
    self.thePicker.showsSelectionIndicator = YES;
    [self registerForKeyboardNotifications];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIPicker methods
-(IBAction)labDidBeginEditing{
    self.thePicker.hidden = NO;
    self.doneBar.hidden = NO;
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
}

- (IBAction)doneChoosing:(id)sender {
    [self.majorField resignFirstResponder];
    //[self.commentField resignFirstResponder];
    self.doneBar.hidden = YES;
}
-(void)textViewDidBeginEditing:(UITextView *)textView{
    self.doneBar.hidden = NO;
    self.activeView = textView;
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    self.doneBar.hidden = YES;
    self.activeView = nil;
}
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification{
    if(self.activeView){
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        double offset = kbSize.height/2;
        offset = self.activeView.frame.origin.y - 44;
        CGPoint scrollPoint = CGPointMake(0.0, offset);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    CGPoint scrollPoint = CGPointMake(0.0, 0.0);
    [self.scrollView setContentOffset:scrollPoint animated:YES];
}
@end
