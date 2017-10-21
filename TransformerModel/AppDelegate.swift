//
//  AppDelegate.swift
//  TransformerModel
//
//  Created by PeterCoolAssHuber on 2015-07-03.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        /*
        let tstCoreCircle = PCH_CoreCircle(targetBmax: 1.564, voltsPerTurn: 42.576, steelType: PCH_CoreSteel(type: PCH_CoreSteel.SteelType.M3T23))
        
        print(tstCoreCircle.diameter)
        
        for nextStep in tstCoreCircle.steps
        {
            print("Width: \(nextStep.lamination!.width), Stack: \(nextStep.stackHeight)")
            
        }
        
        let tstHilo = PCH_Hilo(innerDiameter: 0.25, totalRadialBuild: 0.020, totalSolid: 0.008, numColumns: 18)
        
        tstHilo.height = 1.75
        
        print(tstHilo)
        
        let hiloClearance = PCH_ClearanceData.sharedInstance.HiloDataForBIL(BIL_Level.KV125)
        
        print("Overall: \(hiloClearance.0); Solid: \(hiloClearance.1)")

        */
        
        /*
        DLog("This is a test")
        
        let basicRad = PCH_Radiator(numPanels:32, panelDimensions:(PCH_Radiator.standardWidth, 2.2))
        
        let testFans = PCH_FanBank.GetOptimumNumberOfFansForRad(basicRad, rejectFans: [])
        
        print("Number of fans: \(testFans!.numFans)")

        let CMM = PCH_FanBank.CubicMetersPerMinuteForFan(testFans!.fanModel, speed: PCH_FanBank.FanSpeeds.rpm1140)
        
        print("CMM at 1140 RPM: \(CMM)")
        
        let area = PCH_FanBank.BlowableAreaForFan(testFans!.fanModel)
        
        print("Area: \(area)")
        */
        
        let terminal1 = PCH_TxfoTerminal(name: "LV", terminalVA: (28.2E6, 47.0E6), lineVoltage: 26400.0, numPhases: 3, connection: .delta, phaseAngle: π / 5.0, lineBIL: BIL_Level.kv125, neutralBIL: BIL_Level.kv125)
        
        let terminal2 = PCH_TxfoTerminal(name: "HV", terminalVA: (28.2E6, 47.0E6), lineVoltage: 120000.0, numPhases: 3, connection: .star, phaseAngle: 0.0, lineBIL: BIL_Level.kv550, neutralBIL: BIL_Level.kv95)
        
        let requiredImpedance = PCH_ImpedancePair(term1: terminal1.name, term2: terminal2.name, impedancePU: 0.185 * 3.0 / 5.0, baseVA: 28.2E6 / 3.0)
        
        let eval = PCH_LossEvaluation(noLoad: 6000.0, onanLoad: 2000.0, onafLoad: 2000.0 * (3.0 / 5.0) * (3.0 / 5.0))
        
        let bestDesigns = CreateActivePartDesigns(forTerminals: [terminal1, terminal2], forOnanImpedances: [requiredImpedance], withEvals: eval)
        
        // we want to use the LV coil for volts-per-turn and amp-turns per meter
        let referenceTerm = terminal1
        var refCoilIndex = -1
        for i in 0..<bestDesigns[0].coils.count
        {
            if bestDesigns[0].coils[i].winding.termName == referenceTerm.name
            {
                refCoilIndex = i
                break
            }
        }
        
        guard refCoilIndex >= 0 else
        {
            ALog("Could not find reference coil!!!")
            return
        }
        
        var bestCount = 1
        var outputString = ""
        for nextActivePart in bestDesigns
        {
            let refCoil = nextActivePart.coils[refCoilIndex]
            let vpn = refCoil.winding.volts / refCoil.turns
            let niPerM = refCoil.winding.NIperL
            let Bmax = nextActivePart.core.mainLegCoreCircle.BmaxAtVperN(vpn, frequency: PCH_StdFrequency)
            
            outputString += "Active part #\(bestCount)\nCORE\n====\nVolts Per Turn: \(vpn); Amp-Turns/Meter: \(niPerM); Bmax: \(Bmax)\n\(nextActivePart.core)\nCOILS\n=====\n"
            
            for nextCoil in nextActivePart.coils
            {
                outputString += "\(nextCoil)"
            }
            
            outputString += "\nMaterial Cost: \(nextActivePart.MaterialCosts()); Evaluated Cost \(nextActivePart.EvaluatedCost(atTemp: 85.0, atBmax: Bmax, withEval: eval))\n\n"
            
            bestCount += 1
        }
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectoryURL = paths[0]
        
        do
        {
            try outputString.write(to: documentsDirectoryURL.appendingPathComponent("ActiveParts.txt"), atomically: true, encoding: .unicode)
        }
        catch
        {
            DLog("Error writing active part data")
        }
        
        PCH_Costs.sharedInstance.FlushCostsFile()
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool
    {
        return true
    }


}

