//
//  PCH_Core.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-13.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// The class that represents an entire transformer core.

class PCH_Core {

    /// The number of legs that have coils on them (1,2, or 3)
    let numWoundLegs:Int
    
    /// The total number of legs on the core
    let numLegs:Int
    
    /// The center-to-center distance of the main legs (ones with coils)
    let mainLegCenters:Double
    
    /// Window width between two main legs
    var mainWindowWidth:Double {
        
        get {
            
            return self.mainLegCenters - self.mainLegCoreCircle.mainStepWidth
        }
    }
    
    /// Window width between a main leg and an outside leg
    var outsideWindowWidth:Double {
        
        get {
            
            if let outsideLeg = self.outsideLegCoreCircle
            {
                return self.outsideLegCenters - (self.mainLegCoreCircle.mainStepWidth - outsideLeg.mainStepWidth) / 2.0
            }
            else
            {
                return 0.0
            }
        }
    }
    
    /// The window height of the core
    let windowHeight:Double
    
    /// The center-to-center distance between an outermost main leg and an outside leg
    let outsideLegCenters:Double
    
    /// The PCH_CoreCircle that is used to stack the top and bottom yokes
    let yokeCoreCircle:PCH_CoreCircle
    
    /// The PCH_CoreCircle that is used ot stack the main legs
    let mainLegCoreCircle:PCH_CoreCircle
    
    /// An optional PCH_CoreCircle that is used to stack (any) outside legs
    let outsideLegCoreCircle:PCH_CoreCircle?
    
    /**
        Designated initializer. Creates a new core.
    
        - parameter numWoundLegs: The number of legs that have coils on them (1,2, or 3)
        - parameter numLegs: The total number of legs on the core
        - parameter mainLegCenters: The center-to-center distance of the main legs (ones with coils)
        - parameter windowHt: The window height of the core
        - parameter yokeCoreCircle: The PCH_CoreCircle that is used to stack the top and bottom yokes
        - parameter mainLegCOreCircle: The PCH_CoreCircle that is used ot stack the main legs
        - parameter outsideLegCenters: The center-to-center distance between an outermost main leg and an outside leg
        - parameter outsideLegCoreCircle: An optional PCH_CoreCircle that is used to stack outside legs (if any)
    */
    init(numWoundLegs:Int, numLegs:Int, mainLegCenters:Double, windowHt:Double, yokeCoreCircle:PCH_CoreCircle, mainLegCoreCircle:PCH_CoreCircle, outsideLegCenters:Double = 0.0, outsideLegCoreCircle:PCH_CoreCircle? = nil)
    {
        ZAssert(numWoundLegs <= numLegs, message: "You must have at least as many legs as wound legs!")
        ZAssert(numWoundLegs > 0 && numWoundLegs < 4, message: "This program can only handle transformers with 1, 2, or 3 wound legs.")
        
        self.numLegs = numLegs
        self.numWoundLegs = numWoundLegs
        self.mainLegCenters = mainLegCenters
        self.windowHeight = windowHt
        self.yokeCoreCircle = yokeCoreCircle
        self.mainLegCoreCircle = mainLegCoreCircle
        self.outsideLegCenters = outsideLegCenters
        self.outsideLegCoreCircle = outsideLegCoreCircle
    }
    
}
