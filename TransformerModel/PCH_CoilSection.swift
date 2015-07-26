//
//  PCH_CoilSection.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-24.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Foundation

/// Base class for the concrete coil section classes PCH_CoilSectionDisk, PCH_CoilSectionLayer, PCH_CoilSectionHelix. This could have been designed as a protocol but I thought it would have been more work than just creating a base class that is designed to be subclassed.

class PCH_CoilSection
{
    /**
        Enum to describe the winding direction of the section (used for voltage, impedance, etc. calculations).
    
        - clockwise
        - counterclockwise
    */
    enum WindingDirection:Int {
        
        case clockwise = 1
        case counterclockwise = -1
    }
    
    var direction:WindingDirection
    
    /**
        The physical inner radius of the coil.
    */
    var innerRadius:Double
    
    /**
        The physical inner diameter of the coil
    */
    var innerDiameter:Double
    {
        get
        {
            return self.innerDiameter * 2.0
        }
        
        set(newDiameter)
        {
            innerRadius = newDiameter / 2.0
        }
    }
    
    /**
        The radial build of the coil. physical = overall including the helix; electrical = not including the helix
    */
    let radialBuild:(physical:Double, electrical:Double)
    
    /**
        The physical outer radius of the coil
    */
    var outerRadius:Double
    {
        get
        {
            return innerRadius + radialBuild.physical
        }
    }
    
    /**
        The physical outer diameter of the coil
    */
    var outerDiameter:Double
    {
        get
        {
            return outerRadius * 2.0
        }
    }
    
    /**
        The lower dimension of the winding section. Usually, this is the dimension from the top of the lower yoke. Note that all axial dimensions are SHRUNK.
    */
    let zMin:(physical:Double, electrical:Double)
    
    /**
        The upper dimension of the winding section (a computed property). Usually, this is the dimension from the top of the lower yoke. Note that all axial dimensions are SHRUNK.
    */
    var zMax:(physical:Double, electrical:Double)
    {
        get
        {
            return (zMin.physical + physicalHt, zMin.electrical + electricalHt)
        }
    }
    
    /**
        The electrical height of the coil section (shrunk)
    */
    let electricalHt:Double
    
    /**
        The physical height of the coil section (shrunk)
    */
    let physicalHt:Double
    
    /**
        The length of mean turn of the coil section
    */
    var lmt:Double
    {
        get
        {
            return 2.0 * π * (innerRadius + radialBuild.physical)
        }
    }
    
    /**
        The vector of the current in the coil section. This property may not be retained for future versions.
    */
    var currentVector:(i:Double, θ:Double) = (0.0, 0.0)
    
    /**
        The vector of the voltage in the coil section. This property may not be retained for future versions.
    */
    var voltageVector:(v:Double, θ:Double) = (0.0, 0.0)
    
    /**
        Designated initializer
    
        - parameter innerRadius: Duh, the inner radius
        - parameter radBuildPhysical: The copper-to-copper radial build
        - parameter radBuildElectrical: The radial build without the helix
        - parameter zMinPhysical: The lowest copper point of the coil section
        - parameter zMinElectrical: The lowest electrical point of the coil section (ie: without the helix)
        - parameter electricalHt: The electrical height of the coil section
        - parameter physicalHt: The physical height of the coil section
        - parameter wdgDirection: The direction of the winding (default is clockwise, this value can be changed)
    */
    init(innerRadius:Double, radBuildPhysical:Double, radBuildElectrical:Double, zMinPhysical:Double, zMinElectrical:Double, electricalHt:Double, physicalHt:Double, wdgDirection:WindingDirection = .clockwise)
    {
        self.innerRadius = innerRadius
        self.radialBuild = (radBuildPhysical, radBuildElectrical)
        self.zMin = (zMinPhysical, zMinElectrical)
        self.electricalHt = electricalHt
        self.physicalHt = physicalHt
        self.direction = wdgDirection
    }
    
    /**
        Convenience initializer that accepts an inner diameter as the first argument
    
        - parameter innerDiameter: The inner diameter
        - parameter radBuildPhysical: The copper-to-copper radial build
        - parameter radBuildElectrical: The radial build without the helix
        - parameter zMinPhysical: The lowest copper point of the coil section
        - parameter zMinElectrical: The lowest electrical point of the coil section (ie: without the helix)
        - parameter electricalHt: The electrical height of the coil section
        - parameter physicalHt: The physical height of the coil section
        - parameter wdgDirection: The direction of the winding (default is clockwise, this value can be changed)
    */
    convenience init(innerDiameter:Double, radBuildPhysical:Double, radBuildElectrical:Double, zMinPhysical:Double, zMinElectrical:Double, electricalHt:Double, physicalHt:Double, wdgDirection:WindingDirection = .clockwise)
    {
        self.init(innerRadius: innerDiameter / 2.0, radBuildPhysical: radBuildPhysical, radBuildElectrical: radBuildElectrical, zMinPhysical: zMinPhysical, zMinElectrical: zMinElectrical, electricalHt: electricalHt, physicalHt: physicalHt, wdgDirection:wdgDirection)
    }
    
}