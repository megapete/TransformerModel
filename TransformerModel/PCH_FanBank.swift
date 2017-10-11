//
//  PCH_FanBank.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-13.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// Definition for a bank of cooling fans.

class PCH_FanBank {

    /// The possible fan models
    enum FanModels {
        
        case fac262
        case fac264
        case fac244
        case fac164
        
        /// A static dictionary to hold the keys into the fan data dictionary for each fan type
        static let fanModelKeys = [fac262:"FAC262", fac264:"FAC264", fac244:"FAC244", fac164:"FAC164"]
        
        /// Another dictionary to ocnvert the Strings back to the FanModels (sigh)
        static let fanModelStrings = ["FAC262":fac262, "FAC264":fac264, "FAC244":fac244, "FAC164":fac164]
    }
    
    /// The possible fan motor speeds (RPM)
    enum FanSpeeds {
        
        case rpm850
        case rpm1140
        case rpm1750
        
        /// A static dictionary to get at the different motor-sizes for the fans
        static let fanMotorKeys = [rpm850:"850", rpm1140:"1140", rpm1750:"1750"]
    }
    
    /// The dictionary that holds the fan data. Note that no routine (including local ones) should directly access this member - call the static FanDictionary function instead.
    fileprivate static var fanDataDict:NSDictionary? = nil
    
    let model:FanModels
    let numFans:Int
    let isSplit:Bool

    /**
        Designated initializer. Note that this initializer can fail if the available "blowable" surface is not within a certain range. If the initializer fails, it is recommended that the calling routine call SuitabilityFactorOfRadBank() with some fraction (< 1.0) of the rad bank's total surface to try and get a better chance that the initializer
    */
    init?(radBank:PCH_RadBank, lossToDissipate:Double, mor:inout Double, preferLowNoise:Bool)
    {
        // Write some filler code so the program compiles
        
        // TODO: Fix this so it works
        
        var done = false
        var badFans:[PCH_FanBank.FanModels] = []
        var typicalRad = radBank.radiatorDefinition
        var numFans = 0
        var fanModel = FanModels.fac262
        var isSplit = false
        
        while !done
        {
            // Get the maximum number of fans we can fit onto this rad bank
            guard let optFans = PCH_FanBank.GetOptimumNumberOfFansForRad(typicalRad, rejectFans: badFans) else
            {
                DLog("Could not find fans that fit this rad bank!")
                return nil
            }
            
            // Allow for a loop to split the rad bank in two (two sets of optFans) if needed
            for i:Int in 1...2
            {
                let totalFanArea = Double(optFans.numFans) * PCH_FanBank.BlowableAreaForFan(optFans.fanModel)
                let totalBlownSurface = 2.0 * Double(radBank.numRads) / Double(i) * typicalRad.panelDimensions.width * totalFanArea
                let lossPerBank = lossToDissipate / Double(i)
                
                var yOnaf = lossPerBank / totalBlownSurface / mor
                
                if yOnaf > 20.15
                {
                    isSplit = true
                    continue
                }
                
                while yOnaf < 10.85
                {
                    
                }
            }
            
            done = true
        }
        
        self.model = fanModel
        self.numFans = numFans
        self.isSplit = isSplit
    }
    
    /**
         THIS FUNCTION IS NOT USED
     
        Function used to test the suitability of a given rad bank and MOR.
    
        - parameter radBank: The radiator bank that we want to test
        - parameter withFan: The fan that we want to test
        - parameter loss: The loss we want to dissipate with the fans
        - parameter mor: The mean-oil-rise we want to meet
    
        - returns: A number that indicates the suitability of the parameters. If the number is 1.0, then the parameters are okay. Otherwise, the returned value indicates what the ratio Ablown/MOR must be multiplied by to bring the parameters into an acceptable range.
    */
    static func SuitabilityFactorOfRadBank(_ radBank:PCH_RadBank, withFan:PCH_FanBank.FanModels, loss:Double, mor:Double) -> Double
    {
    
        let totalRadBankSurface = Double(radBank.numRads) * radBank.radiatorDefinition.radSurface
        
        let aOverMor = totalRadBankSurface / mor
        
        let testValue = loss / aOverMor
        
        if testValue < 10.85
        {
            return testValue / 10.85
        }
        else if testValue > 20.15
        {
            return testValue / 20.15
        }
        
        return 1.0
    }
    
    /**
        Function to return the area that a given fan will blow (based on its diameter)
        
        - parameter model: The fan model
        
        - returns: The circular area (in square meters) that the fan can blow.
    */
    static func BlowableAreaForFan(_ model:FanModels) -> Double
    {
        guard let fanDict = PCH_FanBank.FanDictionary() else
        {
            ALog("Bad fan dicitonary!")
            return 0.0
        }
        
        guard let modelDict:NSDictionary = fanDict[FanModels.fanModelKeys[model]!] as? NSDictionary else
        {
            ALog("Bad fan model!")
            return 0.0
        }
        
        let radius = ((modelDict["BladeDiameter"] as! NSNumber) as! Double) * 0.0254 / 2.0
        
        return π * radius * radius
    }
    
    
    /**
        Function to return the CMM (cubic meters per minute) of air from a single unit of a given fan model at a given speed
    
        - parameter model: The fan model
        - parameter speed: The motor rpm
    
        - returns: Cubic meters per minute of air (note that this will return 0 if the requested rpm does not exist for the given model or if any other error occurs)
    */
    static func CubicMetersPerMinuteForFan(_ model:FanModels, speed:FanSpeeds) -> Double
    {
        guard let fanDict = PCH_FanBank.FanDictionary() else
        {
            ALog("Bad fan dicitonary!")
            return 0.0
        }
        
        guard let modelDict:NSDictionary = fanDict[FanModels.fanModelKeys[model]!] as? NSDictionary else
        {
            ALog("Bad fan model!")
            return 0.0
        }
        
        guard let speedDict = modelDict[FanSpeeds.fanMotorKeys[speed]!] as? [String:NSNumber] else
        {
            DLog("This model does not supprt the requested RPM")
            return 0.0
        }
        
        let CFM = (speedDict["CFM"]!) as! Double
        
        // Convert the CFM to CMM
        return CFM * 0.0254 * 0.0254 * 0.0254 * 12.0 * 12.0 * 12.0
        
    }
    
    /**
        Function to return the optimum number of fans (ie: the least number) that can fit on a given radiator. This routine prefers lower-noise fans in the result of a tie.
    
        - parameter radiator: The radiator for which we will calculate the number of fans we can fit
        - parameter rejectFans: A list of fan models that should NOT be tested (may be empty)
        - returns: The tuple (fanModel, numFans)
    */
    static func GetOptimumNumberOfFansForRad(_ radiator:PCH_Radiator, rejectFans:[PCH_FanBank.FanModels]) -> (fanModel:PCH_FanBank.FanModels, numFans:Int)?
    {
        guard let fanDict = PCH_FanBank.FanDictionary() else
        {
            ALog("Bad fan dicitonary!")
            return nil
        }
        
        let availableWidth = radiator.widthForFans
        let availableHt = radiator.panelDimensions.height
        let allowedOverlap = 0.0508
        
        // Set the result to a ridiculously high value
        var result = (fanModel:FanModels.fac262, numFans:Int.max)
        
        for (nextKey, nextValue) in fanDict
        {
            if let nextModel = PCH_FanBank.FanModels.fanModelStrings[nextKey as! String]
            {
                if rejectFans.contains(nextModel)
                {
                    continue
                }
            }
    
            let nextFanDict = nextValue as! NSDictionary
            
            // The fan data is all in Imperial units, convert to metric
            let cageDiameter = ((nextFanDict["CageDiameter"] as! NSNumber) as! Double) * 0.0254
            
            // B34 is availableWidth
            // B35 is availableHt
            // =ROUNDDOWN((B35-30)/IF(B34/2>28,30,MAX(SQRT(30^2-(B34-28)^2),15)),0)*IF(B34/2>28,2,1)+IF(B34/2>28,2,1)
            var numFans = floor((availableHt - cageDiameter) / (availableWidth / 2.0 > (cageDiameter - allowedOverlap) ? cageDiameter : max(sqrt(cageDiameter * cageDiameter - pow(availableWidth - cageDiameter + allowedOverlap, 2.0)), cageDiameter / 2.0)))
                
                numFans *= (availableWidth / 2.0 > (cageDiameter - allowedOverlap) ? 2.0 : 1.0)
                    
                numFans += (availableWidth / 2.0 > (cageDiameter - allowedOverlap) ? 2.0 : 1.0)
            
            if (Int(numFans) < result.numFans)
            {
                result = (FanModels.fanModelStrings[nextKey as! String]!, Int(numFans))
            }
            
        }
        
        if result.numFans == Int.max
        {
            DLog("Could not come up with a suitable fan!")
            return nil
        }
        
        return result
    }
    
    /**
        Function that returns the fan data dictionary. loading it into memory if it is not already done. This function should be used to access the dictionary. Direct access implies checking whether it has been loaded and if not, loading it. **Just use this function!**
    */
    fileprivate static func FanDictionary() -> NSDictionary?
    {
        if (PCH_FanBank.fanDataDict == nil)
        {
            if let path = Bundle.main.path(forResource: "FanData", ofType: "plist")
            {
                PCH_FanBank.fanDataDict = NSDictionary(contentsOfFile: path)
                
                if PCH_FanBank.fanDataDict == nil
                {
                    ALog("Could not import fan dictionary!")
                }
            }
            else
            {
                ALog("Could not open FanData.plist")
            }

        }
        
        return PCH_FanBank.fanDataDict
    }
}
