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
        
        case FAC262
        case FAC264
        case FAC244
        case FAC164
        
        /// A static dictionary to hold the keys into the fan data dictionary for each fan type
        static let fanModelKeys = [FAC262:"FAC262", FAC264:"FAC264", FAC244:"FAC244", FAC164:"FAC164"]
        
        /// Another dictionary to ocnvert the Strings back to the FanModels (sigh)
        static let fanModelStrings = ["FAC262":FAC262, "FAC264":FAC264, "FAC244":FAC244, "FAC164":FAC164]
    }
    
    /// The possible fan motor speeds (RPM)
    enum FanSpeeds {
        
        case RPM850
        case RPM1140
        case RPM1750
        
        /// A static dictionary to get at the different motor-sizes for the fans
        static let fanMotorKeys = [RPM850:"850", RPM1140:"1140", RPM1750:"1750"]
    }
    
    /// The dictionary that holds the fan data. Note that no routine (including local ones) should directly access this member - call teh static FanDictionary function instead.
    private static var fanDataDict:NSDictionary? = nil
    
    let model:FanModels
    let numFans:Int

    /**
        Designated initializer. Note that this initializer can fail if the available "blowable" surface is not within a certain range.
    */
    init?(radBank:PCH_RadBank, lossToDissipate:Double, mor:Double, preferLowNoise:Bool)
    {
        self.model = FanModels.FAC264
        self.numFans = 1
    }
    
    /**
        Function to return the optimum number of fans (ie: the least number) that can fit on a given radiator. This routine prefers lower-noise fans in the result of a tie.
    */
    static func GetOptimumNumberOfFansForRad(radiator:PCH_Radiator) -> (PCH_FanBank.FanModels, Int)?
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
        var result = (FanModels.FAC262, Int.max)
        
        for (nextKey, nextValue) in fanDict
        {
            let nextFanDict = nextValue as! NSDictionary
            
            // The fan data is all in Imperial units, convert to metric
            let cageDiameter = ((nextFanDict["CageDiameter"] as! NSNumber) as Double) * 0.0254
            
            // B34 is availableWidth
            // B35 is availableHt
            // =ROUNDDOWN((B35-30)/IF(B34/2>28,30,MAX(SQRT(30^2-(B34-28)^2),15)),0)*IF(B34/2>28,2,1)+IF(B34/2>28,2,1)
            var numFans = floor((availableHt - cageDiameter) / (availableWidth / 2.0 > (cageDiameter - allowedOverlap) ? cageDiameter : max(sqrt(cageDiameter * cageDiameter - pow(availableWidth - cageDiameter + allowedOverlap, 2.0)), cageDiameter / 2.0)))
                
                numFans *= (availableWidth / 2.0 > (cageDiameter - allowedOverlap) ? 2.0 : 1.0)
                    
                numFans += (availableWidth / 2.0 > (cageDiameter - allowedOverlap) ? 2.0 : 1.0)
            
            if (Int(numFans) < result.1)
            {
                result = (FanModels.fanModelStrings[nextKey as! String]!, Int(numFans))
            }
        }
        
        if result.1 == Int.max
        {
            DLog("Could not come up with a suitable fan!")
            return nil
        }
        
        return result
    }
    
    /**
        Function that returns the fan data dictionary. loading it into memory if it is not already done. This function should be used to access the dictionary. Direct access implies checking whether it has been loaded and if not, loading it. **Just use this function!**
    */
    private static func FanDictionary() -> NSDictionary?
    {
        if (PCH_FanBank.fanDataDict == nil)
        {
            if let path = NSBundle.mainBundle().pathForResource("FanData", ofType: "plist")
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
