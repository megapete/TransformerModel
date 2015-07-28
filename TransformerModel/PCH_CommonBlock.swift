//
//  PCH_CommonBlock.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-27.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// A common block is made up of an insulating plate (PCH_Plate) and radiating PCH_Strips.

class PCH_CommonBlock
{
    /**
        Bool to indicate whether this is a bottom or top common block assembly
    */
    let isBottom:Bool
    
    /**
        The plate of the common block assembly
    */
    let plate:PCH_Plate
    
    /**
        The PCH_Strips that are glued to the plate
    */
    let strip:PCH_Strip
    
    /**
        The number of strips in the common block assembly
    */
    let numStrips:Int
    
    /**
        Designated initializer
    
        - parameter plate: The plate of the common block assmebly
        - parameter strip: The strips that are glued to the plate
        - parameter numStrips: The number of strips glued radially to the plate
        - parameter isBottom: Bool to indicate whether this is a bottom or top common block assembly
    */
    init(plate:PCH_Plate, strip:PCH_Strip, numStrips:Int, isBottom:Bool)
    {
        self.plate = plate
        self.strip = strip
        self.numStrips = numStrips
        self.isBottom = isBottom
    }
    
    
}
