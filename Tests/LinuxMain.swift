import XCTest

import SwiftNbtTests

var tests = [XCTestCaseEntry]()
tests += CompoundTests.allTests()
tests += ListTests.allTests()
tests += NbtFileTests.allTests()
tests += NbtReaderTests.allTests()
tests += NbtWriterTests.allTests()
tests += ShortcutTests.allTests()
tests += SkipTagTests.allTests()
XCTMain(tests)
