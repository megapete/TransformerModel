//
//  PCH_Phase.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-02.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// A PCH_Phase is the entirety of coils and insulation that goes on one leg of the transformer (strictly speaking, calling it PCH_Phase is not really accurate for single phase transformers that are on two legs).

class PCH_Phase {

    /**
        An array of coils, where index 0 is closest to the core, 1 is next, etc.
    */
    let coils:[PCH_Coil]
    
    /**
        An array of hilos, where index 0 is the Hilo between coil 0 and 1, index 1 is between 1 and 2, etc. There is also the possibility of a "hilo" over the final coil, so the count of this array is equal to the count of the coils array. Note that this array is mutable to allow small changes to match required impedances.
    */
    var hilos:[PCH_Hilo]
    
    /**
        Designated initializer
    
        - parameter coils: The array of PCH_Coils that make up the phase
        - parameter hilos: The array of hilos that in between coils (and between the core and first coil, as well as over the final coil)
    */
    init(coils:[PCH_Coil], hilos:[PCH_Hilo])
    {
        self.coils = coils
        self.hilos = hilos
    }
}
