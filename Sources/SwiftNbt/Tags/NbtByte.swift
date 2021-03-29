//
//  NbtByte.swift
//  
//
//  Created by ipshing on 3/13/21.
//

import Foundation

/// Represents a tag containing a single byte.
public final class NbtByte: NbtTag {
    // Override to return the .byte type
    override public var tagType: NbtTagType {
        return .byte
    }
    
    /// Gets or sets the value/payload of this tag (a single byte).
    public var value: UInt8
    
    /// Creates an unnamed `NbtByte` tag with the default of value of 0.
    override public init() {
        value = 0
        super.init()
    }
    
    /// Creates an unnamed `NbtByte` tag with the given value.
    /// - Parameter value: The byte value to assign to this tag.
    convenience public init(_ value: UInt8) {
        self.init(name: nil, value)
    }
    
    /// Creates an `NbtByte` tag with the given name and the default value of 0.
    /// - Parameter name: The name to assign to this tag. May be `nil`.
    convenience public init(name: String?) {
        self.init(name: name, 0)
    }
    
    /// Creates an `NbtByte` tag with the given name and value.
    /// - Parameters:
    ///   - name: The name to assign to this tag. May be `nil`.
    ///   - value: The byte value to assign to this tag.
    public init(name: String?, _ value: UInt8) {
        self.value = value
        super.init()
        self.name = name
    }
    
    /// Creates a copy of the given `NbtByte` tag.
    /// - Parameter other: The tag to copy.
    public init(from other: NbtByte) {
        self.value = other.value
        super.init()
        self.name = other.name
    }
    
    override func readTag(_ readStream: NbtBinaryReader, _ skip: (NbtTag) -> Bool) throws -> Bool {
        // Check if the tag needs to be skipped
        if skip(self) {
            try skipTag(readStream)
            return false
        }

        value = try readStream.readByte()
        return true
    }
    
    override func skipTag(_ readStream: NbtBinaryReader) throws {
        try readStream.skip(MemoryLayout<UInt8>.size)
    }
    
    override func writeTag(_ writeStream: NbtBinaryWriter) throws {
        try writeStream.write(NbtTagType.byte)
        if name == nil {
            throw NbtError.invalidFormat("Name is null")
        }
        try writeStream.write(name!)
        try writeData(writeStream)
    }
    
    override func writeData(_ writeStream: NbtBinaryWriter) throws {
        try writeStream.write(value)
    }
    
    override public func clone() -> NbtTag {
        return NbtByte(from: self)
    }
    
    override func toString(indentString: String, indentLevel: Int) -> String {
        var formattedStr = ""
        for _ in 0..<indentLevel {
            formattedStr.append(indentString)
        }
        formattedStr.append("TAG_Byte")
        if name != nil && name!.count > 0 {
            formattedStr.append("(\"\(name!)\")")
        }
        formattedStr.append(": ")
        formattedStr.append(String(value))
        
        return formattedStr
    }
}
