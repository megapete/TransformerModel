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
}

/// Singeleton class that provides access to a dictionary of clearance values based on BIL level.

class PCH_ClearanceData {
    
    /**
        The one and only PCH_ClearanceData instance, which calling routines must reference
    */
    static let sharedInstance = PCH_ClearanceData()
    
    /// A private dictionary that holds the actual clearance data
    private let clearanceDictionary:NSDictionary?
    
    /// The one and only (private) initializer for the class, which tries to load up the plist file into the clearanceDictionary (and asserts in Debug mode if the dictionary can't be loaded for some reason).
    private init()
    {
        if let path = NSBundle.mainBundle().pathForResource("ClearanceData", ofType: "plist")
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
    func HiloDataForBIL(bil:BIL_Level) -> (total:Double, solid:Double)
    {
        var result = (0.0, 0.0)
        
        let keyName = BIL_Level.bilNames[bil]
        
        if let levelDict = clearanceDictionary?[keyName!]
        {
            result = (levelDict["HiloTotal"] as! Double, levelDict["HiloSolid"] as! Double)
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
    func EdgeDistanceForBIL(bil:BIL_Level) -> Double
    {
        var result = 0.0
        
        let keyName = BIL_Level.bilNames[bil]
        
        if let levelDict = clearanceDictionary?[keyName!]
        {
            result = levelDict["EdgeDistance"] as! Double
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
    func GroundClearanceForBIL(bil:BIL_Level) -> Double
    {
        return self.EdgeDistanceForBIL(bil)
    }

    
    /**
        Get the interphase distance for a given BIL level (note that the GroundClearance() routine also calls this routine. 
    
        - Note: to find out how much solid is required in the space, call the HiloDataForBIL() routine and use the 'solid' element of the returned tuple.
    
        - parameter bil: The BIL level that we are interested in (of the BIL_Level type)
    
        - returns: The required interphase distance (in meters)
    */
    func InterphaseForBIL(bil:BIL_Level) -> Double
    {
        var result = 0.0
        
        let keyName = BIL_Level.bilNames[bil]
        
        if let levelDict = clearanceDictionary?[keyName!]
        {
            result = levelDict["Interphase"] as! Double
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
    func ConductorCoverForBIL(bil:BIL_Level) -> Double
    {
        var result = 0.0
        
        let keyName = BIL_Level.bilNames[bil]
        
        if let levelDict = clearanceDictionary?[keyName!]
        {
            result = levelDict["ConductorCover"] as! Double
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
    func InterDiskForBIL(bil:BIL_Level) -> Double
    {
        var result = 0.0
        
        let keyName = BIL_Level.bilNames[bil]
        
        if let levelDict = clearanceDictionary?[keyName!]
        {
            result = levelDict["BetweenDisks"] as! Double
        }
        else
        {
            ALog("Could not access data in dictionary")
        }
        
        return result
    }
    
}