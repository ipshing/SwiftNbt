//
//  CompoundTests.swift
//  SwiftNbtTests
//
//  Created by ipshing on 3/18/21.
//

import XCTest
@testable import SwiftNbt

class CompoundTests: XCTestCase {
    static var allTests = [
        ("testInitializingCompoundFromCollection", testInitializingCompoundFromCollection),
        ("testGettersAndSetters", testGettersAndSetters),
        ("testRenaming", testRenaming),
        ("testAddingAndRemoving", testAddingAndRemoving),
        ("testUtilityMethods", testUtilityMethods)
    ]
    
    func testInitializingCompoundFromCollection() throws {
        let allNamed: [NbtTag] = [
            NbtShort(name: "allNamed1", 1),
            NbtLong(name: "allNamed2", 2),
            NbtInt(name: "allNamed3", 3)
        ]
        
        let someUnnamed: [NbtTag] = [
            NbtInt(name: "someUnnamed", 1),
            NbtInt(2),
            NbtInt(name: "someUnnamed", 3)
        ]
        
        let dupeNames: [NbtTag] = [
            NbtInt(name: "dupeNames1", 1),
            NbtInt(name: "dupeNames2", 2),
            NbtInt(name: "dupeNames1", 3)
        ]
        
        var allNamedTest = NbtCompound()
        XCTAssertNoThrow(allNamedTest = try NbtCompound(name: "allNamedTest", allNamed))
        // Need a way to compare collections...
        // Test if allNamed == allNamedTest
        
        XCTAssertThrowsError(try NbtCompound(name: "someUnnamedTest", someUnnamed)) { error in
            XCTAssertEqual(error as? NbtError, NbtError.argumentError("Only named tags are allowed in Compound tags."))
        }
        XCTAssertThrowsError(try NbtCompound(name: "dupeNamesTest", dupeNames)) { error in
            XCTAssertEqual(error as? NbtError, NbtError.argumentError("A tag with the same name has already been added."))
        }
    }

    func testGettersAndSetters() throws {
        // construct a compound for testing
        let nestedChild = NbtCompound(name: "NestedChild")
        var nestedInt = NbtInt(1)
        let nestedChildList = try NbtList(name: "NestedChildList", [nestedInt])
        let child = try NbtCompound(name: "Child", [
            nestedChild,
            nestedChildList
        ])
        let childList = try NbtList(name: "ChildList", [NbtInt(1)])
        let parent = try NbtCompound(name: "Parent", [
            child,
            childList
        ])
        
        // Accessing nested compound tags using indexers
        XCTAssertEqual(nestedChild, (parent["Child"] as! NbtCompound)["NestedChild"])
        XCTAssertEqual(nestedChildList, (parent["Child"] as! NbtCompound)["NestedChildList"])
        XCTAssertEqual(nestedInt, ((parent["Child"] as! NbtCompound)["NestedChildList"] as! NbtList)[0])
        
        // Accessing nested compound tags using get
        XCTAssertNil(parent.get("NonExistingChild"))
        XCTAssertNil(parent.get("NonExistingChild") as? NbtCompound)
        XCTAssertEqual(nestedChild, (parent.get("Child") as? NbtCompound)?.get("NestedChild"))
        XCTAssertEqual(nestedChild, (parent.get("Child") as? NbtCompound)?.get("NestedChild") as? NbtCompound)
        XCTAssertEqual(nestedChildList, (parent.get("Child") as? NbtCompound)?.get("NestedChildList"))
        XCTAssertEqual(nestedChildList, (parent.get("Child") as? NbtCompound)?.get("NestedChildList") as? NbtList)
        XCTAssertEqual(nestedInt, ((parent.get("Child") as? NbtCompound)?.get("NestedChildList") as? NbtList)?[0])

        // Accessing get with an invalid given type
        XCTAssertNil(parent.get("Child") as? NbtInt)
        
        // Using get<T>
        var dummyTag: NbtTag?
        XCTAssertFalse(parent.get("NonExistingChild", result: &dummyTag))
        XCTAssertNil(dummyTag)
        XCTAssertTrue(parent.get("Child", result: &dummyTag))
        XCTAssertEqual(dummyTag, child)
        
        var dummyCompoundTag: NbtCompound?
        XCTAssertFalse(parent.get("NonExistingChild", result: &dummyCompoundTag))
        XCTAssertNil(dummyCompoundTag)
        XCTAssertTrue(parent.get("ChildList", result: &dummyCompoundTag))
        XCTAssertNil(dummyCompoundTag)
        XCTAssertTrue(parent.get("Child", result: &dummyCompoundTag))
        XCTAssertEqual(dummyCompoundTag, child)
        
        //
        // TODO: Enable these when Swift support throwing from subscripts
        //
        // Use integer indexers on non-NbtList tags
        //XCTAssertThrowsError(parent[0] = nestedInt)
        //XCTAssertThrowsError(nestedInt[0] = nestedInt)
        
        // Use string indexers on non-NbtCompound tags
        //XCTAssertThrowsError(childList["test"] = nestedInt)
        //XCTAssertThrowsError(nestedInt["test"] = nestedInt)
        
        // Get a non-existing element by name
        XCTAssertNil(parent.get("NonExistingTag"))
        XCTAssertNil(parent["NonExistingTag"])
        
        //
        // TODO: Enable these when Swift support throwing from subscripts
        //
        // Out-of-range indices on NbtList
        //XCTAssertThrowsError(nestedInt = childList[-1] as! NbtInt)
        //XCTAssertThrowsError(childList[-1] = NbtInt(1))
        XCTAssertThrowsError(nestedInt = try childList.get(at: -1) as! NbtInt)
        //XCTAssertThrowsError(nestedInt = try childList[childList.count] as! NbtInt)
        XCTAssertThrowsError(nestedInt = try childList.get(at: childList.count) as! NbtInt)
        
        // Using setter correctly
        XCTAssertNoThrow(parent["NewChild"] = NbtByte(name: "NewChild"))
        
        // Using setter incorrectly
        //XCTAssertThrowsError(parent["Child"] = nil)
        //XCTAssertNotNil(parent["Child"])
        //XCTAssertThrowsError(parent["Child"] = NbtByte(name: "NotChild"))
        
        // Try adding tag to self
        let selfTest = NbtCompound(name: "SelfTest")
        //XCTAssertThrowsError(selfTest["SelfTest"] = selfTest)
        
        // Try adding a tag that already has a parent
        //XCTAssertThrowsError(selfTest[child.name!] = child)
    }
    
    func testRenaming() throws {
        let tagToRename = NbtInt(name: "DifferentName", 1)
        let compound = try NbtCompound([
            NbtInt(name: "SameName", 1),
            tagToRename
        ])
        
        // Proper renaming, should not throw
        XCTAssertNoThrow(tagToRename.name = "SomeOtherName")
        
        // Attempting to use a duplicate name
        //XCTAssertThrowsError(tagToRename.name = "SameName")
        
        // Assigning a nil name to a tag inside a compound; should throw
        //XCTAssertThrowsError(tagToRename.name = nil)
        
        // Assigning a nil name to a tag that's been removed; should not throw
        _ = try compound.remove(tagToRename)
        XCTAssertNoThrow(tagToRename.name = nil)
    }
    
    func testAddingAndRemoving() throws {
        let foo = NbtInt(name: "Foo")
        let test = try NbtCompound([
            foo
        ])
        
        // Add duplicate object
        XCTAssertThrowsError(try test.append(foo))
        
        // Add duplicate name
        XCTAssertThrowsError(try test.append(NbtByte(name: "Foo")))
        
        // Add unnamed tag
        XCTAssertThrowsError(try test.append(NbtInt()))
        
        // Add tag to self
        XCTAssertThrowsError(try test.append(test))
        
        // Contains existing name/object
        XCTAssertTrue(test.contains("Foo"))
        XCTAssertTrue(try test.contains(foo))
        
        // Contains a non-existent name
        XCTAssertFalse(test.contains("Bar"))
        
        // Contains existing name/different objects
        XCTAssertFalse(try test.contains(NbtInt(name: "Foo")))
        
        // Remove non-/existing name
        XCTAssertFalse(test.remove(forKey: "Bar"))
        XCTAssertTrue(test.remove(forKey: "Foo"))
        XCTAssertFalse(test.remove(forKey: "Bar"))
        
        // Re-add object
        XCTAssertNoThrow(try test.append(foo))
        
        // Remove existing object
        XCTAssertTrue(try test.remove(foo))
        XCTAssertFalse(try test.remove(foo))
        
        // Clear empty NbtCompound
        XCTAssertEqual(0, test.count)
        test.removeAll()
        
        // Re-add after clearing
        XCTAssertNoThrow(try test.append(foo))
        XCTAssertEqual(1, test.count)
        
        // Clear non-empty NbtCompound
        test.removeAll()
        XCTAssertEqual(0, test.count)
    }
    
    func testUtilityMethods() throws {
        let testThings: [NbtTag] = [
            NbtShort(name: "Name1", 1),
            NbtInt(name: "Name2", 2),
            NbtLong(name: "Name3", 3)
        ]
        let compound = NbtCompound()
        
        // Add range
        XCTAssertNoThrow(try compound.append(contentsOf: testThings))
        
        // Add range with duplicates
        XCTAssertThrowsError(try compound.append(contentsOf: testThings))
    }
}
