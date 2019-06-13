//
//  PCH_TxfoDesigner.swift
//  TransformerModel
//
//  Created by Peter Huber on 2017-10-11.
//  Copyright © 2017 Peter Huber. All rights reserved.
//


import Foundation
import Cocoa

// For now, we'll create a constant for the frequency since I don't remember a single time where I needed something else. If this changes with TME, I'll create a variable to pass to the routines instead.
let PCH_StdFrequency = 60.0

// Some consants in this convenient location
let PCH_ImpedanceTolerance = (min:-0.075, max:0.075)

let PCH_CurrentDensityRange = (min:1.5E6, max:3.0E6)
let PCH_CurrentDensityIncrement = 0.250E6

let PCH_TypicalConductorRadialDim = 0.09 * 25.4 / 1000.0
let PCH_TypicalConductorAxialDim = 0.010

let PCH_StaticRingAxialDim = 0.75 * 25.4 / 1000.0

let PCH_VperNfactorRange = (min:0.45, max:0.85)
let PCH_VperNfactorIncrement = 0.01
let PCH_MaximumVoltsPerTurn = 200.0

let PCH_BmaxRange = (min:1.40, max:1.65)
let PCH_BmaxIncrement = 0.01

let PCH_NIperLatOnanRange = (min:20000.0, max:120000.0)
let PCH_NIperLnumIncrements = 50


// We need to make sure that the progress indicator sticks around for as long as it's needed, so
var PCH_TxfoDesignerProgressIndicator:PCH_ProgressIndicatorWindow? = nil

// Same thing with the queue that we'll wrap the actual function in
var PCH_TxfoDesignerQueue:DispatchQueue? = nil

struct PCH_WindingBIL
{
    let bottom:BIL_Level
    let middle:BIL_Level
    let top:BIL_Level
    
    var max:BIL_Level
    {
        get
        {
            var result = top
            
            if (self.middle.Value() > result.Value())
            {
                result = middle
            }
            
            if self.bottom.Value() > result.Value()
            {
                result = bottom
            }
            
            return result
        }
    }
}

struct PCH_ImpedancePair
{
    let term1:String
    let term2:String
    let impedancePU:Double
    let baseVA:Double // single-phase VA
    
    func Contains(termName:String) -> Bool
    {
        return termName == self.term1 || termName == self.term2
    }
}

// This is the entry point for the transformer designing program. The idea is that this function will take care of finding the 10 most suitable (and cheapest) designs for the set of terminals passed in, then return those transformers to the calling routine as an array of PCH_Transformer. It is assumed that the forTerminals parameter has been sorted so that the lowest "main" voltage is at index 0 and the highest main voltage is at index 1.
func CreateActivePartDesigns(forTerminals:[PCH_TxfoTerminal], forOnanImpedances:[PCH_ImpedancePair], withEvals:PCH_LossEvaluation) -> [PCH_SimplifiedActivePart]
{
    var simpImpTime:TimeInterval = 0.0
    var rabImpTime:TimeInterval = 0.0
    
    ZAssert(forOnanImpedances.count > 0, message: "There must be at least one impedance pair defined!")
    /*
    let numDesignsToKeep = 10
    let maxVperN = 200.0
    
    var cheapestResults:[PCH_SimplifiedActivePart] = []
    
    let numPhases = forTerminals[0].numPhases
    let refVoltage = forTerminals[0].legVolts
    let vpnRefKVA = (numPhases == 1 ? 3.0 : 1.0) * forTerminals[0].terminalVA.onan / 1000.0
    
    let vaMaxMinRatio = forTerminals[0].terminalVA.onaf / forTerminals[0].terminalVA.onan
    
    // constraints on constants
    let vpnFactorRange = (min:0.45, max:0.65)
    let vpnFactorIncrement = 0.01
    let bmaxRange = (min:1.40, max:1.60)
    let bmaxIncrement = 0.01
    
    // other constants used later on
    var highestMainBIL = forTerminals[1].bil.line
    if (forTerminals[0].bil.line.Value() > highestMainBIL.Value())
    {
        highestMainBIL = forTerminals[0].bil.line
    }
    let clearances = PCH_ClearanceData.sharedInstance
    
    let NIperLmin = 20000.0 * vaMaxMinRatio
    let NIperLmax = 120000.0 * vaMaxMinRatio
    let NI_NumIterations = 50
    let NIperLIncrement = (NIperLmax - NIperLmin) / Double(NI_NumIterations)
    
    // There's no easy way to iterate through an enum, so we just manually set up an array with each of the core steel types (there are only 4 of them!)
    let coreSteelTypes = [PCH_CoreSteel.SteelType.M080, PCH_CoreSteel.SteelType.M085, PCH_CoreSteel.SteelType.M090, PCH_CoreSteel.SteelType.ZDKH]
    
    // Debugging stats
    var totalDesigns = 0
    */
    
    if PCH_TxfoDesignerProgressIndicator == nil
    {
        PCH_TxfoDesignerProgressIndicator = PCH_ProgressIndicatorWindow()
    }
    
    PCH_TxfoDesignerProgressIndicator!.UpdateIndicator(value: PCH_VperNfactorRange.min, minValue: PCH_VperNfactorRange.min, maxValue: PCH_VperNfactorRange.max, text: "Creating active parts...")
    
    // create a queue so we can use our progress indicator
    PCH_TxfoDesignerQueue = DispatchQueue(label: "com.huberis.txfodesigner.vpn")
    
    guard let mainWindow = NSApplication.shared.mainWindow else
    {
        DLog("No main window!")
        return []
    }
    
    mainWindow.beginSheet(PCH_TxfoDesignerProgressIndicator!.window!, completionHandler: nil)
    
    PCH_TxfoDesignerQueue!.async {
        
        let numDesignsToKeep = 10
        let maxVperN = PCH_MaximumVoltsPerTurn
        
        var cheapestResults:[PCH_SimplifiedActivePart] = []
        
        let numPhases = forTerminals[0].numPhases
        let refVoltage = forTerminals[0].legVolts
        let vpnRefKVA = (numPhases == 1 ? 3.0 : 1.0) * forTerminals[0].terminalVA.onan / 1000.0
        
        let vaMaxMinRatio = forTerminals[0].terminalVA.onaf / forTerminals[0].terminalVA.onan
        
        // constraints on constants
        let vpnFactorRange = PCH_VperNfactorRange
        let vpnFactorIncrement = PCH_VperNfactorIncrement
        let bmaxRange = PCH_BmaxRange
        let bmaxIncrement = PCH_BmaxIncrement
        
        // other constants used later on
        var highestMainBIL = forTerminals[1].bil.line
        if (forTerminals[0].bil.line.Value() > highestMainBIL.Value())
        {
            highestMainBIL = forTerminals[0].bil.line
        }
        let clearances = PCH_ClearanceData.sharedInstance
        
        let NIperLmin = PCH_NIperLatOnanRange.min * vaMaxMinRatio
        let NIperLmax = PCH_NIperLatOnanRange.max * vaMaxMinRatio
        let NI_NumIterations = PCH_NIperLnumIncrements
        let NIperLIncrement = (NIperLmax - NIperLmin) / Double(NI_NumIterations)
        
        // There's no easy way to iterate through an enum, so we just manually set up an array with each of the core steel types (there are only 4 of them!)
        let coreSteelTypes = [PCH_CoreSteel.SteelType.M080, PCH_CoreSteel.SteelType.M085, PCH_CoreSteel.SteelType.M090, PCH_CoreSteel.SteelType.ZDKH]
        
        // Debugging stats
        var totalDesigns = 0
        
        for vpnFactor:Double in stride(from: vpnFactorRange.min, through: vpnFactorRange.max, by: vpnFactorIncrement)
        {
            DLog("Executing VPN factor: \(vpnFactor)")
            let vpnApprox = vpnFactor * sqrt(vpnRefKVA)
            let refTurns = round(refVoltage / vpnApprox)
            let vpnExact = refVoltage / refTurns
            
            if vpnExact > maxVperN
            {
                break
            }
            
            DispatchQueue.main.async { PCH_TxfoDesignerProgressIndicator!.UpdateIndicator(value: vpnFactor) }
            
            for approxBMax:Double in stride(from: bmaxRange.min, to: bmaxRange.max, by: bmaxIncrement)
            {
                for coreSteelType in coreSteelTypes
                {
                    let coreCircle = PCH_CoreCircle(targetBmax: approxBMax, voltsPerTurn: vpnExact, steelType: PCH_CoreSteel(type:coreSteelType), frequency: PCH_StdFrequency)
                    
                    // The terminals should have been set up with "preferred" winding locations for their main windings and tap windings (if any). We will make the following assumptions when onload taps are required: if the winding location for taps is the outermost winding, we assume that it is a "double-axial" winding, while if it is an inner winding, we assume that it is a multistart winding.
                    
                    var cheapestForThisCore:PCH_SimplifiedActivePart? = nil
                    var cheapestEval = Double.greatestFiniteMagnitude
                    let concQueue = DispatchQueue(label: "com.huberistech.txfo_designer.niperl", attributes: .concurrent)
                    
                    DispatchQueue.concurrentPerform(iterations: NI_NumIterations)
                    {
                        (i:Int) -> Void in
                        
                        let NIperL = NIperLmin + Double(i) * NIperLIncrement
                        
                        // for NIperL in stride(from: NIperLmin, through: NIperLmax, by: NIperLIncrement)
                        // {
                        
                        // create designs (easy!)
                        let nextArrangement = CoilArrangementForTerminals(terms: forTerminals, NIperL: NIperL, baseVA: forTerminals[0].terminalVA.onaf)
                        
                        var maxWindowHt = 0.0
                        
                        var coils:[PCH_SimplifiedCoilSection] = []
                        
                        // we'll only try playing with the current density if there's a value for the load loss evaluation
                        var startingCurrentDensity = PCH_CurrentDensityRange.max
                        if (withEvals.onanLoad != 0.0)
                        {
                            startingCurrentDensity = PCH_CurrentDensityRange.min
                        }
                        
                        var lowestCost = Double.greatestFiniteMagnitude
                        var coilList:PCH_CoilNode? = nil
                        
                        PCH_CreateChildNodes(parent: nil, vPerN: vpnExact, windings: nextArrangement, windingLevel: 0, previousOD: coreCircle.diameter, lowestCurrentDensity: startingCurrentDensity, onanImpedances: forOnanImpedances, maxWindHt: &maxWindowHt, evalTemp: withEvals.llTemp, evalDollars: withEvals.onafLoad, cheapestCoils: &coilList, cheapestCost: &lowestCost)
                        
                        if coilList != nil
                        {
                            // The last coil is pointed to by coilList, so:
                            let outerOD = coilList!.coil.OD
                            let betweenPhases = clearances.HiloDataForBIL(coilList!.coil.winding.bil.max).total * 1.5
                            
                            while coilList != nil
                            {
                                coils.insert(coilList!.coil, at: 0)
                                
                                coilList = coilList!.parent
                            }
                            
                            let legCenters = outerOD + betweenPhases
                            let windowHt = maxWindowHt + 0.010
                            let core = PCH_Core(numWoundLegs: 3, numLegs: 3, mainLegCenters: legCenters, windowHt: windowHt, yokeCoreCircle: coreCircle, mainLegCoreCircle: coreCircle)
                            
                            // we only allow a 3.5m (max) high core
                            if core.PhysicalHeight() <= 3.5
                            {
                                totalDesigns += 1
                                
                                let newActivePart = PCH_SimplifiedActivePart(coils: coils, core: core)
                                let newEvalCost = newActivePart.EvaluatedCost(atBmax: newActivePart.BMax, withEval: withEvals)
                                
                                concQueue.async(flags: .barrier)
                                {
                                    if newEvalCost < cheapestEval
                                    {
                                        cheapestEval = newEvalCost
                                        cheapestForThisCore = newActivePart
                                    }
                                }
                                
                            } // END if core.PhysicalHeight()
                            
                        } // END if let cList
                        
                    } // END for NIperL
                    
                    if let newActivePart = cheapestForThisCore
                    {
                        /*
                         let simpImpStartTime = ProcessInfo.processInfo.systemUptime
                         let simpImp = SimplifiedImpedance(coil1: newActivePart.coils[0], coil2: newActivePart.coils[1])
                         let simpImpEndTime = ProcessInfo.processInfo.systemUptime
                         simpImpTime += (simpImpEndTime - simpImpStartTime)
                         let rabImpStartTime = ProcessInfo.processInfo.systemUptime
                         let rabImp = RabinsMethodImpedance(refCoil: newActivePart.coils[0], otherCoil: newActivePart.coils[1], withCore: newActivePart.core)
                         let rabImpEndTime = ProcessInfo.processInfo.systemUptime
                         rabImpTime += (rabImpEndTime - rabImpStartTime)
                         */
                        
                        // DLog("Simplified impedance (pu): \(simpImp); Rabin's method: \(rabImp)")
                        
                        let newEvalCost = newActivePart.EvaluatedCost(atBmax: newActivePart.BMax, withEval: withEvals)
                        
                        if cheapestResults.isEmpty
                        {
                            // DLog("First: \(newEvalCost)")
                            cheapestResults.append(newActivePart)
                        }
                        else
                        {
                            // if the new active part cost is greater than all the values already in the array, index will be nil
                            if let index = cheapestResults.firstIndex(where: {$0.EvaluatedCost(atBmax: $0.BMax, withEval: withEvals) > newEvalCost})
                            {
                                /*
                                 if index == 0
                                 {
                                 DLog("Previous: $\(cheapestResults[0].EvaluatedCost(atBmax: cheapestResults[0].BMax, withEval: withEvals)), New: $\(newEvalCost)")
                                 }
                                 */
                                
                                cheapestResults.insert(newActivePart, at: index)
                                
                                if cheapestResults.count > numDesignsToKeep
                                {
                                    // DLog("Current: \(cheapestResults[0].EvaluatedCost(atTemp: 85.0, atBmax: cheapestResults[0].BMax, withEval: withEvals))")
                                    cheapestResults.removeLast()
                                }
                            }
                            else if cheapestResults.count < numDesignsToKeep
                            {
                                cheapestResults.append(newActivePart)
                            }
                        } // END else [if cheapestResults.isEmpty]
                        
                    } // END if let newActivePart
                    
                } // END for coreSteelType
                
            } // END for approxBMax:Double
            
        } // END for vpnFactor:Double
        
        DLog("Total designs created: \(totalDesigns)")
        
        DLog("Simplified impedance calculation time: \(simpImpTime)")
        DLog("Rabin's impedance calculation time: \(rabImpTime)")
        
        // we want to save the resulting designs in a file using an NSSavePanel, but that is UI, which CANNOT be done in any thread except the main thread. We dispatch a sync call to the main thread to take care of this.
        DispatchQueue.main.sync {
            
            guard let mainWindow = NSApplication.shared.mainWindow else
            {
                DLog("No main window!")
                assert(false, "Help!")
                return
            }
            
            mainWindow.endSheet(PCH_TxfoDesignerProgressIndicator!.window!)
            
            let saveFilePanel = NSSavePanel()
            
            saveFilePanel.title = "Save Top 10 Results"
            saveFilePanel.canCreateDirectories = true
            saveFilePanel.allowedFileTypes = ["txt"]
            saveFilePanel.allowsOtherFileTypes = false
            
            if (saveFilePanel.runModal().rawValue == NSFileHandlingPanelOKButton)
            {
                if let newFileURL = saveFilePanel.url
                {
                    // we want to use the LV coil for volts-per-turn and amp-turns per meter
                    let referenceTerm = forTerminals[0]
                    var refCoilIndex = -1
                    for i in 0..<cheapestResults[0].coils.count
                    {
                        if cheapestResults[0].coils[i].winding.termName == referenceTerm.name
                        {
                            refCoilIndex = i
                            break
                        }
                    }
                    
                    var bestCount = 1
                    var outputString = ""
                    for nextActivePart in cheapestResults
                    {
                        let refCoil = nextActivePart.coils[refCoilIndex]
                        let vpn = refCoil.winding.volts / refCoil.turns
                        let vpnString = String(format:"%0.3f", vpn)
                        let niPerM = refCoil.winding.NIperL
                        let niPerMString = String(format:"%0.1f", niPerM)
                        let Bmax = nextActivePart.BMax
                        let nlLoss = nextActivePart.core.LossAtBmax(Bmax)
                        let bMaxString = String(format:"%0.3f", Bmax)
                        
                        outputString += "Active part #\(bestCount)\nCORE\n====\nVolts Per Turn: \(vpnString); Amp-Turns/Meter: \(niPerMString); Bmax: \(bMaxString); Loss: \(nlLoss)\n\(nextActivePart.core)\nCOILS\n=====\n"
                        
                        for nextCoil in nextActivePart.coils
                        {
                            outputString += "\(nextCoil)"
                        }
                        
                        let matCostString = String(format:"%0.2f", nextActivePart.MaterialCosts())
                        let evalCostString = String(format:"%0.2f", nextActivePart.EvaluatedCost(atBmax: Bmax, withEval: withEvals))
                        
                        outputString += "\nMaterial Cost: $\(matCostString); Evaluated Cost: $\(evalCostString)\n\n"
                        
                        bestCount += 1
                    }
                    
                    do
                    {
                        try outputString.write(to: newFileURL, atomically: true, encoding: .unicode)
                        
                        DLog("Finished writing file")
                    }
                    catch
                    {
                        DLog("Error writing active part data")
                    }
                }
                else
                {
                    DLog("Bad file URL!")
                }
            }
        }
        
    } // END vpnQueue.async
    
    return []
}

func RabinsMethodImpedance(refCoil:PCH_SimplifiedCoilSection, otherCoil:PCH_SimplifiedCoilSection, withCore:PCH_Core) -> (pu:Double, baseVA:Double)
{
    let refVA = refCoil.winding.volts * refCoil.winding.amps
    let otherCoilMultiplier = -refVA / (otherCoil.winding.volts * otherCoil.winding.amps)
    
    let clearances = PCH_ClearanceData.sharedInstance
    let lowestZ0 = max(clearances.EdgeDistanceForBIL(refCoil.winding.bil.bottom), clearances.EdgeDistanceForBIL(otherCoil.winding.bil.bottom))
    
    var coilSections = refCoil.AsDiskSectionArray(coilRef:0, currentMultiplier: 1.0, lowestZ0: lowestZ0, withCore: withCore)
    coilSections.append(contentsOf: otherCoil.AsDiskSectionArray(coilRef:1, currentMultiplier: otherCoilMultiplier, lowestZ0: lowestZ0, withCore: withCore))
    
    var energy = 0.0
    for i in 0..<coilSections.count
    {
        let iAmps = sqrt(2.0) * (coilSections[i].coilRef == 0 ? refCoil.winding.amps : otherCoil.winding.amps * otherCoilMultiplier)
        energy += 0.5 * coilSections[i].SelfInductance(3.0) * iAmps * iAmps
        
        for j in i+1..<coilSections.count
        {
            let jAmps = sqrt(2.0) * (coilSections[j].coilRef == 0 ? refCoil.winding.amps : otherCoil.winding.amps * otherCoilMultiplier)
            
            energy += coilSections[i].MutualInductanceTo(coilSections[j], windHtFactor: 3.0) * iAmps * jAmps
        }
    }
    
    let xPU = 2.0 * π * PCH_StdFrequency * energy / refVA
    
    return (xPU, refVA)
}

func SimplifiedImpedance(coil1:PCH_SimplifiedCoilSection, coil2:PCH_SimplifiedCoilSection) -> (pu:Double, baseVA:Double)
{
    // For now, we just use the very simple calculation from the Blue Book (it will eventually be updated to the method used in the Excel design sheet)
    let va1 = coil1.winding.volts * coil1.winding.amps
    let va2 = coil2.winding.volts * coil2.winding.amps
    
    var ATperMM = coil1.winding.NIperL
    if (va2 > va1)
    {
        ATperMM = coil2.winding.NIperL
    }
    ATperMM /= 1000.0
    
    let vPerN = coil1.winding.volts / coil1.turns
    let LMTave = (coil1.LMT + coil2.LMT) * 1000.0 / 2.0
    var a = (coil2.ID - coil1.OD) / 2.0
    if a < 0.0
    {
        a = (coil1.ID - coil2.OD) / 2.0
    }
    a *= 1000.0
    let b1 = coil1.RB * 1000.0
    let b2 = coil2.RB * 1000.0
    
    let result = 7.9E-9 * ATperMM * LMTave * PCH_StdFrequency / vPerN * (a + (b1 + b2) / 3.0)
    
    return (result, max(va1, va2))
}

struct PCH_SimplifiedActivePart
{
    let coils:[PCH_SimplifiedCoilSection]
    let core:PCH_Core
    
    var BMax:Double
    {
        get
        {
            return core.mainLegCoreCircle.BmaxAtVperN(self.VPN, frequency: PCH_StdFrequency)
        }
    }
    
    var VPN:Double
    {
        get
        {
            return coils[0].winding.volts / coils[0].turns
        }
    }
    
    func MaterialCosts() -> Double
    {
        var result = 0.0
        
        for nextCoil in self.coils
        {
            result += nextCoil.CoilMaterialCost()
        }
        
        result += core.CanadianDollarValue()
        
        result += self.InsulationMaterialsEstimate()
        
        return result
    }
    
    func TotalCoilVolume() -> Double
    {
        var result = 0.0
        
        for nextCoil in self.coils
        {
            result += (nextCoil.condArea * nextCoil.LMT)
        }
        
        return result * 3.0
    }
    
    func InsulationMaterialsEstimate() -> Double
    {
        // this is a quick-and-dirty guesstimate of the insulation material costs (it really should use PCH_Costs class instead, but who's got the time?). This is the same calculation as is used in the Excel design sheet
        let exchangeRate = 0.75 // fall 2017
        let insulPrice = 0.4   // fall 2017
        
        let coilVol = self.TotalCoilVolume() * 1.0E9 / (25.4 * 25.4 * 25.4)
        
        return (π * (self.coils.last!.OD * self.coils.last!.OD * 1.0E6 / (25.4 * 25.4) - self.core.mainLegCoreCircle.diameter * self.core.mainLegCoreCircle.diameter * 1.0E6 / (25.4 * 25.4)) / 4.0 * self.core.windowHeight * 1000.0 / 25.4 * 3.0 - coilVol) * insulPrice / exchangeRate
    }
    
    func EvaluatedCost(atBmax:Double, withEval:PCH_LossEvaluation) -> Double
    {
        var loadLossEval = 0.0
        for nextCoil in self.coils
        {
            loadLossEval += nextCoil.EvaluatedCost(atTemp: withEval.llTemp, costPerKW: withEval.onafLoad)
        }
        
        // loadLossEval *= 3.0
        
        let noloadLossEval = self.core.LossAtBmax(atBmax) / 1000.0 * withEval.noLoad
        
        return self.MaterialCosts() + loadLossEval + noloadLossEval
    }
}



class PCH_CoilNode
{
    let parent:PCH_CoilNode?
    let coil:PCH_SimplifiedCoilSection
    
    init(parent:PCH_CoilNode?, coil:PCH_SimplifiedCoilSection)
    {
        self.parent = parent
        self.coil = coil
    }
    
    func ListEvaluatedCost(atTemp:Double, llEval:Double) -> Double
    {
        var result = self.coil.EvaluatedCost(atTemp: atTemp, costPerKW: llEval)
        
        if let parent = self.parent
        {
            result += parent.ListEvaluatedCost(atTemp: atTemp, llEval: llEval)
        }
        
        return result
    }
    
    func MeetsImpedanceRequirements(onanImpedances:[PCH_ImpedancePair]) -> Bool
    {
        for nextImpedance in onanImpedances
        {
            var coil1:PCH_SimplifiedCoilSection? = nil
            var coil2:PCH_SimplifiedCoilSection? = nil
            
            var nextNode:PCH_CoilNode? = self
            while nextNode != nil
            {
                let nextCoil = nextNode!.coil
                if nextImpedance.Contains(termName: nextCoil.winding.termName)
                {
                    if coil1 == nil
                    {
                        coil1 = nextCoil
                    }
                    else
                    {
                        coil2 = nextCoil
                        break
                    }
                }
                
                nextNode = nextNode!.parent
            }
            
            if coil2 == nil
            {
                return false
            }
            
            let theImp = SimplifiedImpedance(coil1: coil1!, coil2: coil2!)
            
            let impedance = theImp.pu * nextImpedance.baseVA / theImp.baseVA
            
            if impedance > nextImpedance.impedancePU * (1.0 + PCH_ImpedanceTolerance.max) || impedance < nextImpedance.impedancePU * (1.0 + PCH_ImpedanceTolerance.min)
            {
                return false
            }
        }
        
        return true
    }
}

struct PCH_SimplifiedCoilSection:CustomStringConvertible
{
    let winding:PCH_Winding
    let turns:Double
    let ID:Double
    let RB:Double
    let condArea:Double
    let conductor:PCH_Conductor.Conductor
    let onafCurrentDensity:Double
    
    var description:String
    {
        get
        {
            let NIperLString = String(format:"%.1f AT/m", self.winding.NIperL)
            let idString = String(format:"%0.4f m", self.ID)
            let rbString = String(format:"%0.4f m", self.RB)
            let loss = self.LoadLoss(tempInC: 85.0)
            return "Coil Name: \(self.winding.termName); AT/m: \(NIperLString) Onaf Current Density: \(self.onafCurrentDensity); ONAF Loss: \(loss); Inner Diameter: \(idString); Radial Build: \(rbString)\n"
        }
    }
    
    var VPN:Double
    {
        get
        {
            return self.winding.volts / self.turns
        }
    }
    
    var OD:Double
    {
        get
        {
            return self.ID + 2.0 * self.RB
        }
    }
    
    var LMT:Double
    {
        get
        {
            return π * (self.ID + self.RB)
        }
    }
    
    func CoilHeight() -> Double
    {
        let ampturns = winding.amps * self.turns
        let height = ampturns / winding.NIperL
        
        return height
    }
    
    // This function uses the admittedly crappy method from the Excel design sheet
    func EddyLossPU() -> Double
    {
        let ampturnsPerInch = winding.NIperL / 1000.0 * 25.4
        let D = PCH_TypicalConductorRadialDim * 1000.0 / 25.4
        let currDensity = self.onafCurrentDensity / 1.0E6 * 25.4 * 25.4
        let cubicInchesPerAmp = D / currDensity
        let freqFactor = 60.0 / 50.0
        let eddyPercent = ampturnsPerInch * ampturnsPerInch * (20.0 / 0.02551) * cubicInchesPerAmp * cubicInchesPerAmp * freqFactor * freqFactor
        
        return eddyPercent / 100.0
    }
    
    func LoadLoss(tempInC:Double) -> Double
    {
        let defaultEddyLossPU = self.EddyLossPU()
        
        let copper = PCH_Conductor(conductor: self.conductor)
        let resistance = copper.Resistance(condArea, length: self.LMT, temperature: tempInC)
        
        let totalAmps = winding.amps * self.turns
        var loss = totalAmps * totalAmps * resistance * (1.0 + defaultEddyLossPU)
        
        loss *= 3.0
        
        return loss
    }
    
    func CoilWeight() -> Double
    {
        return PCH_Conductor(conductor: self.conductor).Weight(area: self.condArea, length: self.LMT)
    }
    
    func CoilMaterialCost() -> Double
    {
        let copper = PCH_Conductor(conductor: self.conductor)
        
        var cost = copper.CanadianDollarValue(area: self.condArea, length: self.LMT)
        
        cost *= 3.0
        
        return cost
    }
    
    func EvaluatedCost(atTemp:Double, costPerKW:Double) -> Double
    {
        let cost = self.LoadLoss(tempInC:atTemp) / 1000.0 * costPerKW
        return cost
    }
    
    func AsDiskSectionArray(coilRef:Int, currentMultiplier:Double, lowestZ0:Double, withCore:PCH_Core) -> [PCH_DiskSection]
    {
        var result:[PCH_DiskSection] = []
        
        var numSections = 1
        for nextGap in self.winding.axialGaps
        {
            if nextGap.thisCoil > 0.0
            {
                numSections += 1
            }
        }
        
        let gapCentersOffset = self.CoilHeight() / Double(numSections)
        var currentGapIndex = 0
        var nextZ0 = lowestZ0
        let turnsPerSection = self.turns / Double(numSections)
        let spaceFactor = self.winding.AxialSpaceFactorWithBIL(bil: self.winding.bil.max) * self.winding.RadialSpaceFactorWithBIL(bil: self.winding.bil.max, amps: self.winding.amps)
        
        for nextSection in 0..<numSections
        {
            let sectionName = "\(self.winding.termName)\(nextSection)"
            let newSectionData = PCH_SectionData(sectionID: sectionName, serNum: 0, inNode: 0, outNode: 0)
            
            let nextGapCenter = Double(nextSection + 1) * gapCentersOffset
            let nextGap = self.winding.axialGaps[currentGapIndex].thisCoil
            let nextHeight = nextGapCenter - nextGap / 2.0 - nextZ0
            let newSectionRect = NSRect(x: self.ID / 2.0, y: nextZ0, width: self.RB, height: nextHeight)
            let newJ = self.onafCurrentDensity * spaceFactor * currentMultiplier
            
            let newSection = PCH_DiskSection(coilRef: coilRef, diskRect: newSectionRect, N: turnsPerSection, J: newJ, windHt: withCore.windowHeight, coreRadius: withCore.mainLegCoreCircle.diameter / 2.0, secData: newSectionData)
            
            result.append(newSection)
            
            currentGapIndex += 1
            nextZ0 += Double(newSectionRect.size.height) + nextGap
        }
        
        return result
    }
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
        case programDecide // let the program decide the winding type
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
    let NIperL:Double
    let isTaps:Bool
    let termName:String
    let bil:PCH_WindingBIL
    
    init(termName:String, position:Int, volts:Double, amps:Double, axialGaps:[axialGap], type:WindingType, staticRings:Int, NIperL:Double, isTaps:Bool, bil:PCH_WindingBIL)
    {
        self.termName = termName
        self.position = position
        self.volts = volts
        self.amps = amps
        self.axialGaps = axialGaps
        self.type = type
        self.staticRings = staticRings
        self.NIperL = NIperL
        self.isTaps = isTaps
        self.bil = bil
    }
    
    // Axial space factor is defined as conductor_axial_space / total_axial_space
    func AxialSpaceFactorWithBIL(bil:BIL_Level) -> Double
    {
        var result = -1.0
        
        let clearance = PCH_ClearanceData.sharedInstance
        
        // we will assume that a reasonably sized conductor will be some multiple of 10mm in the axial direction
        let typCondA = PCH_TypicalConductorAxialDim
        
        switch self.type {
            
        case .disc,
             .helix:
            result = typCondA / (typCondA + clearance.ConductorCoverForBIL(bil) + clearance.InterDiskForBIL(bil))
            
        case .layer,
             .multistart:
            result = typCondA / (typCondA + clearance.ConductorCoverForBIL(bil))
            
        default:
            result = 1.0
        }
        
        return result
    }
    
    // Class function for the axial space factor of "typical" coils of the given BIL
    
    // Radial space factor is defined as conductor_radial_space / total_radial_space. Note that this function only returns the space factor of a single conductor (that is, things like inter-layer insulation and ducts need to be considered elsewhere)
    func RadialSpaceFactorWithBIL(bil:BIL_Level, amps:Double) -> Double
    {
        let clearance = PCH_ClearanceData.sharedInstance
        
        // we will assume that a reasonably sized conductor will be some multiple of 2.5mm in the radial direction
        let typCondR = PCH_TypicalConductorRadialDim
        var result = 0.0
        // If the amps are high and it's a disc winding (the BIL is high enough), we'll probably use twin or CTC instead of a single strand, both of which have a much better space factor.
        // Our algorithm uses 10mm wide conductor (or 2 x 5mm for CTC) and the maximum current density is 3A/mm2, so
        if self.type == .disc && amps > 137.0
        {
            
            let sectionRequired = amps / 3.0E6
            let typicalAxialDim = PCH_TypicalConductorAxialDim
            let totalRadial = sectionRequired / typicalAxialDim
            let numRadialStrands = round(totalRadial / typCondR + 0.5)
            let radialConductorSpace = numRadialStrands * (typCondR + 0.005 * 25.4 / 1000)
            
            result = totalRadial / (radialConductorSpace + clearance.ConductorCoverForBIL(bil))
            
            // result = typCondR / (typCondR + clearance.ConductorCoverForBIL(bil))
        }
        else if self.type == .disc && amps > 68.5
        {
            // twin
            let totalRadialPaperPerTurn = clearance.ConductorCoverForBIL(bil) + 0.012 * 25.4 / 1000.0
            result = 2.0 * typCondR / (2.0 * typCondR + totalRadialPaperPerTurn)
        }
        else
        {
            result = typCondR / (typCondR + clearance.ConductorCoverForBIL(bil))
        }
        
        return result
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

func PCH_CreateChildNodes(parent:PCH_CoilNode?, vPerN:Double, windings:[PCH_Winding], windingLevel:Int, previousOD:Double, lowestCurrentDensity:Double, onanImpedances:[PCH_ImpedancePair], maxWindHt:inout Double, evalTemp:Double, evalDollars:Double, cheapestCoils:inout PCH_CoilNode?, cheapestCost:inout Double)
{
    guard windingLevel < windings.count
    else
    {
        if let path = parent
        {
            if path.MeetsImpedanceRequirements(onanImpedances: onanImpedances)
            {
                let pathCost = path.ListEvaluatedCost(atTemp: evalTemp, llEval: evalDollars)
                if pathCost < cheapestCost
                {
                    cheapestCost = pathCost
                    cheapestCoils = path
                }
            }
        }
        
        return
    }
    
    let clearances = PCH_ClearanceData.sharedInstance
    for nextCurrentDensity in stride(from: lowestCurrentDensity, through: PCH_CurrentDensityRange.max, by: PCH_CurrentDensityIncrement)
    {
        let winding = windings[windingLevel]
        let turns = round(winding.volts / vPerN)
        var hiloBIL = winding.bil.max
        if let lastCoilParent = parent
        {
            if lastCoilParent.coil.winding.bil.max > hiloBIL
            {
                hiloBIL = lastCoilParent.coil.winding.bil.max
            }
        }
        
        let ID = previousOD + 2.0 * clearances.HiloDataForBIL(hiloBIL).total
        let ampTurns = winding.amps * turns
        let condArea = ampTurns / nextCurrentDensity
        let coilHt = ampTurns / winding.NIperL
        let topClearance = clearances.EdgeDistanceForBIL(winding.bil.top)
        let bottomClearance = clearances.EdgeDistanceForBIL(winding.bil.bottom)
        maxWindHt = max(maxWindHt, coilHt + Double(winding.staticRings) * PCH_StaticRingAxialDim + topClearance + bottomClearance)
        
        let totalGaps = winding.axialGaps[0].thisCoil + winding.axialGaps[1].thisCoil + winding.axialGaps[2].thisCoil
        let condAxial = (coilHt - totalGaps) * winding.AxialSpaceFactorWithBIL(bil: winding.bil.max)
        let condRadial = condArea / condAxial
        
        let typicalCondR = PCH_TypicalConductorRadialDim
        let numRadialConds = round(condRadial / typicalCondR + 0.5)
        var radialBuild = condRadial / winding.RadialSpaceFactorWithBIL(bil: winding.bil.max, amps:winding.amps)
        
        if winding.type == .layer || winding.type == .sheet
        {
            radialBuild += min(numRadialConds - 1.0, 2.0) * 0.25 * 25.4 / 1000.0
        }
        
        let newCoil = PCH_SimplifiedCoilSection(winding: winding, turns: turns, ID: ID, RB: radialBuild, condArea: condArea, conductor: .copper, onafCurrentDensity: nextCurrentDensity)
        
        let newCoilNode = PCH_CoilNode(parent: parent, coil: newCoil)
        
        PCH_CreateChildNodes(parent: newCoilNode, vPerN: vPerN, windings: windings, windingLevel: windingLevel + 1, previousOD: newCoil.OD, lowestCurrentDensity: lowestCurrentDensity, onanImpedances: onanImpedances, maxWindHt: &maxWindHt, evalTemp: evalTemp, evalDollars: evalDollars, cheapestCoils: &cheapestCoils, cheapestCost: &cheapestCost)
    }
}


// Note that NIperL and baseVA should be the highest rating of the transformer (.onaf)
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
            
            let nextWinding = PCH_Winding(termName: terminal.name, position: currentPos, volts: terminal.legVolts, amps: terminal.legAmps.onaf, axialGaps: [], type: (terminal.wdgType != .programDecide ? terminal.wdgType : PCH_Winding.WindingTypesForBIL(bil: termBIL.line)[0]), staticRings: totalStaticRings, NIperL: NIperL * tertVA / baseVA, isTaps:false, bil:PCH_WindingBIL(bottom: terminal.bil.neutral, middle: terminal.bil.dv, top: terminal.bil.line))
            
            result.append(nextWinding)
            
            currentPos += 1
            currentTerm += 1
        }
        
    }
    
    // now taps and tapping gaps
    // var tapWindings:[PCH_Winding] = []
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
        
        var axialGaps:[PCH_Winding.axialGap] = [PCH_Winding.axialGap(thisCoil: 0.0, otherCoils:0.0), PCH_Winding.axialGap(thisCoil: 0.0, otherCoils:0.0), PCH_Winding.axialGap(thisCoil: 0.0, otherCoils:0.0)]
        
        if (terminal.hasDualVoltage)
        {
            let clearances = PCH_ClearanceData.sharedInstance
            
            let centerGap = clearances.EdgeDistanceForBIL(terminal.bil.dv)
            
            axialGaps[1] = PCH_Winding.axialGap(thisCoil: centerGap, otherCoils: centerGap)
            
            if terminal.offloadTaps != nil
            {
                var tapGapThisCoil = 25.0
                if terminal.bil.line.Value() > 350
                {
                    tapGapThisCoil *= 1.5
                }
                
                let tapGapOtherCoils = tapGapThisCoil + 50.0
                
                axialGaps[0] = PCH_Winding.axialGap(thisCoil: tapGapThisCoil, otherCoils: tapGapOtherCoils)
                axialGaps[2] = axialGaps[0]
            }
        }
        else if terminal.offloadTaps != nil
        {
            var tapGapThisCoil = 25.0
            if terminal.bil.line.Value() > 350
            {
                tapGapThisCoil *= 1.5
            }
            
            let tapGapOtherCoils = tapGapThisCoil + 50.0
            
            axialGaps[1] = PCH_Winding.axialGap(thisCoil: tapGapThisCoil, otherCoils: tapGapOtherCoils)
        }
        
        let newMainWinding = PCH_Winding(termName: terminal.name, position: currentPos + i, volts: terminal.legVolts, amps: terminal.legAmps.onaf, axialGaps: axialGaps, type: PCH_Winding.WindingTypesForBIL(bil: terminal.bil.line)[0], staticRings: totalStaticRings, NIperL: NIperL, isTaps:false, bil:PCH_WindingBIL(bottom: terminal.bil.neutral, middle: terminal.bil.dv, top: terminal.bil.line))
        
        result.append(newMainWinding)
        
        // we assume that onload taps are never "dual-voltage"
        if let onload = terminal.onloadTaps
        {
            // we use pretty simple logic here, assuming that if the LV winding has onload taps, they are on an inner multistart winding, while HV taps are treated as outer double-stack disc windings
            let tapPos = (i == 0 ? innerTaps : outerTaps)
            let tapWdgType:PCH_Winding.WindingType = (i == 0 ? .multistart : .disc)
            // we assume that taps are always plus/minus (reversing)
            // let numTaps = (onload.count - 1) / 2
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
            
            let rvBIL = (terminal.connection == .delta ? terminal.bil.line : terminal.bil.neutral)
            
            let tapName = terminal.name + "RV"
            let newTapWinding = PCH_Winding(termName:tapName, position: tapPos, volts: tapVolts, amps: tapAmps, axialGaps: axialGaps, type: tapWdgType, staticRings: 0, NIperL: tapNIperL, isTaps:true, bil:PCH_WindingBIL(bottom: rvBIL, middle: rvBIL, top: rvBIL))
            
            result.append(newTapWinding)
        }
        
    }
    
    // Set the gaps in all the coils
    for i in 0..<result.count
    {
        let axGaps = result[i].axialGaps
        
        for j in 0..<result.count
        {
            if j != i
            {
                var otherAxGaps = result[j].axialGaps
                for k in 0..<3
                {
                    if axGaps[k].otherCoils > otherAxGaps[k].thisCoil
                    {
                        result[j].axialGaps[k].thisCoil = axGaps[k].otherCoils
                    }
                }
            }
        }
    }
    
    // we sort the result array according to the position of each winding
    result.sort { (a:PCH_Winding, b:PCH_Winding) -> Bool in
        return a.position < b.position
    }
    
    for i in 0..<result.count
    {
        result[i].position = i
    }
    
    return result
}


