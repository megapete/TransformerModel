//
//  PCH_WdgTurn.swift
//  TransformerModel
//
//  Created by PeterCoolAssHuber on 2015-07-19.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// This class represents the combination of cables that make up a winding "turn" (ie: this is what the winder has to wind onto the winding mould)

class PCH_WdgTurn {
    
    /**
        A two-dimensional array representing the cables that make up the turn. Note that row indices (first index) refer to the cables in the radial direction, with index 0 being closest to the core. Column indices (second index) refer to cables in the axial direction, with 0 being closest to the bottom
    */
    var cableArray = [[PCH_WdgCable]]()
    
    /**
        A two-dimensional array representing the insulation structures in between the cables in cableArray. By definition, this array will have one less index in each direction than cableArray. Entries may be nil.
    */
    var interCableArray = [[PCH_Insulation?]]()

}
