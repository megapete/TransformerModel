//
//  PCH_Radiator.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-13.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// A simplified radiator struct. It is assumed that the radiator is a standard "Menk-type"

struct PCH_Radiator {

    let numPanels:Int
    
    let panelDimensions:(width:Double, height:Double)
    
    var radSurface:Double {
        
        get {
            
            return Double(numPanels) * 2.0 * self.panelDimensions.width * self.panelDimensions.height
        }
    }
}
