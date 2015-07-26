//
//  PCH_CoilSectionDisk.swift
//  TransformerModel
//
//  Created by PeterCoolAssHuber on 2015-07-26.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// A concrete subclass of PCH_CoilSection with PCH_WdgDisk as the basic building block. Note that within a section, all disks and interdisk insulation are identical. However, also note that while disks are physically identical, they may contain taps (ie: some may be PCH_WdgTappedDisks). The correct way to use this class is to initialize it with the starting (lowest Z) disk, the number of disks, and whether the disk starts should alternate (defaults to true). Afterwards, set any tapping disks.

class PCH_CoilSectionDisk: PCH_CoilSection {
    
    /**
        The radial spacer definition used in the coil section. This is defined as an array to allow multiple radial spacers to be used to yield a given thickness.
    */
    let radialSpacer:[PCH_RadialSpacer]
    
    /**
        The number of radial spacer columns per circle
    */
    let numColumns:UInt
    
    /**
        The total number of disks in the section
    */
    let numDisks:UInt
    
    /**
        The array of disks in the section
    */
    var disks = [PCH_WdgDisk]()
    
    /**
        Designated initializer
    
        - parameter firstDisk: A PCH_WdgDisk that describes the first disk in the section
        - parameter flipStart: Bool to tell whether alternating disks should have the start flipped
        - parameter sameInterleave: Bool to tell whether to copy the interleave or not
        - parameter numDisks: The number of disks in the section
        - parameter numColumns: The number of radial spacer columns in the section
        - parameter radialSpacer: An array of PCH_RadialSpacers that make up the space between disks
        - parameter innerRadius: The inner radius of the coil section
        - parameter zMinPhysical: The bottommost (physical copper) dimension
        - parameter wdgDirection: The winding direction of the section
        
    */
    init(firstDisk:PCH_WdgDisk, flipStart:Bool, sameInterleave:Bool, numDisks:UInt, numColumns:UInt, radialSpacer:[PCH_RadialSpacer], innerRadius:Double, zMinPhysical:Double, wdgDirection:WindingDirection = .clockwise)
    {
        let secondDisk:PCH_WdgDisk = PCH_WdgDisk(srcDisk: firstDisk, sameInterleave: sameInterleave, flipStart: flipStart)
        
        for i in 0..<numDisks
        {
            if (i % 2 == 1)
            {
                disks.append(firstDisk)
            }
            else
            {
                disks.append(secondDisk)
            }
        }
        
        self.numDisks = numDisks
        self.numColumns = numColumns
        self.radialSpacer = radialSpacer
        
        var radialSpacerThickness = 0.0
        for nextRadialSpacer in radialSpacer
        {
            radialSpacerThickness += nextRadialSpacer.T * nextRadialSpacer.shrinkageFactor
        }
        
        let height = Double(numDisks) * firstDisk.turnDef.shrunkDimensionOverCover.axial + Double(numDisks - 1) * radialSpacerThickness
        
        super.init(innerRadius: innerRadius, radBuildPhysical: firstDisk.radialBuild.roundup, radBuildElectrical: firstDisk.radialBuild.exact, zMinPhysical: zMinPhysical, zMinElectrical: zMinPhysical, electricalHt: height, physicalHt: height)
    }
    
    /**
        Function to add taps at given turn numbers (in terms of this coil section)
    
        - parameter turns: A list of turn numbers
    */
    func AddTapsAtTurns(turns:Double...)
    {
        
    }

}
