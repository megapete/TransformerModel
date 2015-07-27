//
//  PCH_DuctStrip.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-21.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// A class for creating instances of duct strip. Note that this class is derived from PCH_Insulation even though it is actually a combination of other materials. It has to be derived from PCH_Insulation so that it can be "downcast".

class PCH_DuctStrip:PCH_Insulation {

    /**
        The backing paper of the duct strip. Note that the backing paper is an optional property (it makes life easier to define simple ducts as a ductsrip with no paper)
    */
    let backingPaper:PCH_Paper?
    
    /**
        The strip of the duct strip
    */
    let strip:PCH_Strip
    
    /**
        The center-center distance between strips
    */
    let ccDist:Double
    
    /**
        The radial dimension of the duct spacer
    */
    var radialDimension:Double
    {
        get
        {
            let paperDim = (backingPaper == nil ? 0.0 : backingPaper!.dimensions.thickness)
            
            return strip.thickness + paperDim
        }
    }
    
    /**
        Designated initializer
    
        - parameter paper: The backing paper for the duct strip
        - parameter strip: The insulating strip used on the duct strip
        - parameter ccDistance: The distance (center-center) between strips
    */
    init(paper:PCH_Paper?, strip:PCH_Strip, ccDistance:Double)
    {
        self.backingPaper = paper
        self.strip = strip
        self.ccDist = ccDistance
        
        // A duct strip is mostly oil, so we'll define it as such. However, the permittivity should be overriden to take into account the solids in the duct strip.
        super.init(material: .Oil)
    }
    
    
}
