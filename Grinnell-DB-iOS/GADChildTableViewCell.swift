import UIKit

class GADChildTableViewCell: GADFieldTableViewCell {
  @IBOutlet weak var label: UILabel!

  var option: String! {
    didSet {
      label.text = option
    }
  }
  
}
