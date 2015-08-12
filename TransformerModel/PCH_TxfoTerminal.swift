//
//  PCH_TxfoTerminal.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-12.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// A very complex class that defines a transformer "terminal". A terminal defines voltage, MVA, current/voltage phasors, connections

class PCH_TxfoTerminal {

    /// Optional identifier for the terminal
    var name:String?
    
    /// The private "behind the scenes" value that we hold for numPhases
    private var _numPhases:Int
    
    /// The number of phases. Must be equal to 1 or 3
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
    
    /// Possible transformer terminal connections
    enum Connections {
        
        case OnePhaseOneLeg, OnePhaseTwoLegParallel, OnePhaseTwoLegSeries, Star, Delta, Zigzag
    }
    
    let connection:Connections
    
    let terminalVA:Double
    
    /// Line to line voltage of the terminal
    let lineVolts:Double
    
    /// Leg voltage (can also be accessed as the property phaseVolts)
    var legVolts:Double {
        
        get {
            
            if (numPhases == 1)
            {
                if (self.connection == Connections.OnePhaseOneLeg || self.connection == Connections.OnePhaseTwoLegParallel)
                {
                    return lineVolts
                }
                else
                {
                    return lineVolts / 2.0
                }
            }
            else // must be 3
            {
                if self.connection == Connections.Delta
                {
                    return lineVolts
                }
                else if (self.connection == Connections.Star)
                {
                    return lineVolts / SQRT3
                }
                else // must be zigzag
                {
                    return lineVolts / 3.0
                }
            }
        }
    }
    
    /// Phase voltage (the routine actually just returns the "leg voltage"
    var phaseVolts:Double {
        
        get {
            
            return legVolts
        }
    }
    
    /// The amps entering the terminal (computed property)
    var lineAmps:Double {
        
        get {
            
            let phaseFactor = (self.connection == .Delta || self.connection == .Star ? SQRT3 : 1.0)
            
            return self.terminalVA / phaseFactor / self.lineVolts
        }
    }
    
    var phaseAngleI:Double
    
    
}
