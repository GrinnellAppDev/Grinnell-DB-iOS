import UIKit

class GADFieldTableViewCell: UITableViewCell {
  @IBOutlet weak var checkmarkView: UIImageView!

  var checked = false {
    didSet {
      checkmarkView.hidden = !checked
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    initializeCheckmark()
    // Initialization code
  }

  func initializeCheckmark() {
    var image = checkmarkView.image
    image = image!.imageWithRenderingMode(.AlwaysTemplate)
  }

}
