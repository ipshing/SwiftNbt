//
//  NbtFileTests.swift
//  SwiftNbtTests
//
//  Created by ipshing on 3/16/21.
//

import XCTest
import Foundation
@testable import SwiftNbt

class NbtFileTests: XCTestCase {
    static var allTests = [
        ("testLoadingSmallFileUncompressed", testLoadingSmallFileUncompressed),
        ("testLoadingSmallFileGZip", testLoadingSmallFileGZip),
        ("testLoadingSmallFileZLib", testLoadingSmallFileZLib),
        ("testLoadingBigFileUncompressed", testLoadingBigFileUncompressed),
        ("testLoadingBigFileGZip", testLoadingBigFileGZip),
        ("testLoadingBigFileZLib", testLoadingBigFileZLib),
        ("testLoadingBigFileBuffer", testLoadingBigFileBuffer),
        ("testSavingNbtSmallFileUncompressed", testSavingNbtSmallFileUncompressed),
        ("testReloadFile", testReloadFile),
        ("testSaveToBuffer", testSaveToBuffer),
        ("testToString", testToString),
        ("testHugeNbt", testHugeNbt),
        ("testRootTag", testRootTag)
    ]

    let testDirName = "NbtFileTests"
    var testDir: URL?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    
        let bundle = Bundle(for: Self.self)
        testDir = bundle.resourceURL!.appendingPathComponent(testDirName, isDirectory: true)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: testDir!.path){
            try fileManager.createDirectory(at: testDir!, withIntermediateDirectories: true, attributes: nil)
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        if testDir != nil {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: testDir!.path) {
                try fileManager.removeItem(at: testDir!)
            }
        }
    }
    
    func testLoadingSmallFileUncompressed() throws {
        let url = try TestData.getFileUrl(file: .small, compression: .none)
        let file = try NbtFile(contentsOf: url)
        XCTAssertNotNil(file.fileName)
        XCTAssertEqual(url.path, file.fileName!)
        XCTAssertEqual(NbtCompression.none, file.fileCompression)
        try TestData.assertNbtSmallFile(file)
    }
    
    func testLoadingSmallFileGZip() throws {
        let url = try TestData.getFileUrl(file: .small, compression: .gZip)
        let file = try NbtFile(contentsOf: url)
        XCTAssertNotNil(file.fileName)
        XCTAssertEqual(url.path, file.fileName!)
        XCTAssertEqual(NbtCompression.gZip, file.fileCompression)
        try TestData.assertNbtSmallFile(file)
    }
    
    func testLoadingSmallFileZLib() throws {
        let url = try TestData.getFileUrl(file: .small, compression: .zLib)
        let file = try NbtFile(contentsOf: url)
        XCTAssertNotNil(file.fileName)
        XCTAssertEqual(url.path, file.fileName!)
        XCTAssertEqual(NbtCompression.zLib, file.fileCompression)
        try TestData.assertNbtSmallFile(file)
    }
    
    func testLoadingBigFileUncompressed() throws {
        let file = NbtFile()
        let length = try file.load(contentsOf: TestData.getFileUrl(file: .big, compression: .none), compression: .autoDetect)
        try TestData.assertNbtBigFile(file)
        XCTAssertEqual(length, 1783)
    }
    
    func testLoadingBigFileGZip() throws {
        let file = NbtFile()
        let length = try file.load(contentsOf: TestData.getFileUrl(file: .big, compression: .gZip), compression: .autoDetect)
        try TestData.assertNbtBigFile(file)
        XCTAssertEqual(length, 1783)
    }
    
    func testLoadingBigFileZLib() throws {
        let file = NbtFile()
        let length = try file.load(contentsOf: TestData.getFileUrl(file: .big, compression: .zLib), compression: .autoDetect)
        try TestData.assertNbtBigFile(file)
        XCTAssertEqual(length, 1783)
    }
    
    func testLoadingBigFileBuffer() throws {
        let file = NbtFile()
        let url = try TestData.getFileUrl(file: .big, compression: .none)
        let data = try Data(contentsOf: url)
        let length = try file.load(contentsOf: data, compression: .autoDetect)
        try TestData.assertNbtBigFile(file)
        XCTAssertEqual(length, 1783)
    }

    func testSavingNbtSmallFileUncompressed() throws {
        let file = try TestData.makeSmallFile()
        let fileUrl = testDir!.appendingPathComponent("test.nbt")
        let length = try file.save(to: fileUrl, compression: .none)
        let attr = try FileManager.default.attributesOfItem(atPath: fileUrl.path)
        let fileSize = attr[FileAttributeKey.size] as! Int
        
        XCTAssertEqual(length, fileSize)
    }
    
    func testReloadFile() throws {
        try reloadFileInteral(.big, .none, .none, true)
        try reloadFileInteral(.big, .gZip, .none, true)
        try reloadFileInteral(.big, .zLib, .none, true)
        try reloadFileInteral(.big, .none, .none, false)
        try reloadFileInteral(.big, .gZip, .none, false)
        try reloadFileInteral(.big, .zLib, .none, false)
    }
    
    func reloadFileInteral(_ file: TestFile, _ loadCompression: NbtCompression, _ saveCompression: NbtCompression, _ bigEndian: Bool) throws {
        let loadedFile = try NbtFile(contentsOf: TestData.getFileUrl(file: file, compression: loadCompression))
        loadedFile.bigEndian = bigEndian
        let fileName = TestData.getFileName(file: file, compression: saveCompression)
        let bytesWritten = try loadedFile.save(to: testDir!.appendingPathComponent(fileName), compression: saveCompression)
        let bytesRead = try loadedFile.load(contentsOf: testDir!.appendingPathComponent(fileName), compression: .autoDetect)
        
        XCTAssertEqual(bytesWritten, bytesRead)
        try TestData.assertNbtBigFile(loadedFile)
    }
    
    func testSaveToBuffer() throws {
        var file = try TestData.makeBigFile()
        var buffer = Data()
        var length = try file.save(to: &buffer, compression: .none)
        XCTAssertEqual(length, TestData.getFileSize(file: .big))
        
        file = try TestData.makeSmallFile()
        length = try file.save(to: &buffer, compression: .none)
        XCTAssertEqual(length, TestData.getFileSize(file: .small))
    }
    
    func testToString() throws {
        let file = try NbtFile(contentsOf: TestData.getFileUrl(file: .big, compression: .none))
        XCTAssertEqual(file.rootTag.description, file.description)
        XCTAssertEqual(file.rootTag.toString(indentString: "   "), file.toString(indentString: "   "))
    }
    
    func testHugeNbt() throws {
        let val = [UInt8](repeating: 0, count: 5 * 1024 * 1024)
        let root = try NbtCompound(name: "root", [
            NbtByteArray(name: "payload1", val)
        ])
        let file = try NbtFile(rootTag: root)
        var buffer = Data()
        _ = try file.save(to: &buffer, compression: .none)
    }
    
    func testRootTag() throws {
        let oldRoot = NbtCompound(name: "defaultRoot")
        let newFile = try NbtFile(rootTag: oldRoot)
        XCTAssertThrowsError(try newFile.setRootTag(NbtCompound())) { error in
            XCTAssertEqual(error as! NbtError, NbtError.argumentError("Root tag must be named."))
        }
        
        // Ensure that the root has not changed
        XCTAssert(oldRoot === newFile.rootTag)
        
        // Invalid the root tag, and ensure that expected exception is thrown
        oldRoot.name = nil
        var buffer = Data()
        XCTAssertThrowsError(try newFile.save(to: &buffer, compression: .none)) { error in
            XCTAssertEqual(error as? NbtError, NbtError.invalidFormat("Cannot save NbtFile: root tag is not named. Its name may be an empty string, but not nil."))
        }
    }
}
