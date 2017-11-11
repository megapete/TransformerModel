//
//  PCH_CoreSteel.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-07.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

// This class has been redesigned and rewritten to avoid using .plist files, which is a major pain in the ass in Swift 3. The different core types and their associated data is now hard-coded straight into the class.

import Cocoa

class PCH_CoreSteel: PCH_RawMaterial
{
    /// The different types of steel that are available. These are the designations of Cogent
    enum SteelType: String {
        
        case ZDKH = "23ZDKH85"
        case M080 = "M080-23P"
        case M085 = "M085-23P"
        case M090 = "M090-23P"
    }
    
    struct SteelInfo {
        let type:String // The name of the steel type
        let thickness:Double // The thickness of a single lamination in mm
        let lossCoeffs:[Double] // The loss coefficients from 0th to 4th degree of the material (per kg)
        let price:Double // The price per kg in C$
    }
    
    let Steel:[SteelType:SteelInfo] = [SteelType.ZDKH:SteelInfo(type:"23ZDKH85", thickness:0.23, lossCoeffs:[22.929, -67.833, 75.145, -36.492, 6.6468], price: 6.36),
                                    SteelType.M080:SteelInfo(type:"M080-23P", thickness:0.23, lossCoeffs:[16.945, -50.877, 57.373, -28.327, 5.2584], price: 6.18),
                                    SteelType.M085:SteelInfo(type:"M085-23P", thickness:0.23, lossCoeffs:[21.944, -65.111, 72.543, -35.488, 6.5277], price: 5.90),
                                    SteelType.M090:SteelInfo(type:"M090-23P", thickness:0.23, lossCoeffs:[22.398, -67.134, 75.554, -37.310, 6.9223], price: 5.70)]
    
    /// The type of steel
    let type:SteelType

    /// The thickness of the material (they're all 0.23mm, so...)
    let thickness = 0.23
    
    /**
        Designated initializer
    */
    init(type:SteelType)
    {
        self.type = type
        
        let selfInfo = Steel[type]!
        
        super.init(name: type.rawValue, density: 7490.0, cost: selfInfo.price)
    }
    
    /**
        Function to return the specific loss (in watts per kilogram) for a given Bmax (in teslas)
    */
    func SpecificLossAtBmax(_ teslas:Double) -> Double
    {
        let x:[Double] = [1.0, teslas, pow(teslas, 2), pow(teslas, 3), pow(teslas, 4)]
        let selfInfo = Steel[self.type]!
        
        var result = 0.0
        
        for i in 0..<5
        {
            result += selfInfo.lossCoeffs[i] * x[i]
        }
        
        return result
    }
    
    func CanadianDollarValue(weight:Double) -> Double
    {
        return weight * Steel[self.type]!.price
    }

}
