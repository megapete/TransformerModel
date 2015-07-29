//
//  PCH_Coil.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-27.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// The coil class. A coil is a collection (array) of PCH_CoilSections and occupying a fixed radial location and full electrical height of the transformer. There is always a PCH_Hilo on each side (radially) of the coil (but these are defined in the class PCH_Phase). There is insulation to the top and bottom yoke (edge packs or blocks, or a combination of both). There may be axial insulation and/or radial insulation between sections. The indices of the PCH_CoilSection array start at (axial=0, radial=0) being the section closest to the core and closest to the bottom yoke. Axial insulation indices match the lower section (ie: axial insulation between sections (0,0) and (1,0) would be at index 0. The same is true for radial insulations.

class PCH_Coil
{
    /**
        The array of coil sections that make up the coil
    */
    var coilSections:[[PCH_CoilSection]]?
    
    /**
        A struct that defines one "chunk" of intersection insulation
    */
    struct InterSectionInsulation
    {
        /**
            Bool to indicate whether the insulation is axial or radial
        */
        let isAxial:Bool
        
        /**
            The array of PCH_Insulation subclasses that make up the chunk of insulation
        */
        var insulation:[PCH_Insulation]
        
        /**
            Designated initializer
        
            - parameter isAxial: Bool to indicate whether the insulation is axial or radial
            - parameter insulation: The array of PCH_Insulation subclasses that make up the chunk of insulation
        */
        init(isAxial:Bool, insulation:[PCH_Insulation])
        {
            self.isAxial = isAxial
            self.insulation = insulation
        }
        
        /**
            Convenience initializer to create a chunk of axial insulation from a given number of a specified radial spacer
        */
        init(axialGapWithRadialSpacer:PCH_RadialSpacer, numSpacers:Int)
        {
            let insArray = [PCH_RadialSpacer](count: numSpacers, repeatedValue: axialGapWithRadialSpacer)
            
            self.init(isAxial:true, insulation:insArray)
        }
        
        /**
            Function that returns the axial dimension of an axial insulation or the radial dimension of radial insulation
        */
        func Dimension() -> Double
        {
            var result:Double = 0.0
            
            if (self.isAxial)
            {
                for nextInsulation in insulation
                {
                    if (nextInsulation is PCH_RadialSpacer)
                    {
                        result += (nextInsulation as! PCH_RadialSpacer).T * nextInsulation.shrinkageFactor
                    }
                    else if (nextInsulation is PCH_Board)
                    {
                        result += (nextInsulation as! PCH_Board).width * nextInsulation.shrinkageFactor
                    }
                    else
                    {
                        ALog("Axial intersection insulation must eb made up of either radial spacers (for disk & helical coils) or board (for layer coils)")
                    }
                }
            }
            else
            {
                for nextInsulation in insulation
                {
                    if (nextInsulation is PCH_Board)
                    {
                        result += (nextInsulation as! PCH_Board).thickness
                    }
                    else if (nextInsulation is PCH_DuctStrip)
                    {
                        result += (nextInsulation as! PCH_DuctStrip).radialDimension
                    }
                    else
                    {
                        ALog("Radial intersection insulation must be made up of either duct strips or board")
                    }
                }

            }
            
            return result
        }
    }
    
    var intersectionInsulation:[[InterSectionInsulation]]?
    
    
    
}
