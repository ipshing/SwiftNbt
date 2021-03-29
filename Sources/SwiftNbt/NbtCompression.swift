//
//  NbtCompression.swift
//  
//
//  Created by ipshing on 3/8/21.
//

public enum NbtCompression: UInt8 {
    /// Automatically detect file compression. Not a valid format for saving.
    case autoDetect
    
    /// No compression.
    case none = 0x0a
    
    /// Compressed with GZip header (default).
    case gZip = 0x1F
    
    /// Compressed with ZLib header (RFC-1950).
    case zLib = 0x78
}
