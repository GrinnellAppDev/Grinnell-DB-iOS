import UIKit

class GADDirectoryField: NSObject {
  var textValue : String
  var placeholderText : String
  var shouldAutocomplete : Bool
  var shouldCapitalize : Bool
  var keyboardType : UIKeyboardType

  init(placeholderText: String, textValue: String = "", shouldAutocomplete: Bool = false, shouldCapitalize: Bool = true, keyboardType: UIKeyboardType = .ASCIICapable) {
    self.placeholderText = placeholderText
    self.textValue = textValue
    self.shouldAutocomplete = shouldAutocomplete
    self.shouldCapitalize = shouldCapitalize
    self.keyboardType = keyboardType
  }
}
