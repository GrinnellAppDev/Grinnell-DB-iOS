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
    textFieldIdentifier = 0;
    self.majorsArray = [[NSMutableArray alloc] init];
    self.concentrationArray = [[NSMutableArray alloc] init];
	self.sgaArray = [[NSMutableArray alloc] init];
	self.hiatusArray = [[NSMutableArray alloc] init];
	self.facStaffArray = [[NSMutableArray alloc] init];
    self.classArray = [[NSMutableArray alloc] init];
    
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
            // NSLog(@"Response ==> %@", responseData);
            
            
            NSRange startRange = [responseData rangeOfString:@"<select name=\"Department\">"];
            NSRange endRange = [responseData rangeOfString:@"Student Major"];
            [self parseHTML:startRange :endRange :facStaffArray :responseData];
            
            startRange = [responseData rangeOfString:@"<select name=\"Major\">"];
            endRange = [responseData rangeOfString:@"Concentration"];
            [self parseHTML:startRange :endRange :majorsArray :responseData];
            
            startRange = [responseData rangeOfString:@"<select name=\"conc\">"];
            endRange = [responseData rangeOfString:@"SGA"];
            [self parseHTML:startRange :endRange :concentrationArray :responseData];
            
            startRange = [responseData rangeOfString:@"<select name=\"sga\">"];
            endRange = [responseData rangeOfString:@"Hiatus"];
            [self parseHTML:startRange :endRange :sgaArray :responseData];
            
            startRange = [responseData rangeOfString:@"<select name=\"hiatus\">"];
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

- (void)parseHTML:(NSRange)startRange :(NSRange)endRange :(NSMutableArray *)array :(NSString *)responseData{
    startRange.location = startRange.location + startRange.length;
    startRange.length = endRange.location - startRange.location;
    NSString *deptString = [responseData substringWithRange:startRange];
    
    startRange = [deptString rangeOfString:@"option value="];
    while (NSNotFound != startRange.location){
        endRange = [deptString rangeOfString:@">"];
        endRange.length = endRange.location - (startRange.location + startRange.length) - 2;
        endRange.location = startRange.location + startRange.length + 1;
        NSString *tempString = [deptString substringWithRange:endRange];
        
        if (![tempString isEqualToString:@"\" selecte"] && ![tempString isEqualToString:@"Any"])
            [array addObject:tempString];
        
        NSRange replaceRange = [deptString rangeOfString:@"</option>"];
        if (replaceRange.location != NSNotFound) {
            replaceRange.length = replaceRange.location + replaceRange.length;
            replaceRange.location = 0;
            deptString = [deptString stringByReplacingCharactersInRange:replaceRange withString:@""];
        }
        
        startRange = [deptString rangeOfString:@"option value="];
        
    }
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
