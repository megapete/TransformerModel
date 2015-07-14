//
//  PCH_Insulation.swift
//  TransformerModel
//
//  Created by PeterCoolAssHuber on 2015-07-05.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

// Insulation materials

import Cocoa

class PCH_Insulation: PCH_RawMaterial {
    
    enum Insulation
    {
        case Nomex, Glastic, Paper, TIV, TX, Air, Oil, Vacuum, Formel, Varnish
    }
    
    var material: Insulation
    
    /** The relative permittivity of the material
    */
    var εRel:Double = 1.0
    
    /** The absolute permittivity (computed)
    */
    var ε: Double
    {
        get
        {
            return εRel * ε0
        }
        
        set(newPermittivity)
        {
            εRel = newPermittivity / ε0
        }
    }
    
    /**
        Designated initializer
    */
    init(name: String, density: Double, cost: Double, material:Insulation, εRel:Double)
    {
        self.material = material
        self.εRel = εRel
        
        super.init(name: name, density: density, cost: cost)
    }

}
