import XCTest

class GADIconTest: XCTestCase {
  func test29pt() {
    let onex = UIImage(named: "AppIcon29x29")
    let twox = UIImage(named: "AppIcon29x29@2x")
    let threex = UIImage(named: "AppIcon29x29@3x")
    XCTAssertNotNil(onex)
    XCTAssertNotNil(twox)
    XCTAssertNotNil(threex)
  }

  func test40pt() {
    let onex = UIImage(named: "AppIcon40x40")
    let twox = UIImage(named: "AppIcon40x40@2x")
    let threex = UIImage(named: "AppIcon40x40@3x")
    XCTAssertNotNil(onex)
    XCTAssertNotNil(twox)
    XCTAssertNotNil(threex)
  }

  func test57pt() {
    let onex = UIImage(named: "AppIcon57x57")
    let twox = UIImage(named: "AppIcon57x57@2x")
    XCTAssertNotNil(onex)
    XCTAssertNotNil(twox)
  }

  func test60pt() {
    let twox = UIImage(named: "AppIcon60x60@2x")
    let threex = UIImage(named: "AppIcon60x60@3x")
    XCTAssertNotNil(twox)
    XCTAssertNotNil(threex)
  }

  func test76pt() {
    let onex = UIImage(named: "AppIcon76x76~ipad")
    let twox = UIImage(named: "AppIcon76x76@2x")
    XCTAssertNotNil(onex)
    XCTAssertNotNil(twox)
  }

  func test83_5pt() {
    let twox = UIImage(named: "AppIcon83_5x83_5@2x")
    XCTAssertNotNil(twox)
  }
}
