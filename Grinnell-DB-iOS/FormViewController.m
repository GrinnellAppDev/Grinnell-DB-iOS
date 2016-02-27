#import <MBProgressHUD.h>
#import <Reachability.h>

#import "FormViewController.h"
#import "OptionViewController.h"
#import "Person.h"
#import "ResultsViewController.h"
#import "Grinnell_DB_iOS-Swift.h"


@interface FormViewController ()

@end

@implementation FormViewController
@synthesize lastNameField, firstNameField, usernameField, phoneField, campusAddressField, homeAddressField, majorField, concentrationField, sgaField, hiatusField, classField, facStaffField, keyboardControls, textFieldIdentifier, myPickerView, concentrationArray, sgaArray, facStaffArray, hiatusArray, classArray, majorsArray, searchResults, onCampusBool, notFirstRun, statesArray, stateBeforeSettings;

- (IBAction)clearButtonClicked:(id)sender {
    [self clear:sender];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationItem.rightBarButtonItem setAction:@selector(iPadSearch:)];
    }
    // Instantiate the picker view arrays
    // Note: the empty string sets up the clearing option in the picker
    majorsArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
    concentrationArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
	sgaArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
	hiatusArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
	facStaffArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
    classArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
    statesArray = [[NSMutableArray alloc] initWithObjects:@"", @"Any", @"AL", @"AK", @"AZ", @"AR", @"CA", @"CO", @"CT", @"DC", @"DE", @"FL", @"GA", @"HI", @"ID", @"IL", @"IN", @"IA", @"KS", @"KY", @"LA", @"ME", @"MD", @"MA", @"MI", @"MN", @"MS", @"MO", @"MT", @"NE", @"NV", @"NH", @"NJ", @"NM", @"NY", @"NC", @"ND", @"OH", @"OK", @"OR", @"PA", @"RI", @"SC", @"SD", @"TN", @"TX", @"UT", @"VT", @"VA", @"WA", @"WV", @"WI", @"WY", nil];
    
    // Assume on campus... This will be changed during [self load]
    onCampusBool = YES;
    
    // Used to pass the identity of a textField into pickerView methods
    textFieldIdentifier = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    // Instantiate the picker and set the field inputs
    myPickerView = [[UIPickerView alloc] init];
    [myPickerView setAutoresizesSubviews:YES];
    [myPickerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    myPickerView.delegate = self;
    myPickerView.showsSelectionIndicator = YES;
    [self.view addSubview:myPickerView];
    myPickerView.hidden = YES;
    majorField.inputView = myPickerView;
    concentrationField.inputView = myPickerView;
    sgaField.inputView = myPickerView;
    hiatusField.inputView = myPickerView;
    classField.inputView = myPickerView;
    facStaffField.inputView = myPickerView;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"State"]) {
        homeAddressField.inputView = myPickerView;
    } else {
        homeAddressField.inputView = nil;
    }
    
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    // Check network and load picker views if there is a network
    if ([self networkCheck]) {
        [self load];
    } else {
        [self showNoNetworkAlert];
        return;
    }
    
    // Set up previous/next/done buttons
    if (onCampusBool) {
        fields = [[NSMutableArray alloc] initWithObjects:firstNameField, lastNameField, usernameField, classField, phoneField, campusAddressField, majorField, concentrationField, hiatusField, homeAddressField, facStaffField, sgaField, nil];
    } else {
        fields = [[NSMutableArray alloc] initWithObjects:firstNameField, lastNameField, usernameField, nil];
    }
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    keyboardControls.barTintColor = [UIColor whiteColor];
    [keyboardControls setDelegate:self];
    
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
    [self searchHelper];
    
    // Stop the segue if an error occured (indicated by null value in searchResults)
    if (searchResults) {
        return YES;
    } else {
        return NO;
    }
}

// Pass data to the ResultsViewController
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"searchSegue"]) {
        ResultsViewController *destViewController = segue.destinationViewController;
        destViewController.searchDetails = searchResults;
        destViewController.onCampusBool = onCampusBool;
    }
}

#pragma mark Keyboard/textField methods
- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyControls {
    [keyControls.activeField resignFirstResponder];
}

- (void)keyboardControls:(BSKeyboardControls *)keyControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction {
    [keyControls setActiveField:field];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [keyboardControls setActiveField:textField];
    
    // Show the picker if needed for this field
    if (0 != textField.tag) {
        myPickerView.hidden = NO;
        textFieldIdentifier = (int)textField.tag;
        [myPickerView reloadAllComponents];
        [myPickerView selectRow:0 inComponent:0 animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self iPadSearch:textField];
    } else {
        if ([self shouldPerformSegueWithIdentifier:@"searchSegue" sender:self]) {
            [self performSegueWithIdentifier:@"searchSegue" sender:self];
        }
    }
    return YES;
}

// Minimize keyboard on user drag
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [keyboardControls.activeField resignFirstResponder];
}

#pragma mark UIPicker methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (textFieldIdentifier) {
        case 2001:
            return [classArray objectAtIndex:row];
            break;
        case 2002:
            return [majorsArray objectAtIndex:row];
            break;
        case 2003:
            return [concentrationArray objectAtIndex:row];
            break;
        case 2004:
            return [hiatusArray objectAtIndex:row];
            break;
        case 2005:
            return [facStaffArray objectAtIndex:row];
            break;
        case 2006:
            return [sgaArray objectAtIndex:row];
            break;
        case 2007:
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"State"])
                return [statesArray objectAtIndex:row];
            else return nil;
            break;
        default:
            return nil;
            break;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (textFieldIdentifier) {
        case 2001:
            return classArray.count;
            break;
        case 2002:
            return majorsArray.count;
            break;
        case 2003:
            return concentrationArray.count;
            break;
        case 2004:
            return hiatusArray.count;
            break;
        case 2005:
            return facStaffArray.count;
            break;
        case 2006:
            return sgaArray.count;
            break;
        case 2007:
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"State"]) {
                return statesArray.count;
            } else {
                return 0;
            }
            break;
        default:
            return 0;
            break;
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (textFieldIdentifier) {
        case 2001:
            classField.text = [classArray objectAtIndex:row];
            break;
        case 2002:
            majorField.text = [majorsArray objectAtIndex:row];
            break;
        case 2003:
            concentrationField.text = [concentrationArray objectAtIndex:row];
            break;
        case 2004:
            hiatusField.text = [hiatusArray objectAtIndex:row];
            break;
        case 2005:
            facStaffField.text = [facStaffArray objectAtIndex:row];
            break;
        case 2006:
            sgaField.text = [sgaArray objectAtIndex:row];
            break;
        case 2007:
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"State"]) {
                homeAddressField.text = [statesArray objectAtIndex:row];
            }
            break;
        default:
            break;
    }
}

#pragma mark UITableView overrides
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (onCampusBool) {
        return 12;
    } else {
        return 3;
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [keyboardControls.activeField resignFirstResponder];
    OptionViewController *controller = [[OptionViewController alloc] initWithNibName:@"OptionViewController" bundle:nil];
    popoverController = [[WYPopoverController alloc] initWithContentViewController:controller];
    popoverController.delegate = self;
    [popoverController setPopoverContentSize:CGSizeMake(self.view.frame.size.width, 75)];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (1 >= indexPath.row) {
        controller.state = NO;
        if (0 == indexPath.row) {
            controller.first = YES;
        } else {
            controller.first = NO;
        }
    } else {
        controller.state = YES;
    }
    stateBeforeSettings = [[NSUserDefaults standardUserDefaults] boolForKey:@"State"];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [popoverController presentPopoverFromRect:cell.bounds inView:cell permittedArrowDirections:WYPopoverArrowDirectionLeft animated:YES];
    } else {
        [popoverController presentPopoverFromRect:cell.bounds inView:cell permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark - Popover overrides
- (void)popoverControllerDidDismissPopover:(WYPopoverController *)popoverController {
    BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"State"];
    if (stateBeforeSettings != temp) {
        if (temp) {
            homeAddressField.inputView = myPickerView;
        } else {
            homeAddressField.inputView = nil;
        }
        [self.tableView reloadData];
    }
}

#pragma mark UIAlertViewDelegate Methods
// Called when an alert button is tapped.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self viewWillAppear:YES];
    return;
}

- (void)showNoNetworkAlert {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
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
    [MBProgressHUD hideHUDForView:self.view animated:YES];
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
    [MBProgressHUD hideHUDForView:self.view animated:YES];
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
    [MBProgressHUD hideHUDForView:self.view animated:YES];
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
    @try {
        NSString *post =[[NSString alloc] initWithFormat:@""];
        
        NSURL *url=[NSURL URLWithString:@"https://itwebapps.grinnell.edu/classic/asp/campusdirectory/GCdefault.asp"];
        
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        
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
                onCampusBool = YES;
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
            } else {
                if (!notFirstRun) {
                    [self showGrinnellAlert];
                    notFirstRun = YES;
                }
                onCampusBool = NO;
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
    @try {
        NSString *post =[[NSString alloc] initWithFormat:@""];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
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
        
        if ([response statusCode] >= 200 && [response statusCode] < 300) {
            NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
            
            NSRange startRange = [responseData rangeOfString:@" found"];
            if (NSNotFound == startRange.location) {
                [self showErrorAlert];
                return;
            }
            
            responseData = [self cutString:responseData fromStartToEndOfRange:startRange];
            
            // Test for search with no results
            NSRange endRange = [responseData rangeOfString:@"<strong>no</strong> matches"];
            if (NSNotFound != endRange.location) {
                [self showNoResultsAlert];
                searchResults = NULL;
                return;
            }
            
            // Test for VAGUE SEARCH (too many results)
            endRange = [responseData rangeOfString:@"Your search returned a <i>very</i> large number of records and you must reduce the number of matches by refining your search criteria using the form at the bottom of the page"];
            if (NSNotFound != endRange.location) {
                [self showVagueSearchAlert];
                searchResults = NULL;
                return;
            }
            
            // Sanity Check
            endRange = [responseData rangeOfString:@"entr"];
            if (NSNotFound == endRange.location) {
                [self showErrorAlert];
                searchResults = NULL;
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
        if ([self networkCheck]) {
            [self showErrorAlert];
        } else {
            [self showNoNetworkAlert];
        }
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
    if (NSNotFound != replaceRange.location)
        dataString = [self cutString:dataString fromStartToEndOfRange:replaceRange];
    
    // Check for a value to be processed
    NSRange testRange = [dataString rangeOfString:@"</option>"];
    while (NSNotFound != testRange.location) {
        // Get the range of the value being processed
        startRange = [dataString rangeOfString:@"\">"];
        endRange = [dataString rangeOfString:@"</option>"];
        
        // Get the value and remove whitespace
        if (NSNotFound == endRange.location) {
            [self showErrorAlert];
            NSLog(@"Error parsing picker options");
        }
        NSString *tempString = [self extractFromString:dataString withRange:startRange andRange:endRange];
        tempString = [tempString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // Add value to array
        if (![tempString isEqualToString:@""] && NULL != tempString) {
            [array addObject:tempString];
        }
        
        // Remove the section of the string just processed
        NSRange replaceRange = [dataString rangeOfString:@"</option>"];
        if (replaceRange.location != NSNotFound) {
            dataString = [self cutString:dataString fromStartToEndOfRange:replaceRange];
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
    if (replaceRange.location != NSNotFound)
        dataString = [self cutString:dataString fromStartToEndOfRange:replaceRange];
    
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
        NSString *temporary, *last, *first;
        for (int i = 0; i < 7; i++) {
            switch (i) {
                case 0:
                    temporary = [self getAttributeValue:dataString];
                    endRange = [temporary rangeOfString:@", "];
                    startRange.location = 0;
                    startRange.length = endRange.location;
                    endRange.location += 2;;
                    endRange.length = temporary.length - endRange.location;
                    last = [temporary substringWithRange:startRange];
                    first = [temporary substringWithRange:endRange];
                    tmpPerson.firstName = first;
                    tmpPerson.lastName = last;
                    break;
                case 1:
                    temporary = [self getAttributeValue:dataString];
                    
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
                            
                            //separate multiple titles, if applicable
                            startRange.location = index;
                            startRange.length = temporary.length - index;
                            NSString *majYr = [temporary substringWithRange:startRange];
                            if (![majYr isEqualToString:@""]) {
                                NSMutableArray *titleArray = [[NSMutableArray alloc] init];
                                NSRange testRange = [majYr rangeOfString:@"\n"];
                                majYr = [majYr stringByAppendingString:@"\n"];
                                if (NSNotFound != testRange.location) {
                                    while (NSNotFound != testRange.location) {
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
                                } else {
                                    [tmpPerson.attributes addObject:@"Title"];
                                    [tmpPerson.attributeVals addObject:majYr];
                                }
                            }
                        }
                    }
                    break;
                case 2:
                    temporary = [self getAttributeValue:dataString];
                    
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
                    temporary = [self getEmailAttributeValue:dataString];
                    [tmpPerson.attributes addObject:@"Username"];
                    [tmpPerson.attributeVals addObject:temporary];
                    break;
                case 4:
                    temporary = [self getAttributeValue:dataString];
                    
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
                    temporary = [self getAttributeValue:dataString];
                    
                    temporary = [temporary stringByReplacingOccurrencesOfString:@"<span class=\"tny2\">" withString:@""];
                    temporary = [temporary stringByReplacingOccurrencesOfString:@"</span>" withString:@""];
                    temporary = [temporary stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
                    temporary = [temporary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if (![temporary isEqualToString:@""]) {
                        [tmpPerson.attributes addObject:@"Box Number"];
                        [tmpPerson.attributeVals addObject:temporary];
                    }
                    break;
                case 6:
                    temporary = [self getAttributeValue:dataString];
                    
                    [tmpPerson.attributes addObject:@"Status"];
                    [tmpPerson.attributeVals addObject:temporary];
                    break;
                default:
                    break;
            }
            // Remove the just processed attribute
            replaceRange = [dataString rangeOfString:@"</TD>" options:NSCaseInsensitiveSearch];
            if (replaceRange.location != NSNotFound) {
                dataString = [self cutString:dataString fromStartToEndOfRange:replaceRange];
            }
            
            replaceRange = [dataString rangeOfString:@"</TD>" options:NSCaseInsensitiveSearch];
            endRange = [dataString rangeOfString:@"</tr>" options:NSCaseInsensitiveSearch];
            if (endRange.location < replaceRange.location) {
                break;
            }
        }
        
        // Remove the section of the string just processed
        replaceRange = [dataString rangeOfString:@"</tr>"];
        if (replaceRange.location != NSNotFound) {
            dataString = [self cutString:dataString fromStartToEndOfRange:replaceRange];
        }
        
        // Check for another value to be processed
        testRange = [dataString rangeOfString:@"&nbsp;</TD>"];
        
        // Check if what we expect to be the next person is actually SGA info
        replaceRange = [dataString rangeOfString:@"colspan="];
        if (replaceRange.location < testRange.location) {
            startRange = [dataString rangeOfString:@"<span class=\"tn2y\">"];
            endRange = [dataString rangeOfString:@"</span></TD>" options:NSCaseInsensitiveSearch];
            temporary = [self extractFromString:dataString withRange:startRange andRange:endRange];
            if (nil != temporary) {
                NSUInteger index = [tmpPerson.attributes indexOfObject:@"Status"];
                [tmpPerson.attributes insertObject:@"SGA" atIndex:index];
                [tmpPerson.attributeVals insertObject:temporary atIndex:index];
                replaceRange = [dataString rangeOfString:@"</tr>"];
                if (replaceRange.location != NSNotFound) {
                    dataString = [self cutString:dataString fromStartToEndOfRange:replaceRange];
                }
            }
        }
        
        [searchResults addObject:tmpPerson];
        
        // Remove the header line
        replaceRange = [dataString rangeOfString:@"</TD>" options:NSCaseInsensitiveSearch];
        if (replaceRange.location != NSNotFound) {
            dataString = [self cutString:dataString fromStartToEndOfRange:replaceRange];
        }
    }
}

// This method parses the HTML returned by the search request
- (void)parseResults:(NSString *)dataString {
    // Check for on campus vs. off campus
    NSRange testRange = [dataString rangeOfString:@"You can gain access" options:NSCaseInsensitiveSearch];
    if (NSNotFound != testRange.location) {
        [self parseResultsOffCampus:dataString];
        return;
    }
    
    // Delete the string before the first value
    testRange = [dataString rangeOfString:@"valign=\"top\" style=\"text-align:center;\">"];
    if (NSNotFound != testRange.location) {
        dataString = [self cutString:dataString fromStartToEndOfRange:testRange];
    } else {
        [self showErrorAlert];
        return;
    }
    
    // Loop through the people
    NSRange replaceRange;
    while (NSNotFound != testRange.location) {
        Person *tmpPerson = [[Person alloc] init];
        tmpPerson.attributes = [[NSMutableArray alloc] init];
        tmpPerson.attributeVals = [[NSMutableArray alloc] init];
        
        // Get and process the url string
        NSRange startRange = [dataString rangeOfString:@"<img src=\""];
        NSRange endRange = [dataString rangeOfString:@"\" alt=\"Image Thumbnail"];
        testRange = [dataString rangeOfString:@"href=\""];
        NSString *urlString;
        if (endRange.location < testRange.location) {
            urlString = [self extractFromString:dataString withRange:startRange andRange:endRange];
        }
        
        startRange = [dataString rangeOfString:@"<a href=\"GCdisplaydata.asp?SomeKindofNumber=" options:NSCaseInsensitiveSearch];
        endRange = [dataString rangeOfString:@"\" target ="];
        NSString *profileURLString;
        profileURLString = [self extractFromString:dataString withRange:startRange andRange:endRange];
        
        // Get and process the person's name
        startRange = [dataString rangeOfString:@"target = \"_blank\">"];
        endRange = [dataString rangeOfString:@"</a></TD>"];
        NSString *name = [self extractFromString:dataString withRange:startRange andRange:endRange];
        
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
            dataString = [self cutString:dataString fromStartToEndOfRange:replaceRange];
        }
        
        // Get the remaining attributes
        NSString *temporary, *majYr, *greekTest;
        for (int i = 0; i < 6; i++) {
            switch (i) {
                    // Department/Title OR Major/Year
                case 0:
                    temporary = [self getAttributeValue:dataString];
                    
                    endRange = [temporary rangeOfString:@" ("];
                    startRange = [temporary rangeOfString:@"<br />"];
                    
                    // Deal with departments containing '(' character in name
                    if (NSNotFound != endRange.location){
                        replaceRange.location = endRange.location + endRange.length;
                        replaceRange.length = 1;
                        greekTest = [temporary substringWithRange:replaceRange];
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
                    } else {
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
                        majYr = [self extractFromString:temporary withRange:startRange andRange:endRange];
                        majYr = [majYr stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
                        
                        if (![majYr isEqualToString:@""]) {
                            NSMutableArray *titleArray = [[NSMutableArray alloc] init];
                            
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
                            } else {
                                [tmpPerson.attributes addObject:@"Title"];
                                [tmpPerson.attributeVals addObject:majYr];
                            }
                        }
                    }
                    break;
                case 1:
                    temporary = [self getAttributeValue:dataString];
                    
                    if (![temporary isEqualToString:@""]) {
                        [tmpPerson.attributes addObject:@"Campus Phone"];
                        [tmpPerson.attributeVals addObject:temporary];
                    }
                    break;
                case 2:
                    temporary = [self getEmailAttributeValue:dataString];
                    
                    if (![temporary isEqualToString:@""]) {
                        [tmpPerson.attributes addObject:@"Username"];
                        [tmpPerson.attributeVals addObject:temporary];
                    }
                    break;
                case 3:
                    temporary = [self getAttributeValue:dataString];
                    
                    if (![temporary isEqualToString:@""]) {
                        [tmpPerson.attributes addObject:@"Campus Address"];
                        [tmpPerson.attributeVals addObject:temporary];
                    }
                    break;
                case 4:
                    temporary = [self getAttributeValue:dataString];
                    
                    if (![temporary isEqualToString:@""] && ![temporary isEqualToString:@"&nbsp;"]) {
                        [tmpPerson.attributes addObject:@"Box Number"];
                        [tmpPerson.attributeVals addObject:temporary];
                    }
                    break;
                case 5:
                    temporary = [self getAttributeValue:dataString];
                    [tmpPerson.attributes addObject:@"Status"];
                    [tmpPerson.attributeVals addObject:temporary];
                    break;
                default:
                    break;
            }
            // Remove the just processed attribute
            replaceRange = [dataString rangeOfString:@"</TD>" options:NSCaseInsensitiveSearch];
            if (replaceRange.location != NSNotFound) {
                dataString = [self cutString:dataString fromStartToEndOfRange:replaceRange];
            }
        }
        // Remove the section of the string just processed
        replaceRange = [dataString rangeOfString:@"</tr>"];
        if (replaceRange.location != NSNotFound) {
            dataString = [self cutString:dataString fromStartToEndOfRange:replaceRange];
        }
        
        // Check if what we expect to be the next person is actually SGA info
        testRange = [dataString rangeOfString:@"valign=\"top\" style=\"text-align:center;\">"];
        replaceRange = [dataString rangeOfString:@"colspan="];
        if (replaceRange.location < testRange.location) {
            startRange = [dataString rangeOfString:@"<span class=\"tny\">"];
            endRange = [dataString rangeOfString:@"</span></TD>" options:NSCaseInsensitiveSearch];
            
            if (NSNotFound != startRange.location && NSNotFound != endRange.location) {
                temporary = [self extractFromString:dataString withRange:startRange andRange:endRange];
                NSUInteger index = [tmpPerson.attributes indexOfObject:@"Status"];
                [tmpPerson.attributes insertObject:@"SGA" atIndex:index];
                [tmpPerson.attributeVals insertObject:temporary atIndex:index];
                replaceRange = [dataString rangeOfString:@"</tr>"];
                if (replaceRange.location != NSNotFound) {
                    dataString = [self cutString:dataString fromStartToEndOfRange:replaceRange];
                }
            }
        }
        if (Nil != urlString) {
            [tmpPerson.attributes addObject:@"picURL"];
            [tmpPerson.attributeVals addObject:urlString];
        }
        if (Nil != profileURLString) {
            [tmpPerson.attributes addObject:@"profileURL"];
            [tmpPerson.attributeVals addObject:profileURLString];
        }
        [searchResults addObject:tmpPerson];
        
        // Check for another value to be processed
        testRange = [dataString rangeOfString:@"valign=\"top\" style=\"text-align:center;\">"];
    }
}

// Getting an attribute
- (NSString *)getAttributeValue:(NSString *)dataString {
    NSRange startRange = [dataString rangeOfString:@"valign=\"top\">"];
    NSRange endRange = [dataString rangeOfString:@"</TD>" options:NSCaseInsensitiveSearch];
    return [self extractFromString:dataString withRange:startRange andRange:endRange];
}

// Getting the email attribute
- (NSString *)getEmailAttributeValue:(NSString *)dataString {
    NSRange startRange = [dataString rangeOfString:@"valign=\"top\"> <font size=\"-1\">"];
    NSRange endRange = [dataString rangeOfString:@"@grinnell.edu" options:NSCaseInsensitiveSearch];
    return [self extractFromString:dataString withRange:startRange andRange:endRange];
}

// Taking a substring of a string starting at startRange and ending at endRange
//  Returns nicely formatted!
- (NSString *)extractFromString:(NSString *)str withRange:(NSRange)startRange andRange:(NSRange)endRange {
    endRange.length = endRange.location - (startRange.location + startRange.length);
    endRange.location = startRange.location + startRange.length;
    if (NSNotFound != endRange.location) {
        NSString *temporary = [str substringWithRange:endRange];
        temporary = [temporary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return temporary;
    } else {
        return nil;
    }
}

// Cuts the beginning of a string (up to a certain range)
- (NSString *)cutString:(NSString *)str fromStartToEndOfRange:(NSRange)startRange {
    startRange.length = startRange.location + startRange.length;
    startRange.location = 0;
    return [str stringByReplacingCharactersInRange:startRange withString:@""];
}

// Clears all textFields in the form
- (void)clear:(id)sender {
    for (int i=0; i < fields.count; i++) {
        UITextField *field = [fields objectAtIndex:i];
        field.text = @"";
    }
}

// Refreshes results on iPad
- (void)iPadSearch:(id)sender {
    [self searchHelper];
    UINavigationController *navC = [self.splitViewController.viewControllers lastObject];
    [navC popToRootViewControllerAnimated:NO];
    ResultsViewController *results = (ResultsViewController *)navC.topViewController;
    results.searchDetails = searchResults;
    results.onCampusBool = onCampusBool;
    [results.tableView reloadData];
}

- (void) searchHelper {
    searchResults = [[NSMutableArray alloc] init];
    [keyboardControls.activeField resignFirstResponder];
    // Set up HUD and give it time to run
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Searching";
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
    
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
    NSString *firstSearchType, *lastSearchType;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"First"]) {
        firstSearchType = @"contains";
    } else {
        firstSearchType = @"startswith";
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Last"]) {
        lastSearchType = @"contains";
    } else {
        lastSearchType = @"startswith";
    }
    // Set up the url properly - Nothing containing the word "any" should be in the url
    if (onCampusBool) {
        NSString *year = [searchDetails objectAtIndex:3];
        if ([year isEqualToString:@"Any"]) {
            year = @"";
        }
        NSString *phone = [searchDetails objectAtIndex:4];
        NSString *address = [searchDetails objectAtIndex:5];
        NSString *major = [searchDetails objectAtIndex:6];
        if ([major isEqualToString:@"Any"]) {
            major = @"";
        }
        NSString *conc = [searchDetails objectAtIndex:7];
        if ([conc isEqualToString:@"Any"]) {
            conc = @"";
        }
        NSString *hiatus = [searchDetails objectAtIndex:8];
        if ([hiatus isEqualToString:@"Any"]) {
            hiatus = @"";
        }
        NSString *home = [searchDetails objectAtIndex:9];
        if ([home isEqualToString:@"Any"]) {
            home = @"";
        }
        NSString *facStaff = [searchDetails objectAtIndex:10];
        if ([facStaff isEqualToString:@"Any"]) {
            facStaff = @"";
        }
        NSString *sga = [searchDetails objectAtIndex:11];
        if ([sga isEqualToString:@"Any"]) {
            sga = @"";
        }
        NSString *homeSearchType;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"State"] && ![home isEqualToString:@""]) {
            homeSearchType = @"Y";
        } else {
            homeSearchType = @"N";
        }
        
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itwebapps.grinnell.edu/classic/asp/campusdirectory/GCdefault.asp?transmit=true&blackboardref=true&pagenum=1&LastName=%@&LNameSearch=%@&FirstName=%@&FNameSearch=%@&email=%@&campusphonenumber=%@&campusquery=%@&Homequery=%@&StateOnlyCheck=%@&Department=%@&Major=%@&conc=%@&SGA=%@&Hiatus=%@&Gyear=%@&submit_search=Search", last, lastSearchType, first, firstSearchType, user, phone, address, home, homeSearchType, facStaff, major, conc, sga, hiatus, year]];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itwebapps.grinnell.edu/classic/asp/campusdirectory/GCdefault.asp?transmit=true&blackboardref=true&pagenum=1&LastName=%@&LNameSearch=%@&FirstName=%@&FNameSearch=%@&email=%@&submit_search=Search", last, lastSearchType, first, firstSearchType, user]];
    }
    
    // Start the search
    [self searchUsingURL:url forPage:1];
    
    // Hide the HUD
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}

@end
