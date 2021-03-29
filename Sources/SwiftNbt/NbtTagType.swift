//
//  NbtTagType.swift
//  
//
//  Created by ipshing on 3/7/21.
//

public enum NbtTagType: UInt8 {
    /// Placeholder TagType used to indicate unknown/undefined tag type in NbtList.
    case unknown = 0xff
    
    /// TAG_End: Signifies the end of a Compound tag or List tag.
    case end = 0x00
    
    /// TAG_Byte: A signed 8-bit integer. Sometimes used for booleans.
    case byte = 0x01
    
    /// TAG_Short: A signed 16-bit integer.
    case short = 0x02
    
    /// TAG_Int: A signed 32-bit integer.
    case int = 0x03
    
    /// TAG_Long: A signed 64-bit integer.
    case long = 0x04
    
    /// TAG_Float: A signed IEEE-754 single-precision floating point number.
    case float = 0x05
    
    /// TAG_Double: A signed IEEE-754 double-precision floating point number.
    case double = 0x06
    
    /// TAG_Byte_Array: A length-prefixed array of signed 8-bit integers.
    case byteArray = 0x07
    
    /// TAG_String: A length-prefixed UTF-8 string. It has a size, rather than being null terminated.
    case string = 0x08
    
    /// TAG_List: A list of nameless tags, all of the same type.
    case list = 0x09
    
    /// TAG_Compound: A set of uniquely named tags.
    case compound = 0x0a
    
    /// TAG_Int_Array: A length-prefixed array of signed 32-bit integers.
    case intArray = 0x0b
    
    /// TAG_Long_Array: A length-prefixed array of signed 32-bit integers.
    case longArray = 0x0c
}

extension NbtTagType: Comparable {
    public static func < (lhs: NbtTagType, rhs: NbtTagType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public static func ==(lhs: NbtTagType, rhs: NbtTagType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
