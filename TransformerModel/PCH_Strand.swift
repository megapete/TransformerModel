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
        case rectangular, round
    }
    
    /**
        The Shape of the strand
    */
    let shape:Shape
    
    /** 
        The distance from the cross-sectional center of the conductor to its edge in the x-direction (usually axial)
    */
    let xRadius:Double
    
    /**
        The distance from the cross-sectional center of the conductor to its edge in the y-direction (usually radial)
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
        The unshrunken radial thickness of the cover insulation
    */
    let coverThickness:Double
    
    /**
        The unshrunk dimensions of the strand over the insulation (x [axial], y [radial])
    */
    var unshrunkDimensionOverCover:(axial:Double, radial:Double)
    {
        get
        {
            return (2.0 * (xRadius + coverThickness), 2.0 * (yRadius + coverThickness))
        }
    }
    
    /**
        The  dimensions of the strand over the insulation with the x dimension shrunk (x [axial], y [radial])
    */
    var shrunkDimensionOverCover:(axial:Double, radial:Double)
    {
        get
        {
            return (2.0 * (xRadius + coverThickness * coverInsulation.shrinkageFactor), 2.0 * (yRadius + coverThickness))
        }
    }

    /**
        Most complicated initializer.
        
        - parameter name: The optional name of the material
        - parameter density: The density of the material in kg/m3, at 0C and 100 kPa
        - parameter cost: The cost of the material in CDN$, per unit volume (kg/m3)
        - parameter resistivity: The resistivity of the conductor in Ω・m at 20°C
        - parameter tempCoeff: The temperature coefficient of the conductor in 'per °K'
        - parameter shape: The Shape of the strand
        - parameter xRadius: The distance from the cross-sectional center of the conductor to its edge in the x-direction
        - parameter yRadius: The distance from the cross-sectional center of the conductor to its edge in the y-direction
        - parameter edgeRadius: The edge radius of Rectangular strands
        - parameter coverInsulation: The insulating cover of the strand
        - parameter coverThickness: The radial thickness of the cover insulation
    
        - returns: A new Strand
    */
    init(type: Conductor, density: Double, cost: Double, resistivity:Double, tempCoeff:Double, shape:Shape, xRadius:Double, yRadius:Double, edgeRadius:Double, coverInsulation:PCH_Insulation, coverThickness:Double)
    {
        // Swift peculiarity: You have to initialize this subclass' properties BEFORE calling the super class' init() function (???)
        self.shape = shape
        self.xRadius = xRadius
        self.yRadius = yRadius
        self.edgeRadius = edgeRadius
        self.coverInsulation = coverInsulation
        self.coverThickness = coverThickness
        
        super.init(type: type, density: density, cost: cost, resistivity: resistivity, tempCoeff: tempCoeff)
    }
    
    /** 
        Designated initializer for strands made of Copper or Aluminum (Steel will not cause an error, but probably should/will never be called)
    
        - parameter condType: The type of conductor (Copper or Aluminum)
        - parameter shape: The Shape of the strand
        - parameter xRadius: The distance from the cross-sectional center of the conductor to its edge in the x-direction
        - parameter yRadius: The distance from the cross-sectional center of the conductor to its edge in the y-direction
        - parameter edgeRadius: The edge radius of Rectangular strands
        - parameter coverInsulation: The insulating cover of the strand
        - parameter coverThickness: The radial thickness of the cover insulation
    
        - returns: A new Strand
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
            case .copper:
                
                super.init(type:condType, density:8940.0, cost:3.00, resistivity:1.72E-8, tempCoeff:0.003862)
                
            case .aluminum:
                
                super.init(type:condType, density:2700.0, cost:2.00, resistivity:2.82E-8, tempCoeff:0.0039)
                
            case .steel:
                
                super.init(type:condType, density:7850.0, cost:0.50, resistivity:1.43E-7, tempCoeff:0.0)
            
        }
    }
    
    /**
        Convenience initializer for rectangular strands
        
        - parameter condType: The type of conductor
        - parameter width: The (usually) axial dimension of the conductor
        - parameter thickness: The (usually) radial dimension of the conductor
        - parameter edgeRadius: The edge radius of the strand
        - parameter coverInsulation: The insulating cover of the strand
        - parameter coverThickness: The radial thickness of the cover insulation
    
        - returns: A new rectangular Strand
    */
    convenience init(condType:Conductor, width:Double, thickness:Double, edgeRadius:Double, coverInsulation:PCH_Insulation, coverThickness:Double)
    {
        self.init(condType:condType, shape:Shape.rectangular, xRadius:width / 2.0, yRadius:thickness / 2.0, edgeRadius:edgeRadius, coverInsulation:coverInsulation, coverThickness:coverThickness)
    }
    
    /**
        Convenience initializer for round strands
        
        - parameter condType: The type of conductor
        - parameter diameter: The diameter of the conductor
        - parameter coverInsulation: The insulating cover of the strand
        - parameter coverThickness: The radial thickness of the cover insulation
    
        - returns: A new rectangular Strand
    */
    convenience init(condType:Conductor, diameter:Double,  coverInsulation:PCH_Insulation, coverThickness:Double)
    {
        self.init(condType:condType, shape:Shape.round, xRadius:diameter / 2.0, yRadius:diameter / 2.0, edgeRadius:0.0, coverInsulation:coverInsulation, coverThickness:coverThickness)
    }

    /**
        Calculate the conducting cross-sectional area of the strand
        
        - returns: The x-section in meters-squared
    */
    func Area() -> Double
    {
        switch self.shape
        {
            case .round:
                
                return π * xRadius * xRadius
            
            case .rectangular:
                
                // This is a formula that I developed myself. It calculates the rectagular area and subtracts the part outside the radii of the corners.
                let x = self.edgeRadius * 2.0
                let areaToSubtract = x * x * (4.0 - π) / 4.0
                return (2.0 * xRadius) * (2.0 * yRadius) - areaToSubtract
        }
    }
    
    /**
        Function to calculate the average perimeter of the covered conductor (for insulation weight calculations)
    
        - returns: The average perimeter (ie: following a line through the center of the insulating cover)
    */
    func AveragePerimeter() -> Double
    {
        switch self.shape
        {
        case .round:
            
            return 2.0 * π * (xRadius + coverThickness)
            
        case .rectangular:
            
            let r = self.edgeRadius + coverThickness / 2.0
            let x = 2.0 * (self.xRadius - self.edgeRadius)
            let y = 2.0 * (self.yRadius - self.edgeRadius)
            
            return 2.0 * (x + y + π * r)
        }
    }
    
    /** 
        Calculate the resistance of a given length of the strand at a given temperature
        
        - parameter length: The length of the strand
        - parameter temperature: The temperature at which to calculate the resistance
    
        - returns: The resistance in ohms
    */
    func Resistance(_ length:Double, temperature:Double) -> Double
    {
        return super.Resistance(self.Area(), length: length, temperature: temperature)
    }
    
    /**
        Calculate the weight of a given length of strand. Note that this weight includes the metal and insulation cover (if any)
    
        - parameter length: The length of the strand
        
        - returns: The total weight of the strand, including its insulating cover
    */
    func Weight(_ length:Double) -> Double
    {
        let metalWeight = super.Weight(area:self.Area(), length: length)
        
        let coverWeight = self.coverInsulation.Weight(area: self.coverThickness * self.AveragePerimeter(), length: length)
        
        return metalWeight + coverWeight
    }
    
}

