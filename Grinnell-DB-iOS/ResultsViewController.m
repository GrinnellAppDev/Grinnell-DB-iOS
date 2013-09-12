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
    return 4;
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
    UILabel *name = (UILabel *)[cell viewWithTag:1002];
    UILabel *status = (UILabel *)[cell viewWithTag:1003];
    UILabel *username = (UILabel *)[cell viewWithTag:1004];
    UILabel *major = (UILabel *)[cell viewWithTag:1005];
    UILabel *class = (UILabel *)[cell viewWithTag:1006];
    
    name.text = @"Last, First";
    status.text = @"Student";
    username.text = @"usernameYY";
    major.text = @"Major1/ Major2";
    class.text = @"YEAR";
    
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
        
        Person *person1 = [[Person alloc] init];
        person1.name = @"Colin Tremblay";
        person1.attributes = [[NSMutableArray alloc] initWithObjects:@"Major", @"Class", @"Username", @"Box Number", @"Campus Phone", @"Campus Address", @"Home Address", nil];
        person1.attributeVals = [[NSMutableArray alloc] initWithObjects:@"Computer Science", @"2014", @"username", @"4650", @"425-495-6425", @"1120 Broad St", @"11610 NE 97th LN, Kirkland, WA, 98033", nil];
        NSMutableArray *people = [[NSMutableArray alloc] initWithObjects:person1, nil];
        
        destViewController.selectedPerson = [people objectAtIndex:indexPath.row];
    }
}

@end