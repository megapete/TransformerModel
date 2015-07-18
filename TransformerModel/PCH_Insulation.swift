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
    
    let material: Insulation
    
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
        The "shrinkage factor" of the material (eg: if the material shrinks by 10% when dried, its shrinkage factor is equal to 0.9)
    */
    let shrinkageFactor:Double
    
    /**
        Designated initializer
    */
    init(name: String, density: Double, cost: Double, material:Insulation, shrinkageFactor:Double, εRel:Double)
    {
        self.material = material
        self.shrinkageFactor = shrinkageFactor
        self.εRel = εRel
        
        super.init(name: name, density: density, cost: cost)
    }

}
