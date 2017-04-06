//
//  PCH_CoilSectionLayer.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-27.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// A concrete subclass of PCH_CoilSection with PCH_WdgLayer as the basic building block. Note that within a section, layers and interlayer insulation are identical. However, also note that while the layers are physically identical, they may contain taps (ie: some may be PCH_WdgTappedLayers). The correct way to use this class is to initialize it with the starting (innermost) layer, the number of layers, and whether the layer starts should alternate (defaults to true). Afterwards, set any tapping layers.

class PCH_CoilSectionLayer: PCH_CoilSection {

    /**
        The radial insulation between each layer in this coil section. This is actually made up of at least one of PCH_Paper, PCH_Board, or PCH_DuctStrip. Note that to keep things simple, if there are only vertical strips in the insulation, define a PCH_DuctSttrip without paper and use that.
    */
    let radialInsulation:[PCH_Insulation]
    
    /**
        The number of layers
    */
    let numLayers:Int
    
    /**
        Array of PCH_WdgLayer (and subclasses), starting with the item at index 0 nearest to the core
    */
    var layers = [PCH_WdgLayer]()
    
    /**
        Designated initializer
    
        - parameter firstLayer: A PCH_WdgLayer that describes the first layer in the section
        - parameter flipStart: Bool to tell whether alternating layers should have the start flipped
        - parameter sameInterleave: Bool to tell whether to copy the interleave or not
        - parameter numLayers: The number of layers in the section
        - parameter radialInsulation: An array of PCH_Insulation that make up the insulation between layers (each element of the array MUST be one of PCH_Paper, PCH_Board, or PCH_DuctStrip)
        - parameter innerRadius: The inner radius of the coil section
        - parameter zMinPhysical: The bottommost (physical copper) dimension
        - parameter wdgDirection: The winding direction of the section
    
    */
    init(firstLayer:PCH_WdgLayer, flipStart:Bool, sameInterleave:Bool, numLayers:Int, radialInsulation:[PCH_Insulation], innerRadius:Double, zMinPhysical:Double, wdgDirection:WindingDirection = .clockwise)
    {
        let secondLayer:PCH_WdgLayer = PCH_WdgLayer(srcLayer: firstLayer, sameInterleave: sameInterleave, flipStart: flipStart)
        
        for i in 0..<numLayers
        {
            if (i % 2 == 1)
            {
                layers.append(firstLayer)
            }
            else
            {
                layers.append(secondLayer)
            }
        }
        
        self.numLayers = numLayers
        self.radialInsulation = radialInsulation
        
        var radialInsulationThickness = 0.0
        for nextInsulation in radialInsulation
        {
            if nextInsulation is PCH_Paper
            {
                let paper = nextInsulation as! PCH_Paper
                radialInsulationThickness += paper.dimensions.thickness
            }
            else if nextInsulation is PCH_Board
            {
                let board = nextInsulation as! PCH_Board
                radialInsulationThickness += board.thickness
            }
            else if nextInsulation is PCH_DuctStrip
            {
                let ductstrip = nextInsulation as! PCH_DuctStrip
                radialInsulationThickness += ductstrip.radialDimension
            }
            else
            {
                ZAssert(false, message: "Interlayer insulation must be made of paper, board, or duct strip! Aborting!")
            }
        }
        
        let radBuild = Double(numLayers) * firstLayer.turnDef.unshrunkDimensionOverCover.radial + Double(numLayers - 1) * radialInsulationThickness
        
        super.init(innerRadius: innerRadius, radBuildPhysical: radBuild, radBuildElectrical: radBuild, zMinPhysical: zMinPhysical, zMinElectrical: zMinPhysical + firstLayer.turnDef.shrunkDimensionOverCover.axial / 2.0, electricalHt: firstLayer.axialBuild.exact, physicalHt: firstLayer.axialBuild.withHelix, wdgDirection:wdgDirection)
    }
    
    /**
        Function to add taps at given turn numbers (in terms of this coil section)
    
        - parameter turns: A list of turn numbers
    */
    override func AddTapsAtTurns(_ turns: Double...)
    {
        // Store the number of turns per disk for convenience
        let turnsPerLayer = layers[0].effectiveTurns
        
        // A dictionary of DiskNumber:TurnsArray
        var layersToTurns = [Int : [Double]]()
        
        for nextTurn in turns
        {
            let theLayer = Int(nextTurn / turnsPerLayer)
            
            if (layersToTurns[theLayer] == nil)
            {
                layersToTurns[theLayer] = [nextTurn - Double(theLayer) * turnsPerLayer]
            }
            else
            {
                layersToTurns[theLayer]!.append(nextTurn - Double(theLayer) * turnsPerLayer)
            }
        }
        
        for (layer, turnArray) in layersToTurns
        {
            let newLayer = PCH_WdgTappedLayer(srcLayer: layers[layer], tapLocs: turnArray)
            
            layers[layer] = newLayer
        }

    }
    
}
