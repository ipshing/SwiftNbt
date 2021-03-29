//
//  TestData.swift
//  SwiftNbtTests
//
//  Created by ipshing on 3/16/21.
//

import Foundation
import XCTest
@testable import SwiftNbt

enum TestFile {
    case small
    case big
}

class TestData {
    
    static func makeSmallFile() throws -> NbtFile {
        return try NbtFile(
            rootTag: NbtCompound(name: "hello world", [
                NbtString(name: "name", "Bananarama")
            ])
        )
    }
    
    static func assertNbtSmallFile(_ file: NbtFile) throws {
        let root = file.rootTag
        XCTAssertEqual("hello world", root.name)
        XCTAssertEqual(1, root.count)
        
        XCTAssert(root["name"] is NbtString)
        
        let node = root["name"] as! NbtString
        XCTAssertEqual("name", node.name)
        XCTAssertEqual("Bananarama", node.value)
    }
    
    static func makeBigFile() throws -> NbtFile {
        let byteArrayName = "byteArrayTest (the first 1000 values of (n*n*255+n*7)%100, starting with n=0 (0, 62, 34, 16, 8, ...))"
        var byteArray: [UInt8] = []
        for n in 0..<1000 {
            byteArray.append(UInt8((n*n*255 + n*7)%100))
        }
        
        return try NbtFile(
            rootTag: NbtCompound(name: "Level", [
                NbtLong(name: "longTest", 9223372036854775807),
                NbtShort(name: "shortTest", 32767),
                NbtString(name: "stringTest", "HELLO WORLD THIS IS A TEST STRING ÅÄÖ!"),
                NbtFloat(name: "floatTest", 0.4982315),
                NbtInt(name: "intTest", 2147483647),
                NbtCompound(name: "nested compound test", [
                    NbtCompound(name: "ham", [
                        NbtString(name: "name", "Hampus"),
                        NbtFloat(name: "value", 0.75)
                    ]),
                    NbtCompound(name: "egg", [
                        NbtString(name: "name", "Eggbert"),
                        NbtFloat(name: "value", 0.5)
                    ])
                ]),
                NbtList(name: "listTest (long)", [
                    NbtLong(11),
                    NbtLong(12),
                    NbtLong(13),
                    NbtLong(14),
                    NbtLong(15)
                ]),
                NbtList(name: "listTest (compound)", [
                    NbtCompound([
                        NbtString(name: "name", "Compound tag #0"),
                        NbtLong(name: "created-on", 1264099775885)
                    ]),
                    NbtCompound([
                        NbtString(name: "name", "Compound tag #1"),
                        NbtLong(name: "created-on", 1264099775885)
                    ])
                ]),
                NbtByte(name: "byteTest", 127),
                NbtByteArray(name: byteArrayName, byteArray),
                NbtDouble(name: "doubleTest", 0.493128713218231),
                NbtIntArray(name: "intArrayTest", [ 2058486330, 689588807, 591140869, 1039519385, 1050801872, 1120424277, 436948408, 1022844073, 1164321124, 1667817685 ]),
                NbtLongArray(name: "longArrayTest", [ -6866598452151144177, -1461874943718568068, 5217825863610607223, 1860859988227119473, -5776759366968858117, -7740952930289281811, -6188853534200571741, 4318246429499846831, -47296042280759594, -3674987599896452234, -7226131946019043057, -4289962655585463703, -995980216626770396, -3604406255970428456, 5689530171199932158, 2743453607135376494, 9105486958483704041, -8207372937485762308, 5515722376825306945, -1410484250696471474 ])
            ])
        )
    }
    
    static func assertNbtBigFile(_ file: NbtFile)  throws {
        let root = file.rootTag
        XCTAssertEqual("Level", root.name)
        XCTAssertEqual(13, root.count)
        
        XCTAssert(root["longTest"] is NbtLong)
        var node = root["longTest"]!
        XCTAssertEqual("longTest", node.name)
        XCTAssertEqual(Int64(9223372036854775807), (node as! NbtLong).value)
        
        XCTAssert(root["shortTest"] is NbtShort)
        node = root["shortTest"]!
        XCTAssertEqual("shortTest", node.name)
        XCTAssertEqual(Int16(32767), (node as! NbtShort).value)
        
        XCTAssert(root["stringTest"] is NbtString)
        node = root["stringTest"]!
        XCTAssertEqual("stringTest", node.name)
        XCTAssertEqual("HELLO WORLD THIS IS A TEST STRING ÅÄÖ!", (node as! NbtString).value)
        
        XCTAssert(root["floatTest"] is NbtFloat)
        node = root["floatTest"]!
        XCTAssertEqual("floatTest", node.name)
        XCTAssertEqual(Float(0.4982315), (node as! NbtFloat).value)
        
        XCTAssert(root["intTest"] is NbtInt)
        node = root["intTest"]!
        XCTAssertEqual("intTest", node.name)
        XCTAssertEqual(Int32(2147483647), (node as! NbtInt).value)
        
        XCTAssert(root["nested compound test"] is NbtCompound)
        let compoundNode = root["nested compound test"] as! NbtCompound
        XCTAssertEqual("nested compound test", compoundNode.name)
        XCTAssertEqual(2, compoundNode.count)
        
        // First nested test
        XCTAssert(compoundNode["ham"] is NbtCompound)
        var subNode = compoundNode["ham"] as! NbtCompound
        XCTAssertEqual("ham", subNode.name)
        XCTAssertEqual(2, subNode.count)
        
        // Checking sub node values
        XCTAssert(subNode["name"] is NbtString)
        XCTAssertEqual("name", subNode["name"]!.name)
        XCTAssertEqual("Hampus", (subNode["name"] as! NbtString).value)
        
        XCTAssert(subNode["value"] is NbtFloat)
        XCTAssertEqual("value", subNode["value"]!.name)
        XCTAssertEqual(Float(0.75), (subNode["value"] as! NbtFloat).value)
        // End sub node
        
        // Second nested test
        XCTAssert(compoundNode["egg"] is NbtCompound)
        subNode = compoundNode["egg"] as! NbtCompound
        XCTAssertEqual("egg", subNode.name)
        XCTAssertEqual(2, subNode.count)
        
        // Checking sub node values
        XCTAssert(subNode["name"] is NbtString)
        XCTAssertEqual("name", subNode["name"]!.name)
        XCTAssertEqual("Eggbert", (subNode["name"] as! NbtString).value)
        
        XCTAssert(subNode["value"] is NbtFloat)
        XCTAssertEqual("value", subNode["value"]!.name)
        XCTAssertEqual(Float(0.5), (subNode["value"] as! NbtFloat).value)
        // End sub node
        
        XCTAssert(root["listTest (long)"] is NbtList)
        var listNode = root["listTest (long)"] as! NbtList
        XCTAssertEqual("listTest (long)", listNode.name)
        XCTAssertEqual(5, listNode.count)
        
        // The values should be: 11, 12, 13, 14, 15
        for i in 0..<listNode.count {
            XCTAssert(listNode[i] is NbtLong)
            XCTAssertEqual(nil, listNode[i].name)
            XCTAssertEqual(Int64(i + 11), (listNode[i] as! NbtLong).value)
        }
        
        XCTAssert(root["listTest (compound)"] is NbtList)
        listNode = root["listTest (compound)"] as! NbtList
        XCTAssertEqual("listTest (compound)", listNode.name)
        XCTAssertEqual(2, listNode.count)
        
        // First Sub Node
        XCTAssert(listNode[0] is NbtCompound)
        subNode = listNode[0] as! NbtCompound
        
        // First node in sub node
        XCTAssert(subNode["name"] is NbtString)
        XCTAssertEqual("name", subNode["name"]!.name)
        XCTAssertEqual("Compound tag #0", (subNode["name"] as! NbtString).value)
        
        // Second node in sub node
        XCTAssert(subNode["created-on"] is NbtLong)
        XCTAssertEqual("created-on", subNode["created-on"]!.name)
        XCTAssertEqual(1264099775885, (subNode["created-on"] as! NbtLong).value)
        
        // Second Sub Node
        XCTAssert(listNode[1] is NbtCompound)
        subNode = listNode[1] as! NbtCompound
        
        // First node in sub node
        XCTAssert(subNode["name"] is NbtString)
        XCTAssertEqual("name", subNode["name"]!.name)
        XCTAssertEqual("Compound tag #1", (subNode["name"] as! NbtString).value)
        
        // Second node in sub node
        XCTAssert(subNode["created-on"] is NbtLong)
        XCTAssertEqual("created-on", subNode["created-on"]!.name)
        XCTAssertEqual(1264099775885, (subNode["created-on"] as! NbtLong).value)
        
        XCTAssert(root["byteTest"] is NbtByte)
        node = root["byteTest"]!
        XCTAssertEqual("byteTest", node.name)
        XCTAssertEqual(UInt8(127), (node as! NbtByte).value)
        
        let byteArrayName = "byteArrayTest (the first 1000 values of (n*n*255+n*7)%100, starting with n=0 (0, 62, 34, 16, 8, ...))"
        XCTAssert(root[byteArrayName] is NbtByteArray)
        node = root[byteArrayName]!
        XCTAssertEqual(byteArrayName, node.name)
        XCTAssertEqual(1000, (node as! NbtByteArray).value.count)
        // Values are: the first 1000 values of (n*n*255+n*7)%100, starting with n=0 (0, 62, 34, 16, 8, ...)
        for n in 0..<1000 {
            XCTAssertEqual(UInt8((n*n*255 + n*7)%100), (node as! NbtByteArray)[n])
        }
        
        XCTAssert(root["doubleTest"] is NbtDouble)
        node = root["doubleTest"]!
        XCTAssertEqual("doubleTest", node.name)
        XCTAssertEqual(0.493128713218231, (node as! NbtDouble).value)
        
        XCTAssert(root["intArrayTest"] is NbtIntArray)
        let intArrayTag = root.get("intArrayTest") as! NbtIntArray
        XCTAssertNotNil(intArrayTag)
        let intArrayValues: [Int32] = [2058486330, 689588807, 591140869, 1039519385, 1050801872, 1120424277, 436948408, 1022844073, 1164321124, 1667817685]
        XCTAssertEqual(intArrayTag.value.count, intArrayValues.count)
        for i in 0..<intArrayValues.count {
            XCTAssertEqual(intArrayValues[i], intArrayTag.value[i])
        }
        
        XCTAssert(root["longArrayTest"] is NbtLongArray)
        let longArrayTag = root.get("longArrayTest") as! NbtLongArray
        XCTAssertNotNil(longArrayTag)
        let longArrayValues: [Int64] = [-6866598452151144177, -1461874943718568068, 5217825863610607223, 1860859988227119473, -5776759366968858117, -7740952930289281811, -6188853534200571741, 4318246429499846831, -47296042280759594, -3674987599896452234, -7226131946019043057, -4289962655585463703, -995980216626770396, -3604406255970428456, 5689530171199932158, 2743453607135376494, 9105486958483704041, -8207372937485762308, 5515722376825306945, -1410484250696471474]
        XCTAssertEqual(longArrayTag.value.count, longArrayValues.count)
        for i in 0..<longArrayValues.count {
            XCTAssertEqual(longArrayValues[i], longArrayTag.value[i])
        }
    }

    static func makeTestList() throws -> NbtCompound {
        return try NbtCompound(name: "Root", [
            NbtList(name: "ByteList", [
                NbtByte(100),
                NbtByte(20),
                NbtByte(3)
            ]),
            NbtList(name: "DoubleList", [
                NbtDouble(1),
                NbtDouble(2000),
                NbtDouble(-3000000)
            ]),
            NbtList(name: "FloatList", [
                NbtFloat(1),
                NbtFloat(2000),
                NbtFloat(-3000000)
            ]),
            NbtList(name: "IntList", [
                NbtInt(1),
                NbtInt(2000),
                NbtInt(-3000000)
            ]),
            NbtList(name: "LongList", [
                NbtLong(1),
                NbtLong(2000),
                NbtLong(-3000000)
            ]),
            NbtList(name: "ShortList", [
                NbtShort(1),
                NbtShort(200),
                NbtShort(-30000)
            ]),
            NbtList(name: "StringList", [
                NbtString("one"),
                NbtString("two thousand"),
                NbtString("negative three million")
            ]),
            NbtList(name: "CompoundList", [
                NbtCompound(),
                NbtCompound(),
                NbtCompound()
            ]),
            NbtList(name: "ListList", [
                NbtList(listType: .list),
                NbtList(listType: .list),
                NbtList(listType: .list)
            ]),
            NbtList(name: "ByteArrayList", [
                NbtByteArray([1, 2, 3]),
                NbtByteArray([11, 12, 13]),
                NbtByteArray([21, 22, 23])
            ]),
            NbtList(name: "IntArrayList", [
                NbtIntArray([1, -2, 3]),
                NbtIntArray([1000, -2000, 3000]),
                NbtIntArray([1000000, -2000000, 3000000])
            ]),
            NbtList(name: "LongArrayList", [
                NbtLongArray([1, -2, 3]),
                NbtLongArray([1000, -2000, 3000]),
                NbtLongArray([1000000, -2000000, 3000000])
            ])
        ])
    }
    
    static func makeReaderTest() throws -> NbtBuffer {
        let file = try NbtFile(rootTag: NbtCompound(name: "root", [
            NbtInt(name: "first"),
            NbtInt(name: "second"),
            NbtCompound(name: "third-comp", [
                NbtInt(name: "inComp1"),
                NbtInt(name: "inComp2"),
                NbtInt(name: "inComp3")
            ]),
            NbtList(name: "fourth-list", [
                NbtList([
                    NbtCompound([
                        NbtCompound(name: "inList1")
                    ])
                ]),
                NbtList([
                    NbtCompound([
                        NbtCompound(name: "inList2")
                    ])
                ]),
                NbtList([
                    NbtCompound([
                        NbtCompound(name: "inList3")
                    ])
                ])
            ]),
            NbtInt(name: "fifth"),
            NbtByteArray(name: "hugeArray", [UInt8](repeating: 0, count: 1024*1024))
        ]))
        var buffer = Data()
        _ = try file.save(to: &buffer, compression: .none)
        return NbtBuffer(buffer)
    }
    
    static func makeValueTest() throws -> NbtCompound {
        return try NbtCompound(name: "root", [
            NbtByte(name: "byte", 1),
            NbtShort(name: "short", 2),
            NbtInt(name: "int", 3),
            NbtLong(name: "long", 4),
            NbtFloat(name: "float", 5),
            NbtDouble(name: "double", 6),
            NbtByteArray(name: "byteArray", [10, 11, 12]),
            NbtIntArray(name: "intArray", [20, 21, 22]),
            NbtLongArray(name: "longArray", [30, 31, 32]),
            NbtString(name: "string", "123")
        ])
    }
    
    static func assertValueTest(_ file: NbtFile) throws {
        let root = file.rootTag
        XCTAssertEqual("root", root.name)
        XCTAssertEqual(10, root.count)
        
        XCTAssert(root["byte"] is NbtByte)
        var node = root["byte"]!
        XCTAssertEqual("byte", node.name)
        XCTAssertEqual(1, (node as! NbtByte).value)
        
        XCTAssert(root["short"] is NbtShort)
        node = root["short"]!
        XCTAssertEqual("short", node.name)
        XCTAssertEqual(2, (node as! NbtShort).value)
        
        XCTAssert(root["int"] is NbtInt)
        node = root["int"]!
        XCTAssertEqual("int", node.name)
        XCTAssertEqual(3, (node as! NbtInt).value)
        
        XCTAssert(root["long"] is NbtLong)
        node = root["long"]!
        XCTAssertEqual("long", node.name)
        XCTAssertEqual(4, (node as! NbtLong).value)
        
        XCTAssert(root["float"] is NbtFloat)
        node = root["float"]!
        XCTAssertEqual("float", node.name)
        XCTAssertEqual(5, (node as! NbtFloat).value)
        
        XCTAssert(root["double"] is NbtDouble)
        node = root["double"]!
        XCTAssertEqual("double", node.name)
        XCTAssertEqual(6, (node as! NbtDouble).value)
        
        XCTAssert(root["byteArray"] is NbtByteArray)
        node = root["byteArray"]!
        XCTAssertEqual("byteArray", node.name)
        XCTAssertEqual([UInt8]([10, 11, 12]), (node as! NbtByteArray).value)
        
        XCTAssert(root["intArray"] is NbtIntArray)
        node = root["intArray"]!
        XCTAssertEqual("intArray", node.name)
        XCTAssertEqual([Int32]([20, 21, 22]), (node as! NbtIntArray).value)
        
        XCTAssert(root["longArray"] is NbtLongArray)
        node = root["longArray"]!
        XCTAssertEqual("longArray", node.name)
        XCTAssertEqual([Int64]([30, 31, 32]), (node as! NbtLongArray).value)
        
        XCTAssert(root["string"] is NbtString)
        node = root["string"]!
        XCTAssertEqual("string", node.name)
        XCTAssertEqual("123", (node as! NbtString).value)
    }

    static func getFileName(file: TestFile, compression: NbtCompression) -> String {
        var fileName = ""
        
        switch file {
        case .small:
            fileName.append("test")
        case .big:
            fileName.append("bigtest")
        }
        
        switch compression {
        case .none:
            fileName.append(".nbt")
        case .gZip:
            fileName.append(".nbt.gz")
        case .zLib:
            fileName.append(".nbt.z")
        default:
            fileName.append(".nbt")
        }
        
        return fileName
    }
    
    static func getFileUrl(file: TestFile, compression: NbtCompression) throws -> URL {
        let fileName = getFileName(file: file, compression: compression)
        let url = Bundle.module.url(forResource: fileName, withExtension: nil)
        precondition(url != nil, "Can't find file.")
        return url!
    }
    
    static func getFileData(file: TestFile, compression: NbtCompression) throws -> Data {
        let url = try getFileUrl(file: file, compression: compression)
        let data = try Data(contentsOf: url)
        return data
    }
    
    /// Gets the size of the uncompressed file in bytes.
    static func getFileSize(file: TestFile) -> Int {
        switch file{
        case .small:
            return 34
        case .big:
            return 1783
        }
    }
}
