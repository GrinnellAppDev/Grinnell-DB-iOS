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
@synthesize lastNameField, firstNameField, usernameField, phoneField, campusAddressField, homeAddressField, majorField, concentrationField, sgaField, hiatusField, classField, facStaffField, majorsArray, keyboardControls, textFieldIdentifier, myPickerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up clear button in top left corner
    UIBarButtonItem *clear = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clear:)];
    [self.navigationItem setLeftBarButtonItem:clear animated:YES];
    
    // Set up previous/next/done buttons
    fields = [[NSMutableArray alloc] initWithObjects:firstNameField, lastNameField, usernameField, classField, phoneField, campusAddressField, majorField, concentrationField, hiatusField, homeAddressField, facStaffField, sgaField, nil];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    textFieldIdentifier = 0;
	self.majorsArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects: @"Computer Science", @"Math", @"Physics", nil]];
    myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, 320, 200)];
    myPickerView.delegate = self;
    myPickerView.showsSelectionIndicator = YES;
    [self.view addSubview:myPickerView];
    myPickerView.hidden = YES;
    self.majorField.inputView = myPickerView;
    self.concentrationField.inputView = myPickerView;
    self.sgaField.inputView = myPickerView;
    self.hiatusField.inputView = myPickerView;
    self.classField.inputView = myPickerView;
    self.facStaffField.inputView = myPickerView;
    
    [super viewWillAppear:animated];
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
    
    if (0 != textField.tag) {
        textField.inputView.hidden = NO;
        textFieldIdentifier = textField.tag;
        [myPickerView reloadAllComponents];
    }
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

#pragma mark UIPicker methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch (textFieldIdentifier) {
        case 2001:
            return [self.majorsArray objectAtIndex:row];
            break;
        case 2002:
            return [self.majorsArray objectAtIndex:row];
            break;
        case 2003:
            return [self.majorsArray objectAtIndex:row];
            break;
        case 2004:
            return [self.majorsArray objectAtIndex:row];
            break;
        case 2005:
            return [self.majorsArray objectAtIndex:row];
            break;
        case 2006:
            return [self.majorsArray objectAtIndex:row];
            break;
        default:
            return @"";
            break;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSLog(@"%d", textFieldIdentifier);
    switch (textFieldIdentifier) {
        case 2001:
            return self.majorsArray.count;
            break;
        case 2002:
            return self.majorsArray.count;
            break;
        case 2003:
            return self.majorsArray.count;
            break;
        case 2004:
            return self.majorsArray.count;
            break;
        case 2005:
            return self.majorsArray.count;
            break;
        case 2006:
            return self.majorsArray.count;
            break;
        default:
            return 0;
            break;
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (textFieldIdentifier) {
        case 2001:
            self.classField.text = [self.majorsArray objectAtIndex:row];
            break;
        case 2002:
            self.majorField.text = [self.majorsArray objectAtIndex:row];
            break;
        case 2003:
            self.concentrationField.text = [self.majorsArray objectAtIndex:row];
            break;
        case 2004:
           self.hiatusField.text = [self.majorsArray objectAtIndex:row];
            break;
        case 2005:
            self.facStaffField.text = [self.majorsArray objectAtIndex:row];
            break;
        case 2006:
           self.sgaField.text = [self.majorsArray objectAtIndex:row];
            break;
        default:
            break;
    }
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 300;
}

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
