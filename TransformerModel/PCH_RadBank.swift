//
//  PCH_RadBank.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-13.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Foundation

func wattsPerSqMeterONANWithMOR(mor:Double) -> Double
{
    // from the old Megatran ONAN curve
    return 8.3948E-3 * mor - 1.0044E-1
}

struct PCH_RadBank {
    
    let numRads:Int
    
    let radiatorDefinition:PCH_Radiator
    
    let numFans:Int
    
    let fanDefinition:PCH_Fan
    
    init(maxHeight:Double, ccHtDifference:Double, lossToDissipateONAN:Double, meanOilRiseONAN:Double, lossToDissipateONAF:Double, meanOilRiseONAF:Double)
    {
        
    }
}