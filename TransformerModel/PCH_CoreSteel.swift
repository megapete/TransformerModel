//
//  PCH_CoreSteel.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-07.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

class PCH_CoreSteel: PCH_RawMaterial
{
    /// The different types of steel that are available. Among other things, these Strings are used as keys into the loss dictionary, the excitation current dictionary, etc.
    enum SteelType: String {
        
        case ZDKH   = "ZDKH"
        case M0H    = "M0H"
        case M3     = "M3"
        case M3T23  = "M3-T23"
        case M4     = "M4"
        case M5     = "M5"
    }
    
    /// The type of steel
    let type:SteelType
    
    /// The coefficients to calculate the specific loss for a given induction (in Gauss). The index of each corresponds to the power that the induction must be raised to. Cool eh?
    let lossCoeffs:[Double]
    
    /// Thickness of the material (****NOTE***** This value is in mm)
    let thickness:Double
    
    /**
        Designated initializer
    */
    init(type:SteelType)
    {
        self.type = type
        
        var dataDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("CoreData", ofType: "plist")
        {
            dataDict = NSDictionary(contentsOfFile: path)
        }
        
        var usCost = 0.0
        var lossCoeffArray = [Double](count: 5, repeatedValue: 0)
        var thickness = 0.23
        if let dict = dataDict
        {
            if let steelDict = dict[type.rawValue]
            {
                // We're going to assume that if we get this far, then the fuckin' file has been correctly formatted
                let lossArray:[NSNumber] = steelDict["LossCoefficients"] as! [NSNumber]
                
                var i=0
                for nextNumber in lossArray
                {
                    lossCoeffArray[i] = (nextNumber as Double)
                    i++
                }
                
                usCost = (steelDict["Cost"] as! NSNumber) as Double
                
                thickness = (steelDict["Thickness"] as! NSNumber) as Double
            }
        }
        
        self.lossCoeffs = lossCoeffArray
        self.thickness = thickness
        
        super.init(name: type.rawValue, density: 7490.0, cost: usCost * PCH_Costs.sharedInstance.CostForKey(PCH_Costs.CostKey.UStoCDN))
    }
    
    /**
        Function to return the specific loss (in watts per kilogram) for a given Bmax (in teslas)
    */
    func SpecificLossAtBmax(teslas:Double) -> Double
    {
        let x:[Double] = [1.0, teslas * 10000.0, pow(teslas * 10000.0, 2), pow(teslas * 10000.0, 3), pow(teslas * 10000.0, 4)]
        
        var result = 0.0
        
        for i in 0..<5
        {
            result += lossCoeffs[i] * x[i]
        }
        
        // at this point, the result is in watts per pound, so we convert to watts/kg
        return result * 2.2
    }

}
