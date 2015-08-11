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


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        let tstCoreCircle = PCH_CoreCircle(targetBmax: 1.564, voltsPerTurn: 42.576, steelType: PCH_CoreSteel(type: PCH_CoreSteel.SteelType.M3T23))
        
        print(tstCoreCircle.diameter)
        
        for nextStep in tstCoreCircle.steps
        {
            print("Width: \(nextStep.lamination!.width), Stack: \(nextStep.stackHeight)")
            
        }
        
        let tstHilo = PCH_Hilo(innerDiameter: 0.25, totalRadialBuild: 0.020, totalSolid: 0.008, numColumns: 18)
        
        tstHilo.height = 1.75
        
        print(tstHilo)
        
        PCH_Costs.sharedInstance.FlushCostsFile()
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

