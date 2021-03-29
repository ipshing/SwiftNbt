//
//  NbtLong.swift
//  
//
//  Created by ipshing on 3/13/21.
//

import Foundation

/// Represents a tag containing a signed 64-bit integer.
public final class NbtLong: NbtTag {
    // Override to return the .long type
    override public var tagType: NbtTagType {
        return .long
    }
    
    /// Gets or sets the value/payload of this tag (a signed 64-bit integer).
    public var value: Int64
    
    /// Creates an unnamed `NbtLong` tag with the default of value of 0.
    override public init() {
        value = 0
        super.init()
    }
    
    /// Creates an unnamed `NbtLong` tag with the given value.
    /// - Parameter value: The value to assign to this tag.
    convenience public init(_ value: Int64) {
        self.init(name: nil, value)
    }
    
    /// Creates an `NbtLong` tag with the given name and the default value of 0.
    /// - Parameter name: The name to assign to this tag. May be `nil`.
    convenience public init(name: String?) {
        self.init(name: name, 0)
    }
    
    /// Creates an `NbtLong` tag with the given name and value.
    /// - Parameters:
    ///   - name: The name to assign to this tag. May be `nil`.
    ///   - value: The value to assign to this tag.
    public init(name: String?, _ value: Int64) {
        self.value = value
        super.init()
        self.name = name
    }
    
    /// Creates a copy of the given `NbtLong` tag.
    /// - Parameter other: The tag to copy.
    public init(from other: NbtLong) {
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
        value = try readStream.readInt64()
        return true
    }
    
    override func skipTag(_ readStream: NbtBinaryReader) throws {
        try readStream.skip(MemoryLayout<Int64>.size)
    }
    
    override func writeTag(_ writeStream: NbtBinaryWriter) throws {
        try writeStream.write(NbtTagType.long)
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
        return NbtLong(from: self)
    }
    
    override func toString(indentString: String, indentLevel: Int) -> String {
        var formattedStr = ""
        for _ in 0..<indentLevel {
            formattedStr.append(indentString)
        }
        formattedStr.append("TAG_Double")
        if name != nil && name!.count > 0 {
            formattedStr.append("(\"\(name!)\")")
        }
        formattedStr.append(": ")
        formattedStr.append(String(value))
        
        return formattedStr
    }
    
}
