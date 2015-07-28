//
//  PCH_Coil.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-27.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// The coil class. A coil is a collection (array) of PCH_CoilSections and occupying a fixed radial location and full electrical height of the transformer. There is always a PCH_Hilo on each side (radially) of the coil. There is one current input and one current output on a coil. There is insulation to the top and bottom yoke (edge packs or blocks, or a combination of both). There may be axial insulation and/or radial insulation between sections. The indices of the PCH_CoilSection array start at (axial=0, radial=0) being the section closest to the core and closest to the bottom yoke. Axial insulation indices match the lower section (ie: axial insulation between sections (0,0) and (1,0) would be at index 0. The same is true for radial insulations.

class PCH_Coil
{

}
