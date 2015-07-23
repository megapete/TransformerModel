//
//  PCH_WdgLayer.swift
//  TransformerModel
//
//  Created by PeterCoolAssHuber on 2015-07-23.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

import Cocoa

// A standard winding layer

class PCH_WdgLayer {

    /**
        Bool to indicate whether the start of the disk is on bottom or top of the coil
    */
    let startOnBottom:Bool
    
    /**
        UInt which indicates the "interleave level" of the layer (1 = no interleave, 2 = 2 conds, 3 = 3 conds, etc)
    */
    let interleaveLevel:UInt
    
    /**
        The turn that defines the layer. It is assumed that in the case of an interleaved layer, all conductors are made up of this turn. Note that this property should also be used to calculate the shrunk/unshrunk dimensions of the layer itself.
    */
    let turnDef:PCH_WdgTurn
    
    /**
        The amount of wound turns of the disk
    */
    let woundTurns:Double
    
    /**
        The effective number of turns on the disk
    */
    let effectiveTurns:Double
    
    /**
        The board used for any vertical spacing in the layer. These boards are evenly distributed in the layer.
    */
    let verticalSpacingBoard:PCH_Board?
    
    /**
        The number of vertical spacers in the layer.
    */
    let numVerticalSpacers:Int
    
    /**
        Axial dimensions of the layer (exact, withHelix)
    */
    let axialBuild:(exact:Double, withHelix:Double)
    
    /**
        Designated initializer
    
        :param: startOnBottom Bool to indicate whether the start of the disk is on bottom or top of the coil
        :param: interleaveLevel UInt which indicates the "interleave level" of the layer (1 = no interleave, 2 = 2 conds, 3 = 3 conds, etc)
        :param: turnDef The turn definition used for the layer
        :param: woundTurns The number of turns the winder must wind
        :param: vertSpBoardDef The PCH_Board definition for vertical spaces in the layer (if any)
        :param: numVertSpBoard The number of vertical spacers in the layer
    */
    init(startOnBottom:Bool, interleaveLevel:UInt, turnDef:PCH_WdgTurn, woundTurns:Double, vertSpBoardDef:PCH_Board? = nil, numVerticalSpacers:Int = 0)
    {
        self.startOnBottom = startOnBottom
        self.interleaveLevel = interleaveLevel
        self.turnDef = turnDef
        self.woundTurns = woundTurns
        self.effectiveTurns = woundTurns * Double(self.interleaveLevel)
        self.verticalSpacingBoard = vertSpBoardDef
        self.numVerticalSpacers = (vertSpBoardDef == nil ? 0 : numVerticalSpacers)
        
        // calculate the axial height and stuff it into a property
        var axialHt = (self.verticalSpacingBoard == nil ? 0.0 : Double(self.numVerticalSpacers) * self.verticalSpacingBoard!.width)
        
        axialHt += turnDef.shrunkDimensionOverCover.axial * Double(self.interleaveLevel) * self.woundTurns
        
        axialBuild = (axialHt, axialHt + turnDef.shrunkDimensionOverCover.axial * Double(self.interleaveLevel))
        
    }
}
