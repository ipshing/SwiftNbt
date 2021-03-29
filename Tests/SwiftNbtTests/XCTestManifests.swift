import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CompoundTests.allTests),
        testCase(ListTests.allTests),
        testCase(NbtFileTests.allTests),
        testCase(NbtReaderTests.allTests),
        testcase(NbtWriterTests.allTests),
        testCase(ShortcutTests.allTests),
        testCase(SkipTagTests.allTests)
    ]
}
#endif
