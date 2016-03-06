import GADDirectory
import UIKit

class GADTextFieldTableViewCell: GADFieldTableViewCell {
  @IBOutlet weak var textField: UITextField!
  var property: GADDirectoryPersonStringProperty! {
    didSet {
      textField.text = property.textValue
      textField.placeholder = property.placeholderText
      textField.autocapitalizationType =  property.autocapitalizationType
    }
  }

  override func tap() {
    textField.becomeFirstResponder()
  }
}
