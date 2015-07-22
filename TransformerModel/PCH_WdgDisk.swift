//
//  PCH_WdgDisk.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-21.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// A standard winding disk

class PCH_WdgDisk {

    /**
        Bool to indicate whether the start of the disk is on the ID (easy disk) or not (drop-down disk)
    */
    let startOnID:Bool
    
    /**
        UInt which indicates the "interleave level" of the disk (1 = no interleave, 2 = 2 conds, 4 = 4 conds, etc)
    */
    let interleaveLevel:UInt
    
    /**
        The turn that defines the disk. It is assumed that in the case of an interleaved disk, all conductors are made up of this turn.
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
        Definition of duct strips. Ducts are distributed evenly through the turns of the disk.
    */
    let ductStrip:PCH_DuctStrip?
    
    /** 
        Number of duct strips
    */
    let numDucts:Int
    
    init(startInside:Bool, interleaveLevel:UInt, turn:PCH_WdgTurn, woundTurns:Double, ductStrip:PCH_DuctStrip? = nil, numDucts:Int = 0)
    {
        self.startOnID = startInside
        self.interleaveLevel = (interleaveLevel == 0 ? 1 : interleaveLevel)
        self.turnDef = turn
        self.woundTurns = woundTurns
        self.effectiveTurns = woundTurns * Double(self.interleaveLevel)
        self.ductStrip = ductStrip
        self.numDucts = (ductStrip == nil ? 0 : numDucts)
    }
}
