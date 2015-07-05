//
//  PCH_Strand.swift
//  TransformerModel
//
//  Created by PeterCoolAssHuber on 2015-07-05.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

/// Definition of a single strand of conductor. This class only applies to copper and aluminum conductors

import Cocoa

class PCH_Strand: PCH_Conductor {
    
    /**
        Allowed conductor shapes
    
        - Rectangular
        - Round
    */
    enum Shape
    {
        case Rectangular, Round
    }
    
    /**
        The Shape of the strand
    */
    let shape:Shape
    
    /** 
        The distance from the cross-sectional center of the conductor to its edge in the x-direction
    */
    let xRadius:Double
    
    /**
        The distance from the cross-sectional center of the conductor to its edge in the y-direction
    */
    var yRadius:Double
    
    /**
        The edge radius of Rectangular strands
    */
    let edgeRadius:Double
    
    /**
        The insulating cover of the strand
    */
    let coverInsulation:PCH_Insulation
    
    /**
        The radial thickness of the cover insulation
    */
    let coverThickness:Double

    /**
        Most complicated initializer.
        
        :param: name The optional name of the material
        :param: density The density of the material in kg/m3, at 0C and 100 kPa
        :param: cost The cost of the material in CDN$, per unit volume (kg/m3)
        :param: resistivity The resistivity of the conductor in Ω・m at 20°C
        :param: tempCoeff The temperature coefficient of the conductor in 'per °K'
        :param: shape The Shape of the strand
        :param: xRadius
        :param: yRadius
        :param: edgeRadius
        :param: coverInsulation
        :param: coverThickness
    
        :returns: A new Strand
    */
    init(name: String, density: Double, cost: Double, resistivity:Double, tempCoeff:Double, shape:Shape, xRadius:Double, yRadius:Double, edgeRadius:Double, coverInsulation:PCH_Insulation, coverThickness:Double)
    {
        // Swift peculiarity: You have to initialize this class' properties BEFORE calling the super class' init() function (???)
        self.shape = shape
        self.xRadius = xRadius
        self.yRadius = yRadius
        self.edgeRadius = edgeRadius
        self.coverInsulation = coverInsulation
        self.coverThickness = coverThickness
        
        super.init(name: name, density: density, cost: cost, resistivity: resistivity, tempCoeff: tempCoeff)
    }
    
    /** 
        Designated initializer for strands made of Copper or Aluminum (Steel will not cause an error, but probably should/will never be called)
    
        :param: condType The type of conductor (Copper or Aluminum)
        :param: shape The Shape of the strand
        :param: xRadius
        :param: yRadius
        :param: edgeRadius
        :param: coverInsulation
        :param: coverThickness
        
        :returns: A new Strand
    */
    init(condType:Conductor, shape:Shape, xRadius:Double, yRadius:Double, edgeRadius:Double, coverInsulation:PCH_Insulation, coverThickness:Double)
    {
        self.shape = shape
        self.xRadius = xRadius
        self.yRadius = yRadius
        self.edgeRadius = edgeRadius
        self.coverInsulation = coverInsulation
        self.coverThickness = coverThickness
        
        switch condType
        {
            case .Copper:
                
                super.init(name:"Copper", density:8940.0, cost:3.00, resistivity:1.72E-8, tempCoeff:0.003862)
                
            case .Aluminum:
                
                super.init(name:"Aluminum", density:2700.0, cost:2.00, resistivity:2.82E-8, tempCoeff:0.0039)
                
            case .Steel:
                
                super.init(name:"Steel", density:7850.0, cost:0.50, resistivity:1.43E-7, tempCoeff:0.0)
            
        }
    }

    /**
        Calculate the cross-sectional area of the strand
        
        :returns: The x-section in meters-squared
    */
    func Area() -> Double
    {
        switch self.shape
        {
            case .Round:
                
                return pi * xRadius * xRadius
            
            case .Rectangular:
                
                // This is a formula that I developed myself. It calculates the rectagular area and subtracts the part outside the radii of the corners.
                let x = self.edgeRadius * 2.0
                let areaToSubtract = x * x * (4.0 - pi) / 4.0
                return (2.0 * xRadius) * (2.0 * yRadius) - areaToSubtract
        }
    }
    
    /** 
        Calculate the resistance of a given length of the strand at a given temperature
        
        :param: length The length of the strand
        :param: temperature The temperature at which to calculate the resistance
    
        :returns: The resistance in ohms
    */
    func Resistance(length:Double, temperature:Double)
    {
        let result = super.Resistance(self.Area(), length: length, temperature: temperature)
    }
    
    
    
}

