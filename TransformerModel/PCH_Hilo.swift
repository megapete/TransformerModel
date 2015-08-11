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
        
        ZAssert(totalRadialBuild >= 0.0085, message: "The minimum totalRadialBuild is 8.5mm")
        
        // We save the inner diameter into a var because it might change later
        var useInnerDiameter = innerDiameter * 1000.0
        
        // we immediately reduce the radial build we want to work with by 6mm (the final duct). We also convert to mm to make subsequent calculations simpler.
        let radBuildToFill = (totalRadialBuild - 0.006) * 1000.0
        
        // We now figure out how many tubes we're going to need. The first tube will need to be at least 2.5mm, so:
        var firstTubeThk = 2.5
        let solidToFill = totalSolid * 1000.0 - firstTubeThk
        let ductsToFill = radBuildToFill - solidToFill
        let minNumTubes = ceil(solidToFill / 3.5)
        let maxTubeThk = solidToFill / minNumTubes
        let maxNumTubes = ceil(solidToFill / 2.0)
        let minTubeThk = solidToFill / maxNumTubes
        
        // we prefer more tubes that are less thick, so we set that first
        var numTubes = maxNumTubes
        var tubeThk = minTubeThk
        
        // but if the tube thickness is less than 2, we don't like it anymore
        if (tubeThk < 2.0)
        {
            numTubes = minNumTubes
            tubeThk = maxTubeThk
        }
        
        // if the tube thickness is now too big (> 3.5), we alter the first tube thickness and reduce the ID
        if (tubeThk > 3.5)
        {
            DLog("Can't make a suitable tube thickness. Adjusting first tube and ID")
            
            numTubes = 0.0
            firstTubeThk = totalSolid
            useInnerDiameter -= 2.0 * (totalSolid - 2.5)
        }
        
        let firstTube = PCH_Tube(innerDiameter: useInnerDiameter / 1000.0, tubeHt: 1.0, thickness: firstTubeThk / 1000.0)
        var hilo:[PCH_Insulation] = [firstTube]
        
        var currentOuterDiameter = firstTube.outerDiameter / 2.0
        
        for _ in 0..<Int(numTubes)
        {
            let ductThk = ductsToFill / numTubes
            
            let duct = PCH_DuctStrip(paper: nil, strip: PCH_Strip(materialType: PCH_Insulation.Insulation.TIV, stripType: PCH_Strip.StripShape.rectangular, width: 0.018, thickness: ductThk / 1000.0, length: 1.0), ccDistance: currentOuterDiameter * π / Double(numColumns))
            
            hilo.append(duct)
            
            currentOuterDiameter += 2.0 * ductThk / 1000.0
            
            let tube = PCH_Tube(innerDiameter: currentOuterDiameter, tubeHt: 1.0, thickness: tubeThk / 1000.0)
            
            hilo.append(duct)
            
            currentOuterDiameter = tube.outerDiameter
        }
        
        // and now we add the final duct
        hilo.append(PCH_DuctStrip(paper: nil, strip: PCH_Strip(materialType: PCH_Insulation.Insulation.TIV, stripType: PCH_Strip.StripShape.dovetail, width: 0.018, thickness: 0.006, length: 1.0), ccDistance: currentOuterDiameter * π / Double(numColumns)))
        
        self.init(innerDiameter:useInnerDiameter / 1000.0, hilo:hilo)
        
    }
    
    /**
        Convenience initializer to use for the hilo between the core and the first coil. The innermost tube must be 4mm thick and the hilo must be big enough to fit a 6mm duct over the tube and a 4.5mm space between the core and the tube. So the minimum total hilo allowe is 4.5+4+6 = 14.5mm
    
        * The totalRadialBuild must be designed to allow for a 6mm final duct (to allow for disk windings). That is, for a hilo with only a single tube of say, 4mm, the totalRadialBuild must be exactly equal to 10mm. If it is not, the innermost tube thickness will be increased to a maximum of 3.5mm. If that limit is reached, then the innerDiameter will be adjusted so that a final duct of 6mm will result.
    
        * The innermost tube thickness will be adjusted (if necessary) so that it has a minimum thickness of 4mm (to give it some rigidity for winding).
        
        * The outermost duct will be adjusted to have a thickness of 6mm to allow for a standard dovetail strip.
        
        * Tube thicknesses will be rounded to the nearest 0.5mm.
        
        * After returning, the calling routine should check the innerDiameter property of the returned hilo to make sure that it 1s physically possible to drop the coil over the core.
    
        - parameter coreDiameter: The diameter of the circle that exactly encloses the core steps, in meters
        - parameter totalRadialBuild: The total radial build of the hilo, from innerDiameter to the outside of the outermost duct strips
        - parameter totalSolid: The sum of all the radial builds of the tubes in the hilo. This routine will take care of splitting up the solids.
        - parameter numColumns: The number of strips in the oil ducts of the hilo
        
        - returns: A fully defined hilo. The calling routine should check the innerDiameter property of the returned hilo - it may be different than what was originally passed in.
    
    */
    convenience init(coreDiameter:Double, totalRadialBuild:Double, totalSolid:Double, numColumns:UInt)
    {
        ZAssert(totalRadialBuild >= 0.0145, message: "The minimum totalRadialBuild is 14.5mm")
        
        // we immediately reduce the radial build we want to work with by 6mm (the final duct) + 4.5mm (the initial duct). We also convert to mm to make subsequent calculations simpler.
        let radBuildToFill = (totalRadialBuild - 0.006 - 0.0045) * 1000.0
        
        var useInnerDiameter = (coreDiameter + 2.0 * 0.0045) * 1000.0
        
        // We now figure out how many tubes we're going to need. The first tube will need to be at least 2.5mm, so:
        var firstTubeThk = 4.0
        let solidToFill = totalSolid * 1000.0 - firstTubeThk
        let ductsToFill = radBuildToFill - solidToFill
        let minNumTubes = ceil(solidToFill / 3.5)
        let maxTubeThk = solidToFill / minNumTubes
        let maxNumTubes = ceil(solidToFill / 2.0)
        let minTubeThk = solidToFill / maxNumTubes
        
        // we prefer more tubes that are less thick, so we set that first
        var numTubes = maxNumTubes
        var tubeThk = minTubeThk
        
        // but if the tube thickness is less than 2, we don't like it anymore
        if (tubeThk < 2.0)
        {
            numTubes = minNumTubes
            tubeThk = maxTubeThk
        }
        
        // if the tube thickness is now too big (> 3.5), we alter the first tube thickness and reduce the ID
        if (tubeThk > 3.5)
        {
            DLog("Can't make a suitable tube thickness. Adjusting first tube and ID")
            
            numTubes = 0.0
            firstTubeThk = totalSolid
            useInnerDiameter -= 2.0 * (totalSolid - 2.5)
        }
        
        let firstTube = PCH_Tube(innerDiameter: useInnerDiameter / 1000.0, tubeHt: 1.0, thickness: firstTubeThk / 1000.0)
        var hilo:[PCH_Insulation] = [firstTube]
        
        var currentOuterDiameter = firstTube.outerDiameter / 2.0
        
        for _ in 0..<Int(numTubes)
        {
            let ductThk = ductsToFill / numTubes
            
            let duct = PCH_DuctStrip(paper: nil, strip: PCH_Strip(materialType: PCH_Insulation.Insulation.TIV, stripType: PCH_Strip.StripShape.rectangular, width: 0.018, thickness: ductThk / 1000.0, length: 1.0), ccDistance: currentOuterDiameter * π / Double(numColumns))
            
            hilo.append(duct)
            
            currentOuterDiameter += 2.0 * ductThk / 1000.0
            
            let tube = PCH_Tube(innerDiameter: currentOuterDiameter, tubeHt: 1.0, thickness: tubeThk / 1000.0)
            
            hilo.append(duct)
            
            currentOuterDiameter = tube.outerDiameter
        }
        
        // and now we add the final duct
        hilo.append(PCH_DuctStrip(paper: nil, strip: PCH_Strip(materialType: PCH_Insulation.Insulation.TIV, stripType: PCH_Strip.StripShape.dovetail, width: 0.018, thickness: 0.006, length: 1.0), ccDistance: currentOuterDiameter * π / Double(numColumns)))
        
        self.init(innerDiameter:useInnerDiameter / 1000.0, hilo:hilo)
    }
    
    

}
