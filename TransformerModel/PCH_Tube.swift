//
//  PCH_Tube.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-02.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// The tube class is basically a rolled PCH_Board

class PCH_Tube: PCH_Board {

    /**
        The inner diameter of the tube
    */
    let innerDiameter:Double
    
    /**
        The outer diameter of the tube (computed)
    */
    var outerDiameter:Double
    {
        get
        {
            return innerDiameter + 2.0 * self.thickness
        }
    }
    
    /**
        Designated initializer
    
        - parameter innerDiameter: The inner diameter of the tube
        - parameter tubeHt: The height of the tube (somewhere in the neighbourhood of the coil height)
        - parameter thickness: The thickness of the board that is used to make the tube
    */
    init(innerDiameter:Double, tubeHt:Double, thickness:Double)
    {
        self.innerDiameter = innerDiameter
        
        super.init(width: tubeHt, thickness: thickness, length: π * (innerDiameter + thickness))
    }
    
    /**
        Convenience initializer with the inner radius as the first parameter
    
        - parameter innerRadius: The inner radius of the tube
        - parameter tubeHt: The height of the tube (somewhere in the neighbourhood of the coil height)
        - parameter thickness: The thickness of the board that is used to make the tube
    */
    convenience init(innerRadius:Double, tubeHt:Double, thickness:Double)
    {
        self.init(innerDiameter: innerRadius * 2.0, tubeHt: tubeHt, thickness: thickness)
    }
}
