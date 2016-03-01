import UIKit

class GADSelectionTableViewCell: GADFieldTableViewCell {

  override func drawRect(rect: CGRect) {
    super.drawRect(rect)
    addDropShadow()
  }

  func addDropShadow() {
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOffset = CGSizeMake(0, 3)
    layer.shadowOpacity = 0.5
    layer.shadowRadius = 4
  }
}
