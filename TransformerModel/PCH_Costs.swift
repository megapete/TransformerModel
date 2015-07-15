//
//  PCH_Costs.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-15.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

/// Class for getting/setting costs for materials and labour from the file Costs.plist. Note that this is a singleton class.

import Cocoa

class PCH_Costs {

    static let sharedInstance = PCH_Costs()
    
    private var costDictionary: Dictionary<String, Double>?
    
    var fileIsValid = false
    
    /**
        Constant string definitions relating to the Costs.plist file
    */
    let costFileName = "Costs"
    let costFileType = "plist"
    
    /**
    */
    
    /** Costing key definitions (used to access details in Costs.plist)
    
    - Materials
    
        - Copper
        - Aluminum
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
        if let path = NSBundle.mainBundle().pathForResource(costFileName, ofType: costFileType)
        {
            if let dict = NSDictionary(contentsOfFile:path) as? Dictionary<String, Double>
            {
                if dict.count == 0
                {
                    costDictionary = CreateDefaultCostDictionary()
                }
                else
                {
                    costDictionary = dict
                }
                
                fileIsValid = true
            }
        }
        else
        {
            println("Cannot open 'Costs.plist' file - using default values for costs")
            
            costDictionary = CreateDefaultCostDictionary()
        }
    }
    
    /**
        Private function to create a cost dictionary with default values. Note that this function will probably never be called under normal circumstances.
    */
    private func CreateDefaultCostDictionary() -> Dictionary<String, Double>
    {
        let tst:String = PCH_Costs.CostKey.Copper.rawValue
        
        var result = [
            
            CostKey.Copper.rawValue : 3.00,
            CostKey.Aluminum.rawValue : 3.00,
            CostKey.CoreSteel.rawValue : 1.90,
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
        Flush the data currently in the dictionary to the plist file.
    */
}
