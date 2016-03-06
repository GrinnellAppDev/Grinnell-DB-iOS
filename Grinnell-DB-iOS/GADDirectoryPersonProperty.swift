import Foundation

public class GADDirectoryPersonProperty: NSObject {
  public let type: GADDirectoryPersonPropertyType

  init(type: GADDirectoryPersonPropertyType) {
    self.type = type
  }
}

public enum GADDirectoryPersonPropertyType {
  case String
  case Selection
}
