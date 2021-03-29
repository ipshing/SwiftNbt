//
//  NbtByteArray.swift
//  
//
//  Created by ipshing on 3/13/21.
//

import Foundation

/// Represents a tag containing an array of bytes.
public final class NbtByteArray: NbtTag {
    // Override to return the .byteArray type
    override public var tagType: NbtTagType {
        return .byteArray
    }
    
    /// Gets or sets the value/payload of this tag (an array of bytes).
    public var value: [UInt8]
    
    /// Creates an unnamed `NbtByte` tag, containing an empty array of bytes.
    override public init() {
        value = []
        super.init()
    }
    
    /// Creates an unnamed `NbtByteArray` tag, containing the given array of bytes.
    /// - Parameter value: The byte array to assign to this tag's `value`.
    convenience public init(_ value: [UInt8]) {
        self.init(name: nil, value)
    }
    
    /// Creates an `NbtByteArray` tag with the given name, containing an empty array of bytes.
    /// - Parameter name: The name to assign to this tag.
    convenience public init(name: String?) {
        self.init(name: name, [])
    }
    
    /// Creates an `NbtByteArray` tag with the given name, containing the given array of bytes.
    /// - Parameters:
    ///   - name: The name to assign to this tag.
    ///   - value: The byte array to assign to this tag's `value`.
    public init(name: String?, _ value: [UInt8]) {
        self.value = value
        super.init()
        self.name = name
    }
    
    /// Creates a deep copy of the given `NbtByteArray`.
    /// - Parameter other: The tag to copy.
    public init(from other: NbtByteArray) {
        self.value = other.value
        super.init()
        self.name = other.name
    }
    
    /// Gets or sets a byte at the given index.
    public subscript(_ index: Int) -> UInt8 {
        get { return value[index] }
        set { value[index] = newValue }
    }
    
    override func readTag(_ readStream: NbtBinaryReader, _ skip: (NbtTag) -> Bool) throws -> Bool {
        let length = Int(try readStream.readInt32())
        if length < 0 {
            throw NbtError.invalidFormat("Negative length given in TAG_Byte_Array")
        }
        
        // Check if the tag needs to be skipped
        if skip(self) {
            try readStream.skip(length)
            return false
        }
        
        value = try readStream.readBytes(length)
        if value.count < length {
            throw NbtError.endOfStream
        }
        return true
    }
    
    override func skipTag(_ readStream: NbtBinaryReader) throws {
        let length = Int(try readStream.readInt32())
        if length < 0 {
            throw NbtError.invalidFormat("Negative length given in TAG_Byte_Array")
        }
        try readStream.skip(length)
    }
    
    override func writeTag(_ writeStream: NbtBinaryWriter) throws {
        try writeStream.write(NbtTagType.byteArray)
        if name == nil {
            throw NbtError.invalidFormat("Name is null")
        }
        try writeStream.write(name!)
        try writeData(writeStream)
    }
    
    override func writeData(_ writeStream: NbtBinaryWriter) throws {
        // Need to write the length as Int32
        try writeStream.write(Int32(value.count))
        try writeStream.write(value, 0, value.count)
    }
    
    override public func clone() -> NbtTag {
        return NbtByteArray(from: self)
    }
    
    override func toString(indentString: String, indentLevel: Int) -> String {
        var formattedStr = ""
        for _ in 0..<indentLevel {
            formattedStr.append(indentString)
        }
        formattedStr.append("TAG_Byte_Array")
        if name != nil && name!.count > 0 {
            formattedStr.append("(\"\(name!)\")")
        }
        formattedStr.append(": [\(value.count) bytes]")
        
        return formattedStr
    }
}
