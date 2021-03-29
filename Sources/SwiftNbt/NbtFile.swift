//
//  NbtFile.swift
//  
//
//  Created by ipshing on 3/7/21.
//

import Foundation

@available(OSX 10.11, *)
public final class NbtFile {
    /// Gets the file name used for the most recent loading/saving of this file. May be `nil`
    /// if this `NbtFile` instance has not been loaded from, or saved to a file.
    public private(set) var fileName: String?
    
    /// Gets the compression method used for most recent loading/saving of this file.
    /// Defaults to `.autoDetect`.
    public private(set) var fileCompression: NbtCompression = .autoDetect
    
    private var _rootTag: NbtCompound
    /// Gets the root tag of this file. Defaults to an empty-named tag.
    public var rootTag: NbtCompound {
        get { return _rootTag }
//        set(value) {
//            if value.name == nil {
//                // Throw Error
//            }
//            _rootTag = value
//        }
    }
    // Until Swift allows properties to throw, use a function
    /// Sets the root tag of this file. Must be a named `CompoundTag`.
    /// - Parameter tag: The compound tag to become the root of this file.
    /// - Throws: An `NbtError.argumentError` if the tag is unnamed.
    public func setRootTag(_ tag: NbtCompound) throws {
        if tag.name == nil {
            throw NbtError.argumentError("Root tag must be named.")
        }
        _rootTag = tag
    }
    
    /// Whether new `NbtFiles` should default to big-endian encoding. The default is `true`.
    public static var bigEndianByDefault: Bool = true
    
    /// Whether this file should read/write tags in big-endian encoding format.
    public var bigEndian: Bool
    
    /// Creates an empty `NbtFile`. `rootTag` will be set to an empty
    /// `NbtCompound` with a blank name ("").
    public init() {
        bigEndian = NbtFile.bigEndianByDefault
        _rootTag = NbtCompound(name: "")
    }
    
    /// Creates a new `NbtFile` with the given root tag.
    /// - Parameter rootTag: A named `NbtCompound` tag to set as the root tag.
    /// - Throws: An `NbtError.argumentError` if the tag is unnamed.
    convenience public init(rootTag: NbtCompound) throws {
        self.init()
        try setRootTag(rootTag)
    }
    
    /// Creates a new `NbtFile` from the specified `URL` using the most common settings.
    /// Automatically detects compression and assumes the file to be big-endian.
    /// - Parameter url: The `URL` of the file containing NBT data.
    /// - Throws: An `NbtError.invalidData` error if the compression could not be determined;
    /// an `NbtError.invalidFormat` error if the data could not be properly decompressed.
    convenience public init(contentsOf url: URL) throws {
        self.init()
        _ = try load(contentsOf: url, compression: .autoDetect)
    }
    
    /// Creates a new `NbtFile` from the specified `Data` buffer using the most common settings.
    /// Automatically detects compression and assumes the file to be big-endian.
    /// - Parameter buffer: The `Data` buffer containing the NBT data.
    /// - Throws: An `NbtError.invalidData` error if the compression could not be determined;
    /// an `NbtError.invalidFormat` error if the data could not be properly decompressed.
    convenience public init(contentsOf buffer: Data) throws {
        self.init()
        _ = try load(contentsOf: buffer, compression: .autoDetect)
    }
    
    /// Loads NBT data from a `URL`. Existing `rootTag` will be replaced.
    /// - Parameters:
    ///   - url: The `URL` of the file containing NBT data.
    ///   - compression: The algorithm used to compress the data.
    /// - Throws: An `NbtError.invalidData` error if the compression could not be determined;
    /// an `NbtError.invalidFormat` error if the data could not be properly decompressed.
    /// - Returns: The number of bytes read from the file.
    public func load(contentsOf url: URL, compression: NbtCompression) throws -> Int {
        return try load(contentsOf: url, compression: compression) { tag in
            return false
        }
    }
    
    /// Loads NBT data from a `URL`. Existing `rootTag` will be replaced.
    /// - Parameters:
    ///   - url: The `URL` of the file containing NBT data.
    ///   - compression: The algorithm used to compress the data.
    ///   - selector: Optional callback to select which tags to load into memory.
    ///   Root may not be skipped.
    /// - Throws: An `NbtError.invalidData` error if the compression could not be determined;
    /// an `NbtError.invalidFormat` error if the data could not be properly decompressed.
    /// - Returns: The number of bytes read from the file.
    public func load(contentsOf url: URL, compression: NbtCompression, _ skip: (NbtTag) -> Bool) throws -> Int {
        let data = try Data(contentsOf: url)
        fileName = url.path
        return try load(contentsOf: data, compression: compression, skip)
    }
    
    /// Loads NBT data from an array of bytes. Existing `rootTag` will be replaced
    /// - Parameters:
    ///   - bytes: The array of  unsigned bytes containing the NBT data.
    ///   - compression: The algorithm used to compress the data.
    /// - Throws: An `NbtError.invalidData` error if the compression could not be determined;
    /// an `NbtError.invalidFormat` error if the data could not be properly decompressed.
    /// - Returns: The number of bytes read from the file.
    public func load(contentsOf bytes: [UInt8], compression: NbtCompression) throws -> Int {
        return try load(contentsOf: bytes, compression: compression) { tag in
            return false
        }
    }
    
    /// Loads NBT data from an array of bytes. Existing `rootTag` will be replaced
    /// - Parameters:
    ///   - bytes: The array of  unsigned bytes containing the NBT data.
    ///   - compression: The algorithm used to compress the data.
    ///   - selector: Optional callback to select which tags to load into memory.
    ///   Root may not be skipped.
    /// - Throws: An `NbtError.invalidData` error if the compression could not be determined;
    /// an `NbtError.invalidFormat` error if the data could not be properly decompressed.
    /// - Returns: The number of bytes read from the file.
    public func load(contentsOf bytes: [UInt8], compression: NbtCompression, _ skip: (NbtTag) -> Bool) throws -> Int {
        let data = Data(bytes)
        return try load(contentsOf: data, compression: compression, skip)
    }
    
    /// Loads NBT data from a `Data` buffer. Existing `rootTag` will be replaced.
    /// - Parameters:
    ///   - buffer: The buffer containing the NBT data.
    ///   - compression: The algorithm used to compress the data in `buffer`.
    /// - Throws: An `NbtError.invalidData` error if the compression could not be determined;
    /// an `NbtError.invalidFormat` error if the data could not be properly decompressed.
    /// - Returns: The number of bytes read from the file.
    public func load(contentsOf buffer: Data, compression: NbtCompression) throws -> Int {
        return try load(contentsOf: buffer, compression: compression) { tag in
            return false
        }
    }
    
    /// Loads NBT data from a `Data` buffer. Existing `rootTag` will be replaced.
    /// - Parameters:
    ///   - buffer: The buffer containing the NBT data.
    ///   - compression: The algorithm used to compress the data in `buffer`.
    ///   - selector: Optional callback to select which tags to load into memory.
    ///   Root may not be skipped.
    /// - Throws: An `NbtError.invalidData` error if the compression could not be determined;
    /// an `NbtError.invalidFormat` error if the data could not be properly decompressed.
    /// - Returns: The number of bytes read from the file.
    public func load(contentsOf buffer: Data, compression: NbtCompression, _ skip: (NbtTag) -> Bool) throws -> Int {
        // Detect compression using the first byte in the buffer
        if compression == .autoDetect {
            switch buffer[0] {
            case 0x0a:
                fileCompression = .none
                break
            case 0x1F:
                fileCompression = .gZip
                break
            case 0x78:
                fileCompression = .zLib
                break
            default:
                throw NbtError.invalidData("Could not auto-detect compression format.")
                
            }
        } else {
            fileCompression = compression
        }
        
        // Decompress if needed
        var decompressedData: Data? = buffer
        if fileCompression == .gZip {
            decompressedData = buffer.gunzip()
        }
        else if fileCompression == .zLib {
            decompressedData = buffer.unzip()
        }
        // Validate
        if decompressedData == nil {
            throw NbtError.invalidFormat("NBT file was not compressed in the specified format.")
        }
        
        // Put the data into an NbtBuffer
        let ms = NbtBuffer(decompressedData!)
        return try loadInternal(ms, skip)
    }
    
    /// Loads NBT data from an `NbtBuffer`. It is assumed the data in the buffer is
    /// not compressed. Existing `rootTag` will be replaced.
    /// - Parameters:
    ///   - stream: The stream from which the data will be loaded.
    ///   - tagSelector: Optional callback to select which tags to load into memory.
    ///   Root may not be skipped.
    /// - Throws: An `NbtError.endOfStream` error if the stream ended earlier than expected;
    /// an `NbtError.invalidFormat` error if the root is not a TAG_Compound.
    /// - Returns: The number of bytes read from the stream.
    func loadInternal(_ buffer: NbtBuffer, _ skip: (NbtTag) -> Bool) throws -> Int {
        let firstByte = buffer.readByte()
        if firstByte < 0 {
            throw NbtError.endOfStream
        }
        if firstByte != NbtTagType.compound.rawValue {
            throw NbtError.invalidFormat("Given NBT stream does not start with TAG_Compound.")
        }
        // Initialize reader
        let reader = NbtBinaryReader(buffer, bigEndian)
        // Load data
        let rootCompound = try NbtCompound(name: reader.readString())
        _ = try rootCompound.readTag(reader, skip)
        try setRootTag(rootCompound)
        // Return the position as the number of bytes read
        return buffer.position
    }
    
    /// Saves this NBT file to the local file system.
    /// - Parameters:
    ///   - url: The location to save the data to. Must be a fully qualified path including file name.
    ///   - compression: Compression mode to use for saving. May not be `.autoDetect`.
    /// - Throws: An `NbtError.argumentError` if `.autoDetect` was given as a
    /// compression mode; an `NbtError.invalidFormat` error if one of the `NbtCompound`
    /// tags contained unnamed tags or if an `NbtList` tag had unknown list type and no elements.
    /// - Returns: The number of uncompressed bytes written to the file.
    public func save(to url: URL, compression: NbtCompression) throws -> Int {
        // Get data buffer
        var buffer = Data()
        _ = try save(to: &buffer, compression: compression)
        // Velidate
        if buffer.count == 0 {
            throw NbtError.invalidOperation("Unable to save to URL, no data to write.")
        }
        // Write data to url
        try buffer.write(to: url, options: .atomic)
        
        return buffer.count
    }
    
    /// Saves this NBT file to a `Data` buffer.
    /// - Parameters:
    ///   - buffer: The buffer to write the data to.
    ///   - compression: Compression mode to use for saving. May not be `.autoDetect`.
    /// - Throws: An `NbtError.argumentError` if `.autoDetect` was given as a
    /// compression mode; an `NbtError.invalidFormat` error if one of the `NbtCompound`
    /// tags contained unnamed tags or if an `NbtList` tag had unknown list type and no elements.
    /// - Returns: The number of uncompressed bytes written to the buffer.
    public func save(to buffer: inout Data, compression: NbtCompression) throws -> Int {
        if rootTag.name == nil {
            throw NbtError.invalidFormat("Cannot save NbtFile: root tag is not named. Its name may be an empty string, but not nil.")
        }
        if compression == .autoDetect {
            throw NbtError.argumentError(".autoDetect is not a valid NbtCompression value for saving.")
        }
        
        // Get NBT data into buffer
        let stream = NbtBuffer()
        let writer = NbtBinaryWriter(stream, bigEndian)
        try rootTag.writeTag(writer)
        let data = Data(stream.toArray())
        // Compress the data
        if compression == .gZip {
            if let compressedData = data.gzip() {
                buffer = compressedData
            }
            else {
                throw NbtError.compressionError
            }
        }
        else if compression == .zLib {
            if let compressedData = data.zip() {
                buffer = compressedData
            }
            else {
               throw NbtError.compressionError
            }
        }
        else {
            buffer = data
        }
        return data.count
    }
    
    func saveToBuffer(compression: NbtCompression) throws -> Data {
        var result = Data()
        _ = try save(to: &result, compression: compression)
        return result
    }
    
    public func toString(indentString: String) -> String {
        return rootTag.toString(indentString: indentString)
    }
}

@available(OSX 10.11, *)
extension NbtFile: CustomStringConvertible {
    public var description: String {
        return rootTag.toString(indentString: NbtTag.defaultIndentString)
    }
}
