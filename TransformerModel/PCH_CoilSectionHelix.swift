//
//  PCH_CoilSectionHelix.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-28.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// A helix is a single-layer coil section. It is a sort of combination layer & disk coil section, in that the turns go axial-wise across the coil but (usually) have an axial spacer between turns. 

class PCH_CoilSectionHelix: PCH_CoilSection
{
    /**
        Bool to indicate whether the start of the helical section is on bottom or top of the coil
    */
    let startOnBottom:Bool
    
    /**
        Nodes for the start and finish leads of the helical section
    */
    var startNode:PCH_ConnectionNode? = nil
    var finishNode:PCH_ConnectionNode? = nil
    
    /**
        The turn definition for the helical section
    */
    let turn:PCH_WdgTurn
    
    /**
        The amount of wound turns of the helical section
    */
    let woundTurns:Double
    
    /**
        The effective number of turns on the helical section. I think this will always be equal to woundTurns, but the other classes have this property so, in the interest of standardization, here it is.
    */
    let effectiveTurns:Double
    
    /**
        The number of turns that are active (carrying current) on the helical section (equal to 0.0 or effectiveTurns, which is the default)
    */
    var activeTurns:Double
    
    /**
        The radial spacer definition that will be used between all turns EXCEPT those in the gaps array.
    */
    let defaultRadialSpacer:[PCH_RadialSpacer]?
    
    /**
        Struct to define the gap. It is assumed that the gap goes from 0 to the dimension calculated from the radSpacers array.
    
        - radSpacers: Array which defines the gap at its maximum point
        - afterTurn: The location (in turns after the start) after which the gap is to be installed
    */
    struct AxialGaps
    {
        let radSpacers:[PCH_RadialSpacer]
        let afterTurn:Int
        
        /**
            Convenience function to get the shrunk dimension of the gap
        */
        func maxDimension() -> Double
        {
            var result:Double = 0.0
            for nextSpacer in radSpacers
            {
                result += nextSpacer.T * nextSpacer.shrinkageFactor
            }
            
            return result
        }
    }
    
    /**
        The definitions of any gaps in the helical section
    */
    let gaps:[AxialGaps]?
    
    /** 
        The locations (in turns from the start) of any taps on the helix
    */
    var taps = Set<Int>()
    
    /**
        Designated initializer
    */
    init(innerRadius:Double, zMinPhysical:Double, startOnBottom:Bool, turnDef:PCH_WdgTurn, woundTurns:Double, defaultRadialSpacer:[PCH_RadialSpacer]?, axialGaps:[AxialGaps]? = nil)
    {
        self.startOnBottom = startOnBottom
        self.turn = turnDef
        self.woundTurns = woundTurns
        self.effectiveTurns = woundTurns
        self.activeTurns = woundTurns
        self.defaultRadialSpacer = defaultRadialSpacer
        self.gaps = axialGaps
        
        var defSpacerDim = 0.0
        if (defaultRadialSpacer != nil)
        {
            for nextSpacer in defaultRadialSpacer!
            {
                defSpacerDim += nextSpacer.T * nextSpacer.shrinkageFactor
            }
        }
    
        let defHelixDim = turnDef.shrunkDimensionOverCover.axial + defSpacerDim
        
        var totalGapDim = 0.0
        var numDefSpacers = woundTurns
        
        if (axialGaps != nil)
        {
            for nextGap in axialGaps!
            {
                totalGapDim += nextGap.maxDimension()
                numDefSpacers -= 1
            }
        }
        
        let physHt = woundTurns * turnDef.shrunkDimensionOverCover.axial + numDefSpacers * defSpacerDim + totalGapDim
        
        super.init(innerRadius: innerRadius, radBuildPhysical: turnDef.shrunkDimensionOverCover.radial, radBuildElectrical: turnDef.shrunkDimensionOverCover.radial, zMinPhysical: zMinPhysical, zMinElectrical: zMinPhysical + defHelixDim / 2.0, electricalHt: physHt - defHelixDim, physicalHt: physHt)
    }
    
    /**
        Function to add taps at given turn numbers (in terms of the start of this coil section). Note that for this class, the turns are converted to integers before storage
    
        - parameter turns: A list of turn numbers
    */
    override func AddTapsAtTurns(turns: Double...)
    {
        for nextTurn in turns
        {
            taps.insert(Int(nextTurn))
        }
    }
    
}
