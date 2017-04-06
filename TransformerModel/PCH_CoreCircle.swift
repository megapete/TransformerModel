//
//  PCH_CoreCircle.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-08.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/**
    Private (for now) function to minimize the core diameter for a given area. The algorithm used here is my own, see DesignCoreSteps.docx of the TME Design Manual. Note that eventually, this will probably be changed for the method described in “Transformer Design Principles, 2nd Edition (Del Vecchio, Poulin, et al)”, Section 2.7.

    - parameter requiredArea: The area required in the final core, in sq.m.
    - parameter ducts: Array of doubles indicating where (in terms of width) ducts go
    - parameter sheetThickness: The thickness of a single sheet of steel, in mm
    - parameter lowTolerance: The lower tolerance on the area, in p.u. Defaults to 0.995
    - parameter highTolerance: The upper tolerance on the final area, in p.u. Defaults to 1.01

    - returns: A tuple where the first element is the diameter, in meters; the second element is an array of core-step tuples (width, stack) with both elements in mm, that represent half the core; the third tuple is an array of ints that represent the locations (steps) that have ducts
*/
private func OptimizedCoreDiameter(_ requiredArea:Double, ducts:[Double]?, sheetThickness:Double, lowTolerance:Double = 0.995, highTolerance:Double = 1.01) -> (Double, [(width:Double, stack:Double)], [Int])
{
    // Define a few constants that we use in the algorithm but are kept here for easy editing during testing
    let minStepHt = 10.0 // mm
    let widthIncrement = 10.0 // mm
    let ductThickness = 5.0 // mm
    let tieRodSpace = 25.0 // mm
    let radiusChangeStep = 1.0 // mm
    
    // set up the limits we want to end up within
    let lowArea = requiredArea * lowTolerance
    let hiArea = requiredArea * highTolerance
    
    // Make an initial guess at the diameter in meters
    let diameter = sqrt(requiredArea / 0.66)
    
    // get the initial radius of the core and convert to mm
    var R = diameter / 2.0 * 1000.0
    
    // Create an array to hold the final results
    var ws:[(width:Double, stack:Double)]
    
    // Create and initialize an array for duct locations
    var ductLocs:[Int]
    
    // Loop variables 
    
    // Index into the ducts array
    var nextDuctIndex = 0
    
    // We need to check for thrashing, so we'll create a variable to keep track of direction changes
    var direction:Int = 0
    
    repeat
    {
        var ductThk = 0.0
        ductLocs = [Int]()
        nextDuctIndex = 0
        
        if let ductArray = ducts
        {
            let ductWidth = ductArray[nextDuctIndex] * 1000.0 // convert to mm
            
            if (ductWidth >= floor(2.0 * R / 10.0) * 10.0)
            {
                ductThk = ductThickness / 2.0 // middle duct is effectively split in two
                nextDuctIndex += 1
                ductLocs.append(0)
            }
        }
        
        // calculate the width of the first stack and the maximum theoretical stack we can get out of it. Note that we actually calculate the number of sheetThicness laminations we can fit in, then multiply by sheetThickness to get the step height. We use this for all subsequent stack height calculations
        var w = floor((2.0 * R) / 10.0) * 10.0
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
        while (R - sTotal > tieRodSpace)
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
                        nextDuctIndex += 1
                        ductLocs.append(chkWS.count)
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
        
        chkWS.remove(at: chkWS.count - 1)
        
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
    
    return (2.0 * R / 1000.0, ws, ductLocs)
}

/// The circle in which the core leg's cross-section is defined. The core steps are defined here along with any ducts that are in the core.

class PCH_CoreCircle
{
    /// The steps that make up the core
    let steps:[PCH_CoreStep]
    
    /// Main step width
    var mainStepWidth:Double {
        
        get {
            
            var result = 0.0
            
            for nextStep in self.steps
            {
                if !(nextStep is PCH_CoreDuct)
                {
                    if let lam = nextStep.lamination
                    {
                        result = max(result, lam.width)
                    }
                }
            }
            
            return result
        }
    }
    
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
        
        // Before trying to optimize the diameter, we'll do a quick and dirty calculation of W/sq.m. to see if we need ducts and if so, how many. We'll consider a 1m long section of the core to make calculations fast and easy. This section is currently quite ugly will definitely evolve during testing.
       
        // THIS NUMBER TO BE EVOLVED!!!
        let targetWperSqM = 900.0
        
        let tWt = targetArea * 1 * steelType.density
        let tLoss = tWt * steelType.SpecificLossAtBmax(targetBmax)
        let tDApprox = sqrt(targetArea / 0.66)
        let tSurface = tDApprox * π
        
        var ductWidths:[Double]? = nil
        
        if (tLoss / tSurface > targetWperSqM)
        {
            if (tLoss / (tSurface + 2.0 * tDApprox) < targetWperSqM)
            {
                // we need one duct, in the center
                ductWidths = [tDApprox]
            }
            else if (tLoss / (tSurface + 4.0 * (tDApprox - 10.0)) < targetWperSqM)
            {
                // we need two ducts, on either side of the main step
                ductWidths = [tDApprox - 10.0]
            }
            else if (tLoss / (tSurface + 2.0 * tDApprox + 4.0 * 0.85 * tDApprox) < targetWperSqM)
            {
                // go for three ducts
                ductWidths = [tDApprox, tDApprox * 0.85]
            }
            else if (tLoss / (tSurface + 2.0 * tDApprox + 4.0 * 0.85 * tDApprox + 4.0 * 0.70 * tDApprox) < targetWperSqM)
            {
                // skip straight to five ducts
                ductWidths = [tDApprox, tDApprox * 0.85, tDApprox * 0.7]
            }
            else
            {
                ALog("Cannot add enough ducts to cool this fucking core!")
            }
        }
        
        // set up some vars to get the data from the optimization call
        var newDiameter:Double
        var steps:[(width:Double, stack:Double)]
        var ductLocs:[Int]
        
        // Get the optimized core diameter and steps
        (newDiameter, steps, ductLocs) = OptimizedCoreDiameter(targetArea, ducts: ductWidths, sheetThickness: steelType.thickness)
        
        // save the new diameter
        self.diameter = newDiameter
        
        // initialize the array that we'll fill for the core stack
        var coreStack = [PCH_CoreStep]()
        
        // check if the core has a central duct and if so, save that first
        if (ductLocs.contains(0))
        {
            coreStack.append(PCH_CoreDuct(width:steps[0].width))
        }
        
        // Now, for each step, we create a PCH_CoreStep and add it to the array. If there's a duct on the step, add that too.
        for i in 0..<steps.count
        {
            let lamination = PCH_Lamination(steelType:steelType, width:steps[i].width)
            coreStack.append(PCH_CoreStep(lamination: lamination, stackHeight: steps[i].stack))
            
            if (ductLocs.contains(i+1))
            {
                coreStack.append(PCH_CoreDuct(width: steps[i].width))
            }
        }
        
        // At this point, we have half the core in the array. We need to double the steps (with the exception of the center duct, if any).
        
        var index = 0
        if (ductLocs.contains(0))
        {
            index = 1
        }
        
        let baseArray = Array(coreStack[index..<coreStack.count])
        
        for i in 0..<baseArray.count
        {
            coreStack.insert(baseArray[i], at: 0)
        }
        
        self.steps = coreStack
    }
    
    /**
        Function to return the weight (in kg) of a given length (in meters) of the core circle. Note that this function includes the weight of insulating material used for ducts, so DO NOT use this function to calculate the loss of the core (use the Loss function instead).
    
        - parameter length: The length of core for which we want to calculate the weight.
    */
    func Weight(_ length:Double) -> Double
    {
        var result = 0.0
        
        for nextStep in self.steps
        {
            result += nextStep.WeightForLength(length)
        }
        
        return result
    }
    
    /**
        Function to return the loss (in watts) of a given length (in meters) of the core circle.
    
        - parameter length: The length of core for which we want to calculate the loss.
        - parameter atBMax: The induction level for which we want to calculate the loss.
    */
    func Loss(_ length:Double, atBmax:Double) -> Double
    {
        var result = 0.0
        
        for nextStep in self.steps
        {
            result += nextStep.LossForLength(length, atBmax: atBmax)
        }
        
        return result
    }
    
    /**
        Function to get the Bmax of this core at the given Volts per Turn and frequency. Call this after creating/optimizing the core to see what the actual Bmax is.
    
        - parameter vPerN: The induced volts per turn of the transformer
        - parameter frequency: The frequency of the induced voltage
    
        - returns: Bmax in Teslas
    */
    func BmaxAtVperN(_ vPerN:Double, frequency:Double) -> Double
    {
        var netArea = 0.0
        for nextStep in self.steps
        {
            netArea += nextStep.NetArea()
        }
        
        return vPerN / (4.44 * netArea * frequency)
    }
    
    
}
