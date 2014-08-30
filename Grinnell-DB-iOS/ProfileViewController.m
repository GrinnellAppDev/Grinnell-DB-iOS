//
//  ProfileViewController.m
//  Grinnell-DB-iOS
//
//  Created by Colin Tremblay on 9/12/13.
//  Copyright (c) 2013 AppDev. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

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
    cellIdentifier = @"ProfileCell";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissImage) name:@"DismissImage" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Create table's header view and add name/picture as subviews
    UILabel *label = [[UILabel alloc] init];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    
    // Get image (from the cache) if it's there
    NSUInteger index = [selectedPerson.attributes indexOfObject:@"picURL"];
    if (NSNotFound != index) {
        label.frame = CGRectMake(100, 35, 210, 40);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 90, 90)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        NSString *userImageString = [selectedPerson.attributeVals objectAtIndex:index];
        [imageView sd_setImageWithURL:[NSURL URLWithString:userImageString] placeholderImage:nil];
        UITapGestureRecognizer *imageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
        
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:imageTapGesture];
        [view addSubview:imageView];
    } else {
        label.frame = CGRectMake(20, 35, 280, 40);
    }
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.adjustsFontSizeToFitWidth = YES;
    NSString *name = [NSString stringWithFormat:@"%@ %@", selectedPerson.firstName, selectedPerson.lastName];
    label.text = name;
    
    [view addSubview:label];
    self.tableView.tableHeaderView = view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Repress status and picURL from tableView
    int sub = 0;
    if (NSNotFound != [selectedPerson.attributes indexOfObject:@"picURL"]) {
        sub++;
    }
    if (NSNotFound != [selectedPerson.attributes indexOfObject:@"Status"]) {
        sub++;
    }
    if (NSNotFound != [selectedPerson.attributes indexOfObject:@"profileURL"]) {
        sub++;
    }
    return selectedPerson.attributes.count - sub;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Register the NIB cell object for our custom cell
    [tableView registerNib:[UINib nibWithNibName:@"ProfileCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [selectedPerson.attributeVals objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [selectedPerson.attributes objectAtIndex:indexPath.row];
    
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"] && [cell.detailTextLabel.text isEqualToString:@"Campus Phone"]) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if ([cell.detailTextLabel.text isEqualToString:@"Username"]) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section && [[selectedPerson.attributes objectAtIndex:indexPath.row] isEqualToString:@"Username"]) {
        if([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
            mailViewController.mailComposeDelegate = self;
            
            mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
            NSString *recipient = [selectedPerson.attributeVals objectAtIndex:indexPath.row];
            recipient = [recipient stringByAppendingString:@"@grinnell.edu"];
            [mailViewController setToRecipients:[NSArray arrayWithObject:recipient]];
            [self presentViewController:mailViewController animated:YES completion:nil];
        }
    } else if (0 == indexPath.section && ([[selectedPerson.attributes objectAtIndex:indexPath.row] isEqualToString:@"Campus Phone"] || [[selectedPerson.attributes objectAtIndex:indexPath.row] isEqualToString:@"Home Phone"])) {
        NSString *phoneNum = [selectedPerson.attributeVals objectAtIndex:indexPath.row];
        NSString *url = @"telprompt://";
        if (phoneNum.length >= 10) {
            url = [url stringByAppendingString:phoneNum];
        } else if (phoneNum.length >= 7) {
            url = [url stringByAppendingString:[NSString stringWithFormat:@"641-%@", phoneNum]];
        } else {
            url = [url stringByAppendingString:[NSString stringWithFormat:@"641-269-%@", phoneNum]];
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Mail controller
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - image view expansion
- (void)imageTapped:(id)sender {
    ProfileImageViewController *controller = [[ProfileImageViewController alloc] initWithNibName:@"ProfileImageViewController" bundle:nil];
    popoverController = [[WYPopoverController alloc] initWithContentViewController:controller];
    popoverController.delegate = self;
    [popoverController setPopoverContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    NSUInteger index = [selectedPerson.attributes indexOfObject:@"picURL"];
    NSString *userImageString = [selectedPerson.attributeVals objectAtIndex:index];
    controller.picURL = [NSURL URLWithString:userImageString];
    [popoverController presentPopoverFromRect:self.tableView.tableHeaderView.frame inView:self.view permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
}

- (void)dismissImage {
    [popoverController dismissPopoverAnimated:NO];
}

@end
