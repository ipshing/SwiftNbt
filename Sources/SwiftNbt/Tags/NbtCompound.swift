//
//  NbtCompound.swift
//  
//
//  Created by ipshing on 3/7/21.
//

import Foundation

/// Represents a collection of named `NbtTag` objects.
public final class NbtCompound: NbtTag {
    // We want NbtCompound to emulate an Ordered Dictionary
    // so keys and values are stored in separate collections.
    
    // Use a dictionary for the keys to track the indexes in the _tags array
    private var _keys: [String:Int] = [:]
    // The backing store for the collection of tags
    private var _tags: [NbtTag] = []
    
    /// Creates an empty, unnamed NbtCompound tag.
    override init() {
        super.init()
    }
    
    /// Creates  an empty NbtCompound tag with the given name.
    /// - Parameter name: Name to assign to this tag. May be `nil`.
    init(name: String?) {
        super.init()
        self.name = name
    }
    
    /// Creates an unnamed `NbtCompound` tag, containing the specified tags.
    /// - Parameter tags: Collection of tags to include.
    /// - Throws: An `NbtError.argumentError` if some of the tags were not named or
    /// two tags with teh same name were given.
    convenience init(_ tags: [NbtTag]) throws {
        try self.init(name: nil, tags)
    }
    
    /// Creates a named `NbtCompound` tag, containing the specified tags.
    /// - Parameters:
    ///   - name: Name to assign to this tag. May be `nil`.
    ///   - tags: Collection of tags to include.
    /// - Throws: An `NbtError.argumentError` if some of the tags were not named or
    ///  two tags with teh same name were given.
    init(name: String?, _ tags: [NbtTag]) throws {
        super.init()
        self.name = name
        for tag in tags {
            try append(tag)
        }
    }
    
    /// Creates a deep copy of given NbtCompound.
    /// - Parameter other: An existing NbtCompound to copy.
    /// - Throws: An `NbtError.argumentError` if some of the tags were not named or
    /// two tags with teh same name were given.
    init(from other: NbtCompound) throws {
        super.init()
        _name = other.name
        // Copy keys
        _keys = other._keys
        // Copy tags
        for tag in other._tags {
            try append(tag.clone())
        }
    }
    
    // Override to return the .compound type
    override public var tagType: NbtTagType {
        return .compound
    }
    
    /// Gets a collection containing all tag names in this NbtCompound.
    public var names: [String] {
        return Array(_keys.keys)
    }
    
    /// Gets a collection containing all tags in this NbtCompound.
    public var tags: [NbtTag] {
        return Array(_tags)
    }
    
    /// Gets the number of tags contained in the NbtCompound.
    public var count: Int {
        return _tags.count
    }
    
    /// Gets or sets the tag with the specified name. May return `nil`.
    public override subscript(_ tagName: String) -> NbtTag? {
        get {
            if let index = _keys[tagName] {
                return _tags[index]
            }
            return nil
        }
        set(value) {
            precondition(value != nil)
            precondition(value!.name == tagName, "Given tag name must match the tag's actual name.")
            precondition(value!.parent == nil, "A tag may only be added to one compound/list at a time.")
            precondition(value !== self || value !== parent!, "A compound tag may not be added to itself or to its child tag.")
            
            // This subscript CAN be used to "append" to the collection.
            if let index = _keys[tagName] {
                // Replace (and orphan) the existing tag
                let oldTag = _tags[index]
                oldTag.parent = nil
                _tags[index] = value!
                value!.parent = self
                // Update _keys
                _keys.removeValue(forKey: oldTag.name!)
                _keys[value!.name!] = index
            }
            else {
                // Append to collection
                _tags.append(value!)
                _keys[tagName] = _tags.endIndex - 1
            }
        }
    }

    /// Adds a tag to the end of this `NbtCompound`.
    /// - Parameter newTag: The object to add to this NbtCompound.
    /// - Throws: An `NbtError.argumentError`  if the given tag is unnamed or
    /// if a tag with the given name already exists in this `NbtCompound`.
    public func append(_ newTag: NbtTag) throws {
        if newTag as? NbtCompound === self {
            throw NbtError.argumentError("Cannot add tag to itself")
        }
        if newTag.parent != nil {
            throw NbtError.argumentError("A tag may only be added to one compound/list at a time.")
        }
        if newTag.name == nil {
            throw NbtError.argumentError("Only named tags are allowed in Compound tags.")
        }
        if contains(newTag.name!) {
            throw NbtError.argumentError("A tag with the same name has already been added.")
        }
        
        // Add to the _tags array
        _tags.append(newTag)
        // Get the index just added
        let index = _tags.endIndex - 1
        // Add to _keys
        _keys[newTag.name!] = index
        
        newTag.parent = self
    }
    
    /// Adds all tags from the specified collection to this `NbtCompound`.
    /// - Parameter newTags: The collection whose elements should be added to this `NbtCompound`.
    /// - Throws: An `NbtError.argumentError`  if the given tag is unnamed or
    /// if a tag with the given name already exists in this `NbtCompound`.
    public func append(contentsOf newTags: [NbtTag]) throws {
        for tag in newTags {
            try append(tag)
        }
    }
    
    /// Determines whether this NbtCompound contains a specific NbtTag.
    /// Looks for exact object matches, not name matches.
    /// - Parameter tag: The object to locate in this NbtCompound.
    /// - Returns: `true` if tag is found; otherwise, `false`.
    /// - Throws: An `NbtError.argumentError` if the given tag is unnamed.
    public func contains(_ tag: NbtTag) throws -> Bool {
        if tag.name == nil {
            throw NbtError.argumentError("Only named tags are allowed in Compound tags.")
        }
        if let index = _keys[tag.name!] {
            return tag === _tags[index]
        }
        return false
    }
    
    /// Determines whether this `NbtCompound` contains a tag with a specific name.
    /// - Parameter tagName: Tag name to search for.
    /// - Returns: `true` if a tag with given name was found; otherwise, `false`.
    public func contains(_ tagName: String) -> Bool {
        return _keys.keys.contains(tagName)
    }
    
    /// Gets the tag with the given name. May return `nil`.
    /// - Parameter tagName: The name of the tag to get.
    /// - Returns: The tag with the specified key. `nil` if no tag with the given name was not found.
    public func get(_ tagName: String) -> NbtTag? {
        if let index = _keys[tagName] {
            return _tags[index]
        }
        else {
            return nil
        }
    }
    
    /// Gets the tag with the given name cast to the specified type.
    /// - Parameters:
    ///   - tagName: The name of the tag to get.
    ///   - result: When this method returns, contains the tag associated with the specified name
    ///   if the tag is found AND matches the specified type; otherwise, `nil`.
    /// - Returns: `true` if a tag with the specified name was found, regardless of type; otherwise, `false`.
    public func get<T>(_ tagName: String, result: inout T?) -> Bool where T: NbtTag {
        if let index = _keys[tagName] {
            let tag = _tags[index]
            if tag is T {
                result = (tag as! T)
            }
            else {
                // Force nil if the type doesn't match
                result = nil
            }
            return true // because *A* tag was found
        }
        else {
            result = nil
            return false
        }
    }
    
    /// Removes the first occurrence of a specific NbtTag from the NbtCompound.
    /// Looks for exact object matches, not name matches.
    /// - Parameter tag: The tag to remove from the NbtCompound.
    /// - Returns: `true` if tag was successfully removed from the NbtCompound;
    /// otherwise, `false`. This method also returns `false` if tag is not found.
    public func remove(_ tag: NbtTag) throws -> Bool {
        // Validate
        if tag.name == nil {
            throw NbtError.argumentError("Trying to remove an unnamed tag.")
        }
        
        // Look for name in _keys
        if let index = _keys[tag.name!] {
            // Compare instances
            if _tags[index] === tag {
                // Remove from collections
                _tags.remove(at: index)
                _keys.removeValue(forKey: tag.name!)
                // Set parent to nil
                tag.parent = nil
                
                return true
            }
        }
        
        return false
    }
    
    /// Removes the tag with the specified name from this NbtCompound.
    /// - Parameter tagName: The name of the tag to remove.
    /// - Returns: `true` if the tag is successfully found and removed; otherwise, `false`.
    /// This method returns `false` if name is not found in the `NbtCompound`.
    public func remove(forKey tagName: String) -> Bool {
        if let index = _keys[tagName] {
            // Remove from collections
            let tag = _tags.remove(at: index)
            _keys.removeValue(forKey:tagName)
            // Set parent to nil
            tag.parent = nil
            
            return true
        }
        return false
    }
    
    /// Removes all tags from this NbtCompound
    public func removeAll() {
        for tag in _tags {
            tag.parent = nil
        }
        _tags.removeAll()
        _keys.removeAll()
    }
    
    func renameTag(oldName: String, newName: String) throws {
        if oldName == newName {
            return
        }
        
        if _keys.keys.contains(newName) {
            throw NbtError.argumentError("Cannot rename: a tag with the same name already exists in this compound.")
        }
        
        if let index = _keys[oldName] {
            let tag = _tags[index]
            // Rename tag
            tag._name = newName
            // Update _keys
            _keys.removeValue(forKey: oldName)
            _keys[newName] = index
        }
        else {
            throw NbtError.argumentError("Cannot rename: no tag found to rename.")
        }
    }
    
    override func readTag(_ readStream: NbtBinaryReader, _ skip: (NbtTag) -> Bool) throws -> Bool {
        // Check if the tag needs to be skipped
        if parent != nil && skip(self) {
            try skipTag(readStream)
            return false
        }
        
        while true {
            let type = try readStream.readTagType()
            var newTag: NbtTag
            switch type {
            case .end:
                return true
            case .byte:
                newTag = NbtByte()
                break
            case .short:
                newTag = NbtShort()
                break
            case .int:
                newTag = NbtInt()
                break
            case .long:
                newTag = NbtLong()
                break
            case .float:
                newTag = NbtFloat()
                break
            case .double:
                newTag = NbtDouble()
                break
            case .byteArray:
                newTag = NbtByteArray()
                break
            case .string:
                newTag = NbtString()
                break
            case .list:
                newTag = NbtList()
                break
            case .compound:
                newTag = NbtCompound()
                break
            case .intArray:
                newTag = NbtIntArray()
                break
            case .longArray:
                newTag = NbtLongArray()
                break
            default:
                throw NbtError.invalidFormat("Unsupported tag type found in NBT_Compound: \(type)")
            }
            newTag.parent = self
            newTag._name = try readStream.readString()
            if try newTag.readTag(readStream, skip) {
                // (newTag.name is never nil)
                
                // Add to the _tags array
                _tags.append(newTag)
                // Get the index just added
                let index = _tags.endIndex - 1
                // Add to _keys
                _keys[newTag.name!] = index
            }
        }
    }
    
    override func skipTag(_ readStream: NbtBinaryReader) throws {
        while true {
            let type = try readStream.readTagType()
            var newTag: NbtTag
            switch type {
            case .end:
                return
            case .byte:
                newTag = NbtByte()
                break
            case .short:
                newTag = NbtShort()
                break
            case .int:
                newTag = NbtInt()
                break
            case .long:
                newTag = NbtLong()
                break
            case .float:
                newTag = NbtFloat()
                break
            case .double:
                newTag = NbtDouble()
                break
            case .byteArray:
                newTag = NbtByteArray()
                break
            case .string:
                newTag = NbtString()
                break
            case .list:
                newTag = NbtList()
                break
            case .compound:
                newTag = NbtCompound()
                break
            case .intArray:
                newTag = NbtIntArray()
                break
            case .longArray:
                newTag = NbtLongArray()
                break
            default:
                throw NbtError.invalidFormat("Unsupported tag type found in NBT_Compound: \(type)")
            }
            
            try readStream.skipString()
            try newTag.skipTag(readStream)
        }
    }
    
    override func writeTag(_ writeStream: NbtBinaryWriter) throws {
        try writeStream.write(NbtTagType.compound)
        if name == nil {
            throw NbtError.invalidFormat("Name is nil")
        }
        try writeStream.write(name!)
        try writeData(writeStream)
    }
    
    override func writeData(_ writeStream: NbtBinaryWriter) throws {
        for tag in _tags {
            try tag.writeTag(writeStream)
        }
        try writeStream.write(NbtTagType.end)
    }
    
    override public func clone() throws -> NbtTag {
        return try NbtCompound(from: self)
    }
    
    override func toString(indentString: String, indentLevel: Int) -> String {
        var formattedStr = ""
        for _ in 0..<indentLevel {
            formattedStr.append(indentString)
        }
        formattedStr.append("TAG_Compound")
        if name != nil && name!.count > 0 {
            formattedStr.append("(\"\(name!)\")")
        }
        formattedStr.append(": \(_tags.count) entries {{")
        
        if _tags.count > 0 {
            formattedStr.append("\n")
            for tag in _tags {
                formattedStr.append(tag.toString(indentString: indentString, indentLevel: indentLevel + 1))
                formattedStr.append("\n")
            }
            for _ in 0..<indentLevel {
                formattedStr.append(indentString)
            }
        }
        formattedStr.append("}")
        
        return formattedStr
    }
}

extension NbtCompound: Sequence {
    public func makeIterator() -> Array<NbtTag>.Iterator {
        return _tags.makeIterator()
    }
}

extension NbtCompound: Collection {
    // Implement the startIndex and just pass straight to
    // the startIndex of the _tags array.
    public var startIndex: Int {
        return _tags.startIndex
    }
    
    // Implement the endIndex and just pass straight to
    // the endIndex of the _tags array.
    public var endIndex: Int {
        return _tags.endIndex
    }
    
    // Advances to the next index in the collection
    public func index(after i: Int) -> Int {
        return _tags.index(after: i)
    }
}
