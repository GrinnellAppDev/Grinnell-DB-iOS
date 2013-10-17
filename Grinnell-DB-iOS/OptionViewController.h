//
//  OptionViewController.h
//  Grinnell-DB-iOS
//
//  Created by Colin Tremblay on 10/16/13.
//  Copyright (c) 2013 AppDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionViewController : UIViewController

@property (nonatomic, assign) BOOL state;
@property (nonatomic, assign) BOOL first;
@property (nonatomic, weak) IBOutlet UISwitch *mySwitch;
@property (nonatomic, weak) IBOutlet UILabel *offLabel;
@property (nonatomic, weak) IBOutlet UILabel *onLabel;

@end
