//
//  PCH_WdgTurn.swift
//  TransformerModel
//
//  Created by PeterCoolAssHuber on 2015-07-19.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// This class represents the combination of cables that make up a winding "turn" (ie: this is what the winder has to wind onto the winding mould). There are a couple of assumptions made in this class. First of all, it is assumed that for some given pattern of radial cable/insulation pairs, those pairs are repeated in 0 or more axial arrays. That is, if a turn is made up of cable1/radialIns1/cable2, then that pattern may be paralleled in axial copies, but those copies MUST be exact copies of the original turn. It is also assumed that any axial insulation between cables will be constant

class PCH_WdgTurn {
        
    /**
        Struct to define a radial cable/insulation pair
    
        - cable: The definition of the cable
        - radialInsulation: The type of any radial insulation within the arrangement
        - radialInsulationThickness: The thickness of the radial insulation within the arrangement
        - carriesCurrent: A Bool that indicates whether the cable carries current (useful for intershields)
    */
    struct radialCableArrangement {
        
        let cable:PCH_WdgCable
        let radialInsulation:PCH_Insulation?
        let radialInsulationThickness:Double
        let carriesCurrent:Bool // used for intershield conductor
    }
    
    /**
        Two-dimensional array holding the radial arrangements. The firts index is the axial position, the second is radial. It is assumed that all the radial arrangements are the same, so this method of accessing the turn arrangement (with a 2D array) is sort of a 'convenience'.
    */
    var cableArray = [[radialCableArrangement]]()
    
    /**
        The radial arrangement of each axial position in the turn
    */
    var radialCables:radialCableArrangement
    {
        get
        {
            return cableArray[0][0]
        }
    }

    /**
        The axial insulation within the turn (if any)
    */
    let axialInsulation:PCH_Insulation?
    let axialInsulationThickness:Double
    
    /**
        The number of axial positions in the turn (at least 1)
    */
    let numAxial:Int
    
    /**
        The  dimensions of the turn over the insulation with the x dimension shrunk (x [axial], y [radial])
    */
    var shrunkDimensionOverCover:(axial:Double, radial:Double)
    {
        get
        {
            let shrunkAxialIns = (self.axialInsulation == nil ? 0.0 : self.axialInsulation!.shrinkageFactor * self.axialInsulationThickness)
            
            var radialDim:Double = 0.0
            for i in 0..<cableArray[0].count
            {
                let radArrg = cableArray[0][i]
                radialDim += radArrg.cable.shrunkDimensionOverCover.radial
                
                // Ignore any radial insulation that may be stored in the final radial arrangement
                if (radArrg.radialInsulation != nil) && (i != cableArray[0].count - 1)
                {
                    radialDim += radArrg.radialInsulationThickness
                }
            }
            
            return (Double(numAxial) * cableArray[0][0].cable.shrunkDimensionOverCover.axial + Double(numAxial - 1) * shrunkAxialIns, radialDim)
        }
    }
    
    /**
        The  dimensions of the turn over the insulation with the x dimension unshrunk (x [axial], y [radial])
    */
    var unshrunkDimensionOverCover:(axial:Double, radial:Double)
    {
        get
        {
            let unshrunkAxialIns = (self.axialInsulation == nil ? 0.0 : self.axialInsulationThickness)
            
            var radialDim:Double = 0.0
            for i in 0..<cableArray[0].count
            {
                let radArrg = cableArray[0][i]
                radialDim += radArrg.cable.shrunkDimensionOverCover.radial
                
                // Ignore any radial insulation that may be stored in the final radial arrangement
                if (radArrg.radialInsulation != nil) && (i != cableArray[0].count - 1)
                {
                    radialDim += radArrg.radialInsulationThickness
                }
            }
            
            return (Double(numAxial) * cableArray[0][0].cable.shrunkDimensionOverCover.axial + Double(numAxial - 1) * unshrunkAxialIns, radialDim)
        }
    }
    
    /**
        Designated initializer
    
        - parameter numAxial: The number of axial positions in the turn
        - parameter axialIns: The axial insulation (if any) within the turn
        - parameter axialInsThk: The thickness of any axial insulation within the turn
        - parameter radArrgs: A list (array) of radial cable arragmements
    */
    init(numAxial:Int, axialIns:PCH_Insulation?, axialInsThk:Double, radArrgs:radialCableArrangement...)
    {
        ZAssert(radArrgs.count > 0, message: "You must define at least one radial cable arrangement!")
        
        self.numAxial = numAxial
        self.axialInsulation = axialIns
        self.axialInsulationThickness = (axialIns == nil ? 0.0 : axialInsThk)
        
        for i in 0..<numAxial
        {
            cableArray.insert(radArrgs, atIndex: i)
        }
    }
    
    convenience init(singleCable:PCH_WdgCable)
    {
        self.init(numAxial:1, axialIns:nil, axialInsThk:0.0, radArrgs:radialCableArrangement(cable: singleCable, radialInsulation: nil, radialInsulationThickness: 0.0, carriesCurrent: true))
    }
    
    /**
        Calculate the current-carrying conductor cross-sectional area of the turn
        
        - returns: The x-section in meters-squared
    */
    func Area() -> Double
    {
        var result:Double = 0.0
        
        for nextArrg in cableArray[0]
        {
            if (nextArrg.carriesCurrent)
            {
                result += nextArrg.cable.Area()
            }
        }
        
        return result * Double(numAxial)
    }
    
    /**
        Find the resistance of the given length of turn at the given temperature. Note that this ony returns the resistance of the current-carrying part of the turn
        
        - parameter length: The length of the cable
        - parameter temperature: The temperature at which we want to know the resistance
        
        - returns: The resistance (in ohms) of the cable
    */
    func Resistance(length:Double, temperature:Double) -> Double
    {
        var inverseResistances:Double = 0.0
        
        for nextArrg in cableArray[0]
        {
            if (nextArrg.carriesCurrent)
            {
                let nextRes = nextArrg.cable.Resistance(length, temperature: temperature)
                inverseResistances += 1.0 / nextRes
            }
        }
        
        return (1.0 / inverseResistances) / Double(self.numAxial)
    }
    
    /**
        Calculate the weight of a given length of turn. Note that this weight includes the metal and insulation cover (if any) of everything in the turn, INCLUDING any non-current-carrying conductors.
        
        - parameter length: The length of the strand
        
        - returns: The total weight of the turn, including radial inter-cable insulation, but NOT inter-cable axial insulation, which must be calculated elsewhere
    */
    func Weight(length:Double) -> Double
    {
        var radialWt:Double = 0.0
        
        for nextArrg in cableArray[0]
        {
            radialWt += nextArrg.cable.Weight(length)
            
            if (nextArrg.radialInsulation != nil)
            {
                radialWt += nextArrg.radialInsulation!.Weight(area: nextArrg.cable.unshrunkDimensionOverCover.axial * nextArrg.radialInsulationThickness, length: length)
                
            }
        }
        
        return radialWt * Double(self.numAxial)
    }

    
}
