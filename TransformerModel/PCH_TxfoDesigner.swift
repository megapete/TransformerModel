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

struct PCH_ImpedancePair
{
    let term1:PCH_TxfoTerminal
    let term2:PCH_TxfoTerminal
    let impedancePU:Double
}

// This is the entry point for the transformer designing program. The idea is that this function will take care of finding the 10 most suitable (and cheapest) designs for the set of terminals passed in, then return those transformers to the calling routine as an array of PCH_Transformer. It is assumed that the forTerminals parameter has been sorted so that the lowest "main" voltage is at index 0 and the highest main voltage is at index 1.
func CreateDesign(forTerminals:[PCH_TxfoTerminal], forImpedances:[PCH_ImpedancePair], withEvals:PCH_LossEvaluation) -> [PCH_Transformer]
{
    ZAssert(forImpedances.count > 0, message: "There must be at least one impedance pair defined!")
    
    var result:[PCH_Transformer] = []
    
    let numPhases = forTerminals[0].numPhases
    let refVoltage = forTerminals[0].legVolts
    let vpnRefKVA = (numPhases == 1 ? 3.0 : 1.0) * forTerminals[0].terminalVA.onan / 1000.0
    
    // constraints on constants
    let vpnFactorRange = (min:0.4, max:0.9)
    let vpnFactorIncrement = 0.01
    let bmaxRange = (min:1.40, max:1.70)
    let bmaxIncrement = 0.01
    
    // other constants used later on
    var highestMainBIL = forTerminals[1].bil.line
    if (forTerminals[0].bil.line.Value() > highestMainBIL.Value())
    {
        highestMainBIL = forTerminals[0].bil.line
    }
    let clearances = PCH_ClearanceData.sharedInstance
    let mainHilo = clearances.HiloDataForBIL(highestMainBIL).total
    let typicalCoilRB = 50.0 // 2"
    let impDimnFactor = mainHilo * 1000.0 + 2.0 * typicalCoilRB / 3.0 // mm
    let mainImpedance = forImpedances[0].impedancePU
    
    let NIperLrangePercentage = 0.15
    let NIperLIncrementPercentage = 0.01
    
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
                
                // The terminals should have been set up with "preferred" winding locations for their main windings and tap windings (if any). We will make the following assumptions when onload taps are required: if the winding location for taps is the outermost winding, we assume that it is a "double-axial" winding, while if it is an inner winding, we assume that it is a multistart winding.
                
                // We define a range to use for NI/l (AmpTurns/m) so that we don't try every single height under the sun. We use the simplified formula from the Blue Book for impedances and allow 15% on either side of it.
                let LMTave = (coreCircle.diameter * 1000.0 + 2.0 * typicalCoilRB + mainHilo * 1000.0) * π
                let targetNIperL = mainImpedance * 1.0E12 / ((7.9 * LMTave * PCH_StdFrequency * impDimnFactor) / vpnExact) // AmpTurns per Meter
               
                for NIperL in stride(from: targetNIperL * (1.0 - NIperLrangePercentage), through: targetNIperL * (1.0 + NIperLrangePercentage), by: targetNIperL * NIperLIncrementPercentage)
                {
                    // create designs (easy!)
                }
            }
        }
    }
    
    return result
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
    let puMainNIperL:Double
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
