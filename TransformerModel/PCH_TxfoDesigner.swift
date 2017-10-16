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

// Helper class used to create the separate windings required for a given set of terminals
class PCH_Winding
{
    enum WindingType
    {
        case sheet
        case layer
        case helix
        case disc
        case multistart // actually a specialized layer
    }
    
    struct axialGap {
        
        var thisCoil:Double
        var otherCoils:Double
    }
    
    var position:Int
    let volts:Double
    let amps:Double
    var axialGaps:[axialGap]
    var staticRings:Int
    let type:WindingType
    let puNIperL:Double
    let tapCoil:PCH_Winding?
    
    init(position:Int, volts:Double, amps:Double, axialGaps:[axialGap], type:WindingType, staticRings:Int, puNIperL:Double, tapCoil:PCH_Winding? = nil)
    {
        self.position = position
        self.volts = volts
        self.amps = amps
        self.axialGaps = axialGaps
        self.type = type
        self.staticRings = staticRings
        self.puNIperL = puNIperL
        self.tapCoil = tapCoil
    }
    
    static func WindingTypesForBIL(bil:BIL_Level) -> [PCH_Winding.WindingType]
    {
        var result:[PCH_Winding.WindingType] = []
        
        let bilValue = bil.Value()
        
        if (bilValue <= 30)
        {
            result.append(.sheet)
        }
        
        if (bilValue < 170)
        {
            result.append(.layer)
        }
        
        if (bilValue < 350)
        {
            result.append(.helix)
        }
        
        if (bilValue >= 170)
        {
            result.append(.disc)
        }
        
        return result
    }
    
    static func NeedsStaticRing(bil:BIL_Level) -> Bool
    {
        return bil.Value() >= 170
    }
}

func CoilArrangementForTerminals(terms:[PCH_TxfoTerminal], NIperL:Double, baseVA:Double) -> [PCH_Winding]
{
    var result:[PCH_Winding] = []
    
    var currentPos = 0
    if terms.count > 2
    {
        // We assume that tertiary windings are put closest to the core. We also assume that these terminals do not have taps, nor are they ever dual-voltage.
        var currentTerm = 2
        while currentTerm < terms.count
        {
            let terminal = terms[currentTerm]
            var totalStaticRings = 0
            let termBIL = terminal.bil
            
            if (PCH_Winding.NeedsStaticRing(bil: termBIL.line))
            {
                totalStaticRings += 1
            }
            if (PCH_Winding.NeedsStaticRing(bil: termBIL.neutral))
            {
                totalStaticRings += 1
            }
            if (terminal.hasDualVoltage && PCH_Winding.NeedsStaticRing(bil: termBIL.dv))
            {
                totalStaticRings += 2
            }
            
            let tertVA = terminal.terminalVA.onaf
            
            let nextWinding = PCH_Winding(position: currentPos, volts: terminal.legVolts, amps: terminal.legAmps.onaf, axialGaps: [], type: PCH_Winding.WindingTypesForBIL(bil: termBIL.line)[0], staticRings: totalStaticRings, puNIperL: NIperL * tertVA / baseVA)
            
            result.append(nextWinding)
            
            currentPos += 1
            currentTerm += 1
        }
        
    }
    
    // now taps and tapping gaps
    var tapWindings:[PCH_Winding] = []
    // constants for innermost or outermost tap windings
    let innerTaps = -1
    let outerTaps = 10
    
    // constants for central gaps for delta windings
    let deltaCenterGapMain = 0.05
    let deltaCenterGapTaps = 0.2
    
    // By this point, we will only need to treat the terminals at indices 0 (LV) and 1 (HV)
    for i in 0..<2
    {
        let terminal = terms[i]
        
        // Start with static rings
        var totalStaticRings = 0
        let termBIL = terminal.bil
        
        if (PCH_Winding.NeedsStaticRing(bil: termBIL.line))
        {
            totalStaticRings += 1
        }
        if (PCH_Winding.NeedsStaticRing(bil: termBIL.neutral))
        {
            totalStaticRings += 1
        }
        if (terminal.hasDualVoltage && PCH_Winding.NeedsStaticRing(bil: termBIL.dv))
        {
            totalStaticRings += 2
        }
        
        if (terminal.hasDualVoltage)
        {
            if let offload = terminal.offloadTaps
            {
                
            }
        }
        else if let offload = terminal.offloadTaps
        {
            
        }
        
        // we assume that onload taps are never "dual-voltage"
        if let onload = terminal.onloadTaps
        {
            // we use pretty simple logic here, assuming that if the LV winding has onload taps, they are on an inner multistart winding, while HV taps are treated as outer double-stack disc windings
            let tapPos = (i == 0 ? innerTaps : outerTaps)
            let tapWdgType:PCH_Winding.WindingType = (i == 0 ? .multistart : .disc)
            // we assume that taps are always plus/minus (reversing)
            let numTaps = (onload.count - 1) / 2
            let tapVolts = onload.max()! * terminal.legVolts * (i == 0 ? 1.0 : 2.0)
            let tapAmps = (i == 0 ? 1.0 : 2.0) * terminal.legAmps.onaf
            let centerGap = (i == 0 || terminal.connection == .star ? 0.0 : deltaCenterGapTaps)
            var tapNIperL = NIperL * onload.max()!
            if (tapPos == outerTaps)
            {
                tapNIperL = tapNIperL / 0.8 // we usually try to get around 80% of the main coil height for outer taps
            }
            
            var axialGaps:[PCH_Winding.axialGap] = [PCH_Winding.axialGap(thisCoil: 0.0, otherCoils:0.0), PCH_Winding.axialGap(thisCoil: 0.0, otherCoils:0.0), PCH_Winding.axialGap(thisCoil: 0.0, otherCoils:0.0)]
            if centerGap > 0.0
            {
                axialGaps[1].thisCoil = centerGap
                axialGaps[1].otherCoils = deltaCenterGapMain
            }
            
            let newTapWinding = PCH_Winding(position: tapPos, volts: tapVolts, amps: tapAmps, axialGaps: axialGaps, type: tapWdgType, staticRings: 0, puMainNIperL: tapNIperL)
            
            result.append(newTapWinding)
        }
        
    }
    
    
    return result
}

func CreateCoil(innerRadius:Double, turns:Double, currentDensity:Double, elHeight:Double, topBIL:Double, bottomBIL:Double, middleBIL:Double) -> PCH_Coil
{
    
}
