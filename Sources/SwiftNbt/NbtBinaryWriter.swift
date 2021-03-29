//
//  NbtBinaryWriter.swift
//  
//
//  Created by ipshing on 3/9/21.
//

import Foundation

/// A binary writer class that writes primitives to an NBT stream while taking care
/// of endianness and string encoding, and counts bytes written.
final class NbtBinaryWriter {
    private var _stream: NbtBuffer
    private var _swapNeeded: Bool
    
    // Write at most 4 MiB at a time
    static let maxWriteChunk: Int = 4 * 1024 * 1024
    
    /// Initializes a new instance of the `NbtBinaryWriter` class based on the specified stream and using UTF-8 encoding.
    /// - Parameters:
    ///   - output: The output stream.
    ///   - bigEndian: `true` to write values as big endian; otherwise `false`.
    init(_ output: NbtBuffer, _ bigEndian: Bool) {
        _stream = output
        
        let isLittleEndian = CFByteOrderGetCurrent() == CFByteOrder(CFByteOrderLittleEndian.rawValue)
        _swapNeeded = isLittleEndian == bigEndian
    }
    
    /// Exposes access to the underlying stream of the `NbtBinaryWriter`.
    var baseStream: NbtBuffer { get { return _stream } }

    /// <#Description#>
    /// - Parameter value: <#value description#>
    /// - Throws: <#description#>
    func write(_ value: NbtTagType) throws {
        try _stream.writeByte(value.rawValue)
    }
    
    /// Writes an unsigned byte to the current stream and advances the stream position by one byte.
    /// - Parameter value: The unsigned byte to write.
    /// - Throws: A `streamIsClosed` error if the stream is closed.
    func write(_ value: UInt8) throws {
        try _stream.writeByte(value)
    }
    
    /// Writes a two-byte signed integer to the current stream and advances the stream position by two bytes.
    /// - Parameter value: The two-byte signed integer to write.
    /// - Throws: A `streamIsClosed` error if the stream is closed.
    func write(_ value: Int16) throws {
        var buffer = toByteArray(value)
        if _swapNeeded {
            buffer.reverse()
        }
        try _stream.write(buffer, 0, 2)
    }
    
    /// Writes a two-byte unsigned integer to the current stream and advances the stream position by two bytes.
    /// - Parameter value: The two-byte unsigned integer to write.
    /// - Throws: A `streamIsClosed` error if the stream is closed.
    func write(_ value: UInt16) throws {
        var buffer = toByteArray(value)
        if _swapNeeded {
            buffer.reverse()
        }
        try _stream.write(buffer, 0, 2)
    }
    
    /// Writes a four-byte signed integer to the current stream and advances the stream position by four bytes.
    /// - Parameter value: The four-byte signed integer to write.
    /// - Throws: A `streamIsClosed` error if the stream is closed.
    func write(_ value: Int32) throws {
        var buffer = toByteArray(value)
        if _swapNeeded {
            buffer.reverse()
        }
        try _stream.write(buffer, 0, 4)
    }
    
    /// Writes an eight-byte signed integer to the current stream and advances the stream position by eight bytes.
    /// - Parameter value: The eight-byte signed integer to write.
    /// - Throws: A `streamIsClosed` error if the stream is closed.
    func write(_ value: Int64) throws {
        var buffer = toByteArray(value)
        if _swapNeeded {
            buffer.reverse()
        }
        try _stream.write(buffer, 0, 8)
    }
    
    /// Writes a four-byte floating-point value to the current stream and advances the stream position by four bytes.
    /// - Parameter value: The four-byte floating-point value to write.
    /// - Throws: A `streamIsClosed` error if the stream is closed.
    func write(_ value: Float) throws {
        var buffer = toByteArray(value)
        if _swapNeeded {
            buffer.reverse()
        }
        try _stream.write(buffer, 0, 4)
    }
    
    /// Writes an eight-byte floating-point value to the current stream and advances the stream position by eight bytes.
    /// - Parameter value: The eight-byte floating-point value to write.
    /// - Throws: A `streamIsClosed` error if the stream is closed.
    func write(_ value: Double) throws {
        var buffer = toByteArray(value)
        if _swapNeeded {
            buffer.reverse()
        }
        try _stream.write(buffer, 0, 8)
    }
    
    /// Writes a length-prefixed string to this stream `UTF8` encoding, and advances the current position of the stream in accordance with the encoding used and the specific characters being written to the stream.
    /// - Parameter value: The value to write.
    /// - Throws: A `streamIsClosed` error if the stream is closed.
    func write(_ value: String) throws {
        // Convert string to byte array
        let stringBytes: [UInt8] = Array(value.utf8)
        // Get the length of the string
        let length = UInt16(stringBytes.count)
        // Write the length to the stream
        try write(length)
        // Write the string bytes to the stream
        try _stream.write(stringBytes, 0, Int(length))
    }
    
    /// Writes a region of a byte array to the current stream.
    /// - Parameters:
    ///   - bytes: A byte array containing the data to write.
    ///   - offset: The index of the first byte to read from `bytes` and to write to the stream.
    ///   - count: The number of bytes to read from `bytes` and to write to the stream.
    /// - Throws: An `argumentOutOfRange` error if `offset` or count are `negative`; a `streamIsClosed` error if the stream is closed.
    func write(_ bytes: [UInt8], _ offset: Int, _ count: Int) throws {
        var written = 0
        while written < count {
            let toWrite = min(NbtBinaryWriter.maxWriteChunk, count - written)
            try _stream.write(bytes, offset + written, toWrite)
            written += toWrite
        }
    }

    /// Converts a value to an array of bytes ([UInt8]). This is intended to
    /// be used with FixedWithIntegers, Floats, and Doubles.
    /// - Parameter value: The number to convert.
    /// - Returns: A byte array representing the number.
    func toByteArray<T>(_ value: T) -> [UInt8] {
        return withUnsafeBytes(of: value, Array.init)
    }
}
