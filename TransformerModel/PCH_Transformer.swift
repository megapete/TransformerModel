//
//  PCH_Transformer.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-13.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Foundation

/// A struct that fully defines a transformer. It's a struct so that we can do simple copy assignments even though the member properties are all classes (to keep from excessive copying during optimization). 

struct PCH_Transformer {
    
    /// The core of the transformer
    let core:PCH_Core
    
    /// The definition of one wound leg of the transformer
    let phase:PCH_Phase
    
    /// The definition of the tank that the transformer is in
    let tank:PCH_Tank
    
    /// An array of radiator banks on the transformer. If radiators are not required, this is an empty array
    let radBanks:[PCH_RadBank]
    
    /// An array holding the terminals of the transformer
    let terminals:[PCH_TxfoTerminal]
    
    /// The private "behind the scenes" value that we hold for numPhases
    private var _numPhases:Int
    
    /// The number of phases. Must be equal to 1 or 3. We restrict access to the underlying property by creating a computed property
    var numPhases:Int {
        
        get {
            
            return self._numPhases
        }
        
        set(newNum) {
            
            if (newNum != 1 && newNum != 3)
            {
                ALog("Number of phases must be equal to 1 or 3 - not changing")
            }
            else
            {
                self._numPhases = newNum
            }
        }
    }
    
    /**
        Designated initializer (failable)
    
        - parameter coreDef: The PCH_Core in the transformer
        - parameter phaseDef: The PCH_Phase that is on every wound leg of the transformer
        - parameter tankDef: The PCH_Tank that the transformer is in
        - parameter radBanksDef: The (possibly zero, possibly multiple) PCH_RadBanks on the transformer. If radiators are not required, pass an empty array
        - parameter numPhases: The number of phases of the transformer (must be 1 or 3)
        - parameter termsDef: An array of PCH_TxfoTerminals for the transformer
    */
    init?(coreDef:PCH_Core, phaseDef:PCH_Phase, tankDef:PCH_Tank, radBanksDef:[PCH_RadBank], numPhases:Int, termsDef:[PCH_TxfoTerminal])
    {
        self.core = coreDef
        self.phase = phaseDef
        self.tank = tankDef
        self.radBanks = radBanksDef
        
        if (numPhases == 1 || numPhases == 3)
        {
            self._numPhases = numPhases
        }
        else
        {
            ALog("Number of phases must be 1 or 3!")
            self._numPhases = 3
        }
        
        for nextTerm in termsDef
        {
            if (nextTerm.numPhases != numPhases)
            {
                ALog("Illegal terminal has \(nextTerm.numPhases) phases but the transformer has \(numPhases)!!")
                return nil
            }
        }
        
        self.terminals = termsDef
    }
    
}