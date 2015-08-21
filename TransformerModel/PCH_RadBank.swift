//
//  PCH_RadBank.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-13.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Foundation

/** Function to calculate radiator dissipateion (in w/sq.m.) for a given mean-oil rise (in C) at ONAN (ie: no fans)

    - parameter mor: The mean oil temperature rise (in C or K) at ONAN
    - returns: The watts/sq.m. that the radiators will dissipate
*/
func WattsPerSqMeterONANWithMOR(mor:Double) -> Double
{
    // from the old Megatran ONAN curve
    return 8.3948E-3 * mor - 1.0044E-1
}

/**
    Function to calculate the correction factor of dissipation for a given height difference between thet center of heating and the center of cooling. Note that the center of cooling must be *higher* than the center of heating for this to be a good thing (ie: the diff parameter must be **positive**).

    - parameter diff: The value (center-of-cooling - center-of-heating) in meters
    - returns: The factor that the calculated dissipation (w/sq.m.) should be multiplied by to take into account the height difference

*/
func CenterCoolingToCenterHeatingDifferenceFactor(diff:Double) -> Double
{
    if (diff < 0.0)
    {
        return 1.0
    }
    
    return (-1.0388E-1 * (diff * diff)) + (3.856E-1 * diff) + 0.8092
}

/// A class that defines a bank of radiators, which are arranged together and possibly blown by fans

class PCH_RadBank {
    
    /// The number of radiators in the bank
    let numRads:Int
    
    /// The definition of the radiator(s) in the bank
    let radiatorDefinition:PCH_Radiator
    
    /// The number of fans attached to the bank (optional)
    let numFans:Int?
    
    /// The definition of the fans attached to the bank (optional)
    let fanDefinition:PCH_FanBank?
    
    /**
        The designated initializer. This simply sets the properties of the class. This can be used to manually set the bank instead of using the more convenient initializer below (which actually calls this one).
    
        - parameter numRads: The number of radiators in the bank
        - parameter radiatorDefinition: The definition of the radiator(s) in the bank
        - parameter numFans: The number of fans attached to the bank (optional)
        - parameter fanDefinition: The definition of the fans attached to the bank (optional)
    */
    init(numRads:Int, radiatorDefinition:PCH_Radiator, numFans:Int? = nil, fanDefinition:PCH_FanBank? = nil)
    {
        ZAssert(numRads > 0, message: "Attempt to create a radiator bank with less than one rad")
        
        self.numRads = numRads
        self.radiatorDefinition = radiatorDefinition
        
        // We now go through a complicated mess to make sure that both numFans and fanDefinition are valid
        if let nFans = numFans
        {
            if let fanDef = fanDefinition
            {
                if (nFans > 0)
                {
                    self.numFans = nFans
                    self.fanDefinition = fanDef
                }
                else
                {
                    ALog("Attempt to add 0 or less fans to rad bank")
                    self.numFans = nil
                    self.fanDefinition = nil
                }
            }
            else
            {
                self.numFans = nil
                self.fanDefinition = nil
            }
        }
        else
        {
            self.numFans = nil
            self.fanDefinition = nil
        }
    }
    
    /**
        A more convenient initializer for radiator banks, this routine calculates and defines radiator and fan requirements for given parameters such as losses and mean oil rises.
    
        - parameter maxHeight: The maximum height allowed for the radiators. 
        - parameter ccHtDifference: The desired difference in height between the center of cooling and the center of heating (positive number)
        - parameter lossToDissipateONAN: The loss that must be dissipated at ONAN
        - parameter meanOilRiseONAN: The target mean oil rise at ONAN
        - parameter lossToDissipateONAF: The loss that must be dissipated at ONAF (optional)
        - parameter meanOilRiseONAF: The target mean oil rise at ONAF (optional)
    */
    convenience init(maxHeight:Double, ccHtDifference:Double, lossToDissipateONAN:Double, meanOilRiseONAN:Double, lossToDissipateONAF:Double?, meanOilRiseONAF:Double?)
    {
        let requiredRadSurface = lossToDissipateONAN / (WattsPerSqMeterONANWithMOR(meanOilRiseONAN) * CenterCoolingToCenterHeatingDifferenceFactor(ccHtDifference))
        
        let singlePanelSurface = 2.0 * maxHeight * PCH_Radiator.standardWidth
        
        let requiredPanels = ceil(requiredRadSurface / singlePanelSurface)
        var numRads = ceil(requiredPanels / Double(PCH_Radiator.maxPanels))
        
        if (numRads < 2.0)
        {
            numRads = 2.0
        }
        
        let panelsPerRad = ceil(requiredPanels / numRads)
        
        let basicRad = PCH_Radiator(numPanels:Int(panelsPerRad), panelDimensions:(PCH_Radiator.standardWidth, maxHeight))
        
        var numFans:Int? = nil
        var fanDef:PCH_FanBank? = nil
        
        let tstRadBank = PCH_RadBank(numRads: Int(numRads), radiatorDefinition: basicRad)
        
        if let onafLoss = lossToDissipateONAF
        {
            
        }
        
        self.init(numRads:Int(numRads), radiatorDefinition:basicRad, numFans:numFans, fanDefinition:fanDef)
    }
}