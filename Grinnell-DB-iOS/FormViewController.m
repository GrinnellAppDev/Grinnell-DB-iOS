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
#import "Person.h"
#import "Reachability.h"

@interface FormViewController ()

@end

@implementation FormViewController
@synthesize lastNameField, firstNameField, usernameField, phoneField, campusAddressField, homeAddressField, majorField, concentrationField, sgaField, hiatusField, classField, facStaffField, keyboardControls, textFieldIdentifier, myPickerView, concentrationArray, sgaArray, facStaffArray, hiatusArray, classArray, majorsArray, searchResults;

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
    
    self.searchResults = [[NSMutableArray alloc] init];
    // Instantiate the picker view arrays
    // Note: the empty string sets up the clearing option in the picker
    self.majorsArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
    self.concentrationArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
	self.sgaArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
	self.hiatusArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
	self.facStaffArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
    self.classArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
    
    
    if ([self networkCheck]) {
        [self load];
    }
    else {
        // Network Check Failed - Show Alert
        [self performSelectorOnMainThread:@selector(showNoNetworkAlert)
                               withObject:nil
                            waitUntilDone:YES];
        return;
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

//Method to determine the availability of network Connections using the Reachability Class
- (BOOL)networkCheck {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return (!(networkStatus == NotReachable));
}

// Perform the search
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    NSMutableArray *searchDetails = [[NSMutableArray alloc] init];
    for (int i=0; i < fields.count; i++){
        UITextField *field = [fields objectAtIndex:i];
        NSString *tmp = [field.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        [searchDetails addObject:tmp];
    }
    
    NSString *first = [searchDetails objectAtIndex:0];
    NSString *last = [searchDetails objectAtIndex:1];
    NSString *user = [searchDetails objectAtIndex:2];
    NSString *year = [searchDetails objectAtIndex:3];
    NSString *phone = [searchDetails objectAtIndex:4];
    NSString *address = [searchDetails objectAtIndex:5];
    NSString *major = [searchDetails objectAtIndex:6];
    NSString *conc = [searchDetails objectAtIndex:7];
    NSString *hiatus = [searchDetails objectAtIndex:8];
    NSString *home = [searchDetails objectAtIndex:9];
    NSString *facStaff = [searchDetails objectAtIndex:10];
    NSString *sga = [searchDetails objectAtIndex:11];
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"https://itwebapps.grinnell.edu/classic/asp/campusdirectory/GCdefault.asp?transmit=true&blackboardref=true&pagenum=1&LastName=%@&LNameSearch=startswith&FirstName=%@&FNameSearch=startswith&email=%@&campusphonenumber=%@&campusquery=%@&Homequery=%@&Department=%@&Major=%@&conc=%@&SGA=%@&Hiatus=%@&Gyear=%@&submit_search=Search", last, first, user, phone, address, home, facStaff, major, conc, sga, hiatus, year]];
    
    [self searchUsingURL:url forPage:1];

    if (NULL == self.searchResults)
        return NO;
    else
        return YES;
}

// Pass data to the ResultsViewController
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"searchSegue"]) {
        ResultsViewController *destViewController = segue.destinationViewController;
        destViewController.searchDetails = self.searchResults;
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

#pragma mark UIAlertViewDelegate Methods
// Called when an alert button is tapped.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    return;
}

- (void)showNoNetworkAlert {
    UIAlertView *network = [[UIAlertView alloc]
                            initWithTitle:@"No Network Connection"
                            message:@"Turn on cellular data or use Wi-Fi to access the server"
                            delegate:self
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil
                            ];
    [network show];
}

- (void)showGrinnellAlert {
    UIAlertView *error = [[UIAlertView alloc]
                          initWithTitle:@"An Error Occurred"
                          message:@"Please connect to GrinnellCollegeStudent or GrinnellCollegeWireless"
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil
                          ];
    [error show];
}

- (void)showErrorAlert {
    UIAlertView *error = [[UIAlertView alloc]
                          initWithTitle:@"An Error Occurred"
                          message:@"Please try again later"
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil
                          ];
    [error show];
}

- (void)showVagueSearchAlert {
    UIAlertView *error = [[UIAlertView alloc]
                          initWithTitle:@"Vague Search"
                          message:@"Please refine your search criteria!"
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil
                          ];
    [error show];
}

#pragma mark Custom methods
-(void)load {
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
        [self showGrinnellAlert];
    }
}

- (void)searchUsingURL:(NSURL *)url forPage:(int)pageNum {
    int numberOfPages;
    float numberOfEntries;
    
    // Try the search
    @try{
        NSString *post =[[NSString alloc] initWithFormat:@""];
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
            
            NSRange startRange = [responseData rangeOfString:@"</em> found"];
            NSRange endRange = [responseData rangeOfString:@"entries"];
            endRange.length = endRange.location - (startRange.location + startRange.length);
            endRange.location = startRange.location + startRange.length;
            if (NSNotFound != endRange.location) {
                numberOfEntries = [[responseData substringWithRange:endRange] floatValue];
                numberOfPages = ceil(numberOfEntries / 15);
                //NSLog(@"%d", numberOfPages);
            }
            
            [self parseResults:responseData];
            
            NSLog(@"%d", self.searchResults.count);
            
            if (pageNum < numberOfPages) {
                pageNum++;
                NSString *urlStr = [url absoluteString];
                startRange = [urlStr rangeOfString:@"&pagenum="];
                endRange = [urlStr rangeOfString:@"&LastName="];
                endRange.length = endRange.location - (startRange.location + startRange.length);
                endRange.location = startRange.location + startRange.length;
                urlStr = [urlStr stringByReplacingCharactersInRange:endRange withString:[NSString stringWithFormat:@"%d", pageNum]];
                url = [NSURL URLWithString:urlStr];
                [self searchUsingURL:url forPage:pageNum];
            }
        }
    }
    @catch(NSException * e){
        NSLog(@"Exception: %@", e);
        if ([self networkCheck])
            [self showErrorAlert];
    }
}

// This method is used to get data from the HTML form and populate the picker arrays
- (void)parseHTML:(NSRange)startRange :(NSRange)endRange :(NSMutableArray *)array :(NSString *)responseData {
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

// This method is used to get data from the HTML form and populate the picker arrays
- (void)parseResults:(NSString *)dataString {
    //Test for VAGUE SEARCH
    NSRange testRange = [dataString rangeOfString:@"Your search returned a <i>very</i> large number of records and you must reduce the number of matches by refining your search criteria using the form at the bottom of the page"];
    //NSLog(@"%@", dataString);
    if (NSNotFound != testRange.location) {
        [self showVagueSearchAlert];
        self.searchResults = NULL;
        return;
    }
    
    int pagesNumber;
    testRange = [dataString rangeOfString:@"</em> found "];
    NSRange replaceRange = [dataString rangeOfString:@" entries"];
    replaceRange.length = replaceRange.location - (testRange.location + testRange.length);
    replaceRange.location = testRange.location + testRange.length;
    pagesNumber = [[dataString substringWithRange:replaceRange] intValue];
    
    // Check for a value to be processed
    testRange = [dataString rangeOfString:@"onmouseout=\"this.style.cursor='default'\" >"];
    
    // Delete the string before that value
    replaceRange = [dataString rangeOfString:@"onmouseout=\"this.style.cursor='default'\" >"];
    if (replaceRange.location != NSNotFound) {
        replaceRange.length = replaceRange.location + replaceRange.length;
        replaceRange.location = 0;
        dataString = [dataString stringByReplacingCharactersInRange:replaceRange withString:@""];
    }
    
    // Loop through the people
    while (NSNotFound != testRange.location) {
        Person *tmpPerson = [[Person alloc] init];
        tmpPerson.attributes = [[NSMutableArray alloc] init];
        tmpPerson.attributeVals = [[NSMutableArray alloc] init];
        
        // Get and process the url string
        NSRange startRange = [dataString rangeOfString:@"<img src=\""];
        NSRange endRange = [dataString rangeOfString:@"\" alt=\"Image Thumbnail"];
        endRange.length = endRange.location - (startRange.location + startRange.length);
        endRange.location = startRange.location + startRange.length;
        NSString *urlString = [dataString substringWithRange:endRange];
        urlString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
         //NSLog(@"%@", urlString);
        
        // Get and process the name
        startRange = [dataString rangeOfString:@"target = \"_blank\">"];
        endRange = [dataString rangeOfString:@"</a></TD>"];
        endRange.length = endRange.location - (startRange.location + startRange.length);
        endRange.location = startRange.location + startRange.length;
        NSString *name = [dataString substringWithRange:endRange];
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        endRange = [name rangeOfString:@", "];
        startRange.location = 0;
        startRange.length = endRange.location;
        endRange.location += 2;;
        endRange.length = name.length - endRange.location;
        NSString *last = [name substringWithRange:startRange];
        NSString *first = [name substringWithRange:endRange];
        tmpPerson.firstName = first;
        tmpPerson.lastName = last;
        //NSLog(@"%@ %@ %@", name, first, last);
        
        // Remove everything dealt with so far
        replaceRange = [dataString rangeOfString:@"</a></TD>"];
        if (replaceRange.location != NSNotFound) {
            replaceRange.length = replaceRange.location + replaceRange.length;
            replaceRange.location = 0;
            dataString = [dataString stringByReplacingCharactersInRange:replaceRange withString:@""];
        }
        NSRange anotherRange;
        // Get the remaining attributes
        NSString *temporary;
        NSString *majYr;
        NSString *greekTest;
        for (int i = 0; i < 6; i++) {
            switch (i) {
                case 0:
                    startRange = [dataString rangeOfString:@"valign=\"top\">"];
                    endRange = [dataString rangeOfString:@"</TD>" options:NSCaseInsensitiveSearch];
                    endRange.length = endRange.location - (startRange.location + startRange.length);
                    endRange.location = startRange.location + startRange.length;
                    temporary = [dataString substringWithRange:endRange];
                    endRange = [temporary rangeOfString:@" ("];
                    startRange = [temporary rangeOfString:@"<br />"];
                    
                    // Deal with departments containing '(' character in name
                    if (NSNotFound != endRange.location){
                        anotherRange.location = endRange.location + endRange.length;
                        anotherRange.length = 1;
                        greekTest = [temporary substringWithRange:anotherRange];
                    }
                    
                    if ([@"2" isEqualToString:greekTest] && endRange.location < startRange.location) {
                        startRange.location = 0;
                        startRange.length = endRange.location;
                        majYr = [temporary substringWithRange:startRange];
                        if (![majYr isEqualToString:@""]) {
                            [tmpPerson.attributes addObject:@"Major"];
                            [tmpPerson.attributeVals addObject:majYr];
                        }
                        endRange.location = endRange.location + endRange.length;
                        endRange.length = 4;
                        majYr = [temporary substringWithRange:endRange];
                        if (![majYr isEqualToString:@""]) {
                            [tmpPerson.attributes addObject:@"Class"];
                            [tmpPerson.attributeVals addObject:majYr];
                        }
                    }
                    else {
                        startRange.length = startRange.location;
                        startRange.location = 0;
                        majYr = [temporary substringWithRange:startRange];
                        majYr = [majYr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        if (![majYr isEqualToString:@""]) {
                            [tmpPerson.attributes addObject:@"Department"];
                            [tmpPerson.attributeVals addObject:majYr];
                        }
                        //NSLog(@"%@", majYr);
                        startRange = [temporary rangeOfString:@"<div class=\"tny\">"];
                        endRange = [temporary rangeOfString:@"</div>"];
                        endRange.length = endRange.location - (startRange.location + startRange.length);
                        endRange.location = startRange.location + startRange.length;
                        
                        //NSLog(@"%d %d, %d %d", startRange.location, startRange.length, endRange.location, endRange.length);
                        majYr = [temporary substringWithRange:endRange];
                        majYr = [majYr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        majYr = [majYr stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
                        
                        if (![majYr isEqualToString:@""]) {
                            [tmpPerson.attributes addObject:@"Title"];
                            [tmpPerson.attributeVals addObject:majYr];
                        }
                    }
                    break;
                case 1:
                    startRange = [dataString rangeOfString:@"valign=\"top\">"];
                    endRange = [dataString rangeOfString:@"</TD>" options:NSCaseInsensitiveSearch];
                    endRange.length = endRange.location - (startRange.location + startRange.length);
                    endRange.location = startRange.location + startRange.length;
                    temporary = [dataString substringWithRange:endRange];
                    temporary = [temporary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if (![temporary isEqualToString:@""]) {
                        [tmpPerson.attributes addObject:@"Campus Phone"];
                        [tmpPerson.attributeVals addObject:temporary];
                    }
                    break;
                case 2:
                    startRange = [dataString rangeOfString:@"valign=\"top\"> <font size=\"-1\">"];
                    endRange = [dataString rangeOfString:@"@grinnell.edu" options:NSCaseInsensitiveSearch];
                    endRange.length = endRange.location - (startRange.location + startRange.length);
                    endRange.location = startRange.location + startRange.length;
                    temporary = [dataString substringWithRange:endRange];
                    [tmpPerson.attributes addObject:@"Username"];
                    [tmpPerson.attributeVals addObject:temporary];
                    break;
                case 3:
                    startRange = [dataString rangeOfString:@"valign=\"top\">"];
                    endRange = [dataString rangeOfString:@"</TD>" options:NSCaseInsensitiveSearch];
                    endRange.length = endRange.location - (startRange.location + startRange.length);
                    endRange.location = startRange.location + startRange.length;
                    temporary = [dataString substringWithRange:endRange];
                    temporary = [temporary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if (![temporary isEqualToString:@""]) {
                        [tmpPerson.attributes addObject:@"Campus Address"];
                        [tmpPerson.attributeVals addObject:temporary];
                    }
                    break;
                case 4:
                    startRange = [dataString rangeOfString:@"valign=\"top\">"];
                    endRange = [dataString rangeOfString:@"</TD>" options:NSCaseInsensitiveSearch];
                    endRange.length = endRange.location - (startRange.location + startRange.length);
                    endRange.location = startRange.location + startRange.length;
                    temporary = [dataString substringWithRange:endRange];
                    if (![temporary isEqualToString:@""]) {
                        [tmpPerson.attributes addObject:@"Box Number"];
                        [tmpPerson.attributeVals addObject:temporary];
                    }
                    break;
                case 5:
                    startRange = [dataString rangeOfString:@"valign=\"top\">"];
                    endRange = [dataString rangeOfString:@"</TD>" options:NSCaseInsensitiveSearch];
                    endRange.length = endRange.location - (startRange.location + startRange.length);
                    endRange.location = startRange.location + startRange.length;
                    temporary = [dataString substringWithRange:endRange];
                    temporary = [temporary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [tmpPerson.attributes addObject:@"Status"];
                    [tmpPerson.attributeVals addObject:temporary];
                    break;
                default:
                    break;
                    
            }
            // Remove the just processed attribute
            replaceRange = [dataString rangeOfString:@"</TD>" options:NSCaseInsensitiveSearch];
            if (replaceRange.location != NSNotFound) {
                replaceRange.length = replaceRange.location + replaceRange.length;
                replaceRange.location = 0;
                dataString = [dataString stringByReplacingCharactersInRange:replaceRange withString:@""];
            }
        }
        
        // Remove the section of the string just processed
        replaceRange = [dataString rangeOfString:@"</tr>"];
        if (replaceRange.location != NSNotFound) {
            replaceRange.length = replaceRange.location + replaceRange.length;
            replaceRange.location = 0;
            dataString = [dataString stringByReplacingCharactersInRange:replaceRange withString:@""];
        }
        
        [tmpPerson.attributes addObject:@"picURL"];
        [tmpPerson.attributeVals addObject:urlString];
        
        /*
        NSLog(@"name: %@ %@", tmpPerson.firstName, tmpPerson.lastName);
        for (int i = 0; i < tmpPerson.attributes.count; i++)
            NSLog(@"%@ %@", [tmpPerson.attributes objectAtIndex:i], [tmpPerson.attributeVals objectAtIndex:i]);
        */
       // NSLog(@"%@", tmpPerson.lastName);
    
        [self.searchResults addObject:tmpPerson];
        
        // Check for another value to be processed
        testRange = [dataString rangeOfString:@"onmouseout=\"this.style.cursor='default'\" >"];
    }
}

// Allows the search button to trigger the segue
- (void)search {
    if ([self shouldPerformSegueWithIdentifier:@"searchSegue" sender:self])
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
