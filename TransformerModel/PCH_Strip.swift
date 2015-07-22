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
        Dimensions of the strip
    */
    let width:Double
    let thickness:Double
    let length:Double
    
    init(materialType:PCH_Insulation.Insulation, width:Double, thickness:Double, length:Double)
    {
        self.width = width
        self.thickness = thickness
        self.length = length
        
        super.init(material: materialType)
    }
}
