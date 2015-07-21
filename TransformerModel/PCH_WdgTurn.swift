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
    */
    struct radialCableArrangement {
        
        let cable:PCH_WdgCable
        let radialInsulation:PCH_Insulation?
        let radialInsulationThickness:Double?
    }
    
    var cableArray = [[radialCableArrangement]]()
    
    var radialCables:radialCableArrangement
    {
        get
        {
            return cableArray[0][0]
        }
    }

    let axialInsulation:PCH_Insulation?
    let axialInsulationThickness:Double
    let numAxial:Int
    
    /**
        The  dimensions of the turn over the insulation with the x dimension shrunk (x [axial], y [radial])
    */
    var shrunkDimensionOverCover:(axial:Double, radial:Double)
        {
        get
        {
            let shrunkAxialIns = (self.axialInsulation == nil ? 0.0 : self.axialInsulation!.shrinkageFactor * self.axialInsulationThickness)
            
            
            
            
        }
    }
    
    /**
    The  dimensions of the strand over the insulation with the x dimension unshrunk (x [axial], y [radial])
    */
    var unshrunkDimensionOverCover:(axial:Double, radial:Double)
        {
        get
        {
            
        }
    }
    
    init(numAxial:Int, axialIns:PCH_Insulation?, axialInsThk:Double, radArrgs:radialCableArrangement...)
    {
        ZAssert(radArrgs.count > 0, "You must define at least one radial cable arrangement!")
        
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
        self.init(numAxial:1, axialIns:nil, axialInsThk:0.0, radArrgs:radialCableArrangement(cable: singleCable, radialInsulation: nil, radialInsulationThickness: nil))
    }
    
    
}
