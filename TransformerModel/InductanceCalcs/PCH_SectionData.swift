//
//  PCH_SectionData.swift
//  InductanceCalculator
//
//  Created by PeterCoolAssHuber on 2015-12-28.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

class PCH_SectionData:NSObject, NSCoding {

    /// The ID of the section
    let sectionID:String
    
    /// The unique serial number associated with the section. This is used in the construction of the inductance and capacitance matrices
    let serialNumber:Int
    
    let nodes:(inNode:Int, outNode:Int)
    
    /// The series capacitance of the section, in F
    var seriesCapacitance:Double = 0.0
    
    /// The shunt capacitances to other sections, in F. The keys are the sectionID's of the other sections.
    var shuntCapacitances = [String:Double]()
    
    /// The shunt capacitances to other sections, in F. The keys are the PCH_Section's of the other sections.
    // var shuntCaps = [PCH_DiskSection:Double]()
    
    /// The resistance of the section, in Ω
    var resistance:Double = 0.0
    
    /// The self-inductance of the section, in H
    var selfInductance:Double = 0.0
    
    /// The mutual inductances to all other sections, in H. The keys are the sectionID's of the other sections.
    var mutualInductances = [String:Double]()
    
    /// The mutual inductances to all other sections, in H. The keys are the PCH_Section's of the other sections
    // var mutInd = [PCH_DiskSection:Double]()
    
    /// The mutual inductances as coefficients k = M12 / sqrt(L1 * L2). The keys are the sectionID's of the other sections.
    var mutIndCoeff = [String:Double]()
    
    init(sectionID:String, serNum:Int, inNode:Int, outNode:Int, seriesCapacitance:Double = 0.0, shuntCapacitances:[String:Double] = [String:Double](), resistance:Double = 0.0, selfInductance:Double = 0.0, mutualInductances:[String:Double] = [String:Double](), mutIndCoeff:[String:Double] = [String:Double]())
    {
        self.sectionID = sectionID
        self.serialNumber = serNum
        self.nodes = (inNode, outNode)
        self.seriesCapacitance = seriesCapacitance
        self.shuntCapacitances = shuntCapacitances
        // self.shuntCaps = shuntCaps
        self.resistance = resistance
        self.selfInductance = selfInductance
        self.mutualInductances = mutualInductances
        // self.mutInd = mutInd
        self.mutIndCoeff = mutIndCoeff
    }
    
    /*
    init(sectionID:String, serNum:Int, inNode:Int, outNode:Int)
    {
        self.sectionID = sectionID
        self.serialNumber = serNum
        self.nodes = (inNode, outNode)
    }
     */
    
    // Required initializer for archiving
    convenience required init?(coder aDecoder: NSCoder)
    {
        let sectionID = aDecoder.decodeObject(forKey: "SectionID") as! String
        let serialNumber = aDecoder.decodeInteger(forKey: "SerialNumber")
        let inNode = aDecoder.decodeInteger(forKey: "InNode")
        let outNode = aDecoder.decodeInteger(forKey: "OutNode")
        let seriesCapacitance = aDecoder.decodeDouble(forKey: "SeriesCapacitance")
        let shuntCapacitances = aDecoder.decodeObject(forKey: "ShuntCapacitances") as! [String:Double]
        // let shuntCaps = aDecoder.decodeObject(forKey: "ShuntCaps") as! [PCH_DiskSection:Double]
        let resistance = aDecoder.decodeDouble(forKey: "Resistance")
        let selfInductance = aDecoder.decodeDouble(forKey: "SelfInductance")
        let mutualInductances = aDecoder.decodeObject(forKey: "MutualInductances") as! [String:Double]
        // let mutInd = aDecoder.decodeObject(forKey: "MutInd") as! [PCH_DiskSection:Double]
        let mutIndCoeff = aDecoder.decodeObject(forKey: "MutIndCoeffs") as! [String:Double]
        
        self.init(sectionID:sectionID, serNum:serialNumber, inNode:inNode, outNode:outNode, seriesCapacitance:seriesCapacitance, shuntCapacitances:shuntCapacitances, resistance:resistance, selfInductance:selfInductance, mutualInductances:mutualInductances, mutIndCoeff:mutIndCoeff)
        
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.sectionID, forKey: "SectionID")
        aCoder.encode(self.serialNumber, forKey: "SerialNumber")
        aCoder.encode(self.nodes.inNode, forKey: "InNode")
        aCoder.encode(self.nodes.outNode, forKey: "OutNode")
        aCoder.encode(self.seriesCapacitance, forKey: "SeriesCapacitance")
        aCoder.encode(self.shuntCapacitances, forKey: "ShuntCapacitances")
        // aCoder.encode(self.shuntCaps, forKey: "ShuntCaps")
        aCoder.encode(self.resistance, forKey: "Resistance")
        aCoder.encode(self.selfInductance, forKey: "SelfInductance")
        aCoder.encode(self.mutualInductances, forKey: "MutualInductances")
        // aCoder.encode(self.mutInd, forKey: "MutInd")
        aCoder.encode(self.mutIndCoeff, forKey: "MutIndCoeffs")
    }
    
}
