//
//  PCH_Board.swift
//  TransformerModel
//
//  Created by PeterCoolAssHuber on 2015-07-23.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

import Cocoa

class PCH_Board: PCH_Insulation {

    /**
        The dimensions of the board (note that for coils, thickness=radial, width=axial
    */
    var width:Double
    var thickness:Double
    var length:Double
    
    init(width:Double, thickness:Double, length:Double)
    {
        self.width = width
        self.thickness = thickness
        self.length = length
        
        super.init(material: PCH_Insulation.Insulation.TIV)
    }
}
