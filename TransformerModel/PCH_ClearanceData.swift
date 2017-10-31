//
//  PCH_ClearanceData.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-11.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Foundation

/** An enum that can be used anywhere in the program as standard BIL levels.

    Available levels:
    * KV10
    * KV20
    * KV30
    * KV45
    * KV50
    * KV60
    * KV75
    * KV95
    * KV110
    * KV125
    * KV150
    * KV170
    * KV200
    * KV250
    * KV350
    * KV450
    * KV550
    * KV650
    * KV750
    * KV850
    * KV950
    * KV1050

*/
enum BIL_Level {
    
    case kv10
    case kv20
    case kv30
    case kv45
    case kv50
    case kv60
    case kv75
    case kv95
    case kv110
    case kv125
    case kv150
    case kv170
    case kv200
    case kv250
    case kv350
    case kv450
    case kv550
    case kv650
    case kv750
    case kv850
    case kv950
    case kv1050
    
    /// Create a static dictionary that maps each defined BIL level to it's string (for use as a key in other dictionaries)
    static let bilNames = [kv10:"10", kv20:"20", kv30:"30", kv45:"45", kv50:"50", kv60:"60", kv75:"75", kv95:"95", kv110:"110", kv125:"125", kv150:"150", kv170:"170", kv200:"200", kv250:"250", kv350:"350", kv450:"450", kv550:"550", kv650:"650", kv750:"750", kv850:"850", kv950:"950", kv1050:"1050"]
    
    /// Since we have the BIL levels available as numerical strings, we'll just convert them to UInts for use wherever they are needed as a numerical type
    func Value() -> UInt
    {
        var result:UInt = 0
        
        if let bilName:String = BIL_Level.bilNames[self]
        {
            result = UInt(bilName)!
        }
        
        return result
    }
    
    static func >(lhs:BIL_Level, rhs:BIL_Level) -> Bool
    {
        return lhs.Value() > rhs.Value()
    }
    
    static func <(lhs:BIL_Level, rhs:BIL_Level) -> Bool
    {
        return lhs.Value() < rhs.Value()
    }
    
    static func BilLevelWithValue(bilValue:UInt) -> BIL_Level?
    {
        let stringValue = "\(bilValue)"
        
        var result:BIL_Level? = nil
        
        for (key,value) in BIL_Level.bilNames
        {
            if value == stringValue
            {
                result = key
                break
            }
        }
        
        return result
    }
}

/// Singeleton class that provides access to a dictionary of clearance values based on BIL level.

class PCH_ClearanceData {
    
    /**
        The one and only PCH_ClearanceData instance, which calling routines must reference
    */
    static let sharedInstance = PCH_ClearanceData()
    
    /// A private dictionary that holds the actual clearance data
    fileprivate let clearanceDictionary:NSDictionary?
    
    /// The one and only (private) initializer for the class, which tries to load up the plist file into the clearanceDictionary (and asserts in Debug mode if the dictionary can't be loaded for some reason).
    fileprivate init()
    {
        if let path = Bundle.main.path(forResource: "ClearanceData", ofType: "plist")
        {
            self.clearanceDictionary = NSDictionary(contentsOfFile: path)
        }
        else
        {
            ALog("Could not open ClearanceData.plist")
            
            self.clearanceDictionary = nil
        }
        
    }
    
    /**
        Get the hilo data for a given BIL level.
    
        - parameter bil: The BIL level that we are interested in (of the BIL_Level type)
    
        - returns: (total, solid) tuple of Doubles (meters) where total is the total hilo distance, while solid is the amount of total that must be filled with solid insulation
    */
    func HiloDataForBIL(_ bil:BIL_Level) -> (total:Double, solid:Double)
    {
        var result = (0.0, 0.0)
        
        let keyName = BIL_Level.bilNames[bil]
        
        if let levelDict = clearanceDictionary?[keyName!] as? [String:Double]
        {
            result = (levelDict["HiloTotal"]!, levelDict["HiloSolid"]!)
        }
        else
        {
            ALog("Could not access data in dictionary")
        }
        
        return result
    }
    
    /**
        Get the edge distance for a given BIL level (note that the GroundClearance() routine also calls this routine.
    
        - parameter bil: The BIL level that we are interested in (of the BIL_Level type)
    
        - returns: The required edge distance (in meters)
    */
    func EdgeDistanceForBIL(_ bil:BIL_Level) -> Double
    {
        var result = 0.0
        
        let keyName = BIL_Level.bilNames[bil]
        
        if let levelDict = clearanceDictionary?[keyName!] as? [String:Double]
        {
            result = levelDict["EdgeDistance"]!
        }
        else
        {
            ALog("Could not access data in dictionary")
        }
        
        return result
    }
    
    /**
        Get the ground clearance for a given BIL level. Note that this routine uses the edge distance as the ground clearance.
    
        - parameter bil: The BIL level that we are interested in (of the BIL_Level type)
    
        - returns: The required ground clearance (in meters)
    */
    func GroundClearanceForBIL(_ bil:BIL_Level) -> Double
    {
        return self.EdgeDistanceForBIL(bil)
    }

    
    /**
        Get the interphase distance for a given BIL level (note that the GroundClearance() routine also calls this routine. 
    
        - Note: to find out how much solid is required in the space, call the HiloDataForBIL() routine and use the 'solid' element of the returned tuple.
    
        - parameter bil: The BIL level that we are interested in (of the BIL_Level type)
    
        - returns: The required interphase distance (in meters)
    */
    func InterphaseForBIL(_ bil:BIL_Level) -> Double
    {
        var result = 0.0
        
        let keyName = BIL_Level.bilNames[bil]
        
        if let levelDict = clearanceDictionary?[keyName!] as? [String:Double]
        {
            result = levelDict["Interphase"]!
        }
        else
        {
            ALog("Could not access data in dictionary")
        }
        
        return result
    }

    /**
        Get the conductor cover for a given BIL level.
    
        - parameter bil: The BIL level that we are interested in (of the BIL_Level type)
    
        - returns: The required conductor cover (in meters)
    */
    func ConductorCoverForBIL(_ bil:BIL_Level) -> Double
    {
        var result = 0.0
        
        let keyName = BIL_Level.bilNames[bil]
        
        if let levelDict = clearanceDictionary?[keyName!] as? [String:Double]
        {
            result = levelDict["ConductorCover"]!
        }
        else
        {
            ALog("Could not access data in dictionary")
        }
        
        return result
    }
    
    /**
        Get the interdisk clearance for a given BIL level.
    
        - parameter bil: The BIL level that we are interested in (of the BIL_Level type)
    
        - returns: The required interdisk distance (in meters)
    */
    func InterDiskForBIL(_ bil:BIL_Level) -> Double
    {
        var result = 0.0
        
        let keyName = BIL_Level.bilNames[bil]
        
        if let levelDict = clearanceDictionary?[keyName!] as? [String:Double]
        {
            result = levelDict["BetweenDisks"]!
        }
        else
        {
            ALog("Could not access data in dictionary")
        }
        
        return result
    }
    
    /**
         Inter-layer insulation is calculated using the inter-layer voltage and is a multiple of 0.007". Note that the voltage passed should be equal to the leg-voltage divided by the number of layers (the routine will take care of the test factor and the "2"). The minimum inter-layer thickness that will be returned is 2 paper thicknesses.
     
         - parameter voltage: The voltage equal to the rated leg-voltage divided by the number of layers
     
         - returns: The required thickness of paper in meters
    */
    func InterLayerForVoltage(voltage:Double) -> Double
    {
        var result = 0.0
        
        let stdPaperThk = 0.007
        
        result = max(0.014, round(voltage * 2.0 * 2.0 / 140000.0 / stdPaperThk + 0.5) * stdPaperThk)
        
        return result
    }
    
}
