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
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    // Set up clear button in top left corner
    UIBarButtonItem *clear = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clear:)];
    [self.navigationItem setLeftBarButtonItem:clear animated:YES];
    
    // Instantiate the picker view arrays
    // Note: the empty string sets up the clearing option in the picker
    self.majorsArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
    self.concentrationArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
	self.sgaArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
	self.hiatusArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
	self.facStaffArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
    self.classArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
    
    // Assume on campus... This will be changed during [self load]
    self.onCampusBool = YES;
    
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
    
    // Used to pass the identity of a textField into pickerView methods
    textFieldIdentifier = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    // Must be re-initialized each time this view re-appears
    self.searchResults = [[NSMutableArray alloc] init];
    
    // Check network and load picker views if there is a network
    if ([self networkCheck])
        [self load];
    else {
        [self showNoNetworkAlert];
        return;
    }
    
    // Set up previous/next/done buttons
    if (self.onCampusBool)
        fields = [[NSMutableArray alloc] initWithObjects:firstNameField, lastNameField, usernameField, classField, phoneField, campusAddressField, majorField, concentrationField, hiatusField, homeAddressField, facStaffField, sgaField, nil];
    else
        fields = [[NSMutableArray alloc] initWithObjects:firstNameField, lastNameField, usernameField, nil];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//Method to determine the availability of network Connections using the Reachability Class
- (BOOL)networkCheck {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return (!(networkStatus == NotReachable));
}

// Perform the search... If no results come back, prevent segue from happening by returning NO
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    NSMutableArray *searchDetails = [[NSMutableArray alloc] init];
    NSURL *url;
    
    // Any spaces typed into a field should be turned into pluses for the URL
    for (int i=0; i < fields.count; i++){
        UITextField *field = [fields objectAtIndex:i];
        NSString *tmp = [field.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        [searchDetails addObject:tmp];
    }
    
    NSString *first = [searchDetails objectAtIndex:0];
    NSString *last = [searchDetails objectAtIndex:1];
    NSString *user = [searchDetails objectAtIndex:2];
    
    // Set up the url properly - Nothing containing the word "any" should be in the url
    if (self.onCampusBool) {
        NSString *year = [searchDetails objectAtIndex:3];
        if ([year isEqualToString:@"Any"])
            year = @"";
        NSString *phone = [searchDetails objectAtIndex:4];
        NSString *address = [searchDetails objectAtIndex:5];
        NSString *major = [searchDetails objectAtIndex:6];
        if ([major isEqualToString:@"Any"])
            major = @"";
        NSString *conc = [searchDetails objectAtIndex:7];
        if ([conc isEqualToString:@"Any"])
            conc = @"";
        NSString *hiatus = [searchDetails objectAtIndex:8];
        if ([hiatus isEqualToString:@"Any"])
            hiatus = @"";
        NSString *home = [searchDetails objectAtIndex:9];
        NSString *facStaff = [searchDetails objectAtIndex:10];
        if ([facStaff isEqualToString:@"Any"])
            facStaff = @"";
        NSString *sga = [searchDetails objectAtIndex:11];
        if ([sga isEqualToString:@"Any"])
            sga = @"";
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itwebapps.grinnell.edu/classic/asp/campusdirectory/GCdefault.asp?transmit=true&blackboardref=true&pagenum=1&LastName=%@&LNameSearch=startswith&FirstName=%@&FNameSearch=startswith&email=%@&campusphonenumber=%@&campusquery=%@&Homequery=%@&Department=%@&Major=%@&conc=%@&SGA=%@&Hiatus=%@&Gyear=%@&submit_search=Search", last, first, user, phone, address, home, facStaff, major, conc, sga, hiatus, year]];
    }
    else
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itwebapps.grinnell.edu/classic/asp/campusdirectory/GCdefault.asp?transmit=true&blackboardref=true&pagenum=1&LastName=%@&LNameSearch=startswith&FirstName=%@&FNameSearch=startswith&email=%@&submit_search=Search", last, first, user]];
    
    // Start the search
    [self searchUsingURL:url forPage:1];
    
    // Stop the segue if an error occured (indicated by null value in searchResults)
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
    /*UIView *view = keyControls.activeField.superview.superview;
     [self.tableView scrollRectToVisible:view.frame animated:YES];*/
    [keyControls setActiveField:field];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [keyboardControls setActiveField:textField];
    
    // Show the picker if needed for this field
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

#pragma mark UITableView overrides
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.onCampusBool) {
        return 12;
    }
    else return 3;
}

#pragma mark UIAlertViewDelegate Methods
// Called when an alert button is tapped.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self viewWillAppear:YES];
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
                          initWithTitle:@"Note:"
                          message:@"You can gain access to the full directory search system and information by connecting to GrinnellCollegeStudent or GrinnellCollegeWireless"
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

- (void)showNoResultsAlert {
    UIAlertView *error = [[UIAlertView alloc]
                          initWithTitle:@"An Error Occurred"
                          message:@"Your search returned no results!"
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
        
        if([response statusCode] >= 200 && [response statusCode] < 300){
            NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
            
            NSRange startRange = [responseData rangeOfString:@"<select name=\"Department\">"];
            NSRange endRange = [responseData rangeOfString:@"Student Major"];
            if (NSNotFound != endRange.location) {
                self.onCampusBool = YES;
                if (NSNotFound == [facStaffArray indexOfObject:@"Any"]) {
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
                [self.tableView reloadData];
            }
            else {
                if (!self.notFirstRun) {
                    [self showGrinnellAlert];
                    self.notFirstRun = YES;
                }
                self.onCampusBool = NO;
                [self.tableView reloadData];
            }
        }
    }
    @catch(NSException * e){
        NSLog(@"Exception: %@", e);
        [self showErrorAlert];
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
        
        if([response statusCode] >= 200 && [response statusCode] < 300){
            NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
            
            NSRange startRange = [responseData rangeOfString:@" found"];
            if (NSNotFound == startRange.location) {
                [self showErrorAlert];
                return;
            }
            startRange.length = startRange.location + startRange.length;
            startRange.location = 0;
            responseData = [responseData stringByReplacingCharactersInRange:startRange withString:@""];
            
            // Test for search with no results
            NSRange endRange = [responseData rangeOfString:@"<strong>no</strong> matches"];
            if (NSNotFound != endRange.location) {
                [self showNoResultsAlert];
                self.searchResults = NULL;
                return;
            }
            
            // Test for VAGUE SEARCH (too many results)
            endRange = [responseData rangeOfString:@"Your search returned a <i>very</i> large number of records and you must reduce the number of matches by refining your search criteria using the form at the bottom of the page"];
            if (NSNotFound != endRange.location) {
                [self showVagueSearchAlert];
                self.searchResults = NULL;
                return;
            }
            
            // Sanity Check
            endRange = [responseData rangeOfString:@"entr"];
            if (NSNotFound == endRange.location) {
                [self showErrorAlert];
                self.searchResults = NULL;
                return;
            }
            
            // Get the number of pages of results so we can loop through and get all of them
            endRange.length = endRange.location;
            endRange.location = 0;
            numberOfEntries = [[responseData substringWithRange:endRange] floatValue];
            numberOfPages = ceil(numberOfEntries / 15);
            
            // Parse our search results
            [self parseResults:responseData];
            
            // Recursive call to parse the next page worth of results
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
        else
            [self showNoNetworkAlert];
    }
}

// This method is used to get data from the HTML form and populate the picker arrays
- (void)parseHTML:(NSRange)startRange :(NSRange)endRange :(NSMutableArray *)array :(NSString *)responseData {
    // Create a string with only the data we are interested in for this picker
    startRange.location = startRange.location + startRange.length;
    startRange.length = endRange.location - startRange.location;
    // Sanity Check
    if (NSNotFound == startRange.location) {
        [self showErrorAlert];
        return;
    }
    NSString *dataString = [responseData substringWithRange:startRange];
    
    // Skip over the initial empty tag
    NSRange replaceRange = [dataString rangeOfString:@"</option>"];
    if (NSNotFound != replaceRange.location) {
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
        if (NSNotFound == endRange.location) {
            [self showErrorAlert];
            NSLog(@"Error parsing picker options");
        }
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

// This method parses the HTML returned by the search request when off campus
- (void)parseResultsOffCampus:(NSString *)dataString {
    // Check for a value to be processed
    NSRange testRange = [dataString rangeOfString:@"&nbsp;</TD>" options:NSCaseInsensitiveSearch];
    
    // Delete the string before that value
    NSRange replaceRange = [dataString rangeOfString:@"&nbsp;</TD>" options:NSCaseInsensitiveSearch];
    if (replaceRange.location != NSNotFound) {
        replaceRange.length = replaceRange.location + replaceRange.length;
        replaceRange.location = 0;
        dataString = [dataString stringByReplacingCharactersInRange:replaceRange withString:@""];
    }
    
    // Delete string after final person
    replaceRange = [dataString rangeOfString:@"End of page - Begin Footers" options:NSCaseInsensitiveSearch];
    NSRange endRange = [dataString rangeOfString:@"</html>" options:NSCaseInsensitiveSearch];
    replaceRange.length = endRange.length + endRange.location - replaceRange.location;
    dataString = [dataString stringByReplacingCharactersInRange:replaceRange withString:@""];
    
    // Loop through the people
    while (NSNotFound != testRange.location) {
        Person *tmpPerson = [[Person alloc] init];
        tmpPerson.attributes = [[NSMutableArray alloc] init];
        tmpPerson.attributeVals = [[NSMutableArray alloc] init];
        NSRange startRange;
        NSString *temporary, *name, *last, *first;
        for (int i = 0; i < 6; i++) {
            switch (i) {
                case 0:
                    startRange = [dataString rangeOfString:@"valign=\"top\">"];
                    endRange = [dataString rangeOfString:@"</TD>" options:NSCaseInsensitiveSearch];
                    endRange.length = endRange.location - (startRange.location + startRange.length);
                    endRange.location = startRange.location + startRange.length;
                    name = [dataString substringWithRange:endRange];
                    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    endRange = [name rangeOfString:@", "];
                    startRange.location = 0;
                    startRange.length = endRange.location;
                    endRange.location += 2;;
                    endRange.length = name.length - endRange.location;
                    last = [name substringWithRange:startRange];
                    first = [name substringWithRange:endRange];
                    tmpPerson.firstName = first;
                    tmpPerson.lastName = last;
                    break;
                case 1:
                    startRange = [dataString rangeOfString:@"valign=\"top\">"];
                    endRange = [dataString rangeOfString:@"</TD>" options:NSCaseInsensitiveSearch];
                    endRange.length = endRange.location - (startRange.location + startRange.length);
                    endRange.location = startRange.location + startRange.length;
                    temporary = [dataString substringWithRange:endRange];
                    
                    if (![temporary isEqualToString:@""]) {
                        if (NSNotFound != [temporary rangeOfString:@"<span class=\"tn2y\">Data"].location) {
                            [tmpPerson.attributes addObject:@"Department"];
                            [tmpPerson.attributeVals addObject:@"Data unavailable off campus"];
                        }
                        else {
                            temporary = [temporary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            temporary = [temporary stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
                            int index = 0;
                            for (int i = 2; i < temporary.length; i++) {
                                BOOL letterOneIsLowercase = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[temporary characterAtIndex:i-2]];
                                BOOL letterTwoIsUppercase = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[temporary characterAtIndex:i-1]];
                                BOOL letterThreeIsLowercase = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[temporary characterAtIndex:i]];
                                if (letterOneIsLowercase && letterTwoIsUppercase && letterThreeIsLowercase) {
                                    index = i - 1;
                                    break;
                                }
                            }
                            if (0 == index)
                                for (int i = 1; i < temporary.length; i++) {
                                    BOOL letterOneIsUppercase = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[temporary characterAtIndex:i-1]];
                                    BOOL letterTwoIsLowercase = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[temporary characterAtIndex:i]];
                                    if (letterOneIsUppercase && letterTwoIsLowercase) {
                                        index = i - 1;
                                        break;
                                    }
                                }
                            startRange.location = 0;
                            startRange.length = index;
                            [tmpPerson.attributes addObject:@"Department"];
                            [tmpPerson.attributeVals addObject:[temporary substringWithRange:startRange]];
                            startRange.location = index;
                            startRange.length = temporary.length - index;
                            [tmpPerson.attributes addObject:@"Title"];
                            [tmpPerson.attributeVals addObject:[temporary substringWithRange:startRange]];
                        }
                    }
                    break;
                case 2:
                    startRange = [dataString rangeOfString:@"valign=\"top\">"];
                    endRange = [dataString rangeOfString:@"</TD>" options:NSCaseInsensitiveSearch];
                    endRange.length = endRange.location - (startRange.location + startRange.length);
                    endRange.location = startRange.location + startRange.length;
                    temporary = [dataString substringWithRange:endRange];
                    temporary = [temporary stringByReplacingOccurrencesOfString:@"<span class=\"tny2\">" withString:@""];
                    temporary = [temporary stringByReplacingOccurrencesOfString:@"</span>" withString:@""];
                    temporary = [temporary stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
                    temporary = [temporary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if (![temporary isEqualToString:@""]) {
                        [tmpPerson.attributes addObject:@"Campus Phone"];
                        [tmpPerson.attributeVals addObject:temporary];
                    }
                    break;
                case 3:
                    startRange = [dataString rangeOfString:@"valign=\"top\"> <font size=\"-1\">"];
                    endRange = [dataString rangeOfString:@"@grinnell.edu" options:NSCaseInsensitiveSearch];
                    endRange.length = endRange.location - (startRange.location + startRange.length);
                    endRange.location = startRange.location + startRange.length;
                    temporary = [dataString substringWithRange:endRange];
                    [tmpPerson.attributes addObject:@"Username"];
                    [tmpPerson.attributeVals addObject:temporary];
                    break;
                case 4:
                    startRange = [dataString rangeOfString:@"valign=\"top\">"];
                    endRange = [dataString rangeOfString:@"</TD>" options:NSCaseInsensitiveSearch];
                    endRange.length = endRange.location - (startRange.location + startRange.length);
                    endRange.location = startRange.location + startRange.length;
                    temporary = [dataString substringWithRange:endRange];
                    temporary = [temporary stringByReplacingOccurrencesOfString:@"<span class=\"tny2\">" withString:@""];
                    temporary = [temporary stringByReplacingOccurrencesOfString:@"</span>" withString:@""];
                    temporary = [temporary stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
                    temporary = [temporary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if (![temporary isEqualToString:@""]) {
                        [tmpPerson.attributes addObject:@"Campus Address"];
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
        
        // Check for another value to be processed
        testRange = [dataString rangeOfString:@"&nbsp;</TD>"];
        
        // Check if what we expect to be the next person is actually SGA info
        replaceRange = [dataString rangeOfString:@"colspan="];
        if (replaceRange.location < testRange.location) {
            startRange = [dataString rangeOfString:@"<span class=\"tn2y\">"];
            endRange = [dataString rangeOfString:@"</span></TD>" options:NSCaseInsensitiveSearch];
            endRange.length = endRange.location - (startRange.location + startRange.length);
            endRange.location = startRange.location + startRange.length;
            temporary = [dataString substringWithRange:endRange];
            temporary = [temporary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            int index = [tmpPerson.attributes indexOfObject:@"Status"];
            [tmpPerson.attributes insertObject:@"SGA" atIndex:index];
            [tmpPerson.attributeVals insertObject:temporary atIndex:index];
            replaceRange = [dataString rangeOfString:@"</tr>"];
            if (replaceRange.location != NSNotFound) {
                replaceRange.length = replaceRange.location + replaceRange.length;
                replaceRange.location = 0;
                dataString = [dataString stringByReplacingCharactersInRange:replaceRange withString:@""];
            }
        }
        
        [self.searchResults addObject:tmpPerson];
        
        // Remove the header line
        replaceRange = [dataString rangeOfString:@"</TD>" options:NSCaseInsensitiveSearch];
        if (replaceRange.location != NSNotFound) {
            replaceRange.length = replaceRange.location + replaceRange.length;
            replaceRange.location = 0;
            dataString = [dataString stringByReplacingCharactersInRange:replaceRange withString:@""];
        }
    }
}

// This method parses the HTML returned by the search request
- (void)parseResults:(NSString *)dataString {
    // Check for a value to be processed
    NSRange testRange = [dataString rangeOfString:@"onmouseout=\"this.style.cursor='default'\" >"];
    if (NSNotFound == testRange.location) {
        [self parseResultsOffCampus:dataString];
        return;
    }
    // Delete the string before that value
    NSRange replaceRange = [dataString rangeOfString:@"onmouseout=\"this.style.cursor='default'\" >"];
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
        
        // Remove everything dealt with so far
        replaceRange = [dataString rangeOfString:@"</a></TD>"];
        if (replaceRange.location != NSNotFound) {
            replaceRange.length = replaceRange.location + replaceRange.length;
            replaceRange.location = 0;
            dataString = [dataString stringByReplacingCharactersInRange:replaceRange withString:@""];
        }
        
        // Get the remaining attributes
        NSRange anotherRange;
        NSString *temporary, *majYr, *greekTest;
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
                        startRange = [temporary rangeOfString:@"<div class=\"tny\">"];
                        startRange.length = startRange.location;
                        startRange.location = 0;
                        majYr = [temporary substringWithRange:startRange];
                        majYr = [majYr stringByReplacingOccurrencesOfString:@";<br" withString:@""];
                        majYr = [majYr stringByReplacingOccurrencesOfString:@">" withString:@""];
                        majYr = [majYr stringByReplacingOccurrencesOfString:@";" withString:@""];
                        majYr = [majYr stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
                        majYr = [majYr stringByReplacingOccurrencesOfString:@"<br /" withString:@""];
                        majYr = [majYr stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
                        majYr = [majYr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        if (![majYr isEqualToString:@""]) {
                            [tmpPerson.attributes addObject:@"Department"];
                            [tmpPerson.attributeVals addObject:majYr];
                        }
                        
                        startRange = [temporary rangeOfString:@"<div class=\"tny\">"];
                        endRange = [temporary rangeOfString:@"</div>"];
                        endRange.length = endRange.location - (startRange.location + startRange.length);
                        endRange.location = startRange.location + startRange.length;
                        
                        majYr = [temporary substringWithRange:endRange];
                        majYr = [majYr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        majYr = [majYr stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
                        
                        if (![majYr isEqualToString:@""]) {
                            
                            NSMutableArray *titleArray = [[NSMutableArray alloc] init];
//                            int index = [tmpPerson.attributes indexOfObject:@"Title"];
//                            NSString *title = [tmpPerson.attributeVals objectAtIndex:index];
                            NSRange testRange = [majYr rangeOfString:@"\n"];
                            majYr = [majYr stringByAppendingString:@"\n"];
                            if (NSNotFound != testRange.location) {
                                while (NSNotFound != testRange.location) {
                                    //separate the two titles
                                    testRange.length = testRange.location;
                                    testRange.location = 0;
                                    NSString *tempTitle = [majYr substringWithRange:testRange];
                                    tempTitle = [tempTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                    tempTitle = [tempTitle stringByReplacingOccurrencesOfString:@";" withString:@""];
                                    testRange.length++;
                                    majYr = [majYr stringByReplacingCharactersInRange:testRange withString:@""];
                                    
                                    //add to title array
                                    [titleArray addObject:tempTitle];
                                    
                                    testRange = [majYr rangeOfString:@"\n"];
                                }
                                for (int i = 0; i < titleArray.count; i++) {
                                    [tmpPerson.attributes addObject:@"Title"];
                                    [tmpPerson.attributeVals addObject:[titleArray objectAtIndex:i]];
                                }
                            }
                            else {
                                [tmpPerson.attributes addObject:@"Title"];
                                [tmpPerson.attributeVals addObject:majYr];
                            }
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
                    if (![temporary isEqualToString:@""] && ![temporary isEqualToString:@"&nbsp;"]) {
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
        
        // Check if what we expect to be the next person is actually SGA info
        testRange = [dataString rangeOfString:@"onmouseout=\"this.style.cursor='default'\" >"];
        replaceRange = [dataString rangeOfString:@"colspan="];
        if (replaceRange.location < testRange.location) {
            startRange = [dataString rangeOfString:@"<span class=\"tny\">"];
            endRange = [dataString rangeOfString:@"</span></TD>" options:NSCaseInsensitiveSearch];
            
            if (NSNotFound != startRange.location && NSNotFound != endRange.location) {
                endRange.length = endRange.location - (startRange.location + startRange.length);
                endRange.location = startRange.location + startRange.length;
                temporary = [dataString substringWithRange:endRange];
                temporary = [temporary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                int index = [tmpPerson.attributes indexOfObject:@"Status"];
                [tmpPerson.attributes insertObject:@"SGA" atIndex:index];
                [tmpPerson.attributeVals insertObject:temporary atIndex:index];
                replaceRange = [dataString rangeOfString:@"</tr>"];
                if (replaceRange.location != NSNotFound) {
                    replaceRange.length = replaceRange.location + replaceRange.length;
                    replaceRange.location = 0;
                    dataString = [dataString stringByReplacingCharactersInRange:replaceRange withString:@""];
                }
            }
        }
        [tmpPerson.attributes addObject:@"picURL"];
        [tmpPerson.attributeVals addObject:urlString];
        
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
