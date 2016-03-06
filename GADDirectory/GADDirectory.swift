import Foundation

public class GADDirectory: NSObject {
  public class func availableProperties() -> [GADDirectoryPersonProperty] {
    return defaultProperties()
  }
}

extension GADDirectory {
  class func defaultProperties() -> [GADDirectoryPersonProperty] {
    let firstName = GADDirectoryPersonStringProperty(placeholderText: "First Name",
                                   autocorrectionType: .No,
                               autocapitalizationType: .Words,
                                         keyboardType: .ASCIICapable)

    let lastName = GADDirectoryPersonStringProperty(placeholderText: "Last Name",
                                   autocorrectionType: .No,
                               autocapitalizationType: .Words,
                                         keyboardType: .ASCIICapable)

    return [firstName, lastName]
  }
}
