import UIKit

class GADTextFieldTableViewCell: GADFieldTableViewCell {
  @IBOutlet weak var textField: GADFieldTextField!
  var field: GADDirectoryField! {
    didSet {
      textField.text = field.textValue
      textField.placeholder = field.placeholderText
    }
  }
}
