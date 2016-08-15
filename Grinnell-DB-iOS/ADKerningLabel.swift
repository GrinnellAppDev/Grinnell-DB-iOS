import UIKit
@IBDesignable
class ADKerningLabel: UILabel {
  @IBInspectable var kerning:CGFloat = 0.0 {
    didSet {
      if var attributedText = attributedText {
        let attributedString = NSMutableAttributedString(attributedString: attributedText)
        attributedString.addAttributes([NSKernAttributeName:kerning], range: NSMakeRange(0, attributedText.length))
        attributedText = attributedString
      }
    }
  }
}
