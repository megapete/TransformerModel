//
//  PCH_Hilo.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-02.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// An enum that can be used anywhere in the program as standard BIL levels
enum BIL_Level:String {
    
    case KV10
    case KV20
    case KV30
    case KV45
    case KV50
    case KV60
    case KV75
    case KV95
    case KV110
    case KV125
    case KV150
    case KV170
    case KV200
    case KV250
    case KV350
    case KV450
    case KV550
    case KV650
    case KV750
    case KV850
    case KV950
    case KV1050
    
    /// Create a static dictionary that maps each defined BIL level to it's string (for use as a key in other dictionaries)
    static let bilNames = [KV10:"10", KV20:"20", KV30:"30", KV45:"45", KV50:"50", KV60:"60", KV75:"75", KV95:"95", KV110:"110", KV125:"125", KV150:"150", KV170:"170", KV200:"200", KV250:"250", KV350:"350", KV450:"450", KV550:"550", KV650:"650", KV750:"750", KV850:"850", KV950:"950", KV1050:"1050"]
    
    
    /// Since we have the BIL levels available as numerical strings, we'll just convert them to UInts for use wherever needed
    func Value() -> UInt
    {
        var result:UInt = 0
        
        if let bilName:String = BIL_Level.bilNames[self]
        {
            result = UInt(bilName)!
        }
        
        return result
    }
}

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
        An optional height for the hilo
    */
    var height:Double?
    
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
    
    /**
        Convenience initializer that creates a hilo of a given overall radial dimension with a defined total thickness of solid (ala Frank's old hilo design sheet). Note that this initializer should NOT be used to create the innermost (ie: to the core) hilo. Use the initializer that is specifically designed for that purpose.
    
        * The totalRadialBuild must be designed to allow for a 6mm final duct (to allow for disk windings). That is, for a hilo with only a single tube of say, 2.5mm, the totalRadialBuild must be exactly equal to 8.5mm. If it is not, the innermost tube thickness will be increased to a maximum of 3.5mm. If that limit is reached, then the innerDiameter will be adjusted so that a final duct of 6mm will result.
    
        * The innermost tube thickness will be adjusted (if necessary) so that it has a minimum thickness of 2.5mm (to give it some rigidity for winding).
    
        * The outermost duct will be adjusted to have a thickness of 6mm to allow for a standard dovetail strip.
    
        * Tube thicknesses will be rounded to the nearest 0.5mm.
    
        * After returning, the calling routine should check the innerDiameter property of the returned hilo - it may be different than what was originally passed in.
    
        - parameter innerDiameter: The innermost diameter of the innermost TUBE. Note that this implies that whatever strips are used between the previous coil and this tube must be considered elsewhere
        - parameter totalRadialBuild: The total radial build of the hilo, from innerDiameter to the outside of the outermost duct strips
        - parameter totalSolid: The sum of all the radial builds of the tubes in the hilo. This routine will take care of splitting up the solids.
        - parameter numColumns: The number of strips in the oil ducts of the hilo
    
        - returns: A fully defined hilo. The calling routine should check the innerDiameter property of the returned hilo - it may be different than what was originally passed in.
    */
    convenience init(innerDiameter:Double, totalRadialBuild:Double, totalSolid:Double, numColumns:UInt)
    {
        // We have a few built-in prejudices here. The final duct will be 6mm (for dovetails). The innermost tube will be at least 2.5mm. The minimum solid thickness is 2mm and the maximum is 3.5mm.
        
        
    }
    
    /**
        Convenience initializer to use for the hilo between the core and the first coil
    */
    convenience init(coreDiameter:Double, totalRadialBuild:Double, totalSolid:Double, numColumns:UInt)
    {
        
    }
    
    

}
