//
//  PCH_TxfoTerminal.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-12.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// A somewhat complicated class that defines a transformer "terminal". A terminal defines voltage, MVA, current/voltage phasors, connections, taps, etc.

class PCH_TxfoTerminal {

    /// Required identifier for the terminal
    var name:String
    
    /// The private "behind the scenes" value that we hold for numPhases
    fileprivate var _numPhases:Int
    
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
    
    /// Possible transformer terminal connections
    enum Connections {
        
        case onePhaseOneLeg, onePhaseTwoLegParallel, onePhaseTwoLegSeries, star, delta, zigzag
    }
    
    /// The connection of the terminal
    let connection:Connections
    
    /// The VA of the terminal
    let terminalVA:(onan:Double, onaf:Double)
    
    /// Line to line voltage of the terminal
    let lineVolts:Double
    
    /// Leg voltage (can also be accessed as the property phaseVolts)
    var legVolts:Double {
        
        get {
            
            if (self.numPhases == 1)
            {
                if (self.connection == Connections.onePhaseOneLeg || self.connection == Connections.onePhaseTwoLegParallel)
                {
                    return self.lineVolts
                }
                else
                {
                    return lineVolts / 2.0
                }
            }
            else // must be 3
            {
                if self.connection == Connections.delta
                {
                    return self.lineVolts
                }
                else if (self.connection == Connections.star)
                {
                    return self.lineVolts / SQRT3
                }
                else // must be zigzag
                {
                    return self.lineVolts / 3.0
                }
            }
        }
    }
    
    /// Phase voltage (the routine actually just returns the "leg voltage"
    var phaseVolts:Double {
        
        get {
            
            return self.legVolts
        }
    }
    
    /// The amps entering the terminal (computed property)
    var lineAmps:(onan:Double, onaf:Double) {
        
        get {
            
            let phaseFactor = (self.connection == .delta || self.connection == .star ? SQRT3 : 1.0)
            
            return (self.terminalVA.onan / phaseFactor / self.lineVolts, self.terminalVA.onaf / phaseFactor / self.lineVolts)
        }
    }
    
    /// The amps going through the leg (ie: the same for all series-connected windings)
    var legAmps:(onan:Double, onaf:Double) {
        
        get {
            
            if (self.numPhases == 1)
            {
                if (self.connection == Connections.onePhaseOneLeg || self.connection == Connections.onePhaseTwoLegSeries)
                {
                    return self.lineAmps
                }
                else
                {
                    return (self.lineAmps.onan / 2.0, self.lineAmps.onaf / 2.0)
                }
            }
            else
            {
                return (self.terminalVA.onan / 3.0 / self.legVolts, self.terminalVA.onaf / 3.0 / self.legVolts)
            }
        }
    }
    
    /// The phase angle of the current entering line terminal T2 (for 3-phase connectiions) or T1 (for single-phase)
    var lineAmpsPhaseAngle:Double
    
    /// The BIL level of the line, dual-voltage point, and neutral end of the winding
    let bil:(line:BIL_Level, dv:BIL_Level, neutral:BIL_Level)
    
    /// Boolean for dual-voltage indication
    let hasDualVoltage:Bool
    
    /// The line voltage of the "dual voltage". This number can be used to calculate DV leg volts, amps, etc., if needed.
    let dvLineVolts:Double
    
    /// Optional array of offload tap percentages
    var offloadTaps:[Double]?
    
    /// Optional array of onload tap percentages
    var onloadTaps:[Double]?
    
    var preferredMainWindingLocation:Int
    var preferredTapWindingLocation:Int
    
    /// An array of PCH_Coils that belong to this terminal. This is made an optional so that we don't have to have the coils defined before we actually create the terminal.
    var coils:[PCH_Coil]?
    
    /// The preferred coil type, for use in the automatic design process
    var wdgType:PCH_Winding.WindingType
    
    /**
        Designated initializer, that allows the caller to enter **everything**.
    
        - parameter name: The required ID of the terminal
        - parameter terminalVA: The full (all phases) VA of the terminal
        - parameter lineVoltage: The line-to-line voltage of the terminal
        - parameter numPhases: Either 1 or 3 (anything else is an error)
        - parameter connection: The connection of the terminal
        - parameter phaseAngle: The phase angle of the T2 terminal (or T1 for single-phase), in radians
        - parameter lineBIL: The BIL level of the line end of the terminal
        - parameter neutralBIL: The BIL level of the neutral (non-line) end of the terminal
        - parameter offloadTaps: An array of percentages of the specified line voltage (can include 100%)
        - parameter onloadTaps: An array of percentages of the specified line voltage (cna include 100%)
        - parameter hasDualVoltages: Set if there is a second voltage possibility for the terminal
        - parameter dvLineVolts: The line voltage of the dual voltage, if any (ignored unless hasDualVoltages is true)
        - parameter dvBIL: The BIL level of the DV, if any (ignored inless hasDualVoltages is true)
    */
    init(name:String, terminalVA:(onan:Double, onaf:Double), lineVoltage:Double, preferredWindingLocation:Int = -1, preferredWindingType:PCH_Winding.WindingType = .programDecide, numPhases:UInt, connection:Connections, phaseAngle:Double, lineBIL:BIL_Level, neutralBIL:BIL_Level, offloadTaps:[Double]? = nil, onloadTaps:[Double]? = nil, preferredTapWindingLocation:Int = -1, hasDualVoltage:Bool = false, dvLineVolts:Double = 0.0, dvBIL:BIL_Level = BIL_Level.kv10)
    {
        self.name = name
        self.terminalVA = terminalVA
        self.lineVolts = lineVoltage
        if (numPhases == 1 || numPhases == 3)
        {
            self._numPhases = Int(numPhases)
        }
        else
        {
            ALog("Number of phases must be 1 or 3!")
            self._numPhases = 3
        }
        
        self.preferredMainWindingLocation = preferredWindingLocation
        self.preferredTapWindingLocation = preferredTapWindingLocation
        self.connection = connection
        self.lineAmpsPhaseAngle = phaseAngle
        self.bil.line = lineBIL
        self.bil.neutral = neutralBIL
        self.offloadTaps = offloadTaps
        self.onloadTaps = onloadTaps
        self.hasDualVoltage = hasDualVoltage
        self.dvLineVolts = dvLineVolts
        self.bil.dv = dvBIL
        self.wdgType = preferredWindingType
    }
}
