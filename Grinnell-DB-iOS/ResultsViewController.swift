import UIKit


extension ResultsViewController: UIViewControllerPreviewingDelegate {

  public func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
  self.navigationController!.pushViewController(viewControllerToCommit, animated: true)
    //navigationController?.presentViewController(viewControllerToCommit, animated: true, completion: nil)
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
      let person = searchDetails.objectAtIndex(indexPath.row) as! Person
      let index = person.attributes?.indexOfObject("profileURL")
      if let index = index where person.attributeVals.count == 0 {
        parseProfilePage(person.attributeVals!.objectAtIndex(index) as! String, forPerson: person)
      }
      let controller = ProfileViewController()
      controller.selectedPerson = person
      return controller
    }
    return nil
  }
}
