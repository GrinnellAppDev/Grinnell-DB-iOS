import UIKit

class FormViewController: BADFormViewController {
  @IBOutlet weak var tableView: UITableView!
  var fields = [GADDirectoryField]()

  override func viewDidLoad() {
    let field = GADDirectoryField(placeholderText: "First Name")
    fields.append(field)
  }


}



/// MARK: TableView Delegates

extension FormViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fields.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    if tableView == self.tableView {
      let cell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! GADTextFieldTableViewCell
      cell.field = fields[indexPath.row]
      return cell
    }

    return UITableViewCell()
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if tableView == self.tableView {
      let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! GADFieldTableViewCell
      cell.tap()
    }
  }
}

  extension FormViewController: UITableViewDelegate {
    
}