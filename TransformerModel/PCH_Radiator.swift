//
//  PCH_Radiator.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-13.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// A simplified radiator class. It is assumed that the radiator is a standard "Menk-type"

struct PCH_Radiator {

    /// The standard width of a Menk panel (constant)
    static let standardWidth = 20.5 * 25.4 / 1000.0
    
    /// The maximum number of panels on a rad (constant)
    static let maxPanels = 32
    
    /// The number of panels on the rad
    let numPanels:Int
    
    /// The dimensions of one panel
    let panelDimensions:(width:Double, height:Double)
    
    /// The surface available for heat dissipation (in sq.m.)
    var radSurface:Double {
        
        get {
            
            return Double(numPanels) * 2.0 * self.panelDimensions.width * self.panelDimensions.height
        }
    }
    
    /// The width available for fans, to the nearest 10mm.
    var widthForFans:Double {
        
        get {
            
            return ceil(Double(numPanels) * 0.045 * 100.0) / 100.0
        }
    }
}
