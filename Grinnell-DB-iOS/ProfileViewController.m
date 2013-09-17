//
//  ProfileViewController.m
//  Grinnell-DB-iOS
//
//  Created by Colin Tremblay on 9/12/13.
//  Copyright (c) 2013 AppDev. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize selectedPerson, cellIdentifier;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cellIdentifier = @"ProfileCell";
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    // Create table's header view and add name/picture as subviews
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(120, 40, 200, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont boldSystemFontOfSize:18];
    NSString *name = [NSString stringWithFormat:@"%@ %@", self.selectedPerson.firstName, self.selectedPerson.lastName];
    label.text = name;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 90, 90)];
    imageView.image = self.selectedPerson.profilePic;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    [view addSubview:imageView];
    [view addSubview:label];
    self.tableView.tableHeaderView = view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Repress status and picURL from tableView
    return self.selectedPerson.attributes.count - 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Register the NIB cell object for our custom cell
    [tableView registerNib:[UINib nibWithNibName:@"ProfileCell" bundle:nil] forCellReuseIdentifier:self.cellIdentifier];
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
	}
    
    // Configure the cell...
    cell.textLabel.text = [self.selectedPerson.attributeVals objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [self.selectedPerson.attributes objectAtIndex:indexPath.row];
    
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"] && [cell.detailTextLabel.text isEqualToString:@"Campus Phone"]){
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if ([cell.detailTextLabel.text isEqualToString:@"Username"]){
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section && [[self.selectedPerson.attributes objectAtIndex:indexPath.row] isEqualToString:@"Username"]){
        if([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
            mailViewController.mailComposeDelegate = self;
            
            mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
            NSString *recipient = [self.selectedPerson.attributeVals objectAtIndex:indexPath.row];
            recipient = [recipient stringByAppendingString:@"@grinnell.edu"];
            [mailViewController setToRecipients:[NSArray arrayWithObject:recipient]];
            [self presentModalViewController:mailViewController animated:YES];
        }
    }
    else if (0 == indexPath.section && [[self.selectedPerson.attributes objectAtIndex:indexPath.row] isEqualToString:@"Campus Phone"]){
        NSString *phoneNum = [self.selectedPerson.attributeVals objectAtIndex:indexPath.row];
        NSString *url = @"telprompt://";
        if (phoneNum.length >= 10)
            url = [url stringByAppendingString:phoneNum];
        else if (phoneNum.length >= 7)
             url = [url stringByAppendingString:[NSString stringWithFormat:@"telprompt://641-%@", phoneNum]];
        else
            url = [url stringByAppendingString:[NSString stringWithFormat:@"telprompt://641-269-%@", phoneNum]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}

@end
