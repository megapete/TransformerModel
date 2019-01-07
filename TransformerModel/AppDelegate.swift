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
        
        let terminal1 = PCH_TxfoTerminal(name: "LV", terminalVA: (7.5E6, 7.5E6), lineVoltage: 72500.0, preferredWindingType:.disc, numPhases: 3, connection: .star, phaseAngle: 0.0, lineBIL: BIL_Level.kv350, neutralBIL: BIL_Level.kv350)
        
        let terminal2 = PCH_TxfoTerminal(name: "HV", terminalVA: (7.5E6, 7.5E6), lineVoltage: 12500.0, preferredWindingType:.disc, numPhases: 3, connection: .delta, phaseAngle: -0.5235, lineBIL: BIL_Level.kv125, neutralBIL: BIL_Level.kv125)
        
        let requiredImpedance = PCH_ImpedancePair(term1: terminal1.name, term2: terminal2.name, impedancePU: 0.065, baseVA: 7.5E6 / 3.0)
        
        let eval = PCH_LossEvaluation(noLoad: 8000.0, onanLoad: 2500.0, onafLoad: 2500.0, llTemp: 85.0)
        
        let bestDesigns = CreateActivePartDesigns(forTerminals: [terminal1, terminal2], forOnanImpedances: [requiredImpedance], withEvals: eval)
        
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

