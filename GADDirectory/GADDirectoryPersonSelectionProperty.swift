/**
 * A property of a person which is a 'one of n' type selection
 */
public class GADDirectoryPersonSelectionProperty: GADDirectoryPersonProperty {
  public let friendlyText: String
  public let options: [String]

  public init(friendlyText: String, options: [String]) {
    self.options = options
    self.friendlyText = friendlyText
    super.init(type: .Selection)
  }

}
