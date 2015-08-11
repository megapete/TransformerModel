//
//  PCH_Insulation.swift
//  TransformerModel
//
//  Created by PeterCoolAssHuber on 2015-07-05.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

// Insulation materials

import Cocoa

class PCH_Insulation: PCH_RawMaterial, CustomStringConvertible {
    
    /**
        The different insulating materials we use (note that Formel is more widely known as "Formvar", but I decided not to use it because of the Weidmann material of teh same name)
    */
    enum Insulation
    {
        case Nomex, Glastic, Paper, TIV, TX, Air, Oil, Vacuum, Formel, Varnish
    }
    
    let material: Insulation
    
    /// static library to convert insulation types into their strings
    static let typeString = [Insulation.Nomex:"Nomex", Insulation.Glastic:"Glastic", Insulation.Paper:"Paper", Insulation.TIV:"TIV", Insulation.TX:"TX", Insulation.Air:"Air", Insulation.Oil:"Oil", Insulation.Vacuum:"Vacuum", Insulation.Formel:"Formel", Insulation.Varnish:"Varnish"]
    
    /// Property required when adopting CustomStringConvertible
    var description: String
    {
        get
        {
            var result = ""
            if let tString = PCH_Insulation.typeString[self.material]
            {
                result = tString
            }
            
            return result
        }
    }
    
    /** 
        The relative permittivity of the material. Note that for materials used in oil, it is assumed that they are oil-soaked for this property. Also note that for some materials (eg: Nomex) teh dielectric constant depends on the thickness of the material. For those materials, the minimum value is returned by this property. If you need more accurate number, use the εRel(thickness:Double) function instead.
    */
    var εRel:Double
    {
        get
        {
            switch(self.material)
            {
                case .Nomex:
                    DLog("This is for Nomex <= 3mil thick - use εRel(thickness:Double) for thicker")
                    return 1.6
                case .Glastic:
                    return 4.2
                case .Paper:
                    return 3.5
                case .TIV:
                    return 4.5
                case .TX:
                    return 4.5
                case .Oil:
                    return 2.2
                case .Formel:
                    return 2.8
                case .Varnish:
                    DLog("This is actually the permittivity of PTFE, which I vaguely recall. TO BE CONFIRMED!")
                    return 2.10
                case .Air:
                    return 1.0006
                default:
                    return 1.0
            }
        }
    }
    
    
    
    /**
        The "shrinkage factor" of the material (eg: if the material shrinks by 10% when dried, its shrinkage factor is equal to 0.9)
    */
    var shrinkageFactor:Double
    {
        get
        {
            switch(self.material)
            {
                case .Paper:
                    return 0.85
                case .TIV:
                    return 0.95
                case .TX:
                    return 0.98
                default:
                    return 1.0
            }
        }
    }
    
    /**
        Designated initializer
    
        - parameter material: The material used to make the insulator. Note that the densities used are either "typical" or "average", depending on what I found on websites.
    */
    init(material:Insulation)
    {
        self.material = material
        
        switch material {
            
        case .Air:
            super.init(name: "", density: 1.225, cost: 0.0)
            
        case .Nomex:
            super.init(name: "", density: 880.0, cost: PCH_Costs.sharedInstance.CostForKey(PCH_Costs.CostKey.Nomex))
            
        case .Glastic:
            super.init(name: "", density: 2000.0, cost: PCH_Costs.sharedInstance.CostForKey(PCH_Costs.CostKey.Glastic))
            
        case .Paper:
            super.init(name: "", density: 635.0, cost: PCH_Costs.sharedInstance.CostForKey(PCH_Costs.CostKey.Paper))
            
        case .TIV:
            super.init(name: "", density: 1180.0, cost: PCH_Costs.sharedInstance.CostForKey(PCH_Costs.CostKey.TIV))
            
        case .TX:
            super.init(name: "", density: 1280.0, cost: PCH_Costs.sharedInstance.CostForKey(PCH_Costs.CostKey.TX))
            
        case .Oil:
            super.init(name: "", density: 835.0, cost: PCH_Costs.sharedInstance.CostForKey(PCH_Costs.CostKey.Oil))
            
        case .Formel:
            super.init(name: "", density: 1230.0, cost: PCH_Costs.sharedInstance.CostForKey(PCH_Costs.CostKey.Formel))
            
        case .Varnish:
            super.init(name: "", density: 1230.0, cost: PCH_Costs.sharedInstance.CostForKey(PCH_Costs.CostKey.Varnish))
            
        case .Vacuum:
            super.init(name: "", density: 0.0, cost: 0.0)
            
        }
    }
    
    /**
        Some materials (eg: Nomex) have different εRel values for different thicknesses. Use this function for those materials.
    
        - parameter thickness: The thickness of the material in meters to use to get the permittivity
    */
    func εRel(thickness:Double) -> Double
    {
        if (self.material == .Nomex)
        {
            if (thickness <= 0.08E-3)
            {
                return 1.6
            }
            else if (thickness <= 0.10E-3)
            {
                return 1.8
            }
            else if (thickness <= 0.13E-3)
            {
                return 2.4
            }
            else if (thickness <= 0.25E-3)
            {
                return 2.7
            }
            else if (thickness <= 0.3E-3)
            {
                return 2.9
            }
            else if (thickness <= 0.38E-3)
            {
                return 3.2
            }
            else if (thickness <= 0.51E-3)
            {
                return 3.4
            }
            else
            {
                return 3.7
            }
        }
        
        return self.εRel
    }

}
