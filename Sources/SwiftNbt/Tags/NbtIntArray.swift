//
//  NbtIntArray.swift
//  
//
//  Created by ipshing on 3/13/21.
//

import Foundation

public final class NbtIntArray: NbtTag {
    // Override to return the .intArray type
    override public var tagType: NbtTagType {
        return .intArray
    }
    
    /// Gets or sets the value/payload of this tag (an array of signed 32-bit integers).
    public var value: [Int32]
    
    /// Creates an unnamed `NbtByte` tag, containing an empty array of bytes.
    override public init() {
        value = []
        super.init()
    }
    
    /// Creates an unnamed `NbtIntArray` tag, containing the given array.
    /// - Parameter value: The array to assign to this tag's `value`.
    convenience public init(_ value: [Int32]) {
        self.init(name: nil, value)
    }
    
    /// Creates an `NbtIntArray` tag with the given name, containing an empty array.
    /// - Parameter name: The name to assign to this tag.
    convenience public init(name: String?) {
        self.init(name: name, [])
    }
    
    /// Creates an `NbtIntArray` tag with the given name, containing the given array.
    /// - Parameters:
    ///   - name: The name to assign to this tag.
    ///   - value: The array to assign to this tag's `value`.
    public init(name: String?, _ value: [Int32]) {
        self.value = value
        super.init()
        self.name = name
    }
    
    /// Creates a deep copy of the given `NbtIntArray`.
    /// - Parameter other: The tag to copy.
    public init(from other: NbtIntArray) {
        self.value = other.value
        super.init()
        self.name = other.name
    }
    
    /// Gets or sets a byte at the given index.
    public subscript(_ index: Int) -> Int32 {
        get { return value[index] }
        set { value[index] = newValue }
    }
    
    override func readTag(_ readStream: NbtBinaryReader, _ skip: (NbtTag) -> Bool) throws -> Bool {
        let length = Int(try readStream.readInt32())
        if length < 0 {
            throw NbtError.invalidFormat("Negative length given in TAG_Int_Array")
        }
        
        // Check if the tag needs to be skipped
        if skip(self) {
            try readStream.skip(length * MemoryLayout<Int32>.size)
            return false
        }
        
        value = [Int32](repeating: 0, count: length)
        for i in 0..<length {
            value[i] = try readStream.readInt32()
        }
        return true
    }
    
    override func skipTag(_ readStream: NbtBinaryReader) throws {
        let length = Int(try readStream.readInt32())
        if length < 0 {
            throw NbtError.invalidFormat("Negative length given in TAG_Int_Array")
        }
        try readStream.skip(length * MemoryLayout<Int32>.size)
    }
    
    override func writeTag(_ writeStream: NbtBinaryWriter) throws {
        try writeStream.write(NbtTagType.intArray)
        if name == nil {
            throw NbtError.invalidFormat("Name is null")
        }
        try writeStream.write(name!)
        try writeData(writeStream)
    }
    
    override func writeData(_ writeStream: NbtBinaryWriter) throws {
        // Need to write the length as Int32
        try writeStream.write(Int32(value.count))
        for i in 0..<value.count {
            try writeStream.write(value[i])
        }
    }
    
    override public func clone() -> NbtTag {
        return NbtIntArray(from: self)
    }
    
    override func toString(indentString: String, indentLevel: Int) -> String {
        var formattedStr = ""
        for _ in 0..<indentLevel {
            formattedStr.append(indentString)
        }
        formattedStr.append("TAG_Int_Array")
        if name != nil && name!.count > 0 {
            formattedStr.append("(\"\(name!)\")")
        }
        formattedStr.append(": [\(value.count) ints]")
        
        return formattedStr
    }
}
