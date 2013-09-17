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
    
    for (int i = 0; i < tempPerson.attributes.count; i++)
        NSLog(@"%@", [tempPerson.attributes objectAtIndex:i]);
    NSLog(@"done with that person\n");

    
    NSString *first = tempPerson.firstName;
    NSString *last = tempPerson.lastName;
    NSLog(@"%d", [tempPerson.attributes indexOfObject:@"Status"]);
    NSString *status = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Status"]];
    NSString *username = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Username"]];
    NSString *year = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Class"]];
    NSString *major = [tempPerson.attributeVals objectAtIndex:[tempPerson.attributes indexOfObject:@"Major"]];
    
    
    nameLbl.text = [NSString stringWithFormat:@"%@, %@", last, first];
    statusLbl.text = status;
    usernameLbl.text = username;
    majorLbl.text = major;
    classLbl.text = year;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"PushToProfile" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushToProfile"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ProfileViewController *destViewController = segue.destinationViewController;
        
        destViewController.selectedPerson = [self.searchDetails objectAtIndex:indexPath.row];
    }
}

@end
