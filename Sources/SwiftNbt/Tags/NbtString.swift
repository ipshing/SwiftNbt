//
//  NbtString.swift
//  
//
//  Created by ipshing on 3/13/21.
//

import Foundation

/// Represents a tag containing a UTF-8-encoded string.
public final class NbtString: NbtTag {
    // Override to return the .string type
    override public var tagType: NbtTagType {
        return .string
    }
    
    /// The value/payload of this tag (a single string). May not be null.
    public var value: String
    
    /// Creates an unnamed `NbtString` tag with the default value (empty string).
    override public init() {
        value = ""
        super.init()
    }
    
    /// Creates an unnamed `NbtString` tag with the given value.
    /// - Parameter value: The `String` value to assign to this tag.
    convenience public init(_ value: String) {
        self.init(name: nil, value)
    }
    
    /// Creates an `NbtString` tag with the given name and value.
    /// - Parameters:
    ///   - name: The name to assign to this tag.
    ///   - value: The `String` value to assign to this tag.
    public init(name: String?, _ value: String) {
        self.value = value
        super.init()
        self.name = name
    }
    
    /// Creates a copy of given `NbtString` tag.
    /// - Parameter other: The tag to copy.
    public init(from other: NbtString) {
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
        value = try readStream.readString()
        return true
    }
    
    override func skipTag(_ readStream: NbtBinaryReader) throws {
        try readStream.skipString()
    }
    
    override func writeTag(_ writeStream: NbtBinaryWriter) throws {
        try writeStream.write(NbtTagType.string)
        if name == nil {
            throw NbtError.invalidFormat("Name is nil")
        }
        try writeStream.write(name!)
        try writeData(writeStream)
    }
    
    override func writeData(_ writeStream: NbtBinaryWriter) throws {
        try writeStream.write(value)
    }
    
    public override func clone() -> NbtTag {
        return NbtString(from: self)
    }
    
    override func toString(indentString: String, indentLevel: Int) -> String {
        var formattedStr = ""
        for _ in 0..<indentLevel {
            formattedStr.append(indentString)
        }
        formattedStr.append("TAG_String")
        if name != nil && name!.count > 0 {
            formattedStr.append("(\"\(name!)\")")
        }
        formattedStr.append(": \"")
        formattedStr.append(value)
        formattedStr.append("\"")

        return formattedStr
    }
}
