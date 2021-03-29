//
//  NbtParseState.swift
//  
//
//  Created by ipshing on 3/8/21.
//

enum NbtParseState {
    case atStreamBeginning
    case atCompoundBeginning
    case inCompound
    case atCompoundEnd
    case atListBeginning
    case inList
    case atStreamEnd
    case error
}
