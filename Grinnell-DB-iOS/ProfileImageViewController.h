//
//  ProfileImageViewController.h
//  Grinnell-DB-iOS
//
//  Created by Colin Tremblay on 10/18/13.
//  Copyright (c) 2013 AppDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileImageViewController : UIViewController


@property (nonatomic, weak) IBOutlet UIImageView *profPicView;
@property (nonatomic, strong) NSURL *picURL;
@end
