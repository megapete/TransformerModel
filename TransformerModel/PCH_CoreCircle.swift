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

    - returns: A tuple where the first element is the diameter, in meters; and the second element is an array of core-step tuples (width, stack) with both elements in mm, that represent half the core.
*/
private func OptimizedCoreDiameter(requiredArea:Double, ducts:[Double]?, sheetThickness:Double, lowTolerance:Double = 0.995, highTolerance:Double = 1.01) -> (Double, [(width:Double, stack:Double)])
{
    // Define a few constants that we use in the algorithm but are kept here for easy editing during testing
    let minStepHt = 10.0 // mm
    let widthIncrement = 10.0 // mm
    let ductThickness = 5.0 // mm
    let tieRodSpace = 25.0 // mm
    let radiusChangeStep = 1.0 // mm
    
    let lowArea = requiredArea * lowTolerance
    let hiArea = requiredArea * highTolerance
    
    // Make an initial guess at the diameter in meters
    let diameter = sqrt(0.66 * requiredArea)
    
    // get the initial radius of the core and convert to mm
    var R = diameter / 2.0 * 1000.0
    
    
    // Create an array to hold the final results
    var ws:[(width:Double, stack:Double)]
    
    // Loop variables 
    
    // Index into the ducts array
    var nextDuctIndex = 0
    
    // We need to check for thrashing, so we'll create a variable to keep track of direction changes
    var direction:Int = 0
    
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
        var sTotal = s + ductThk
        
        // now we'll enter a loop to calculate the rest of the steps
        while (R - sTotal < tieRodSpace)
        {
            ductThk = 0.0
            
            if let ductArray = ducts
            {
                // check if there are any more ducts to add
                if (nextDuctIndex < ductArray.count)
                {
                    let ductWidth = ductArray[nextDuctIndex] * 1000.0
                    
                    if (ductWidth <= w) && (ductWidth > w - widthIncrement)
                    {
                        ductThk = ductThickness
                        nextDuctIndex++
                    }
                }
            }
            
            s = 0.0
            while (s < minStepHt)
            {
                w -= widthIncrement
                s = floor((sqrt(R * R - w * w / 4.0) - ductThickness) / sheetThickness) * sheetThickness - sTotal
            }
            
            sTotal += s + ductThk
            chkWS.append((w,s))
        }
        
        // Since the loop is set up to run until we go PAST the R-sTotal limit, we need to remove the last step that was added to chkWS
        
        chkWS.removeAtIndex(chkWS.count - 1)
        
        var Anet = 0.0
        for i in 0..<chkWS.count
        {
            let wi = chkWS[i].0
            let si = chkWS[i].1
            
            Anet += 2.0 * wi * si * 0.96E-6
        }
        
        if (Anet > hiArea)
        {
            if (direction >= 0)
            {
                direction -= 1
            }
            
            if (direction != 0)
            {
                R -= radiusChangeStep
            }
        }
        else if (Anet < lowArea)
        {
            if (direction <= 0)
            {
                direction += 1
            }
            
            if (direction != 0)
            {
                R += radiusChangeStep
            }
        }
        else
        {
            direction = 0
        }
        
        ws = chkWS
    
    } while direction != 0
    
    // At this point, we'll have the routine's best guess at a core, so we just return the final values of R and ws
    
    return (2.0 * R / 1000.0, ws)
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
        
        
    }
    
    
}
