//
//  PCH_Strip.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-21.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

import Cocoa

class PCH_Strip: PCH_Insulation {

    /**
        The different types of strips that are available
    */
    enum StripShape {
        
        case rectangular, dovetail, tstrip
    }
    
    /**
        The strip type
    */
    let type:StripShape
    
    /**
        Dimensions of the strip
    */
    let width:Double
    let thickness:Double
    let length:Double
    
    init(materialType:PCH_Insulation.Insulation, stripType:StripShape, width:Double, thickness:Double, length:Double)
    {
        self.type = stripType
        self.width = width
        self.thickness = thickness
        self.length = length
        
        super.init(material: materialType)
    }
}
