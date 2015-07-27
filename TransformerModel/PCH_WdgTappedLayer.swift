//
//  PCH_WdgTappedLayer.swift
//  TransformerModel
//
//  Created by PeterCoolAssHuber on 2015-07-26.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// A layer that has at least one tap brought out (besides the start and finish of the layer)

class PCH_WdgTappedLayer: PCH_WdgLayer {

    /**
        The locations of the taps (in turns after the start)
    */
    let tapLocations:[Double]
    
    /**
        Designated initializer
        
        - parameter startOnBottom: Bool to indicate whether the start of the disk is on bottom or top of the coil
        - parameter interleaveLevel: UInt which indicates the "interleave level" of the layer (1 = no interleave, 2 = 2 conds, 3 = 3 conds, etc)
        - parameter turnDef: The turn definition used for the layer
        - parameter woundTurns: The number of turns the winder must wind
        - parameter tapLocs: The turns (after the start) where taps will be brought out
        - parameter vertSpBoardDef: The PCH_Board definition for vertical spaces in the layer (if any)
        - parameter numVertSpBoard: The number of vertical spacers in the layer
    */
    init(startOnBottom:Bool, interleaveLevel:UInt, turnDef:PCH_WdgTurn, woundTurns:Double, tapLocs:[Double], vertSpBoardDef:PCH_Board? = nil, numVerticalSpacers:Int = 0)
    {
        self.tapLocations = tapLocs
        
        super.init(startOnBottom: startOnBottom, interleaveLevel: interleaveLevel, turnDef: turnDef, woundTurns: woundTurns, vertSpBoardDef: vertSpBoardDef, numVerticalSpacers: numVerticalSpacers)
    }
    
    /**
        Convenience initializer that takes an existing layer as its base and adds taps in the given locations
        
        - parameter srcLayer: The layer to use as a base
        - parameter tapLocs: The turn number(s) where taps are to be located
    */
    convenience init(srcLayer:PCH_WdgLayer, tapLocs:[Double])
    {
        self.init(startOnBottom:srcLayer.startOnBottom, interleaveLevel:srcLayer.interleaveLevel, turnDef:srcLayer.turnDef, woundTurns:srcLayer.woundTurns, tapLocs:tapLocs, vertSpBoardDef:srcLayer.verticalSpacingBoard, numVerticalSpacers:srcLayer.numVerticalSpacers)
    }
    
    /**
        Function to activate only some turns of the layer. The tap index is the index into the tapLocations property. If index is less than 0 all the turns are deactivated. If index is greater than the highest index, all turns are activated.
    */
    func activateToTapIndex(index:Int)
    {
        if (index < 0)
        {
            self.deactivateLayer()
        }
        else if (index >= tapLocations.count)
        {
            self.activateLayer()
        }
        else
        {
            self.activeTurns = tapLocations[index]
        }
    }
}
