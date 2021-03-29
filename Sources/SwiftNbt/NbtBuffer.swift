//
//  NbtBuffer.swift
//  
//
//  Created by ipshing on 3/9/21.
//
// This class is a partial port of the .NET MemoryStream class.
// It borrows heavily in design and functionality to create a
// stream-like object that uses a backing buffer while maintaining
// a reference type.

import Foundation

/// Specifies the position in a buffer to use for seeking.
public enum SeekOrigin {
    /// Specifies the beginning of a buffer.
    case begin
    
    /// Specifies the current position within a buffer.
    case current
    
    /// Specifies the end of a buffer.
    case end
}

/// Creates a buffer whose backing store is a byte array in memory.
public class NbtBuffer {
    private var _buffer: [UInt8] // Either allocated internally or externally
    private var _origin: Int = 0 // For user-provided arrays, start at this origin
    private var _position: Int = 0 // read/write head
    private var _length: Int = 0 // Number of bytes within the buffer
    private var _capacity: Int = 0 // length of usable portion of buffer
    // Note that _capacity == _buffer.count for non-user-provided [UInt8]'s
    
    private var _expandable: Bool = false // User-provided buffers aren't expandable
    
    // Constants
    private let maxBufferLength: Int = Int(Int32.max)
    private let maxByteArrayLength: Int = 0x7FFFFFC7
    
    /// Initializes a new instance of the `NbtBuffer` class with an expandable capacity initialized to zero.
    public convenience init() {
        // Ignore the throw possibility because we know 0 is a valid capcity
        do {
            try self.init(0)
        } catch {
            // This will never get called but it satisfies the compiler
            self.init()
        }
    }
    
    /// Initializes a new instance of the `NbtBuffer` class with an expandable capacity initialized as specified.
    /// - Parameter capacity: The initial size of the internal array in bytes.
    /// - Throws: an `argumentOutOfRange` error if `capacity` is negative.
    public init(_ capacity: Int) throws {
        if capacity < 0 {
            throw NbtError.argumentOutOfRange("capacity", "Non-negative number required.")
        }
        if capacity == 0 {
            _buffer = []
        } else {
            _buffer = [UInt8](repeating: 0, count: capacity)
        }
        _capacity = capacity
        _expandable = true
    }
    
    /// Initializes a new instance of the `NbtBuffer` class based on the specified region of
    /// a `Data` buffer, with the `canWrite` property set as specified, and the ability to call
    /// `getBuffer` set as specified.
    /// - Parameter buffer: The `Data` buffer from which to create the current `NbtBuffer`.
    public convenience init(_ buffer: Data) {
        self.init([UInt8](buffer))
    }
    
    /// Initializes a new non-resizable instance of the `NbtBuffer` class based on
    /// the specified byte array with the `canWrite` property set as specified.
    /// - Parameter buffer: The array of unsigned bytes from which to create the current `NbtBuffer`.
    public init(_ buffer: [UInt8]) {
        _buffer = buffer
        _length = buffer.count
        _capacity = buffer.count
    }
    
    /// Initializes a new instance of the `NbtBuffer` class based on the specified region of
    /// a `Data` buffer.
    /// - Parameters:
    ///   - buffer: The `Data` buffer from which to create the current `NbtBuffer`.
    ///   - index: The index into `buffer` at which the `NbtBuffer` begins.
    ///   - count: The length of the `NbtBuffer` in bytes.
    /// - Throws: An `argumentOutOfRange` error if index or count is less than zero;
    /// or a `formatError` if the buffer length minus the `index` is less than `count`.
    public convenience init(_ buffer: Data, _ index: Int, _ count: Int) throws {
        try self.init([UInt8](buffer), index, count)
    }
    
    /// Initializes a new instance of the `NbtBuffer` class based on the specified region of
    /// a byte array.
    /// - Parameters:
    ///   - buffer: The array of unsigned bytes from which to create the current `NbtBuffer`.
    ///   - index: The index into `buffer` at which the `NbtBuffer` begins.
    ///   - count: The length of the `NbtBuffer` in bytes.
    /// - Throws: An `argumentOutOfRange` error if index or count is less than zero;
    /// or a `formatError` if the buffer length minus the `index` is less than `count`.
    public init(_ buffer: [UInt8], _ index: Int, _ count: Int) throws {
        if index < 0 {
            throw NbtError.argumentOutOfRange("index", "Non-negative number required.")
        }
        if count < 0 {
            throw NbtError.argumentOutOfRange("count", "Non-negative number required.")
        }
        if buffer.count - index < count {
            throw NbtError.argumentError("Offset and length were out of bounds for the array or count is greater than the number of elements from index to the end of the source collection.")
        }
        
        _buffer = buffer
        _origin = index
        _position = index
        _length = index + count
        _capacity = index + count
    }
    
    /// Gets the number of bytes allocated for this `NbtBuffer`.
    public var capacity: Int {
        get {
            // As of Swift 5.3, throwing errors is not allowed in properties
            // try ensureNotClosed()
            return _capacity - _origin
        }
    }
    // Use a method to set capacity until Swift allows throwing in properties
    /// Sets the number of bytes allocated for this `NbtBuffer`.
    public func setCapacity(_ value: Int) throws {
        // Only update the capacity if the NbtBuffer is expandable and
        // the value is different than the current capacity. Special
        // behavior if the buffer isn't expandable: we don't throw if
        // value is the same as the current capacity
        if value < length {
            throw NbtError.argumentOutOfRange("capacity", "Capacity cannot be less than the current size.")
        }
        
        if !_expandable && value != capacity {
            throw NbtError.bufferNotExpandable
        }
        
        // NbtBuffer has this invariant: _origin > 0 => !expandable (see init)
        if _expandable && value != _capacity {
            if value > 0 {
                var newBuffer: [UInt8] = [UInt8](repeating: 0, count: value)
                if _length > 0 {
                    // Copy the contents of the current _buffer to the new one
                    for i in 0..<_length {
                        newBuffer[i] = _buffer[i]
                    }
                }
                
                _buffer = newBuffer
            } else {
                _buffer = []
            }
            
            _capacity = value
        }
    }
    
    /// Gets the length of the `NbtBuffer` in bytes.
    public var length: Int {
        get {
            // As of Swift 5.3, throwing errors is not allowed in properties
            // try ensureNotClosed()
            return _length - _origin
        }
    }
    // Use a method to set length until Swift allows throwing in properties
    /// Sets the length of the `NbtBuffer` in bytes.
    public func setLength(_ value: Int) throws {
        // Sets the length of the NbtBuffer to a given value.  The new
        // value must be nonnegative and less than the space remaining in
        // the array, int.MaxValue - origin
        // Origin is 0 in all cases other than a NbtBuffer created on
        // top of an existing array and a specific starting offset was passed
        // into the NbtBuffer constructor.  The upper bounds prevents any
        // situations where a buffer may be created on top of an array then
        // the buffer is made longer than the maximum possible length of the
        // array (int.MaxValue).
        
        if value < 0 || value > Int.max {
            throw NbtError.argumentOutOfRange("length", "Stream length must be non-negative and less than 2^31 - 1 - origin.")
        }
                
        // Origin wasn't publicly exposed above
        if value > Int.max - _origin {
            throw NbtError.argumentOutOfRange("length", "Stream length must be non-negative and less than 2^31 - 1 - origin.")
        }
        
        let newLength = _origin + value
        let allocatedNewArray = try ensureCapacity(newLength)
        if !allocatedNewArray && newLength > _length {
            // "Clear" the elements starting at _length
            for i in _length..<(newLength - _length) {
                _buffer[i] = 0
            }
        }
        _length = newLength
        if _position > newLength {
            _position = newLength
        }
    }
    
    /// Gets  the current position within the `NbtBuffer`.
    public var position: Int {
        get {
            // As of Swift 5.3, throwing errors is not allowed in properties
            // try ensureNotClosed()
            return _position - _origin
        }
    }
    // Use a method to set length until Swift allows throwing in properties
    /// Sets  the current position within the `NbtBuffer`.
    public func setPosition(_ value: Int) throws {
        if value < 0 {
            throw NbtError.argumentOutOfRange("position", "Non-negative number required.")
        }
        
        if value > maxBufferLength {
            throw NbtError.argumentOutOfRange("position", "Value must be less than 2^31 - 1 - origin.")
        }
        _position = _origin + value
    }
    
    // Returns a bool saying whether a new array was allocated
    private func ensureCapacity(_ value: Int) throws -> Bool {
        // Check for overflow
        if value < 0 {
            throw NbtError.argumentOutOfRange("value", "Non-negative number required.")
        }
        
        if value > _capacity {
            var newCapacity = max(value, 256)
            
            // Overflow is okay here since the next statement will deal
            // with the cases where _capacity * 2 overflows.
            if newCapacity < _capacity * 2 {
                newCapacity = _capacity * 2
            }
            
            // Expand the array only up to maxByteArrayLength
            // but also give the user the value they asked for
            if UInt(_capacity * 2) > maxByteArrayLength {
                newCapacity = max(value, maxByteArrayLength)
            }
            
            try setCapacity(newCapacity)
            return true
        }
        return false
    }
    
    private func validateBufferArguments(_ buffer: [UInt8], _ offset: Int, _ count: Int) throws {
        if offset < 0 {
            throw NbtError.argumentOutOfRange("offset", "Non-negative number required.")
        }
        if count < 0 {
            throw NbtError.argumentOutOfRange("count", "Non-negative number required.")
        }
        if count > buffer.count - offset {
            throw NbtError.argumentOutOfRange("count", "Offset and length were out of bounds for the array or count is greater than the number of elements from index to the end of the source collection.")
        }
    }
    
    /// Returns the array of unsigned bytes from which this `NbtBuffer` was created.
    /// - Returns: The byte array from which this `NbtBuffer` was created, or the underlying array if
    /// a byte array was not provided to the `NbtBuffer` constructor during construction of
    /// the current instance.
    public func getBuffer() -> [UInt8] {
        return _buffer
    }
    
    /// Reads a block of bytes from the current `NbtBuffer` and writes the data to a buffer.
    /// - Parameters:
    ///   - buffer: When this method returns, contains the specified byte array with the values
    ///   between `offset` and (`offset` + `count` - 1) replaced by the bytes read from
    ///   the current `NbtBuffer`.
    ///   - offset: The zero-based byte offset in `buffer` at which to begin storing data from
    ///   the current `NbtBuffer`.
    ///   - count: The maximum number of bytes to read.
    /// - Throws: An `argumentOutOfRange` error if `offset` or `count` is negative or if
    /// `offset` subtracted from the buffer length is less than `count`.
    /// - Returns: The total number of bytes written into the buffer. This can be less than the
    /// number of bytes requested if that number of bytes are not currently available,
    /// or zero if the end of the `NbtBuffer` is reached before any bytes are read.
    public func read(_ buffer: inout [UInt8], _ offset: Int, _ count: Int) throws -> Int {
        try validateBufferArguments(buffer, offset, count)
        
        var n = _length - _position
        if n > count {
            n = count
        }
        if n <= 0 {
            return 0
        }
        
        if n <= 8 {
            var byteCount = n - 1
            while byteCount >= 0 {
                buffer[offset + byteCount] = _buffer[_position + byteCount]
                byteCount -= 1
            }
        } else {
            // Copy bytes to buffer
            let tmpArray = Array(_buffer[_position..<(_position + n)])
            var tmpPos = 0
            for i in offset..<(offset + n) {
                buffer[i] = tmpArray[tmpPos]
                tmpPos += 1
            }
        }
        
        _position += n
        
        return n
    }
    
    /// Reads a byte from the current `NbtBuffer`.
    /// - Returns: The byte cast to `Int`, or -1 if the end of the `NbtBuffer` has been reached.
    public func readByte() -> Int {
        if(_position >= _length) {
            return -1
        }
        
        let byte = _buffer[_position]
        _position += 1
        
        return Int(byte)
    }
    
    /// Sets the position within the current `NbtBuffer` to the specified value.
    /// - Parameters:
    ///   - offset: The new position within the `NbtBuffer`. This is relative to the `loc`
    ///   parameter, and can be positive or negative.
    ///   - loc: A value of type `SeekOrigin`, which acts as the seek reference point.
    /// - Throws: An `argumentOutOfRange` error if `offset` is greater than `Int32.max`;
    /// a `seekBeforeBegin` error if seeking is attempted before the beginning of the `NbtBuffer`.
    /// - Returns: The new position within the `NbtBuffer`, calculated by combining
    /// the initial reference point and the offset.
    public func seek(to offset: Int, from loc: SeekOrigin) throws -> Int {
        if offset > maxBufferLength {
            throw NbtError.argumentOutOfRange("offset", "Value must be less than 2^31 - 1 - origin.")
        }
        
        switch loc {
        case .begin:
            let tempPosition = _origin + offset
            if offset < 0 || tempPosition < _origin {
                throw NbtError.seekBeforeBegin
            }
            _position = tempPosition
            break
        case .current:
            let tempPosition = _origin + offset
            if _position + offset < _origin || tempPosition < _origin {
                throw NbtError.seekBeforeBegin
            }
            _position = tempPosition
            break
        case .end:
            let tempPosition = _origin + offset
            if _length + offset < _origin || tempPosition < _origin {
                throw NbtError.seekBeforeBegin
            }
            _position = tempPosition
            break
        }
        
        return _position
    }
    
    /// Writes the `NbtBuffer` contents to a byte array, regardless of the `position` property.
    /// - Returns: A new byte array.
    public func toArray() -> [UInt8] {
        let count = _length - _origin
        if count == 0 {
            return [UInt8]()
        }
        var copy = [UInt8](repeating: 0, count: count)
        // Copy bytes over
        let tmpArray = _buffer[_origin..<(_origin + count)]
        var tmpPos = 0
        for i in 0..<count {
            copy[i] = tmpArray[tmpPos]
            tmpPos += 1
        }
        
        return copy
    }
    
    /// Writes a block of bytes to the current `NbtBuffer` using data read from a buffer.
    /// - Parameters:
    ///   - buffer: The buffer to write data from.
    ///   - offset: The zero-based byte offset in `buffer` at which to begin copying bytes to the current `NbtBuffer`.
    ///   - count: The maximum number of bytes to write.
    /// - Throws: A `writeNotSupported` error if the `NbtBuffer` does not support writing or
    /// if the current position is closer than `count` bytes to the end of the `NbtBuffer` and
    /// the capacity cannot be modified; an argumentOutOfRange if `offset` or `count` are negative.
    public func write(_ buffer: [UInt8], _ offset: Int, _ count: Int) throws {
        try validateBufferArguments(buffer, offset, count)
        
        let i = _position + count
        // Check for overflow
        if i < 0 {
            throw NbtError.invalidOperation("Stream too long.")
        }
        
        if i > _length {
            var mustZero = _position > _length
            if i > _capacity {
                let allocatedNewArray = try ensureCapacity(i)
                if allocatedNewArray {
                    mustZero = false
                }
            }
            if mustZero {
                for j in _length..<i {
                    _buffer[j] = 0
                }
            }
            _length = i
        }
        // Technically buffer will never == _buffer because [UInt8]
        // is not a reference type, but keep the check to maintain
        // parity with .NET
        if count <= 8 && buffer != _buffer {
            var byteCount = count - 1
            while byteCount >= 0 {
                _buffer[_position + byteCount] = buffer[offset + byteCount]
                byteCount -= 1
            }
        } else {
            // Copy bytes to _buffer
            let tmpArray = Array(buffer[offset..<(offset + count)])
            var tmpPos = 0
            for i in _position..<(_position + count) {
                _buffer[i] = tmpArray[tmpPos]
                tmpPos += 1
            }
        }
        _position = i
    }
    
    /// Writes a byte to the current `NbtBuffer` at the current position.
    /// - Parameter value: The byte to write.
    /// - Throws: A `writeNotSupported` error if the `NbtBuffer` does not support writing or
    /// the current position is at the end of the `NbtBuffer`, and the capacity cannot be modified.
    public func writeByte(_ value: UInt8) throws {
        if _position >= _length {
            let newLength = _position + 1
            var mustZero = _position > _length
            if newLength > _capacity {
                let allocatedNewArray = try ensureCapacity(newLength)
                if allocatedNewArray {
                    mustZero = false
                }
            }
            if mustZero {
                for i in _length..<_position {
                    _buffer[i] = 0
                }
            }
            
            _length = newLength
        }
        
        _buffer[_position] = value
        _position += 1
    }
}
