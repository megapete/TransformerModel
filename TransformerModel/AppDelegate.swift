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
        
        
        
        // let testString = PCH_FLD12_Library.fld12("This is a test", outputType: .metric)!
        
        // DLog("RESULT:\n\(testString)")
        
        
        
        // PCH_Costs.sharedInstance.FlushCostsFile()
        
    }

    @IBAction func handleDemo(_ sender: Any) {
        
        let onanMVA = 30.0E6
        let onafMVA = onanMVA * 5.0 / 3.0
        
        let terminal1 = PCH_TxfoTerminal(name: "LV", terminalVA: (onanMVA, onafMVA), lineVoltage: 12470.0, preferredWindingType:.disc, numPhases: 3, connection: .star, phaseAngle: 0.0, lineBIL: BIL_Level.kv110, neutralBIL: BIL_Level.kv110)
        
        let terminal2 = PCH_TxfoTerminal(name: "HV", terminalVA: (onanMVA, onafMVA), lineVoltage: 69000.0, preferredWindingType:.disc, numPhases: 3, connection: .delta, phaseAngle: -0.5235, lineBIL: BIL_Level.kv350, neutralBIL: BIL_Level.kv350)
        
        let requiredImpedance = PCH_ImpedancePair(term1: terminal1.name, term2: terminal2.name, impedancePU: 0.10, baseVA: onanMVA / 3.0)
        
        let onafEval = 4750.0 * (3.0 * 3.0) / (5.0 * 5.0)
        let eval = PCH_LossEvaluation(noLoad: 5150.0, onanLoad: 4750.0, onafLoad: onafEval, llTemp: 85.0)
        
        let bestDesigns = CreateActivePartDesigns(forTerminals: [terminal1, terminal2], forOnanImpedances: [requiredImpedance], withEvals: eval)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        PCH_Costs.sharedInstance.FlushCostsFile()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool
    {
        return true
    }


}

