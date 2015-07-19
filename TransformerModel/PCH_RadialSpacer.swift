//
//  PCH_RadialSpacer.swift
//  TransformerModel
//
//  Created by PeterCoolAssHuber on 2015-07-19.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

import Foundation

/// Radial spacer class.

class PCH_RadialSpacer: PCH_Insulation {
    
    /**
        Weidmann possibilities for radial spacer end configurations. See Weidmann drawing EHV00083 for details (integer between 1 and 14). Use 0 for "unspecified"
    */
    var aEnd:Int
    var bEnd:Int
    
    /**
        Key dimensions for spacer (see Weidmann drawing EHV00083 for definitions
    */
    let SL:Double
    let D: Double
    let W: Double
    let T: Double
    
    init(type:Insulation, thickness:Double, width:Double, slLength:Double, dLength:Double, aEnd:Int = 0, bEnd:Int = 0)
    {
        self.aEnd = aEnd
        self.bEnd = bEnd
        self.SL = slLength
        self.D = dLength
        self.W = width
        self.T = thickness
        
        super.init(material: .TIV)
    }
}