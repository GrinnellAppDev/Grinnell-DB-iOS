import UIKit

class GADSelectionTableViewCell: GADFieldTableViewCell {
  @IBOutlet weak var displayLabel: UILabel!

  var children = [GADChildTableViewCell]()
  var expanded = false
  var property: GADDirectoryPersonSelectionProperty! {
    didSet {
      displayLabel.text = property.display
    }
  }
  
  override func drawRect(rect: CGRect) {
    super.drawRect(rect)
    initializeDropShadow()
  }

  override func tap(tableView: UITableView, indexPath: NSIndexPath) {
    if expanded {
      var indexPathsToRemove = [NSIndexPath]()
      for (var i = 1; i <= property.options.count; i++) {
        let indexPath = NSIndexPath(forRow: i, inSection: indexPath.section)
        indexPathsToRemove.append(indexPath)
      }

      tableView.beginUpdates()
      tableView.deleteRowsAtIndexPaths(indexPathsToRemove, withRowAnimation: .Bottom)
      expanded = false
      tableView.endUpdates()

      removeDropShadow()
    } else {
      addDropShadow()
      var indexPathsToAdd = [NSIndexPath]()
      for (var i = 1; i <= property.options.count; i++) {
        let indexPath = NSIndexPath(forRow: i, inSection: indexPath.section)
        indexPathsToAdd.append(indexPath)
      }

      tableView.beginUpdates()
      tableView.insertRowsAtIndexPaths(indexPathsToAdd, withRowAnimation: .Top)
      expanded = true
      tableView.endUpdates()
    }
  }

  /// MARK: Cell Drop Shadow

  func initializeDropShadow() {
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOffset = CGSizeMake(0, 3)
    layer.shadowOpacity = 0
    layer.shadowRadius = 4
  }

  func addDropShadow() {
    layer.shadowOpacity = 0.5
  }

  func removeDropShadow() {
    layer.shadowOpacity = 0
  }
}
