//
//  NbtReaderNode.swift
//  
//
//  Created by ipshing on 3/8/21.
//

import Foundation

struct NbtReaderNode {
    var parentName: String?
    var parentTagType: NbtTagType
    var listType: NbtTagType
    var parentTagLength: Int
    var listIndex: Int
}
