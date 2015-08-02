//
//  PCH_Tube.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-02.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

class PCH_Tube: PCH_Board {

    let innerDiameter:Double
    
    var outerDiameter:Double
    {
        get
        {
            return innerDiameter + 2.0 * self.thickness
        }
    }
    
    init(innerDiameter:Double, tubeHt:Double, thickness:Double)
    {
        self.innerDiameter = innerDiameter
        
        super.init(width: tubeHt, thickness: thickness, length: π * (innerDiameter + thickness))
    }
    
    convenience init(innerRadius:Double, tubeHt:Double, thickness:Double)
    {
        self.init(innerDiameter: innerRadius * 2.0, tubeHt: tubeHt, thickness: thickness)
    }
}
