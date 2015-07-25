//
//  PCH_WdgTappedDisk.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-24.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// A disk that has at least one tap brought out (besides the start and finish of the disk)

class PCH_WdgTappedDisk: PCH_WdgDisk {

    /**
        The locations of the taps (in turns after the start)
    */
    let tapLocations:[Double]
    
    /**
        Designated initializer
    
        - parameter startInside: Boolean to indicate whether the start of the disk is on top or bottom (generally only useful for winding starts, finishes, or breaks)
        - parameter interleaveLevel: UInt which indicates the "interleave level" of the disk (1 = no interleave, 2 = 2 conds, 4 = 4 conds, etc)
        - parameter turn: The PCH_WdgTurn that defines each turn of the disk
        - parameter woundTurns: The number of turns the winder will actually put on the disk
        - parameter tapLocs: The turns (after the start) where taps will be brought out
        - parameter ducstStrip: A PCH_DuctStrip that defines all ducts in the disk. Pass nil for no ducts. Note that ducts will be evenly distributed in the disk.
        - parameter numDucts: The number of ducts in the disk
    */
    
    init(startInside:Bool, interleaveLevel:UInt, turn:PCH_WdgTurn, woundTurns:Double, tapLocs:[Double], ductStrip:PCH_DuctStrip? = nil, numDucts:Int = 0)
    {
        self.tapLocations = tapLocs
        
        super.init(startInside: startInside, interleaveLevel: interleaveLevel, turn: turn, woundTurns: woundTurns, ductStrip:ductStrip, numDucts:numDucts)
    }
    
    /**
        Function to activate only some turns of the disk. The tap index is the index into the tapLocations property. If index is less than 0 all the turns are deactivated. If index is greater than the highest index, all turns are activated.
    */
    func activateToTapIndex(index:Int)
    {
        if (index < 0)
        {
            self.deactivateDisk()
        }
        else if (index >= tapLocations.count)
        {
            self.activateDisk()
        }
        else
        {
            self.activeTurns = tapLocations[index]
        }
    }
}
