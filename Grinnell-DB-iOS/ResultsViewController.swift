import UIKit

public class ResultsViewController: BADResultsViewController {
  override public func viewDidLoad() {
    super.viewDidLoad()
    /*
    if ([self.traitCollection
    respondsToSelector:@selector(forceTouchCapability)] &&
    (self.traitCollection.forceTouchCapability ==
    UIForceTouchCapabilityAvailable)) {
    [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
    */
  }
}


extension ResultsViewController: UIViewControllerPreviewingDelegate {

  public func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
    if let viewControllerToCommit = viewControllerToCommit as? ProfileViewController {
      self.navigationController!.pushViewController(viewControllerToCommit, animated: true)
    }
  }

  public func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
    let indexPath = tableView.indexPathForRowAtPoint(location)

    if let indexPath = indexPath {
      let cell = tableView.cellForRowAtIndexPath(indexPath)
      if let cell = cell {
        if #available(iOS 9.0, *) {
          previewingContext.sourceRect = cell.frame
        }
      }
      let controller = ProfileViewController()
      controller.selectedPerson = self.personForIndexPath(indexPath)
      return controller
    }
    return nil
  }
}
