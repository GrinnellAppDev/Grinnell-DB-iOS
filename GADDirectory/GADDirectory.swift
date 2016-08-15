import Foundation

public class GADDirectory: NSObject {
  public class func availableProperties() -> [GADDirectoryPersonProperty] {
    return defaultProperties()
  }
}

extension GADDirectory {
  public class func defaultProperties() -> [GADDirectoryPersonProperty] {
    let firstName = GADDirectoryPersonStringProperty(friendlyText: "First Name",
                                   autocorrectionType: .No,
                               autocapitalizationType: .Words,
                                         keyboardType: .ASCIICapable)

    let lastName = GADDirectoryPersonStringProperty(friendlyText: "Last Name",
                                   autocorrectionType: .No,
                               autocapitalizationType: .Words,
                                         keyboardType: .ASCIICapable)

    let classYear = GADDirectoryPersonSelectionProperty(friendlyText: "Class Year", options: ["2016", "2017", "2018", "2019"])

    return [firstName, lastName, classYear]
  }
}
