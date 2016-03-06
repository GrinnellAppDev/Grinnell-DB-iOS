import UIKit

public class GADDirectoryPersonStringProperty: GADDirectoryPersonProperty {
  public var textValue : String
  public var placeholderText : String
  public var autocorrectionType : UITextAutocorrectionType
  public var autocapitalizationType : UITextAutocapitalizationType
  public var keyboardType : UIKeyboardType

  public init(placeholderText: String, textValue: String = "", autocorrectionType: UITextAutocorrectionType = .No, autocapitalizationType: UITextAutocapitalizationType = .Words, keyboardType: UIKeyboardType = .ASCIICapable) {
    self.placeholderText = placeholderText
    self.textValue = textValue
    self.autocorrectionType = autocorrectionType
    self.autocapitalizationType = autocapitalizationType
    self.keyboardType = keyboardType
    super.init(type: .String)
  }
}
