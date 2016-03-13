import UIKit

public class GADDirectoryPersonSelectionProperty: GADDirectoryPersonProperty {
  public let display: String
  public let options: [String]

  public init(display: String, options: [String]) {
    self.options = options
    self.display = display
    super.init(type: .Selection)
  }

}
