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
        
        DLog("This is a test")
        
        let basicRad = PCH_Radiator(numPanels:28, panelDimensions:(PCH_Radiator.standardWidth, 2.2))
        
        let testFans = PCH_FanBank.GetOptimumNumberOfFansForRad(basicRad)
        
        print("Number of fans: \(testFans!.numFans)")

        let CMM = PCH_FanBank.CubicMetersPerMinuteForFan(testFans!.fanModel, speed: PCH_FanBank.FanSpeeds.rpm1140)
        
        print("CMM at 1140 RPM: \(CMM)")
        
        let area = PCH_FanBank.BlowableAreaForFan(testFans!.fanModel)
        
        print("Area: \(area)")
        
        
        
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

