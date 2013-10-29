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

- (void)viewDidLoad {
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.splitViewController.delegate = self;
    }
    if (onCampusBool)
        cellIdentifier = @"OnCResultsCell";
    else
        cellIdentifier = @"OffCResultsCell";
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
    if (onCampusBool)
        [tableView registerNib:[UINib nibWithNibName:@"OnCResultsCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    else
        [tableView registerNib:[UINib nibWithNibName:@"OffCResultsCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
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
    int index = [tempPerson.attributes indexOfObject:@"picURL"];
    if (NSNotFound != index){
        NSString *userImageString = [tempPerson.attributeVals objectAtIndex:index];
        userImageView.contentMode = UIViewContentModeScaleAspectFit;
        [userImageView setImageWithURL:[NSURL URLWithString:userImageString] placeholderImage:nil];
    }
    
    if ([status isEqualToString:@"Student"]) {
        NSString *year = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Class"]];
        NSString *major = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Major"]];
        majorLbl.text = major;
        classLbl.text = year;
        statusLbl.text = status;
    }
    else if ([status isEqualToString:@"Faculty / Staff"]) {
        NSString *dept = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Department"]];
        
        NSMutableArray *titleArray = [[NSMutableArray alloc] init];
        int index = [tempPerson.attributes indexOfObject:@"Title"];
        while ([@"Title" isEqualToString:[tempPerson.attributes objectAtIndex:index]]) {
            NSString *title = [tempPerson.attributeVals objectAtIndex:index];
            [titleArray addObject:title];
            index++;
        }
        NSString *compositeTitle = [titleArray objectAtIndex:0];
        
        for (int i = 1; i < titleArray.count; i++)
          compositeTitle = [compositeTitle stringByAppendingString:[NSString stringWithFormat:@"/%@", [titleArray objectAtIndex:i]]];
        
        compositeTitle = [compositeTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        majorLbl.text = compositeTitle;
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

- (BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}
@end
