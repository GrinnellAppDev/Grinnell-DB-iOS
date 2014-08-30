//
//  ResultsViewController.m
//  Grinnell-DB-iOS
//
//  Created by Colin Tremblay on 9/12/13.
//  Copyright (c) 2013 AppDev. All rights reserved.
//

#import "ResultsViewController.h"
#import "ProfileViewController.h"
#import <Reachability.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ResultsViewController ()

@end

@implementation ResultsViewController

@synthesize cellIdentifier, searchDetails, onCampusBool;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib {
    self.splitViewController.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (onCampusBool) {
        cellIdentifier = @"OnCResultsCell";
    } else {
        cellIdentifier = @"OffCResultsCell";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushToProfile"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        ProfileViewController *destViewController = segue.destinationViewController;
        Person *selected = [[Person alloc] init];
        selected = [searchDetails objectAtIndex:indexPath.row];
        NSUInteger index = [selected.attributes indexOfObject:@"profileURL"];
        if (NSNotFound != index) {
            [self parseProfilePage:[selected.attributeVals objectAtIndex:index] forPerson:selected];
        }
        destViewController.selectedPerson = selected;
    }
}

//Method to determine the availability of network Connections using the Reachability Class
- (BOOL)networkCheck {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return (!(networkStatus == NotReachable));
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return searchDetails.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Register the NIB cell object for our custom cell
    if (onCampusBool) {
        [tableView registerNib:[UINib nibWithNibName:@"OnCResultsCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    } else {
        [tableView registerNib:[UINib nibWithNibName:@"OffCResultsCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    }
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
    
    // Connect the cell's properties
    UILabel *nameLbl = (UILabel *)[cell viewWithTag:1002];
    UILabel *statusLbl = (UILabel *)[cell viewWithTag:1003];
    UILabel *usernameLbl = (UILabel *)[cell viewWithTag:1004];
    UILabel *majorLbl = (UILabel *)[cell viewWithTag:1005];
    UILabel *classLbl = (UILabel *)[cell viewWithTag:1006];
    UIImageView *userImageView = (UIImageView *) [cell viewWithTag:1007];
    
    Person *tempPerson = [[Person alloc] init];
    tempPerson = [searchDetails objectAtIndex:indexPath.row];
    
    NSString *first = tempPerson.firstName;
    NSString *last = tempPerson.lastName;
    NSString *status = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Status"]];
    NSString *username = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Username"]];
    
    // Fetch the image
    NSUInteger index = [tempPerson.attributes indexOfObject:@"picURL"];
    if (NSNotFound != index) {
        NSString *userImageString = [tempPerson.attributeVals objectAtIndex:index];
        userImageView.contentMode = UIViewContentModeScaleAspectFit;
        [userImageView sd_setImageWithURL:[NSURL URLWithString:userImageString] placeholderImage:nil];
    } else {
        userImageView.image = nil;
    }
    
    if ([status isEqualToString:@"Student"]) {
        NSString *year = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Class"]];
        NSString *major = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Major"]];
        majorLbl.text = major;
        classLbl.text = year;
        statusLbl.text = status;
    } else if ([status isEqualToString:@"Faculty / Staff"]) {
        NSString *dept = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Department"]];
        
        NSMutableArray *titleArray = [[NSMutableArray alloc] init];
        NSUInteger index = [tempPerson.attributes indexOfObject:@"Title"];
        while ([@"Title" isEqualToString:[tempPerson.attributes objectAtIndex:index]]) {
            NSString *title = [tempPerson.attributeVals objectAtIndex:index];
            [titleArray addObject:title];
            index++;
        }
        NSString *compositeTitle = [titleArray objectAtIndex:0];
        
        for (int i = 1; i < titleArray.count; i++) {
            compositeTitle = [compositeTitle stringByAppendingString:[NSString stringWithFormat:@"/%@", [titleArray objectAtIndex:i]]];
        }
        
        compositeTitle = [compositeTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        majorLbl.text = compositeTitle;
        classLbl.text = dept;
        statusLbl.text = @"Fac/Staff";
    } else {
        NSUInteger index = [tempPerson.attributes indexOfObject:@"Title"];
        if (NSNotFound != index) {
            NSString *title = [tempPerson.attributeVals objectAtIndex:index];
            majorLbl.text = title;
            classLbl.text = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Department"]];
        } else {
            majorLbl.text = @"Data unavailable off campus";
            classLbl.text = @"Unavailable";
        }
        statusLbl.text = @"Unavailable";
    }
    
    nameLbl.text = [NSString stringWithFormat:@"%@, %@", last, first];
    usernameLbl.text = username;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"PushToProfile" sender:self];
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

- (void)parseProfilePage:(NSString *)urlString forPerson:(Person *)selected {
    @try {
        NSString *post =[[NSString alloc] initWithFormat:@""];
        
        NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"https://itwebapps.grinnell.edu/classic/asp/campusdirectory/GCdisplaydata.asp?SomeKindofNumber=%@", urlString]];
        
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
            
            NSRange startRange = [responseData rangeOfString:@"<td ></td></tr><tr><td valign = \"top\">" options:NSCaseInsensitiveSearch];
            responseData = [self cutString:responseData fromStartToEndOfRange:startRange];
            NSUInteger i = [selected.attributes indexOfObject:@"picURL"];
            NSUInteger j = [selected.attributes indexOfObject:@"profileURL"];
            NSUInteger k = [selected.attributes indexOfObject:@"Status"];
            NSUInteger index = MIN(k, MIN(i, j));
            if (NSNotFound == index)
                index = selected.attributes.count;
            
            startRange = [responseData rangeOfString:@"<TR><TD valign=\"top\" align=\"right\" ><Strong>"];
            while (NSNotFound != startRange.location) {
            	NSUInteger tempIndex = index;
                NSRange endRange = [responseData rangeOfString:@":</strong>"];
                NSString *temp = [self extractFromString:responseData withRange:startRange andRange:endRange];
                
                if ([temp isEqualToString:@"Name"] || [temp isEqualToString:@"Major"] || [temp isEqualToString:@"Class"] || [temp isEqualToString:@"E-Mail"] || [temp isEqualToString:@"Campus Box"] || [temp isEqualToString:@"Local Addr"] || [temp isEqualToString:@"Campus Address"] || [temp isEqualToString:@"Campus Phone"] || [temp isEqualToString:@"Titles"] || [temp isEqualToString:@"Department(s)"] || [temp isEqualToString:@"Title"] || [temp isEqualToString:@"Off Campus Study"] || [temp isEqualToString:@"SGA Member"]) {
                    ; // Do Nothing
                } else {
                    startRange = [responseData rangeOfString:@"<TD valign=\"top\">" options:NSCaseInsensitiveSearch];
                    endRange = [responseData rangeOfString:@"</TD></TR>" options:NSCaseInsensitiveSearch];
                    if ([temp isEqualToString:@""]) {
                        temp = @"Home Address";
                    } else if ([temp isEqualToString:@"Home Addr"]) {
                        temp = @"Home Address";
                    } else if ([temp isEqualToString:@"Name*"]) {
                    	temp = @"Full Name";
                    	tempIndex = 0;
                    }
                    [selected.attributes insertObject:temp atIndex:tempIndex];
                    [selected.attributeVals insertObject:[self extractFromString:responseData withRange:startRange andRange:endRange] atIndex:tempIndex];
                    index++;
                }
                endRange = [responseData rangeOfString:@"</tr>" options:NSCaseInsensitiveSearch];
                responseData = [self cutString:responseData fromStartToEndOfRange:endRange];
                startRange = [responseData rangeOfString:@"<TR><TD valign=\"top\" align=\"right\" ><Strong>"];
            }
        } else {
            [self showErrorAlert];
        }
    }
    @catch(NSException * e){
        NSLog(@"Exception: %@", e);
        [self showErrorAlert];
    }
}

// Cuts the beginning of a string (up to a certain range)
- (NSString *)cutString:(NSString *)str fromStartToEndOfRange:(NSRange)startRange {
    startRange.length = startRange.location + startRange.length;
    startRange.location = 0;
    return [str stringByReplacingCharactersInRange:startRange withString:@""];
}


// Taking a substring of a string starting at startRange and ending at endRange
//  Returns nicely formatted!
- (NSString *)extractFromString:(NSString *)str withRange:(NSRange)startRange andRange:(NSRange)endRange {
    endRange.length = endRange.location - (startRange.location + startRange.length);
    endRange.location = startRange.location + startRange.length;
    if (NSNotFound != endRange.location) {
        NSString *temporary = [str substringWithRange:endRange];
        temporary = [temporary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        temporary = [temporary stringByReplacingOccurrencesOfString:@"</address>" withString:@""];
        temporary = [temporary stringByReplacingOccurrencesOfString:@"<address>" withString:@""];
        temporary = [temporary stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
        return temporary;
    } else {
        return nil;
    }
}

- (BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}
/*
 - (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
 barButtonItem.title = @"Master";
 [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
 self.popover = popoverController;
 }*/

@end
