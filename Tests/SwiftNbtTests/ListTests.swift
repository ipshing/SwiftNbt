//
//  ListTests.swift
//  SwiftNbtTests
//
//  Created by ipshing on 3/18/21.
//

import XCTest
@testable import SwiftNbt

class ListTests: XCTestCase {
    static var allTests = [
        ("testSubscripts", testSubscripts),
        ("testInitializingListFromCollection", testInitializingListFromCollection),
        ("testManipulatingList", testManipulatingList),
        ("testChangingListType", testChangingListType),
        ("testSerializingWithoutListType", testSerializingWithoutListType),
        ("testSerializing", testSerializing),
        ("testSerializingEmpty", testSerializingEmpty),
        ("testNestedListAndCompound", testNestedListAndCompound),
        ("testFirstInsert", testFirstInsert)
    ]

    func testSubscripts() throws {
        //
        // TODO: Implement tests once subscripts can throw errors
        //
    }
    
    func testInitializingListFromCollection() throws {
        // Auto-detect list type
        let test1 = try NbtList(name: "Test1", [
            NbtInt(1),
            NbtInt(2),
            NbtInt(3)
        ])
        XCTAssertEqual(NbtTagType.int, test1.listType)
        
        // Correct explicitly-given list type
        XCTAssertNoThrow(try NbtList(name: "Test2", [
            NbtInt(1),
            NbtInt(2),
            NbtInt(3)
        ], listType: .int))
        
        // Wrong explicitly-given list type
        XCTAssertThrowsError(try NbtList(name: "Test3", [
            NbtInt(1),
            NbtInt(2),
            NbtInt(3)
        ], listType: .float))
        
        // Auto-detecting mixed list
        XCTAssertThrowsError(try NbtList(name: "Test4", [
            NbtFloat(1),
            NbtByte(2),
            NbtInt(3)
        ]))
        
        // Using append with range
        XCTAssertNoThrow(try NbtList().append(contentsOf: [
            NbtInt(1),
            NbtInt(2),
            NbtInt(3)
        ]))
    }
    
    func testManipulatingList() throws {
        let sameTags: [NbtTag] = [
            NbtInt(0),
            NbtInt(1),
            NbtInt(2)
        ]
        
        let list = try NbtList(name: "Test1", sameTags)
        
        // Test enumerator, indexer, contains, indexOf
        var j = 0
        for tag in list {
            XCTAssertTrue(list.contains(sameTags[j]))
            XCTAssertEqual(sameTags[j], tag)
            XCTAssertEqual(j, list.firstIndex(of: tag))
            j += 1
        }
        
        // Adding an item of correct type
        XCTAssertNoThrow(try list.append(NbtInt(3)))
        XCTAssertNoThrow(try list.insert(NbtInt(4), at: 3))
        
        // Adding an item of wrong type
        XCTAssertThrowsError(try list.append(NbtString()))
        XCTAssertThrowsError(try list.insert(NbtString(), at: 3))
        
        // Test array contents
        for i in 0..<sameTags.count {
            XCTAssertEqual(sameTags[i], list[i])
            XCTAssertEqual(i, Int((list[i] as! NbtInt).value))
        }
        
        // Test removal
        XCTAssertFalse(list.remove(NbtInt(5)))
        XCTAssertTrue(list.remove(sameTags[0]))
        XCTAssertNoThrow(try list.remove(at: 0))
        XCTAssertThrowsError(try list.remove(at: 10))
        
        // Test some failure scenarios for Add:
        // Add list to itself
        let loopList = NbtList()
        XCTAssertEqual(NbtTagType.unknown, loopList.listType)
        XCTAssertThrowsError(try loopList.append(loopList))
        
        // Add same tag to multiple lists
        XCTAssertThrowsError(try loopList.append(list[0]))
        XCTAssertThrowsError(try loopList.insert(list[0], at: 0))
        
        // Make sure that all those failed adds didn't affect the tag
        XCTAssertEqual(0, loopList.count)
        XCTAssertEqual(NbtTagType.unknown, loopList.listType)
    }
    
    func testChangingListType() throws {
        let list = NbtList()
                
        // Failing to add or insert a tag should not change teh list type
        XCTAssertThrowsError(try list.insert(NbtInt(), at: -1))
        XCTAssertThrowsError(try list.append(NbtInt(name: "namedTagWhereUnnamedIsExpected")))
        XCTAssertEqual(NbtTagType.unknown, list.listType)
        
        // Changing the type of an empty list to .end is allowed
        XCTAssertNoThrow(try list.setListType(.end))
        XCTAssertEqual(list.listType, NbtTagType.end)
        
        // Changing the type of an empty list to .unknown is allowed
        XCTAssertNoThrow(try list.setListType(.unknown))
        XCTAssertEqual(list.listType, NbtTagType.unknown)
        
        // Adding the first element should set the tag type
        XCTAssertNoThrow(try list.append(NbtInt()))
        XCTAssertEqual(list.listType, NbtTagType.int)
        
        // Setting correct type for a non-empty list
        XCTAssertNoThrow(try list.setListType(.int))
        
        // Changing list type to incorrect type
        XCTAssertThrowsError(try list.setListType(.short))
        
        // After list is cleared, change the tag type
        list.removeAll()
        XCTAssertNoThrow(try list.setListType(.short))
    }
    
    func testSerializingWithoutListType() throws {
        let root = try NbtCompound(name: "root", [
            NbtList(name: "List")
        ])
        let file = try NbtFile(rootTag: root)
        var buffer = Data()
        XCTAssertThrowsError(try file.save(to: &buffer, compression: .none))
    }
    
    func testSerializing() throws {
        let expectedListType = NbtTagType.int
        let elements = 10
        
        // Construct NBT File
        let writtenFile = try NbtFile(rootTag: NbtCompound(name: "ListTypeTest"))
        let writtenList = try NbtList(name: "Entities", listType: expectedListType)
        for i in 0..<elements {
            try writtenList.append(NbtInt(Int32(i)))
        }
        try writtenFile.rootTag.append(writtenList)
        
        // Test saving
        var buffer = Data()
        var bytesWritten = try writtenFile.save(to: &buffer, compression: .none)
        XCTAssertEqual(bytesWritten, buffer.count)
        
        // Test loading
        let readFile = NbtFile()
        var bytesRead = try readFile.load(contentsOf: buffer, compression: .none)
        XCTAssertEqual(bytesRead, buffer.count)
        
        // Check contents of loaded file
        XCTAssert(readFile.rootTag["Entities"] is NbtList)
        let readList = readFile.rootTag["Entities"] as! NbtList
        XCTAssertEqual(writtenList.listType, readList.listType)
        XCTAssertEqual(writtenList.count, readList.count)
        
        // Check contents of loaded list
        for i in 0..<elements {
            try XCTAssertEqual((readList.get(at: i) as! NbtInt).value, (writtenList.get(at: i) as! NbtInt).value)
        }
        
        // Check saving/loading lists of all possible value types
        let testFile = try NbtFile(rootTag: TestData.makeTestList())
        bytesWritten = try testFile.save(to: &buffer, compression: .none)
        bytesRead = try testFile.load(contentsOf: buffer, compression: .none)
        XCTAssertEqual(bytesRead, buffer.count)
    }
    
    func testSerializingEmpty() throws {
        // Check saving/loading lists of empty lists
        let testFile = try NbtFile(rootTag: NbtCompound(name: "root", [
            NbtList(name: "emptyList", listType: .end),
            NbtList(name: "listyList", [
                NbtList(listType: .end)
            ], listType: .list)
        ]))
        var buffer = Data()
        _ = try testFile.save(to: &buffer, compression: .none)
        
        let list1 = testFile.rootTag.get("emptyList") as! NbtList
        XCTAssertEqual(list1.count, 0)
        XCTAssertEqual(list1.listType, NbtTagType.end)
        
        let list2 = testFile.rootTag.get("listyList") as! NbtList
        XCTAssertEqual(list2.count, 1)
        XCTAssertEqual(list2.listType, NbtTagType.list)
        XCTAssertEqual((try list2.get(at: 0) as? NbtList)?.count, 0)
        XCTAssertEqual((try list2.get(at: 0) as? NbtList)?.listType, NbtTagType.end)
    }
    
    func testNestedListAndCompound() throws {
        var buffer = Data()
        
        let root = NbtCompound(name: "Root")
        let outerList = try NbtList(name: "OuterList", listType: .compound)
        let outerCompound = NbtCompound()
        let innerList = try NbtList(name: "InnerList", listType: .compound)
        let innerCompound = NbtCompound()
        
        try innerList.append(innerCompound)
        try outerCompound.append(innerList)
        try outerList.append(outerCompound)
        try root.append(outerList)
        
        var file = try NbtFile(rootTag: root)
        _ = try file.save(to: &buffer, compression: .none)
        
        file = NbtFile()
        let bytesRead = try file.load(contentsOf: buffer, compression: .none)
        XCTAssertEqual(bytesRead, buffer.count)
        XCTAssertEqual(1, (file.rootTag.get("OuterList") as? NbtList)?.count)
        try XCTAssertEqual(nil, ((file.rootTag.get("OuterList") as? NbtList)?.get(at: 0) as? NbtCompound)?.name)
        try XCTAssertEqual(1, (((file.rootTag
                                    .get("OuterList") as? NbtList)?
                                    .get(at: 0) as? NbtCompound)?
                                    .get("InnerList") as? NbtList)?
                                    .count)
        try XCTAssertEqual(nil, ((((file.rootTag
                                    .get("OuterList") as? NbtList)?
                                    .get(at: 0) as? NbtCompound)?
                                    .get("InnerList") as? NbtList)?
                                    .get(at: 0) as? NbtCompound)?
                                    .name)
        
    }
    
    func testFirstInsert() throws {
        let list = NbtList()
        XCTAssertEqual(NbtTagType.unknown, list.listType)
        XCTAssertNoThrow(try list.insert(NbtInt(123), at: 0))
        // Inserting a tag should set ListType
        XCTAssertEqual(NbtTagType.int, list.listType)
    }
}
