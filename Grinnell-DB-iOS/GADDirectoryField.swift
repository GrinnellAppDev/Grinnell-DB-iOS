import UIKit

class GADDirectoryField: NSObject {
  var textValue : String
  var placeholderText : String
  var autocorrectionType : UITextAutocorrectionType
  var autocapitalizationType : UITextAutocapitalizationType
  var keyboardType : UIKeyboardType

  init(placeholderText: String, textValue: String = "", autocorrectionType: UITextAutocorrectionType = .No, autocapitalizationType: UITextAutocapitalizationType = .Words, keyboardType: UIKeyboardType = .ASCIICapable) {
    self.placeholderText = placeholderText
    self.textValue = textValue
    self.autocorrectionType = autocorrectionType
    self.autocapitalizationType = autocapitalizationType
    self.keyboardType = keyboardType
  }
}
