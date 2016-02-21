#import "AppDelegate.h"
#import "FormViewController.h"
#import <Crashlytics/Crashlytics.h>
#import <Fabric/Fabric.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Fabric with:@[[Crashlytics self]]];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // Clears app on exit
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissImage" object:nil];
    UINavigationController *navC = (UINavigationController *)self.window.rootViewController;
    [navC popToRootViewControllerAnimated:NO];
    FormViewController *formVC = (FormViewController *)[navC.childViewControllers objectAtIndex:0];
    [formVC clear:self];
}

@end
