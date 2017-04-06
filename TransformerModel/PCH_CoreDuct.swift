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
        
        self.ductstrip = PCH_DuctStrip(paper: nil, strip: PCH_Strip(materialType: PCH_Insulation.Insulation.tx
            , stripType: PCH_Strip.StripShape.rectangular, width: 0.0065, thickness: 0.005, length: 1.0), ccDistance: 0.030)
        
        super.init(lamination: nil, stackHeight: 0.005)
    }
    
    // Required overrides
    
    /**
        The NetArea function returns the "magnetic" part of the core circle. Obviously, a cooling duct does not have any magentic material in it, so we return 0.0
    */
    override func NetArea() -> Double
    {
        return 0.0
    }
    
    /**
        Function to calculate the Weight of the duct in the core
        
        - parameter length: The length of core for which we want to calculate the weight
    */
    override func WeightForLength(_ length: Double) -> Double
    {
        // This is a bit nuts, but the way that the PCH_DuctStrip calculates weight (ie: it's definitions of weight and length) are opposite those of a core duct
        return self.ductstrip.WeightOfWidth(length, length: self.width)
    }
    
    /**
        The LossForLength function only returns a meaningful result for magnetic material, which this is not - so we return 0.0
    */
    override func LossForLength(_ length: Double, atBmax: Double) -> Double
    {
        return 0.0
    }
    
    
}
