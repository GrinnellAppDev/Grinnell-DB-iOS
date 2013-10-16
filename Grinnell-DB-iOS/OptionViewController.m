//
//  OptionViewController.m
//  Grinnell-DB-iOS
//
//  Created by Colin Tremblay on 10/16/13.
//  Copyright (c) 2013 AppDev. All rights reserved.
//

#import "OptionViewController.h"

@interface OptionViewController ()

@end

@implementation OptionViewController
@synthesize mySwitch, state, onLabel, offLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (state) {
        offLabel.text = @"Search by Full Address";
        onLabel.text = @"Search by State only";
    }
    else {
        offLabel.text = @"Search for name that begins with";
        onLabel.text = @"Search for name containing";
    }
    [mySwitch addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)valueChange:(id)sender {
    NSLog(@"HERE");
}

@end
