import GADDirectory
import UIKit

class FormViewController: BADFormViewController {
  @IBOutlet weak var tableView: UITableView!
  var properties = GADDirectory.availableProperties()
}



/// MARK: TableView Delegates

extension FormViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return properties.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    if tableView == self.tableView {
      let cell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! GADTextFieldTableViewCell
      cell.property = properties[indexPath.row]
      return cell
    }

    return UITableViewCell()
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if tableView == self.tableView {
      let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! GADFieldTableViewCell
      cell.tap()
      if let cell = cell as? GADSelectionTableViewCell {
        cell
      }

    }
  }
}

  extension FormViewController: UITableViewDelegate {
    
}