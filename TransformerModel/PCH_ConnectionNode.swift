//
//  PCH_ConnectionNode.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-28.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// This class is used to define connection points for winding starts/finishes and shielding elements. This class will probably expand as the program becomes more complete and complex.

class PCH_ConnectionNode
{
    /**
        A static (class) property holding the next (unique) node id number
    */
    private static var idNumber:Int32 = 0
    
    /**
        Bool to indicate whether the node is a terminal (external connection point)
    */
    var isTerminal:Bool = false
    
    /**
        The identification for this node
    */
    let identification:String
    
    /**
        Designated initializer
    
        - parameter identification: The string identifier for the node
        - parameter isTerminal: Set to 'true' if the node is an external terminal
    */
    private init(identification:String, isTerminal:Bool = false)
    {
        self.identification = identification
        self.isTerminal = isTerminal
    }
    
    /**
        Convenience initializer. This is the initializer that is exposed to the outside world.
    
        - parameter isTerminal: Set to 'true' if the node is an external terminal
    */
    convenience init(isTerminal:Bool = false)
    {
        self.init(identification:PCH_ConnectionNode.GetNextSerialNumber(), isTerminal:isTerminal)
    }
    
    /**
        A private function to get and increment (atomically) the next serial number
    */
    private static func GetNextSerialNumber() -> String
    {
        // I think that this might actually be thread-safe, but I'm not 100% sure
        let result = "\(OSAtomicIncrement32(&PCH_ConnectionNode.idNumber))"
        
        return result
    }
}
