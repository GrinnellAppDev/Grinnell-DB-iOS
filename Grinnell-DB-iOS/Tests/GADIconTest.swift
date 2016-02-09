import XCTest
/**
    GADIconTest ensures that the application has all the required and recommended icon sizes for iOS
      7+.
*/
class GADIconTest: XCTestCase {
  /**
      Check 29pt @1x, @2x, and @3x
  */
  func test29pt() {
    let onex = UIImage(named: "AppIcon29x29")
    let twox = UIImage(named: "AppIcon29x29@2x")
    let threex = UIImage(named: "AppIcon29x29@3x")
    XCTAssertNotNil(onex)
    XCTAssertNotNil(twox)
    XCTAssertNotNil(threex)
  }
  /**
      Check 40pt @1x, @2x, and @3x
  */
  func test40pt() {
    let onex = UIImage(named: "AppIcon40x40")
    let twox = UIImage(named: "AppIcon40x40@2x")
    let threex = UIImage(named: "AppIcon40x40@3x")
    XCTAssertNotNil(onex)
    XCTAssertNotNil(twox)
    XCTAssertNotNil(threex)
  }

  // TODO: Functional Test for 57pt @1x and @2x

  /**
      Check 29pt @2x and @3x
  */
  func test60pt() {
    let twox = UIImage(named: "AppIcon60x60@2x")
    let threex = UIImage(named: "AppIcon60x60@3x")
    XCTAssertNotNil(twox)
    XCTAssertNotNil(threex)
  }

  // TODO: Functional Test for 76pt @1x and @2x

  // TODO: Functional Test for 83.5pt @2x

}
