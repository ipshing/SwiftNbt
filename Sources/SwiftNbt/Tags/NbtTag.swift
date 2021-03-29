//
//  NbtTag.swift
//  
//
//  Created by ipshing on 3/7/21.
//

import Foundation

/// An  base class for the different kinds of named binary tags. This class is not meant to be instantiated but Swift currently does not allow for abstract classes and protocols are too limited for the behavior desired here.
public class NbtTag {
    /// String to use for indentation when getting the `description` of this `NbtTag`.
    public static var defaultIndentString: String = "  "
    
    /// Parent compound tag, either NbtList or NbtCompound, if any. May be `nil` for detached tags.
    public internal(set) var parent: NbtTag?
    
    /// The type of this tag.
    public var tagType: NbtTagType {
        return .unknown
    }
    
    /// Gets whether this tag has a value attached. All tags except Compound, List, and End have values.
    public var hasValue: Bool {
        switch tagType {
        case .compound,
             .end,
             .list,
             .unknown:
            return false
        default:
            return true
        }
    }
    
    var _name: String?
    /// Gets the name of this tag.
    public var name: String? {
        get { return _name }
        set(newName) {
            if(_name == newName) {
                return
            }
            
            let parentAsCompound = parent as? NbtCompound
            if parentAsCompound != nil {
                if newName == nil {
                    preconditionFailure("Tags inside an NbtCompound must have a name.")
                } else {
                    do {
                        try parentAsCompound!.renameTag(oldName: name!, newName: newName!)
                    } catch {
                        fatalError("Cannot rename tag")
                    }
                }
            }
            _name = newName
        }
    }
    
    /// Gets the full name of this tag, including all parent tag names, separated by periods. Unnamed tags show up as empty strings.
    public var path: String {
        if parent == nil {
            return name ?? ""
        }
        if let parentAsList = parent as? NbtList {
            return "\(parentAsList.path)[\(String(parentAsList.firstIndex(of: self)!))]"
        } else {
            return "\(parent!.path).\(name ?? "")"
        }
    }

    // There is no way to force a subclass to override a function without using
    // protocols and the functionality needed for NbtTag means it has to be a
    // class. Therefore, since functions cannot use "required", use a fatal
    // error call.
    func readTag(_ readStream: NbtBinaryReader, _ skip: (NbtTag) -> Bool) throws -> Bool {
        fatalError("Cannot call this function from NbtTag; subclasses need to override and add functionality.")
    }
    func skipTag(_ readStream: NbtBinaryReader) throws {
        fatalError("Cannot call this function from NbtTag; subclasses need to override and add functionality.")
    }
    func writeTag(_ writeStream: NbtBinaryWriter) throws {
        fatalError("Cannot call this function from NbtTag; subclasses need to override and add functionality.")
    }
    func writeData(_ writeStream: NbtBinaryWriter) throws {
        fatalError("Cannot call this function from NbtTag; subclasses need to override and add functionality.")
    }
    
    /// Creates a deep copy of this tag.
    public func clone() throws -> NbtTag {
        fatalError("Cannot call this function from NbtTag; subclasses need to override and add functionality.")
    }
    
    func toString(indentString: String) -> String {
        toString(indentString: indentString, indentLevel: 0)
    }
    
    func toString(indentString: String, indentLevel: Int) -> String {
        fatalError("Cannot call this function from NbtTag; subclasses need to override and add functionality.")
    }
    
    // SHORTCUTS - These are included for developer convenience to avoid extra type casts.
    
    /// Gets or sets the tag with the specified name. May return `nil`.
    /// - Remark: This subscript is only applicable to `NbtCompound` tags. Using this subscript from
    /// any other tag type will result in a `fataError`.
    public subscript(_ tagName: String) -> NbtTag? {
        get { fatalError("String indexers only work on NbtCompound tags.") }
        set { fatalError("String indexers only work on NbtCompound tags.") }
    }
    
    /// Gets or sets the tag at the specified index.
    /// - Remark: This subscript is only applicable to `NbtList` tags. Using this subscript from
    /// any other tag type will result in a `fataError`.
    public subscript(_ index: Int) -> NbtTag {
        get { fatalError("Integer indexers only work on NbtList tags.") }
        set { fatalError("Integer indexers only work on NbtList tags.") }
    }
    
    /// Returns the value of this tag cast as a byte (unsigned 8-bit integer).
    /// - Remark: Only supported by `NbtByte` tags.
    public var byteValue: UInt8 {
        precondition(tagType == .byte, "Cannot get byteValue from \(NbtTag.getCanonicalTagName(tagType))")
        return (self as! NbtByte).value
    }
    
    /// Returns the value of this tag cast as a short (signed 16-bit integer).
    /// - Remark: Only supported by `NbtByte` and `NbtShort` tags.
    public var shortValue: Int16 {
        switch tagType {
        case .byte:
            return Int16((self as! NbtByte).value)
        case .short:
            return (self as! NbtShort).value
        default:
            preconditionFailure("Cannot get shortValue from \(NbtTag.getCanonicalTagName(tagType))")
        }
    }
    
    /// Returns the value of this tag cast as an int (signed 32-bit integer).
    /// - Remark: Only supported by `NbtByte`, `NbtShort`, and `NbtInt` tags.
    public var intValue: Int32 {
        switch tagType {
        case .byte:
            return Int32((self as! NbtByte).value)
        case .short:
            return Int32((self as! NbtShort).value)
        case .int:
            return (self as! NbtInt).value
        default:
            preconditionFailure("Cannot get intValue from \(NbtTag.getCanonicalTagName(tagType))")
        }
    }
    
    /// Returns the value of this tag cast as a long (signed 64-bit integer).
    /// - Remark: Only supported by `NbtByte`, `NbtShort`, `NbtInt`, and `NbtLong` tags.
    public var longValue: Int64 {
        switch tagType {
        case .byte:
            return Int64((self as! NbtByte).value)
        case .short:
            return Int64((self as! NbtShort).value)
        case .int:
            return Int64((self as! NbtInt).value)
        case .long:
            return (self as! NbtLong).value
        default:
            preconditionFailure("Cannot get longValue from \(NbtTag.getCanonicalTagName(tagType))")
        }
    }
    
    /// Returns the value of this tag cast as a float (single-precision floating point number).
    /// - Remark: Only supported by `NbtByte`, `NbtShort`, `NbtInt`, `NbtLong`,
    /// and `NbtFloat` tags.
    public var floatValue: Float {
        switch tagType {
        case .byte:
            return Float((self as! NbtByte).value)
        case .short:
            return Float((self as! NbtShort).value)
        case .int:
            return Float((self as! NbtInt).value)
        case .long:
            return Float((self as! NbtLong).value)
        case .float:
            return (self as! NbtFloat).value
        case .double:
            return Float((self as! NbtDouble).value)
        default:
            preconditionFailure("Cannot get floatValue from \(NbtTag.getCanonicalTagName(tagType))")
        }
    }
    
    /// Returns the value of this tag cast as a byte (double-precision floating point number).
    /// - Remark: Only supported by `NbtByte`, `NbtShort`, `NbtInt`, `NbtLong`,
    /// `NbtFloat`, and `NbtDouble` tags.
    public var doubleValue: Double {
        switch tagType {
        case .byte:
            return Double((self as! NbtByte).value)
        case .short:
            return Double((self as! NbtShort).value)
        case .int:
            return Double((self as! NbtInt).value)
        case .long:
            return Double((self as! NbtLong).value)
        case .float:
            return Double(String((self as! NbtFloat).value))!
        case .double:
            return (self as! NbtDouble).value
        default:
            preconditionFailure("Cannot get doubleValue from \(NbtTag.getCanonicalTagName(tagType))")
        }
    }
    
    /// Returns the value of this tag cast as a byte array (`[UInt8]`).
    /// - Remark: Only supported by `NbtByteArray` tags.
    public var byteArrayValue: [UInt8] {
        precondition(tagType == .byteArray, "Cannot get byteArrayValue from \(NbtTag.getCanonicalTagName(tagType))")
        return (self as! NbtByteArray).value
    }
    
    /// Returns the value of this tag cast as a byte array (`[Int32]`).
    /// - Remark: Only supported by `NbtIntArray` tags.
    public var intArrayValue: [Int32] {
        precondition(tagType == .intArray, "Cannot get intArrayValue from \(NbtTag.getCanonicalTagName(tagType))")
        return (self as! NbtIntArray).value
    }
    
    /// Returns the value of this tag cast as a byte array (`[Int64]`).
    /// - Remark: Only supported by `NbtLongArray` tags.
    public var longArrayValue: [Int64] {
        precondition(tagType == .longArray, "Cannot get longArrayValue from \(NbtTag.getCanonicalTagName(tagType))")
        return (self as! NbtLongArray).value
    }
    
    /// Returns the value of this tag cast as a `String`. For number values, returns the stringified version.
    /// - Remark: Not supported by `NbtCompound`, `NbtList`, `NbtByteArray`,
    /// `NbtIntArray`, or `NbtLongArray` tags.
    public var stringValue: String {
        switch tagType {
        case .string:
            return (self as! NbtString).value
        case .byte:
            return String((self as! NbtByte).value)
        case .short:
            return String((self as! NbtShort).value)
        case .int:
            return String((self as! NbtInt).value)
        case .long:
            return String((self as! NbtLong).value)
        case .float:
            return String((self as! NbtFloat).value)
        case .double:
            return String((self as! NbtDouble).value)
        default:
            preconditionFailure("Cannot get stringValue from \(NbtTag.getCanonicalTagName(tagType))")
        }
    }

    static func getCanonicalTagName(_ type: NbtTagType) -> String {
        switch type {
        case .byte:
            return "TAG_Byte"
        case .byteArray:
            return "TAG_Byte_Array"
        case .compound:
            return "TAG_Compound"
        case .double:
            return "TAG_Double"
        case .end:
            return "TAG_End"
        case .float:
            return "TAG_Float"
        case .int:
            return "TAG_Int"
        case .intArray:
            return "TAG_Int_Array"
        case .list:
            return "TAG_List"
        case .long:
            return "TAG_Long"
        case .longArray:
            return "TAG_Long_Array"
        case .short:
            return "TAG_Short"
        case .string:
            return "TAG_String"
        default:
            return "UNKNOWN";
        }
    }
}

extension NbtTag: CustomStringConvertible {
    /// Gets the contents of this tag and any child tags as a string. Indents the string using
    /// multiples of `defaultIndentString`.
    public var description: String {
        return toString(indentString: NbtTag.defaultIndentString)
    }
}

extension NbtTag: Equatable {
    public static func == (lhs: NbtTag, rhs: NbtTag) -> Bool {
        return lhs === rhs
    }
}
