import GADDirectory
import UIKit

class GADTextFieldTableViewCell: GADFieldTableViewCell {
  @IBOutlet weak var textField: UITextField!
  var property: GADDirectoryPersonStringProperty! {
    didSet {
      textField.text = property.textValue
      textField.placeholder = property.friendlyText
      textField.autocorrectionType = property.autocorrectionType
      textField.autocapitalizationType =  property.autocapitalizationType
    }
  }

  override func tap(tableView: UITableView, indexPath: NSIndexPath) {
    textField.becomeFirstResponder()
  }
}
