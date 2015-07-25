//
//  GlobalDefs.swift
//  TransformerModel
//
//  Created by PeterCoolAssHuber on 2015-07-05.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

import Foundation

/// Important value #1: π
let π:Double = 3.1415926535897932384626433832795

/// Permeability of vacuum
let µ0:Double = π * 4.0E-7

/// Speed of light
let c:Double = 299792458.0 // m/s

/// Permittivity of free space
let ε0:Double = 1 / (µ0 * c * c) // Farads/m

/// Exponential function (this is basically an alias to make it easier to copy formulae)
func e(arg:Double) -> Double
{
    return exp(arg)
}
