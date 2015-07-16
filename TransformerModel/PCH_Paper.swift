//
//  PCH_Paper.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-08.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

import Cocoa

class PCH_Paper: PCH_Insulation {

    enum PaperType
    {
        case Plain, SingleSideDot, DoubleSideDot
    }
    
    var paperType:PaperType
    
    var thickness:Double
    var width:Double
    var length:Double
    
    init(type:PaperType, thickness:Double, width:Double, length:Double)
    {
        self.paperType = type
        self.thickness = thickness
        self.width = width
        self.length = length
        
        super.init(name: "Kraft paper", density: 1000.0, cost: PCH_Costs.sharedInstance.CostForKey(PCH_Costs.CostKey.Paper), material: Insulation.Paper, εRel: 1.0)
    }
}
