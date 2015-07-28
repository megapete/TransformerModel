//
//  PCH_Plate.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-27.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// A round plate of insulating material

class PCH_Plate: PCH_Insulation
{
    /**
        The thickness of the plate
    */
    let thickness:Double
    
    /**
        The inner and outer diameters of the plate
    */
    let diameter:(inner:Double, outer:Double)
    
    /**
        Designated initializer
    
        - parameter material: The material of the plate
        - parameter thickness: The thickness of the plate
        - parameter ID: The inner diameter of the plate
        - parameter OD: The outer diameter of the plate
    */
    init(material:Insulation, thickness:Double, ID:Double, OD:Double)
    {
        self.thickness = thickness
        self.diameter = (ID, OD)
        
        super.init(material: material)
    }
    
    func Weight() -> Double
    {
        return super.Weight(diameter: self.diameter.outer, length: thickness) - super.Weight(diameter: self.diameter.inner, length: thickness)
    }
}
