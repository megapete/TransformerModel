//
//  PCH_WdgLayer.swift
//  TransformerModel
//
//  Created by PeterCoolAssHuber on 2015-07-23.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// A standard winding layer

class PCH_WdgLayer {

    /**
        Bool to indicate whether the start of the disk is on bottom or top of the coil
    */
    let startOnBottom:Bool
    
    /**
        Nodes for the start and finish leads of the disk
    */
    var startNode:PCH_ConnectionNode? = nil
    var finishNode:PCH_ConnectionNode? = nil
    
    /**
        UInt which indicates the "interleave level" of the layer (1 = no interleave, 2 = 2 conds, 3 = 3 conds, etc)
    */
    let interleaveLevel:UInt
    
    /**
        The turn that defines the layer. It is assumed that in the case of an interleaved layer, all conductors are made up of this turn. Note that this property should also be used to calculate the shrunk/unshrunk dimensions of the layer itself.
    */
    let turnDef:PCH_WdgTurn
    
    /**
        The amount of wound turns of the layer
    */
    let woundTurns:Double
    
    /**
        The effective number of turns on the layer
    */
    let effectiveTurns:Double
    
    /**
        The number of turns that are active (carrying current) on the disk (equal to 0.0 or effectiveTurns, which is the default)
    */
    var activeTurns:Double
    
    /**
        Struct that defines an axial gap in the layer winding. 
    
        - board: A PCH_Board that defines the material used for the gap.
        - htFraction: The fraction of the electrical height where the center of the gap is located
    */
    struct AxialGaps {
        
        let board:PCH_Board
        let htFraction:Double
    }
    
    /**
        An array of the axial gaps located within the layer
    */
    var gaps = [AxialGaps]()
    
    
    /**
        Axial dimensions of the layer (exact, withHelix)
    */
    let axialBuild:(exact:Double, withHelix:Double)
    
    /**
        Designated initializer
    
        - parameter startOnBottom: Bool to indicate whether the start of the disk is on bottom or top of the coil
        - parameter interleaveLevel: UInt which indicates the "interleave level" of the layer (1 = no interleave, 2 = 2 conds, 3 = 3 conds, etc)
        - parameter turnDef: The turn definition used for the layer
        - parameter woundTurns: The number of turns the winder must wind
        - parameter axialGaps: An array of any gaps within the layer
        - parameter numVertSpBoard: The number of vertical spacers in the layer
    */
    init(startOnBottom:Bool, interleaveLevel:UInt, turnDef:PCH_WdgTurn, woundTurns:Double, axialGaps:[AxialGaps]?)
    {
        self.startOnBottom = startOnBottom
        self.interleaveLevel = interleaveLevel
        self.turnDef = turnDef
        self.woundTurns = woundTurns
        self.effectiveTurns = woundTurns * Double(self.interleaveLevel)
        self.activeTurns = self.effectiveTurns
        
        // calculate the axial height and stuff it into a property
        var axialHt = 0.0
        
        if (axialGaps != nil)
        {
            for nextGap in axialGaps!
            {
                self.gaps.append(nextGap)
                axialHt += nextGap.board.width
            }
        }
        
        axialHt += turnDef.shrunkDimensionOverCover.axial * Double(self.interleaveLevel) * self.woundTurns
        
        axialBuild = (axialHt, axialHt + turnDef.shrunkDimensionOverCover.axial * Double(self.interleaveLevel))
    }
    
    /**
        Convenience initializer that uses a given layer and gives the caller the option to switch the startOnBottom and to keep whatever interleave level of the source. This is handy to create layer-pairs in standard multi-layer windings
    */
    convenience init(srcLayer:PCH_WdgLayer, sameInterleave:Bool = true, flipStart:Bool = false)
    {
        let newStart = (flipStart ? !srcLayer.startOnBottom : srcLayer.startOnBottom)
        
        var interleaveLevel = srcLayer.interleaveLevel
        var woundTurns = srcLayer.woundTurns
        
        if (!sameInterleave)
        {
            interleaveLevel = 1
            woundTurns = srcLayer.effectiveTurns
        }
        
        self.init(startOnBottom:newStart, interleaveLevel:interleaveLevel, turnDef:srcLayer.turnDef, woundTurns:woundTurns, axialGaps:srcLayer.gaps)
        
    }
    
    /**
        Activate all the effective turns of the layer
    */
    func activateLayer()
    {
        self.activeTurns = self.effectiveTurns
    }
    
    /**
        Deactivate all the effective turns of the layer
    */
    func deactivateLayer()
    {
        self.activeTurns = 0.0
    }
}
