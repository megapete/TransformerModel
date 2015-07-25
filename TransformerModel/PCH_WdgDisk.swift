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
        The turn that defines the disk. It is assumed that in the case of an interleaved disk, all conductors are made up of this turn. Note that this property should also be used to calculate the shrunk/unshrunk dimensions of the disk itself.
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
        The number of turns that are active (carrying current) on the disk (equal to 0.0 or effectiveTurns, which is the default)
    */
    var activeTurns:Double
    
    /**
        Definition of duct strips. Ducts are distributed evenly through the turns of the disk.
    */
    let ductStrip:PCH_DuctStrip?
    
    /** 
        Number of duct strips
    */
    let numDucts:Int
    
    /**
        The radial build of the disk: 'exact' does not take into account the helix, 'roundup' does
    */
    let radialBuild:(exact:Double, roundup:Double)
    
    /**
        Designated initializer
        
        - parameter startInside: Boolean to indicate whether the start of the disk is on top or bottom (generally only useful for winding starts, finishes, or breaks)
        - parameter interleaveLevel: UInt which indicates the "interleave level" of the disk (1 = no interleave, 2 = 2 conds, 4 = 4 conds, etc)
        - parameter turn: The PCH_WdgTurn that defines each turn of the disk
        - parameter woundTurns: The number of turns the winder will actually put on the disk
        - parameter ducstStrip: A PCH_DuctStrip that defines all ducts in the disk. Pass nil for no ducts. Note that ducts will be evenly distributed in the disk.
        - parameter numDucts: The number of ducts in the disk
    */
    init(startInside:Bool, interleaveLevel:UInt, turn:PCH_WdgTurn, woundTurns:Double, ductStrip:PCH_DuctStrip? = nil, numDucts:Int = 0)
    {
        self.startOnID = startInside
        self.interleaveLevel = (interleaveLevel == 0 ? 1 : interleaveLevel)
        self.turnDef = turn
        self.woundTurns = woundTurns
        self.effectiveTurns = woundTurns * Double(self.interleaveLevel)
        self.activeTurns = self.effectiveTurns
        self.ductStrip = ductStrip
        self.numDucts = (ductStrip == nil ? 0 : numDucts)
        
        // we calculate the radial build here and stuff it into a property
        var radBuild:Double = (ductStrip == nil ? 0.0 : Double(self.numDucts) * ductStrip!.radialDimension)
        radBuild += (woundTurns * Double(self.interleaveLevel) * turn.unshrunkDimensionOverCover.radial)
        
        // We add one turn's dimension for the 'roundup' field
        self.radialBuild = (radBuild, radBuild + Double(self.interleaveLevel) * turn.unshrunkDimensionOverCover.radial)
        
    }
    
    /**
        Activate all the effective turns of the disk
    */
    func activateDisk()
    {
        self.activeTurns = self.effectiveTurns
    }
    
    /**
        Deactivate all the effective turns of the disk
    */
    func deactivateDisk()
    {
        self.activeTurns = 0.0
    }
}
