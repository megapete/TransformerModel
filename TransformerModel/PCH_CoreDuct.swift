//
//  PCH_CoreDuct.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-08.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// A core duct is defined as a subclass of PCH_CoreStep to make things easier. They usually use duct strips of 5mm thick. For now, it is only possible to create this "standard" duct. Note that while this definition can be used as the basis for specifying the duct material to purchase, it should not be used directly to do so (ie: use the ductstrip defined as a property herein to create a new ductstrip(s) for specification purposes).

class PCH_CoreDuct: PCH_CoreStep
{
    /// The ductstrip used to make the core duct
    let ductstrip:PCH_DuctStrip
    
    /// The width of the step where the duct will be installed
    let width:Double
    
    /**
        Designated initializer
    */
    init(width:Double)
    {
        self.width = width
        
        self.ductstrip = PCH_DuctStrip(paper: nil, strip: PCH_Strip(materialType: PCH_Insulation.Insulation.TX
            , stripType: PCH_Strip.StripShape.rectangular, width: 0.0065, thickness: 0.005, length: 1.0), ccDistance: 0.030)
        
        super.init(lamination: nil, stackHeight: 0.005)
    }
}
