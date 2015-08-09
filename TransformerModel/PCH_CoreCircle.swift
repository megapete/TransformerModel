//
//  PCH_CoreCircle.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-08.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/**
    Private (for now) function to minimize the core diameter for a given area. The algorithm used here is my own, see DesignCoreSteps.docx of the TME Design Manual

    - parameter requiredArea: The area required in the final core, in sq.m.
    - parameter ducts: Array of doubles indicating where (in terms of width) ducts go
    - parameter sheetThickness: The thickness of a single sheet of steel, in mm
    - parameter lowTolerance: The lower tolerance on the area, in p.u. Defaults to 0.995
    - parameter highTolerance: The upper tolerance on the final area, in p.u. Defaults to 1.01

    - returns: A tuple where the first element is the diameter, in meters; and the second element is an array of core-steps
*/
private func OptimizedCoreDiameter(requiredArea:Double, ducts:[Double]?, sheetThickness:Double, lowTolerance:Double = 0.995, highTolerance:Double = 1.01) -> (Double, [PCH_CoreStep])
{
    // Define a few constants that we use in the algorithm but are kept here for easy editing during testing
    let minStepHt = 10.0 // mm
    let widthIncrement = 10.0 // mm
    let ductThickness = 5.0 // mm
    let tieRodSpace = 25.0 // mm
    
    // Make an initial guess at the diameter in meters
    var diameter = sqrt(0.66 * requiredArea)
    
    // get the initial radius of the core and convert to mm
    var R = diameter / 2.0 * 1000.0
    var area = 0.0
    var W = [Double]()
    
    // Create an array to hold the final results
    var ws = [(width:Double, stack:Double)]()
    
    // Index into the ducts array
    var nextDuctIndex = 0
    
    repeat
    {
        var ductThk = 0.0
        if let ductArray = ducts
        {
            let ductWidth = ductArray[nextDuctIndex] * 1000.0 // convert to mm
            
            if (ductWidth >= floor(2.0 * R / 10.0) * 10.0)
            {
                ductThk = ductThickness / 2.0 // middle duct is effectively split in two
                nextDuctIndex++
            }
        }
        
        // calculate the width of the first stack and the maximum theoretical stack we can get out of it. Note that we actually calculate the number of sheetThicness laminations we can fit in, then multiply by sheetThickness to get the step height. We use this for all subsequent stack height calculations
        var w = floor(2.0 * R / 10.0) * 10.0
        var s = floor((sqrt(R * R - w * w / 4.0) - ductThk) / sheetThickness) * sheetThickness
        
        // check to make sure the step is greater than the minimum allowed
        while (s < minStepHt)
        {
            w -= widthIncrement
            s = floor((sqrt(R * R - w * w / 4.0) - ductThk) / sheetThickness) * sheetThickness
        }
        
        // create a temporary array to hold the current core steps
        var chkWS = [(width:Double, stack:Double)]()
        
        // add the first (index 0) step
        chkWS.append((w,s))
        
        // set up some loop variables
        var sTotal = s
        
        // now we'll enter a loop to calculate the rest of the steps
        while (R - sTotal < tieRodSpace)
        {
            s = 0.0
            while (s < minStepHt)
            {
                w -= widthIncrement
                s = floor((sqrt(R * R - w * w / 4.0) - middleDuct) / sheetThickness) * sheetThickness
            }
        }
    
    
    } while true
}

/// The circle in which the core leg's cross-section is defined. The core steps are defined here along with any ducts that are in the core.

class PCH_CoreCircle
{
    /// The steps that make up the core
    let steps:[PCH_CoreStep]
    
    /// The diameter of the core circle
    let diameter:Double
    
    /**
        Designated initializer to get a core-step design from the V/N, frequency, and a target Bmax.
    
        - parameter targetBmax: The target induction level for the core, in Teslas
        - parameter voltsPerTurn: The V/N of the leg
        - parameter frequency: The frequency (in Hz) of the transformer. Defaults to 60
    */
    init(targetBmax:Double, voltsPerTurn:Double, steelType:PCH_CoreSteel, frequency:Double = 60.0)
    {
        // Using the given parameters, we calculate the required diameter
        let targetArea = voltsPerTurn / (4.44 * targetBmax * frequency)
        
        // Before trying to optimize the diameter, we'll do a quick and dirty calculation of W/sq.m. to see if we need ducts and if so, how many. We'll consider a 1m long section of the core to make calculations fast and easy. This section will definitely evolve during testing.
        let tWt = targetArea * 1 * steelType.density
        let tLoss = tWt * steelType.SpecificLossAtBmax(targetBmax)
        let tDApprox = sqrt(0.66 * targetArea)
        var tSurface = tDApprox * π
        
        var numDucts = 0
        while (tLoss / tSurface > 950.0) // constant that needs to be tested
        {
            if (numDucts == 0)
            {
                tSurface += 2.0 * tDApprox
                numDucts++
            }
            else
            {
                tSurface += 4.0 * tDApprox * 0.7 // another constant that needs to be tested
                numDucts += 2
            }
        }
        
        (self.diameter, self.steps) = OptimizedCoreDiameter(targetArea, numDucts: numDucts, sheetThickness: steelType.thickness)
    }
    
    
}
