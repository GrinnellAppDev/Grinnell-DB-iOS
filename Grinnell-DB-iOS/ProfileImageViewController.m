//
//  ProfileImageViewController.m
//  Grinnell-DB-iOS
//
//  Created by Colin Tremblay on 10/18/13.
//  Copyright (c) 2013 AppDev. All rights reserved.
//

#import "ProfileImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ProfileImageViewController ()

@end

@implementation ProfileImageViewController

@synthesize profPicView, picURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [profPicView setImageWithURL:picURL placeholderImage:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
