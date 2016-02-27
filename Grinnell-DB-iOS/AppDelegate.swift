import Fabric
import Crashlytics
import UIKit

public class AppDelegate: UIResponder, UIApplicationDelegate {
  public var window: UIWindow?

  public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
    Fabric.with([Crashlytics.self])
    return true
  }

  public func applicationWillResignActive(application: UIApplication) {
    if NSUserDefaults.standardUserDefaults().boolForKey("clearOnExit") {
      reset(application)
    }
  }

  func reset(application: UIApplication) {
    NSNotificationCenter.defaultCenter().postNotificationName("DismissImage", object: nil)
    let window = application.delegate?.window!
    let navigationVC = window!.rootViewController as! UINavigationController
    navigationVC.popToRootViewControllerAnimated(false)
    let form = navigationVC.childViewControllers.first as! FormViewController
    form.clear()
  }
}
