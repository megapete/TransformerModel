//
//  PCH_DuctStrip.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-21.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

import Cocoa

class PCH_DuctStrip {

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
    }
    
    
}