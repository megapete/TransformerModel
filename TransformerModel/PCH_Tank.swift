//
//  PCH_Tank.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-13.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Foundation

/// An oversimplified tank definition, which only considers the inner volume of the tank for liquid calculations.

struct PCH_Tank {
    
    /// A quick-and-dirty factor for the amount of the tank that actually participates in radiation
    static let tankDissipationFactor = 0.9
    
    /// The 3 dimensions of the tank, in meters
    let dimensions:(length:Double, width:Double, height:Double)
    
    /** Tank dissipation, based on MOR
        
        - parameter mor: The mean oil rise for which we want to know the dissipation
        - returns: The dissipation, in watts/sq.m.
    */
    static func DissipationAtMOR(_ mor:Double) -> Double
    {
        return 0.0051 * pow(mor, 1.2115)
    }
    
    /**
        The total number of watts this tank will dissipate, at a given mean oil rise
        
        - parameter mor: Mean oil rise for which we want to know the tank loss
        - returns: The tank loss in watts
    */
    func TankLossAtMOR(_ mor:Double) -> Double
    {
        // We'll assume that the two short sides, one long side, and the cover radiate heat (the other long side has rads and obviously the base doesn't radiate)
        
        let radiatingSurface = (2.0 * self.dimensions.width * self.dimensions.height + self.dimensions.length * self.dimensions.height + self.dimensions.length * self.dimensions.width) * PCH_Tank.tankDissipationFactor
        
        return radiatingSurface * PCH_Tank.DissipationAtMOR(mor)
    }
    
}
