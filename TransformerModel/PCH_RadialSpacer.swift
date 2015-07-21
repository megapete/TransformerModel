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
    
    /**
        Designated initializer
        
        :param: type The type of insulation used (usually, T-IV)
        :param: thickness The thickness of the radial spacer
        :param: width The width of the radial spacer
        :param: slLength The SL (overall) length of the radial spacer
        :param: dLength The D ("effective") length of the radial spacer
        :param: aEnd The A-end (per Weidmann) configuration of the radial spacer
        :param: bEnd The B-end (per Weidmann) configuration of the radial spacer
    
        :returns: A radial spacer
    */
    init(type:Insulation, thickness:Double, width:Double, slLength:Double, dLength:Double, aEnd:Int = 0, bEnd:Int = 0)
    {
        self.aEnd = aEnd
        self.bEnd = bEnd
        self.SL = slLength
        self.D = dLength
        self.W = width
        self.T = thickness
        
        super.init(material: type)
    }
    
    /**
        The weight of a single radial spacer (uses the average dimension of SL and D)
    */
    func Weight() -> Double
    {
        return super.Weight(area: self.W * self.T, length:(self.SL + self.D) / 2.0)
    }
}