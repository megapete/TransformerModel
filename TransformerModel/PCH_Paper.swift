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
    override var description: String
    {
        get
        {
            var result:String
            
            switch (self.type)
            {
                case .Plain:
                    result = "Insuldur"
                case .SingleSideDot:
                    result = "One sided epoxy diamond-dot, insuldur"
                case .DoubleSideDot:
                    result = "Double-sided epoxy diamond dot, insuldur"
            }
            
            return result + " \(self.dimensions.thickness) x \(self.dimensions.width) x \(self.dimensions.length) (TxWxL)"
        }
    }
    
    /**
        Dimensions of the paper. Width is the axial-direction dimension. 
    */
    var dimensions: (thickness:Double, width:Double, length:Double)
    
    /**
        Designated initializer
    
        - parameter type: The type of paper
        - parameter thickness: The thickness of the paper used
        - parameter width: The width of the paper (only used for interlayer or hilo sheets)
        - parameter length: The length of the paper (only used for interlayer or hilo sheets)
    */
    init(type:PaperType, thickness:Double, width:Double, length:Double)
    {
        self.type = type
        self.dimensions.thickness = thickness
        self.dimensions.width = width
        self.dimensions.length = length
        
        super.init(material: .Paper)
        
        self.name = self.description
    }
    
}
