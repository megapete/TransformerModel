//
//  PCH_Paper.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-08.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

/// Paper (insuldur) class. Used for sheets of paper (ie: not conductor cover).

class PCH_Paper: PCH_Insulation {

    /**
        The different types of paper available.
    
        - Plain
        - SingleSideDot
        - DoubleSideDot
    */
    enum PaperType
    {
        case Plain, SingleSideDot, DoubleSideDot
    }
    
    /**
        The type of paper.
    */
    var type:PaperType
    
    /**
        The description of the insulating paper
    */
    var description: String
    {
        get
        {
            switch (self.type)
            {
                case .Plain:
                    return "Insuldur"
                case .SingleSideDot:
                    return "One sided epoxy diamond-dot, insuldur"
                case .DoubleSideDot:
                    return "Double-sided epoxy diamond dot, insuldur"
            }
        }
    }
    
    /**
        Dimensions of the paper. Width is the axial-direction dimension. 
    */
    var dimensions: (thickness:Double, width:Double, length:Double)
    
    /**
        Designated initializer
    
        :param: type The type of paper
        :param: thickness The thickness of the paper used
        :param: width The width of the paper (only used for interlayer or hilo sheets)
        :param: length The length of the paper (only used for interlayer or hilo sheets)
    */
    init(type:PaperType, thickness:Double, width:Double, length:Double)
    {
        self.type = type
        self.dimensions.thickness = thickness
        self.dimensions.width = width
        self.dimensions.length = length
        
        super.init(name: "", density: 1000.0, cost: PCH_Costs.sharedInstance.CostForKey(PCH_Costs.CostKey.Paper), material: Insulation.Paper, εRel: 1.0)
        
        self.name = self.description
    }
}
