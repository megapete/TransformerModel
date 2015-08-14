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
    
    let core:PCH_Core
    
    let phase:PCH_Phase
    
    
    
}