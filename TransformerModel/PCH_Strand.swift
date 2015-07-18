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
        :param: xRadius The distance from the cross-sectional center of the conductor to its edge in the x-direction
        :param: yRadius The distance from the cross-sectional center of the conductor to its edge in the y-direction
        :param: edgeRadius The edge radius of Rectangular strands
        :param: coverInsulation The insulating cover of the strand
        :param: coverThickness The radial thickness of the cover insulation
    
        :returns: A new Strand
    */
    init(name: String, density: Double, cost: Double, resistivity:Double, tempCoeff:Double, shape:Shape, xRadius:Double, yRadius:Double, edgeRadius:Double, coverInsulation:PCH_Insulation, coverThickness:Double)
    {
        // Swift peculiarity: You have to initialize this subclass' properties BEFORE calling the super class' init() function (???)
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
        :param: xRadius The distance from the cross-sectional center of the conductor to its edge in the x-direction
        :param: yRadius The distance from the cross-sectional center of the conductor to its edge in the y-direction
        :param: edgeRadius The edge radius of Rectangular strands
        :param: coverInsulation The insulating cover of the strand
        :param: coverThickness The radial thickness of the cover insulation
    
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
        Convenience initializer for rectangular strands
        
        :param: condType The type of conductor
        :param: width The (usually) axial dimension of the conductor
        :param: thickness The (usually) radial dimension of the conductor
        :param: edgeRadius The edge radius of the strand
        :param: coverInsulation The insulating cover of the strand
        :param: coverThickness The radial thickness of the cover insulation
    
        :returns: A new rectangular Strand
    */
    convenience init(condType:Conductor, width:Double, thickness:Double, edgeRadius:Double, coverInsulation:PCH_Insulation, coverThickness:Double)
    {
        self.init(condType:condType, shape:Shape.Rectangular, xRadius:width / 2.0, yRadius:thickness / 2.0, edgeRadius:edgeRadius, coverInsulation:coverInsulation, coverThickness:coverThickness)
    }
    
    /**
        Convenience initializer for round strands
        
        :param: condType The type of conductor
        :param: diameter The diameter of the conductor
        :param: coverInsulation The insulating cover of the strand
        :param: coverThickness The radial thickness of the cover insulation
    
        :returns: A new rectangular Strand
    */
    convenience init(condType:Conductor, diameter:Double,  coverInsulation:PCH_Insulation, coverThickness:Double)
    {
        self.init(condType:condType, shape:Shape.Round, xRadius:diameter / 2.0, yRadius:diameter / 2.0, edgeRadius:0.0, coverInsulation:coverInsulation, coverThickness:coverThickness)
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
                
                return π * xRadius * xRadius
            
            case .Rectangular:
                
                // This is a formula that I developed myself. It calculates the rectagular area and subtracts the part outside the radii of the corners.
                let x = self.edgeRadius * 2.0
                let areaToSubtract = x * x * (4.0 - π) / 4.0
                return (2.0 * xRadius) * (2.0 * yRadius) - areaToSubtract
        }
    }
    
    /**
        Function to calculate the average perimeter of the covered conductor (for insulation weight calculations)
    
        :returns: The average perimeter (ie: following a line through the center of the insulating cover)
    */
    func AveragePerimeter() -> Double
    {
        switch self.shape
        {
        case .Round:
            
            return 2.0 * π * (xRadius + coverThickness)
            
        case .Rectangular:
            
            let r = self.edgeRadius + coverThickness / 2.0
            let x = 2.0 * (self.xRadius - self.edgeRadius)
            let y = 2.0 * (self.yRadius - self.edgeRadius)
            
            return 2.0 * (x + y + π * r)
        }
    }
    
    /** 
        Calculate the resistance of a given length of the strand at a given temperature
        
        :param: length The length of the strand
        :param: temperature The temperature at which to calculate the resistance
    
        :returns: The resistance in ohms
    */
    func Resistance(length:Double, temperature:Double) -> Double
    {
        return super.Resistance(self.Area(), length: length, temperature: temperature)
    }
    
    /**
        Calculate the weight of a given length of strand. Note that this weight includes the metal and insulation cover (if any)
    
        :param: length The length of the strand
        
        :returns: The total weight of the strand, including its insulating cover
    */
    func Weight(length:Double) -> Double
    {
        let metalWeight = super.Weight(area:self.Area(), length: length)
        
        let coverWeight = self.coverInsulation.Weight(area: self.coverThickness * self.AveragePerimeter(), length: length)
        
        return metalWeight + coverWeight
    }
    
}

