//
//  ShortcutTests.swift
//  SwiftNbtTests
//
//  Created by ipshing on 3/23/21.
//

import XCTest
@testable import SwiftNbt

class ShortcutTests: XCTestCase {
    static var allTests = [
        ("testNbtByte", testNbtByte),
        ("testNbtShort", testNbtShort),
        ("testNbtInt", testNbtInt),
        ("testNbtLong", testNbtLong),
        ("testNbtFloat", testNbtFloat),
        ("testNbtDouble", testNbtDouble),
        ("testNbtString", testNbtString),
        ("testNbtByteArray", testNbtByteArray),
        ("testNbtIntArray", testNbtIntArray),
        ("testNbtLongArray", testNbtLongArray),
        ("testNbtCompound", testNbtCompound),
        ("testNbtList", testNbtList)
    ]

    func testNbtByte() throws {
        //
        // Can't currently test for invalid cast because properties can't throw errors
        //
        //var dummy: Any?
        let test: NbtTag = NbtByte(250)
        XCTAssertEqual(250, test.byteValue)
        XCTAssertEqual(250, test.shortValue)
        XCTAssertEqual(250, test.intValue)
        XCTAssertEqual(250, test.longValue)
        XCTAssertEqual(250, test.floatValue)
        XCTAssertEqual(250, test.doubleValue)
        XCTAssertEqual("250", test.stringValue)
        //XCTAssertThrowsError(dummy = test.byteArrayValue)
        //XCTAssertThrowsError(dummy = test.intArrayValue)
        //XCTAssertThrowsError(dummy = test.longArrayValue)
        XCTAssertTrue(test.hasValue)
    }

    func testNbtShort() throws {
        //
        // Can't currently test for invalid cast because properties can't throw errors
        //
        //var dummy: Any?
        let test: NbtTag = NbtShort(32767)
        //XCTAssertThrowsError(dummy = test.byteValue)
        XCTAssertEqual(32767, test.shortValue)
        XCTAssertEqual(32767, test.intValue)
        XCTAssertEqual(32767, test.longValue)
        XCTAssertEqual(32767, test.floatValue)
        XCTAssertEqual(32767, test.doubleValue)
        XCTAssertEqual("32767", test.stringValue)
        //XCTAssertThrowsError(dummy = test.byteArrayValue)
        //XCTAssertThrowsError(dummy = test.intArrayValue)
        //XCTAssertThrowsError(dummy = test.longArrayValue)
        XCTAssertTrue(test.hasValue)
    }

    func testNbtInt() throws {
        //
        // Can't currently test for invalid cast because properties can't throw errors
        //
        //var dummy: Any?
        let test: NbtTag = NbtInt(2147483647)
        //XCTAssertThrowsError(dummy = test.byteValue)
        //XCTAssertThrowsError(dummy = test.shortValue)
        XCTAssertEqual(2147483647, test.intValue)
        XCTAssertEqual(2147483647, test.longValue)
        XCTAssertEqual(2147483647, test.floatValue)
        XCTAssertEqual(2147483647, test.doubleValue)
        XCTAssertEqual("2147483647", test.stringValue)
        //XCTAssertThrowsError(dummy = test.byteArrayValue)
        //XCTAssertThrowsError(dummy = test.intArrayValue)
        //XCTAssertThrowsError(dummy = test.longArrayValue)
        XCTAssertTrue(test.hasValue)
    }

    func testNbtLong() throws {
        //
        // Can't currently test for invalid cast because properties can't throw errors
        //
        //var dummy: Any?
        let test: NbtTag = NbtLong(9223372036854775807)
        //XCTAssertThrowsError(dummy = test.byteValue)
        //XCTAssertThrowsError(dummy = test.shortValue)
        //XCTAssertThrowsError(dummy = test.intValue)
        XCTAssertEqual(9223372036854775807, test.longValue)
        XCTAssertEqual(Float(9223372036854775807), test.floatValue)
        XCTAssertEqual(Double(9223372036854775807), test.doubleValue)
        XCTAssertEqual("9223372036854775807", test.stringValue)
        //XCTAssertThrowsError(dummy = test.byteArrayValue)
        //XCTAssertThrowsError(dummy = test.intArrayValue)
        //XCTAssertThrowsError(dummy = test.longArrayValue)
        XCTAssertTrue(test.hasValue)
    }

    func testNbtFloat() throws {
        //
        // Can't currently test for invalid cast because properties can't throw errors
        //
        //var dummy: Any?
        let test: NbtTag = NbtFloat(0.49823147)
        //XCTAssertThrowsError(dummy = test.byteValue)
        //XCTAssertThrowsError(dummy = test.shortValue)
        //XCTAssertThrowsError(dummy = test.intValue)
        //XCTAssertThrowsError(dummy = test.longValue)
        XCTAssertEqual(0.49823147, test.floatValue)
        XCTAssertEqual(0.49823147, test.doubleValue)
        XCTAssertEqual("0.49823147", test.stringValue)
        //XCTAssertThrowsError(dummy = test.byteArrayValue)
        //XCTAssertThrowsError(dummy = test.intArrayValue)
        //XCTAssertThrowsError(dummy = test.longArrayValue)
        XCTAssertTrue(test.hasValue)
    }

    func testNbtDouble() throws {
        //
        // Can't currently test for invalid cast because properties can't throw errors
        //
        //var dummy: Any?
        let test: NbtTag = NbtDouble(0.4931287132182315)
        //XCTAssertThrowsError(dummy = test.byteValue)
        //XCTAssertThrowsError(dummy = test.shortValue)
        //XCTAssertThrowsError(dummy = test.intValue)
        //XCTAssertThrowsError(dummy = test.longValue)
        XCTAssertEqual(Float(0.4931287132182315), test.floatValue)
        XCTAssertEqual(0.4931287132182315, test.doubleValue)
        XCTAssertEqual("0.4931287132182315", test.stringValue)
        //XCTAssertThrowsError(dummy = test.byteArrayValue)
        //XCTAssertThrowsError(dummy = test.intArrayValue)
        //XCTAssertThrowsError(dummy = test.longArrayValue)
        XCTAssertTrue(test.hasValue)
    }

    func testNbtString() throws {
        //
        // Can't currently test for invalid cast because properties can't throw errors
        //
        //var dummy: Any?
        let test: NbtTag = NbtString("HELLO WORLD THIS IS A TEST STRING ÅÄÖ!")
        //XCTAssertThrowsError(dummy = test.byteValue)
        //XCTAssertThrowsError(dummy = test.shortValue)
        //XCTAssertThrowsError(dummy = test.intValue)
        //XCTAssertThrowsError(dummy = test.longValue)
        //XCTAssertThrowsError(dummy = test.floatValue)
        //XCTAssertThrowsError(dummy = test.doubleValue)
        XCTAssertEqual("HELLO WORLD THIS IS A TEST STRING ÅÄÖ!", test.stringValue)
        //XCTAssertThrowsError(dummy = test.byteArrayValue)
        //XCTAssertThrowsError(dummy = test.intArrayValue)
        //XCTAssertThrowsError(dummy = test.longArrayValue)
        XCTAssertTrue(test.hasValue)
    }

    func testNbtByteArray() throws {
        //
        // Can't currently test for invalid cast because properties can't throw errors
        //
        //var dummy: Any?
        let bytes: [UInt8] = [1, 2, 3, 4, 5]
        let test: NbtTag = NbtByteArray(bytes)
        //XCTAssertThrowsError(dummy = test.byteValue)
        //XCTAssertThrowsError(dummy = test.shortValue)
        //XCTAssertThrowsError(dummy = test.intValue)
        //XCTAssertThrowsError(dummy = test.longValue)
        //XCTAssertThrowsError(dummy = test.floatValue)
        //XCTAssertThrowsError(dummy = test.doubleValue)
        //XCTAssertThrowsError(dummy = test.stringValue)
        XCTAssertEqual(bytes, test.byteArrayValue)
        //XCTAssertThrowsError(dummy = test.intArrayValue)
        //XCTAssertThrowsError(dummy = test.longArrayValue)
        XCTAssertTrue(test.hasValue)
    }

    func testNbtIntArray() throws {
        //
        // Can't currently test for invalid cast because properties can't throw errors
        //
        //var dummy: Any?
        let ints: [Int32] = [1111, 2222, 3333, 4444, 5555]
        let test: NbtTag = NbtIntArray(ints)
        //XCTAssertThrowsError(dummy = test.byteValue)
        //XCTAssertThrowsError(dummy = test.shortValue)
        //XCTAssertThrowsError(dummy = test.intValue)
        //XCTAssertThrowsError(dummy = test.longValue)
        //XCTAssertThrowsError(dummy = test.floatValue)
        //XCTAssertThrowsError(dummy = test.doubleValue)
        //XCTAssertThrowsError(dummy = test.stringValue)
        //XCTAssertThrowsError(dummy = test.byteArrayValue)
        XCTAssertEqual(ints, test.intArrayValue)
        //XCTAssertThrowsError(dummy = test.longArrayValue)
        XCTAssertTrue(test.hasValue)
    }

    func testNbtLongArray() throws {
        //
        // Can't currently test for invalid cast because properties can't throw errors
        //
        //var dummy: Any?
        let longs: [Int64] = [11111111111, 22222222222, 33333333333, 44444444444, 55555555555]
        let test: NbtTag = NbtLongArray(longs)
        //XCTAssertThrowsError(dummy = test.byteValue)
        //XCTAssertThrowsError(dummy = test.shortValue)
        //XCTAssertThrowsError(dummy = test.intValue)
        //XCTAssertThrowsError(dummy = test.longValue)
        //XCTAssertThrowsError(dummy = test.floatValue)
        //XCTAssertThrowsError(dummy = test.doubleValue)
        //XCTAssertThrowsError(dummy = test.stringValue)
        //XCTAssertThrowsError(dummy = test.byteArrayValue)
        //XCTAssertThrowsError(dummy = test.intArrayValue)
        XCTAssertEqual(longs, test.longArrayValue)
        XCTAssertTrue(test.hasValue)
    }

    func testNbtCompound() throws {
        //
        // Can't currently test for invalid cast because properties can't throw errors
        //
        //var dummy: Any?
        let test: NbtTag = NbtCompound(name: "Derp")
        //XCTAssertThrowsError(dummy = test.byteValue)
        //XCTAssertThrowsError(dummy = test.shortValue)
        //XCTAssertThrowsError(dummy = test.intValue)
        //XCTAssertThrowsError(dummy = test.longValue)
        //XCTAssertThrowsError(dummy = test.floatValue)
        //XCTAssertThrowsError(dummy = test.doubleValue)
        //XCTAssertThrowsError(dummy = test.stringValue)
        //XCTAssertThrowsError(dummy = test.byteArrayValue)
        //XCTAssertThrowsError(dummy = test.intArrayValue)
        //XCTAssertThrowsError(dummy = test.longArrayValue)
        XCTAssertFalse(test.hasValue)
    }

    func testNbtList() throws {
        //
        // Can't currently test for invalid cast because properties can't throw errors
        //
        //var dummy: Any?
        let test: NbtTag = NbtList(name: "Derp")
        //XCTAssertThrowsError(dummy = test.byteValue)
        //XCTAssertThrowsError(dummy = test.shortValue)
        //XCTAssertThrowsError(dummy = test.intValue)
        //XCTAssertThrowsError(dummy = test.longValue)
        //XCTAssertThrowsError(dummy = test.floatValue)
        //XCTAssertThrowsError(dummy = test.doubleValue)
        //XCTAssertThrowsError(dummy = test.stringValue)
        //XCTAssertThrowsError(dummy = test.byteArrayValue)
        //XCTAssertThrowsError(dummy = test.intArrayValue)
        //XCTAssertThrowsError(dummy = test.longArrayValue)
        XCTAssertFalse(test.hasValue)
    }

}
