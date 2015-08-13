//
//  PCH_Coil.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-27.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// The coil class. A coil is a collection (array) of PCH_CoilSections and occupying a fixed radial location and full electrical height of the transformer. There is always a PCH_Hilo on each side (radially) of the coil (but these are defined in the class PCH_Phase). There is insulation to the top and bottom yoke (edge packs or blocks, or a combination of both). There may be axial insulation and/or radial insulation between sections. The indices of the PCH_CoilSection array start at (axial=0, radial=0) being the section closest to the core and closest to the bottom yoke. Axial insulation indices match the lower section (ie: axial insulation between sections (0,0) and (1,0) would be at index 0. The same is true for radial insulations. Current is defined to enter at the start lead of the coil and exit at the finish lead.

class PCH_Coil
{
    /**
        The array of coil sections that make up the coil. This member is private to ensure that the caller uses instance methods to acces it.
    */
    private var coilSections:[[PCH_CoilSection?]]
    
    /**
        A struct that defines one "chunk" of intersection insulation
    */
    struct InterSectionInsulation
    {
        /**
            Bool to indicate whether the insulation is axial or radial
        */
        let isAxial:Bool
        
        /**
            The array of PCH_Insulation subclasses that make up the chunk of insulation
        */
        var insulation:[PCH_Insulation]
        
        /**
            Designated initializer
        
            - parameter isAxial: Bool to indicate whether the insulation is axial or radial
            - parameter insulation: The array of PCH_Insulation subclasses that make up the chunk of insulation
        */
        init(isAxial:Bool, insulation:[PCH_Insulation])
        {
            self.isAxial = isAxial
            self.insulation = insulation
        }
        
        /**
            Convenience initializer to create a chunk of axial insulation from a given number of a specified radial spacer
        */
        init(axialGapWithRadialSpacer:PCH_RadialSpacer, numSpacers:Int)
        {
            let insArray = [PCH_RadialSpacer](count: numSpacers, repeatedValue: axialGapWithRadialSpacer)
            
            self.init(isAxial:true, insulation:insArray)
        }
        
        /**
            Function that returns the axial dimension of an axial insulation or the radial dimension of radial insulation
        */
        func Dimension() -> Double
        {
            var result:Double = 0.0
            
            if (self.isAxial)
            {
                for nextInsulation in insulation
                {
                    if (nextInsulation is PCH_RadialSpacer)
                    {
                        result += (nextInsulation as! PCH_RadialSpacer).T * nextInsulation.shrinkageFactor
                    }
                    else if (nextInsulation is PCH_Board)
                    {
                        result += (nextInsulation as! PCH_Board).width * nextInsulation.shrinkageFactor
                    }
                    else
                    {
                        ALog("Axial intersection insulation must eb made up of either radial spacers (for disk & helical coils) or board (for layer coils)")
                    }
                }
            }
            else
            {
                for nextInsulation in insulation
                {
                    if (nextInsulation is PCH_Board)
                    {
                        result += (nextInsulation as! PCH_Board).thickness
                    }
                    else if (nextInsulation is PCH_DuctStrip)
                    {
                        result += (nextInsulation as! PCH_DuctStrip).radialDimension
                    }
                    else
                    {
                        ALog("Radial intersection insulation must be made up of either duct strips or board")
                    }
                }

            }
            
            return result
        }
    }
    
    /**
        A private array to hold the axial intersecion insulation chunks. The index (i,j) points at the insulation chunk between axial sections i and i+1 in radial section j
    */
    private var axialInterSectionInsulation:[[InterSectionInsulation?]]?
    
    /**
        A private array to hold the radial intersecion insulation chunks. The index (i,j) points at the insulation chunk between radial sections j and j+1 in axial section i
    */
    private var radialInterSectionInsulation:[[InterSectionInsulation?]]?
    
    /**
        The number of axial and radial coil sections
    */
    private var  numAxialSections:Int
    private var numRadialSections:Int
    
    /**
        The edge insulation for a coil is always comprised of a common block, followed by either radial spacers (disk & helical coils) or a board (layer).
    */
    struct EdgeInsulation
    {
        /**
            The common block used between the core yoke and the coil edgepack
        */
        let commonBlock:PCH_CommonBlock
        
        /**
            The edgepack of the coil (either a board or a collection of radial spacers
        */
        let edgePack:[PCH_Insulation]
        
        func AxialDimension() -> Double
        {
            var result:Double = 0.0
            
            if (edgePack[0] is PCH_RadialSpacer)
            {
                for nextSpacer in edgePack
                {
                    result += (nextSpacer as! PCH_RadialSpacer).T * nextSpacer.shrinkageFactor
                }
            }
            else // must be PCH_Board
            {
                result += (edgePack[0] as! PCH_Board).width
            }
            
            result += commonBlock.plate.thickness + commonBlock.strip.thickness
            
            return result
        }
    }
    
    
    /**
        The top and bottom edge insulation. Note that these are currently created as vars to allow for tweaking of the edgpacks if necessary.
    */
    var topEdgeInsulation:EdgeInsulation?
    var bottomEdgeInsulation:EdgeInsulation?
    
    /**
        The start and finish nodes of the coil. These correspond to already-existing PCH_ConnectionNodes of one or two of the coil sections.
    */
    var startNode:PCH_ConnectionNode?
    var finishNode:PCH_ConnectionNode?
    
    /// The optional parent terminal of the coil. 
    weak var parentTerminal:PCH_TxfoTerminal?
    
    /**
        Designated initializer, which sets the number of axial and radial coil sections in the coil. It also "primes" the coilSections private member so that it already holds the right number of coil sctions elements (they all hold 'nil' after initialization). The caller may also set the top and bottom edge insulation if desired
    */
    init(numAxialSections:Int, numRadialSections:Int, parentTerminal:PCH_TxfoTerminal? = nil, topEdgeInsulation:EdgeInsulation? = nil, bottomEdgeInsulation:EdgeInsulation? = nil)
    {
        self.numAxialSections = numAxialSections
        self.numRadialSections = numRadialSections
        self.parentTerminal = parentTerminal
        
        let nilRadialArray = [PCH_CoilSection?](count: numRadialSections, repeatedValue: nil)
        
        self.coilSections = [[PCH_CoilSection?]](count: numAxialSections, repeatedValue: nilRadialArray)
        
        self.topEdgeInsulation = topEdgeInsulation
        self.bottomEdgeInsulation = bottomEdgeInsulation
    }
    
    
    /**
        Function to set a given axial and radial position of the array. This will grow the array (with nil values) as necessary.
    
        - parameter axialPos: The axial position of the element we want to set
        - parameter radialPos: The radial position of the element we want to set
        - parameter coilSection: The coil section to set (cannot be nil)
    */
    func SetCoilSectionAtAxialPos(axialPos:Int, radialPos:Int, coilSection:PCH_CoilSection)
    {
        ZAssert(axialPos >= 0 && radialPos >= 0, message: "Indices must be greater or equal to zero!")
        
        // First we'll grow the array axially, if necessary, adding nil-value radial arrays
        if (axialPos >= self.numAxialSections)
        {
            DLog("The axial position specified is greater than what is currently in the array - adding elements as necessary")
            
            let newRadialArray = [PCH_CoilSection?](count: self.numRadialSections, repeatedValue: nil)
            
            for _ in self.numAxialSections...axialPos
            {
                self.coilSections.append(newRadialArray)
            }
            
            self.numAxialSections = axialPos + 1
        }
        
        // Now we check if the number of radial positions increased, and if so, we add nil values to each existing radial array.
        if (radialPos >= self.numRadialSections)
        {
            DLog("The radial position specified is greater than what is currently in the array - adding elements as necessary")
            
            for i in 0..<self.numAxialSections
            {
                var replacementRadialArray = self.coilSections[i]
                
                for _ in self.numRadialSections...radialPos
                {
                    replacementRadialArray.append(nil)
                }
                
                self.coilSections[i] = replacementRadialArray
            }
            
            self.numRadialSections = radialPos + 1
        }
        
        // finally, we set the element
        self.coilSections[axialPos][radialPos] = coilSection
        
    }
    
    
    /**
        Function to get the coil section at a given axial and radial position
        
        - parameter axialPos: The axial position of the element we want to set
        - parameter radialPos: The radial position of the element we want to set
    
        - returns: The PCH_CoilSection at the given axial and radial positions (may be nil)
    */
    func CoilSectionAtAxialPos(axialPos:Int, radialPos:Int) -> PCH_CoilSection?
    {
        ZAssert(axialPos >= 0 && radialPos >= 0, message: "Indices must be greater or equal to zero!")
        
        if (axialPos >= numAxialSections) || (radialPos >= numRadialSections)
        {
            return nil
        }
        
        return self.coilSections[axialPos][radialPos]
    }
    
    
    /**
        Function to check whether all the coil sections in the coil are non-nil
    
        - returns: true if all coil sections have been defined (ie: they are non-nil), otherwise false
    */
    func CoilIsValid() -> Bool
    {
        for i in 0...self.numAxialSections
        {
            for j in 0...self.numRadialSections
            {
                if self.coilSections[i][j] == nil
                {
                    return false
                }
            }
        }
        
        return true
    }
    
    
    /**
        Function to set the interaxial insulation after a given axial coil section and on a given radial coil section index
    
        (Note: This function does index checking but only asserts in Debug mode)
    
        - parameter afterAxialPos: The axial coil section position index AFTER which the insulation should be placed
        - parameter onRadialPos: The radial coil section position index where the insulation should be placed
        - paramater axialIns: The InterSectionInsulation (must have the isAxial property set!)
    */
    func SetAxialInsulationAfterAxialPos(afterAxialPos:Int, onRadialPos:Int, axialIns:PCH_Coil.InterSectionInsulation)
    {
        ZAssert(axialIns.isAxial, message: "Illegal inter-section insulation type - must be axial")
        ZAssert(afterAxialPos >= 0 && onRadialPos >= 0, message: "Indices must be greater or equal to zero!")
        ZAssert(afterAxialPos < (self.numAxialSections - 1), message: "After axial position index too great!")
        ZAssert(onRadialPos < self.numRadialSections, message: "Radial position index too great!")
        
        // first check if the axial interinsulation array has been initialized, and if not, do it
        if self.axialInterSectionInsulation == nil
        {
            let radialArray = [InterSectionInsulation?](count: numRadialSections, repeatedValue: nil)
            
            self.axialInterSectionInsulation = [[InterSectionInsulation?]](count: numAxialSections - 1, repeatedValue: radialArray)
        }
        
        self.axialInterSectionInsulation![afterAxialPos][onRadialPos] = axialIns
        
    }
    
    
    /**
        Function to set the interradial insulation after a given radial coil section and on a given axial coil section index
        
        (Note: This function does index checking but only asserts in Debug mode)
        
        - parameter afterRadialPos: The radial coil section position index AFTER which the insulation should be placed
        - parameter onAxialPos: The axial coil section position index where the insulation should be placed
        - paramater axialIns: The InterSectionInsulation (must have the isRadial property set!)
    */

    func SetRadialInsulationAfterRadialPos(afterRadialPos:Int, onAxialPos:Int, radialIns:PCH_Coil.InterSectionInsulation)
    {
        ZAssert(!radialIns.isAxial, message: "Illegal inter-section insulation type - must be radial")
        ZAssert(afterRadialPos >= 0 && onAxialPos >= 0, message: "Indices must be greater or equal to zero!")
        ZAssert(afterRadialPos < (self.numRadialSections - 1), message: "After radial position index too great!")
        ZAssert(onAxialPos < self.numAxialSections, message: "Axial position index too great!")
        
        // first check if the radial interinsulation array has been initialized, and if not, do it
        if self.radialInterSectionInsulation == nil
        {
            let radialArray = [InterSectionInsulation?](count: numRadialSections - 1, repeatedValue: nil)
            
            self.radialInterSectionInsulation = [[InterSectionInsulation?]](count: numAxialSections, repeatedValue: radialArray)
        }
        
        self.axialInterSectionInsulation![onAxialPos][afterRadialPos] = radialIns
        
    }
}
