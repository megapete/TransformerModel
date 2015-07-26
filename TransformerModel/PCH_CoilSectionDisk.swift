//
//  PCH_CoilSectionDisk.swift
//  TransformerModel
//
//  Created by PeterCoolAssHuber on 2015-07-26.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// A concrete class of PCH_CoilSection with PCH_WdgDisk as the basic building block. Note that within a section, all disks and interdisk insulation are identical. However, also note that while disks are physically identical, they may contain taps (ie: some may be PCH_WdgTappedDisks). The correct way to use this class is to initialize it with all regular disks, then set certain disks to have taps.

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
    
    

}
