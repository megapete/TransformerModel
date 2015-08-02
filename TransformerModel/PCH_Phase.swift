//
//  PCH_Phase.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-02.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

class PCH_Phase {

    let coils:[PCH_Coil]
    
    let hilos:[PCH_Hilo]
    
    init(coils:[PCH_Coil], hilos:[PCH_Hilo])
    {
        self.coils = coils
        self.hilos = hilos
    }
}
