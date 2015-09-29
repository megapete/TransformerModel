//
//  PCH_Transformer.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-13.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Foundation

/// A struct that fully defines a transformer. It's a struct so that we can do simple copy assignments even though the member properties are all classes (to keep from excessive copying during optimization). For now, only the active part and a simple "tank" (for oil calculations) are modeled.

struct PCH_Transformer {
    
    /// The core of the transformer
    let core:PCH_Core
    
    /// The definition of one wound leg of the transformer
    let phase:PCH_Phase
    
    /// The definition of the tank that the transformer is in
    let tank:PCH_Tank
    
    /// An array of radiator banks on the transformer. This is an optional since it is possible that a transformer does not need any radiators for sufficient cooling (the tank is enough).
    let radBanks:[PCH_RadBank]?
    
    /// The number of phases of the transformer. Note that for now, this is essentially limited to the values 1 or 3.
    let numPhases:Int = 1
    
    
    
}