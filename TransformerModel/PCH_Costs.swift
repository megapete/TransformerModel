//
//  PCH_Costs.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-15.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// Class for getting/setting costs for materials and labour from the file Costs.plist. Note that this is a singleton class. All public methods and properties are available through PCH_Costs.sharedInstance.methodName

class PCH_Costs {

    /**
        The one and only PCH_Costs instance
    */
    static let sharedInstance = PCH_Costs()
    
    private var costDictionary: NSDictionary?
    
    var fileIsValid = false
    
    /**
        Constant string definitions relating to the Costs.plist file
    */
    let costFileName = "Costs"
    let costFileType = "plist"
    
    
    /** Costing key definitions (used to access details in Costs.plist)
    
    - Materials
    
        - Copper
        - Aluminum
        - CarbonSteel
        - CoreSteel
        - Nomex
        - Paper
        - Glastic
        - TIV
        - TX
        - Oil
        - Formel
        - Varnish
    
    - Labour
    
        - Winding
        - Stacking
        - HeadStacking
        - CoreCoilAssy
        - TransformerAssy
        - Testing
        - Packaging
    
    */
    enum CostKey : String
    {
        // Materials
        case Copper      = "CopperCostKey"
        case Aluminum    = "AluminumCostKey"
        case CarbonSteel = "CarbonSteelCostKey"
        case CoreSteel   = "CoreSteelCostKey"
        case Nomex       = "NomexCostKey"
        case Paper       = "PaperCostKey"
        case Glastic     = "GlasticCostKey"
        case TIV         = "TIVCostKey"
        case TX          = "TXCostKey"
        case Oil         = "OilCostKey"
        case Formel      = "FormelCostKey"
        case Varnish     = "VarnishCostKey"
        
        // Labour
        case Winding            = "WindingCostKey"
        case Stacking           = "StackingCostKey"
        case HeadStacking       = "HeadStackingCostKey"
        case CoreCoilAssy       = "CoreCoilAssyCostKey"
        case TransformerAssy    = "TransformerAssyCostKey"
        case Testing            = "TestingCostKey"
        case Packaging          = "PackagingCostKey"
        
    }

    /**
        Private (and the only) initializer for the class
    */
    private init()
    {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDir = paths.firstObject as! String
        let fileName = costFileName + "." + costFileType
        let filePath = documentsDir.stringByAppendingPathComponent(fileName)
        
        let fileManager = NSFileManager.defaultManager()
        if (fileManager.fileExistsAtPath(filePath))
        {
            if let dict = NSDictionary(contentsOfFile: filePath)
            {
                // This should be better checked to make sure that dict is actually the cost file with all the required costs
                costDictionary = dict
                fileIsValid = true
            }
            else
            {
                DLog("Costs.plist is not a correctly-formatted plist (Dictionary) file. Using default values")
                costDictionary = self.CreateDefaultCostDictionary()
            }
        }
        else
        {
            DLog("Costs.plist does not exist. Using default values")
            costDictionary = self.CreateDefaultCostDictionary()
        }
    }
    
    /**
        Private function to create a cost dictionary with default values. Note that this function will only be called under "error" circumstances.
    
        - returns: Cost dictionary filled with default values
    */
    private func CreateDefaultCostDictionary() -> NSDictionary
    {
        let result:NSDictionary = [
            
            CostKey.Copper.rawValue : 3.00,
            CostKey.Aluminum.rawValue : 3.00,
            CostKey.CoreSteel.rawValue : 1.90,
            CostKey.CarbonSteel.rawValue : 0.50,
            CostKey.Nomex.rawValue : 1.00,
            CostKey.Paper.rawValue : 1.00,
            CostKey.Glastic.rawValue : 1.00,
            CostKey.TIV.rawValue : 1.00,
            CostKey.TX.rawValue : 1.00,
            CostKey.Oil.rawValue : 1.75,
            CostKey.Formel.rawValue : 1.00,
            CostKey.Varnish.rawValue : 1.00,
            
            CostKey.Winding.rawValue : 50.00,
            CostKey.Stacking.rawValue : 50.00,
            CostKey.HeadStacking.rawValue : 50.00,
            CostKey.CoreCoilAssy.rawValue : 50.00,
            CostKey.TransformerAssy.rawValue : 50.00,
            CostKey.Testing.rawValue : 50.00,
            CostKey.Packaging.rawValue : 50.00
        ]
    
        return result
    }
    
    /**
        Get the currently-saved cost for the given CostCode
    
        - parameter CostCode: for the material or labour unit desired
    
        - returns: The cost as a double
    */
    func CostForKey(theKey: CostKey) -> Double
    {
        let theNum:NSNumber = costDictionary!.valueForKey(theKey.rawValue) as! NSNumber
        
        return theNum.doubleValue
    }
    
    /**
        Set a new cost for the given CostCode
    
        - parameter The: new cost (as a Double)
        - parameter CostCode: for the material or labour unit desired
    
    */
    func SetCost(cost:Double, forKey:CostKey)
    {
        costDictionary!.setValue(cost, forKey:forKey.rawValue)
    }
    
    /**
        Flush the data currently in the dictionary to the plist file.
    */
    func FlushCostsFile()
    {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDir = paths.firstObject as! String
        let fileName = costFileName + "." + costFileType
        let filePath = documentsDir.stringByAppendingPathComponent(fileName)
        
        if costDictionary!.writeToFile(filePath, atomically: true)
        {
            fileIsValid = true
        }
        else
        {
            DLog("Could not write costs to file!")
        }
        
    }
    
    /**
        Deinit routine to make sure that the new prices are saved to the file
    */
    deinit
    {
        FlushCostsFile()
    }
}
