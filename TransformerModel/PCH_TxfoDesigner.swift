//
//  PCH_TxfoDesigner.swift
//  TransformerModel
//
//  Created by Peter Huber on 2017-10-11.
//  Copyright © 2017 Peter Huber. All rights reserved.
//


import Foundation

// For now, we'll create a constant for the frequency since I don't remember a single time where I needed something else. If this changes with TME, I'll create a variable to pass to the routines instead.
let PCH_StdFrequency = 60.0

// This is the entry point for the transformer designing program. The idea is that this function will take care of finding a suitable (and cheapest) design for the set of terminals passed in, then return that transformer to the calling routine. It is assumed that the forTerminals parameter has been sorted so that the lowest "main" voltage is at index 0.
func CreateDesign(forTerminals:[PCH_TxfoTerminal], withEvals:PCH_LossEvaluation) -> PCH_Transformer
{
    let numPhases = forTerminals[0].numPhases
    let refVoltage = forTerminals[0].legVolts
    let vpnRefKVA = (numPhases == 1 ? 3.0 : 1.0) * forTerminals[0].terminalVA / 1000.0
    
    // constraints on constants
    let vpnFactorRange = (min:0.4, max:0.9)
    let vpnFactorIncrement = 0.01
    let bmaxRange = (min:1.40, max:1.70)
    let bmaxIncrement = 0.01
    
    // There's no easy way to iterate through an enum, so we just manually set up an array with each of the core steel types (there are only 4 of them!)
    let coreSteelTypes = [PCH_CoreSteel.SteelType.M080, PCH_CoreSteel.SteelType.M085, PCH_CoreSteel.SteelType.M090, PCH_CoreSteel.SteelType.ZDKH]
    
    for vpnFactor:Double in stride(from: vpnFactorRange.min, through: vpnFactorRange.max, by: vpnFactorIncrement)
    {
        let vpnApprox = vpnFactor * sqrt(vpnRefKVA)
        let refTurns = round(refVoltage / vpnApprox)
        let vpnExact = refVoltage / refTurns
        
        for bMax:Double in stride(from: bmaxRange.min, to: bmaxRange.max, by: bmaxIncrement)
        {
            for coreSteelType in coreSteelTypes
            {
                let coreCircle = PCH_CoreCircle(targetBmax: bMax, voltsPerTurn: vpnExact, steelType: PCH_CoreSteel(type:coreSteelType), frequency: PCH_StdFrequency)
                
                // At this point, we need to decide on the ordering of the coils
            }
        }
    }
    
}

// Helper struct used to create the separate windings required for a given set of terminals
struct PCH_Winding
{
    enum WindingType
    {
        case disc
        case layer
        case multistart
    }
    
    let volts:Double
    var axialGaps:[Double]
    let type:WindingType
}

func CoilArrangementForTerminals(terms:[PCH_TxfoTerminal]) -> [PCH_Winding]
{
    var result:[PCH_Winding] = []
    
    // We make a first pass through the terminals to see if we need axial gaps in the windings
    var gaps = [0.0, 0.0, 0.0]
    for nextTerm in terms
    {
        if nextTerm.hasDualVoltage
        {
            
        }
    }
    
    return result
}

func CreateCoil(innerRadius:Double, turns:Double, currentDensity:Double, elHeight:Double, topBIL:Double, bottomBIL:Double, middleBIL:Double) -> PCH_Coil
{
    
}
