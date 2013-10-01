//
//  ResultsViewController.m
//  Grinnell-DB-iOS
//
//  Created by Colin Tremblay on 9/12/13.
//  Copyright (c) 2013 AppDev. All rights reserved.
//

#import "ResultsViewController.h"
#import "ProfileViewController.h"
#import "Person.h"
#import "Reachability.h"

@interface ResultsViewController ()

@end

@implementation ResultsViewController
@synthesize cellIdentifier;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cellIdentifier = @"ResultsCell";
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
        selected = [self.searchDetails objectAtIndex:indexPath.row];
        
        if ([@"Faculty / Staff" isEqualToString:[selected.attributeVals objectAtIndex:[selected.attributes indexOfObject:@"Status"]]]) {
            NSMutableArray *titleArray = [[NSMutableArray alloc] init];
            int index = [selected.attributes indexOfObject:@"Title"];
            NSString *title = [selected.attributeVals objectAtIndex:index];
            NSRange testRange = [title rangeOfString:@"\n"];
            title = [title stringByAppendingString:@"\n"];
            if (NSNotFound != testRange.location) {
                [selected.attributes removeObjectAtIndex:index];
                [selected.attributeVals removeObjectAtIndex:index];
                
                while (NSNotFound != testRange.location) {
                    //separate the two titles
                    testRange.length = testRange.location;
                    testRange.location = 0;
                    NSString *tempTitle = [title substringWithRange:testRange];
                    tempTitle = [tempTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    tempTitle = [tempTitle stringByReplacingOccurrencesOfString:@";" withString:@""];
                    testRange.length++;
                    title = [title stringByReplacingCharactersInRange:testRange withString:@""];
                    
                    //add to title array
                    [titleArray addObject:tempTitle];
                    
                    testRange = [title rangeOfString:@"\n"];
                }
                for (int i = 0; i < titleArray.count; i++) {
                    
                    [selected.attributes insertObject:@"Title" atIndex:index];
                    [selected.attributeVals insertObject:[titleArray objectAtIndex:i] atIndex:index + i];
                }
                    
            }
            else {
            // Do nothing
            }
            
        }
        if ([self networkCheck]){
            int index = [selected.attributes indexOfObject:@"picURL"];
            if (NSNotFound != index) {
                NSString *urlStr = [selected.attributeVals objectAtIndex:index];
                if(urlStr != NULL) {
                    NSURL *imageURL = [[NSURL alloc] initWithString:urlStr];
                    // Fetch the image
                    selected.profilePic = [UIImage imageWithData: [NSData dataWithContentsOfURL:imageURL]];
                }
            }
        }
        else {
            // Network Check Failed - Show Alert
            [self performSelectorOnMainThread:@selector(showNoNetworkAlert)
                                   withObject:nil
                                waitUntilDone:YES];
            return;
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
    return self.searchDetails.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Register the NIB cell object for our custom cell
    [tableView registerNib:[UINib nibWithNibName:@"ResultsCell" bundle:nil] forCellReuseIdentifier:self.cellIdentifier];
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
	}
    
    // Connect the cell's properties
    UILabel *nameLbl = (UILabel *)[cell viewWithTag:1002];
    UILabel *statusLbl = (UILabel *)[cell viewWithTag:1003];
    UILabel *usernameLbl = (UILabel *)[cell viewWithTag:1004];
    UILabel *majorLbl = (UILabel *)[cell viewWithTag:1005];
    UILabel *classLbl = (UILabel *)[cell viewWithTag:1006];
    
    Person *tempPerson = [[Person alloc] init];
    tempPerson = [self.searchDetails objectAtIndex:indexPath.row];
    
    NSString *first = tempPerson.firstName;
    NSString *last = tempPerson.lastName;
    NSString *status = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Status"]];
    NSString *username = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Username"]];
    
    if ([status isEqualToString:@"Student"]) {
        NSString *year = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Class"]];
        NSString *major = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Major"]];
        majorLbl.text = major;
        classLbl.text = year;
        statusLbl.text = status;
    }
    else if ([status isEqualToString:@"Faculty / Staff"]) {
        NSString *dept = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Department"]];
        NSString *title = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Title"]];
        majorLbl.text = title;
        classLbl.text = dept;
        statusLbl.text = @"Fac/Staff";
    }
    else {
        int index = [tempPerson.attributes indexOfObject:@"Title"];
        if (NSNotFound != index) {
            NSString *title = [tempPerson.attributeVals objectAtIndex:index];
            majorLbl.text = title;
            classLbl.text = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Department"]];
        }
        else {
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

@end
