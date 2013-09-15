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
@synthesize lastNameField, firstNameField, usernameField, phoneField, campusAddressField, homeAddressField, majorField, concentrationField, sgaField, hiatusField, classField, facStaffField, keyboardControls, textFieldIdentifier, myPickerView, concentrationArray, sgaArray, facStaffArray, hiatusArray, classArray, majorsArray;

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
    // Used to pass the identity of a textField into pickerView methods
    textFieldIdentifier = 0;
    
    // Instantiate the picker view arrays
    // Note: the empty string sets up the clearing option in the picker
    self.majorsArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
    self.concentrationArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
	self.sgaArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
	self.hiatusArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
	self.facStaffArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
    self.classArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
    
    // Try to populate the picker view arrays
    @try{
        NSString *post =[[NSString alloc] initWithFormat:@""];
        
        NSURL *url=[NSURL URLWithString:@"https://itwebapps.grinnell.edu/classic/asp/campusdirectory/GCdefault.asp"];
        
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/html" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *response = nil;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        //NSLog(@"Response code: %d", [response statusCode]);
        if([response statusCode] >= 200 && [response statusCode] < 300){
            NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
             //NSLog(@"Response ==> %@", responseData);
            
            NSRange startRange = [responseData rangeOfString:@"<select name=\"Department\">"];
            NSRange endRange = [responseData rangeOfString:@"Student Major"];
            [self parseHTML:startRange :endRange :facStaffArray :responseData];
            
            startRange = [responseData rangeOfString:@"<select name=\"Major\">"];
            endRange = [responseData rangeOfString:@"Concentration"];
            [self parseHTML:startRange :endRange :majorsArray :responseData];
            
            startRange = [responseData rangeOfString:@"<select name=\"conc\">"];
            endRange = [responseData rangeOfString:@"SGA"];
            [self parseHTML:startRange :endRange :concentrationArray :responseData];
            
            startRange = [responseData rangeOfString:@"<select name=\"SGA\">"];
            endRange = [responseData rangeOfString:@"Hiatus"];
            [self parseHTML:startRange :endRange :sgaArray :responseData];
            
            startRange = [responseData rangeOfString:@"<select name=\"Hiatus\">"];
            endRange = [responseData rangeOfString:@"Student Class"];
            [self parseHTML:startRange :endRange :hiatusArray :responseData];
            
            startRange = [responseData rangeOfString:@"<select name=\"Gyear\">"];
            endRange = [responseData rangeOfString:@"</form>"];
            [self parseHTML:startRange :endRange :classArray :responseData];
        }
    }
    @catch(NSException * e){
        NSLog(@"Exception: %@", e);
        //[self alertStatus:@"Login Failed." :@"Login Failed!"];
    }
    
    // Instantiate the picker and set the field inputs
    myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, 320, 240)];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Pass data to the ResultsViewController
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

#pragma mark Keyboard/textField methods
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
        [myPickerView selectRow:0 inComponent:0 animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self search];
    return YES;
}

#pragma mark UIPicker methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch (textFieldIdentifier) {
        case 2001:
            return [self.classArray objectAtIndex:row];
            break;
        case 2002:
            return [self.majorsArray objectAtIndex:row];
            break;
        case 2003:
            return [self.concentrationArray objectAtIndex:row];
            break;
        case 2004:
            return [self.hiatusArray objectAtIndex:row];
            break;
        case 2005:
            return [self.facStaffArray objectAtIndex:row];
            break;
        case 2006:
            return [self.sgaArray objectAtIndex:row];
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
    switch (textFieldIdentifier) {
        case 2001:
            return self.classArray.count;
            break;
        case 2002:
            return self.majorsArray.count;
            break;
        case 2003:
            return self.concentrationArray.count;
            break;
        case 2004:
            return self.hiatusArray.count;
            break;
        case 2005:
            return self.facStaffArray.count;
            break;
        case 2006:
            return self.sgaArray.count;
            break;
        default:
            return 0;
            break;
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (textFieldIdentifier) {
        case 2001:
            self.classField.text = [self.classArray objectAtIndex:row];
            break;
        case 2002:
            self.majorField.text = [self.majorsArray objectAtIndex:row];
            break;
        case 2003:
            self.concentrationField.text = [self.concentrationArray objectAtIndex:row];
            break;
        case 2004:
            self.hiatusField.text = [self.hiatusArray objectAtIndex:row];
            break;
        case 2005:
            self.facStaffField.text = [self.facStaffArray objectAtIndex:row];
            break;
        case 2006:
            self.sgaField.text = [self.sgaArray objectAtIndex:row];
            break;
        default:
            break;
    }
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 300;
}

#pragma mark Custom methods
// This method is used to get data from the HTML form and populate the picker arrays
- (void)parseHTML:(NSRange)startRange :(NSRange)endRange :(NSMutableArray *)array :(NSString *)responseData{
    // Create a string with only the data we are interested in for this picker
    startRange.location = startRange.location + startRange.length;
    startRange.length = endRange.location - startRange.location;
    NSString *dataString = [responseData substringWithRange:startRange];
    
    // Skip over the initial empty tag
    NSRange replaceRange = [dataString rangeOfString:@"</option>"];
    if (replaceRange.location != NSNotFound) {
        replaceRange.length = replaceRange.location + replaceRange.length;
        replaceRange.location = 0;
        dataString = [dataString stringByReplacingCharactersInRange:replaceRange withString:@""];
    }
    
    // Check for a value to be processed
    NSRange testRange = [dataString rangeOfString:@"</option>"];
    while (NSNotFound != testRange.location) {
        // Get the range of the value being processed
        startRange = [dataString rangeOfString:@"\">"];
        endRange = [dataString rangeOfString:@"</option>"];
        endRange.length = endRange.location - (startRange.location + startRange.length);
        endRange.location = startRange.location + startRange.length;
        
        // Get the value and remove whitespace
        NSString *tempString = [dataString substringWithRange:endRange];
        tempString = [tempString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // Add value to array
        if (![tempString isEqualToString:@""] && NULL != tempString)
            [array addObject:tempString];
        
        // Remove the section of the string just processed
        NSRange replaceRange = [dataString rangeOfString:@"</option>"];
        if (replaceRange.location != NSNotFound) {
            replaceRange.length = replaceRange.location + replaceRange.length;
            replaceRange.location = 0;
            dataString = [dataString stringByReplacingCharactersInRange:replaceRange withString:@""];
        }
        
        // Check for another value to be processed
        testRange = [dataString rangeOfString:@"</option>"];
    }
}

// Allows the search button to trigger the segue
- (void)search {
    [self performSegueWithIdentifier:@"searchSegue" sender:self];
}

// Clears all textFields in the form
- (void)clear:(id)sender{
    for (int i=0; i < fields.count; i++){
        UITextField *field = [fields objectAtIndex:i];
        field.text = @"";
    }
}

@end
