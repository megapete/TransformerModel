//
//  PCH_Hilo.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-02.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// A class for Hilos, which are (usually) made up of alternating duct strips and tubes.

class PCH_Hilo {
    
    /**
        An array of alternating duct strips and tubes that make up the hilo
    */
    let hilo:[PCH_Insulation]
    
    /**
        The inner diameter of the hilo
    */
    let innerDiameter:Double
    
    /**
        The radial build of the hilo (computed property)
    */
    var radialBuild:Double
    {
        get
        {
            var result:Double = 0.0
            
            for nextIns in self.hilo
            {
                if (nextIns is PCH_DuctStrip)
                {
                    result += (nextIns as! PCH_DuctStrip).radialDimension
                }
                else if (nextIns is PCH_Tube)
                {
                    result += (nextIns as! PCH_Tube).thickness
                }
                else
                {
                    ALog("Hilos must be made up of duct strips or tubes!")
                }
            }
            
            return result
        }
    }
    
    /**
        The outer diameter of the hilo
    */
    var outerDiameter:Double
    {
        get
        {
            return self.innerDiameter + 2.0 * self.radialBuild
        }
    }
    
    /**
        Designated initializer
    
        - parameter innerDiameter: The inner diameter of the hilo
        - parameter hilo: An array of (usually) alternating duct strips and tubes
    */
    init(innerDiameter:Double, hilo:[PCH_Insulation])
    {
        self.innerDiameter = innerDiameter
        self.hilo = hilo
    }

}
