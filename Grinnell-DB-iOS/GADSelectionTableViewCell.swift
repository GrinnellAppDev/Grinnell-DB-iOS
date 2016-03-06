import UIKit

class GADSelectionTableViewCell: GADFieldTableViewCell {
  var children = [GADChildTableViewCell]()
  var expanded = false

  override func drawRect(rect: CGRect) {
    super.drawRect(rect)
    initializeDropShadow()
  }

  override func tap() {
    if expanded {
      removeDropShadow()
      expanded = false
    } else {
      addDropShadow()
      expanded = true
    }
  }

  /// MARK: Cell Drop Shadow

  func initializeDropShadow() {
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOffset = CGSizeMake(0, 3)
    layer.shadowOpacity = 0
    layer.shadowRadius = 4
  }

  func addDropShadow() {
    layer.shadowOpacity = 0.5
  }

  func removeDropShadow() {
    layer.shadowOpacity = 0
  }
}
