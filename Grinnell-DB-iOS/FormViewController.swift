import GADDirectory
import UIKit

class FormViewController: BADFormViewController {
  @IBOutlet weak var tableView: UITableView!
  var properties = GADDirectory.availableProperties()
  var expandedIndexPaths = [NSIndexPath : Bool]()
}

/// MARK: TableView Delegates

extension FormViewController: UITableViewDataSource {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return properties.count
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let rootCellIndexPath = NSIndexPath(forRow: 0, inSection: section)
    if let property = properties[section] as? GADDirectoryPersonSelectionProperty where expandedIndexPaths[rootCellIndexPath] == true {
        return property.options.count + 1
    } else {
      return 1
    }
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let property = properties[indexPath.section]

    switch property.type {
    case .Selection:
      return selectionCellForTableView(tableView, property: property, indexPath: indexPath)

    case .String:
      let cell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! GADTextFieldTableViewCell
      cell.property = property as! GADDirectoryPersonStringProperty
      return cell
    }
  }

  func selectionCellForTableView(tableView: UITableView, property: GADDirectoryPersonProperty, indexPath: NSIndexPath) -> GADFieldTableViewCell {
    if let property = property as? GADDirectoryPersonSelectionProperty {
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCellWithIdentifier("dropdownCell") as! GADSelectionTableViewCell
        cell.property = property
        return cell
      } else {
        let cell = tableView.dequeueReusableCellWithIdentifier("childCell") as! GADChildTableViewCell
        // indexPath includes the root node, so the position in this array will be one less than the
        //   indexPath.row
        cell.option = property.options[indexPath.row - 1]
        return cell
      }
    }
    return GADFieldTableViewCell()
  }

}

extension FormViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath) as! GADFieldTableViewCell
    expandedIndexPaths[indexPath] = expandedIndexPaths[indexPath] == true ? false : true
    cell.tap(tableView, indexPath: indexPath)
  }
}