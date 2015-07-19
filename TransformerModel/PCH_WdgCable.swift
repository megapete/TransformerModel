//
//  PCH_WdgCable.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-18.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// The basic cable, one or more of which will make up a "turn" (note that a WdgCable may actually be a single strand). A cable is an entirely "packaged" subunit of a turn (ie: this is what is sepcified to and ordered from suppliers)

class PCH_WdgCable {
    
    /**
        Possible cable types
    
        - Single
        - MultipleRadial
        - MultipleAxial
        - CTC
    */
    enum CableType {
        
        case Single
        case MultipleRadial
        case MultipleAxial
        case CTC
    }
    
    /**
        The cable type
    */
    let type:CableType
    
    /**
        The number of strands radially (note: for CTC, this  includes the "odd" cable - that is, for a 23-strand CTC cable, this would be equal to 12)
    */
    let numRadial:Int
    
    /**
        The number of strands axially
    */
    let numAxial:Int
    
    /**
        The total number of strands (computed read-only property)
    */
    var totalStrands:Int
    {
        get
        {
            if (self.type == .CTC)
            {
                return numAxial * (numRadial - 1) + 1
            }
            else
            {
                return numAxial * numRadial
            }
        }
    }

    /**
        The basic strand that makes up the cable
    */
    let strand:PCH_Strand
    
    /**
        The insulating cover of the cable
    */
    let coverInsulation:PCH_Insulation?
    
    /**
        The unshrunken radial thickness of the cover insulation
    */
    let coverThickness:Double
    
    /**
        The  dimensions of the strand over the insulation with the x dimension shrunk (x [axial], y [radial])
    */
    var shrunkDimensionOverCover:(axial:Double, radial:Double)
    {
        get
        {
            let shrunkcover = (self.coverInsulation == nil ? 0.0 : self.coverInsulation!.shrinkageFactor * self.coverThickness)
            
            let unshrunkcover = (self.coverInsulation == nil ? 0.0 : self.coverThickness)
            
            return (Double(self.numAxial) * self.strand.shrunkDimensionOverCover.axial + shrunkcover, Double(self.numRadial) * self.strand.shrunkDimensionOverCover.radial + unshrunkcover)
        }
    }
    
    /**
        The  dimensions of the strand over the insulation with the x dimension unshrunk (x [axial], y [radial])
    */
    var unshrunkDimensionOverCover:(axial:Double, radial:Double)
    {
        get
        {
            let unshrunkcover = (self.coverInsulation == nil ? 0.0 : self.coverThickness)
            
            return (Double(self.numAxial) * self.strand.shrunkDimensionOverCover.axial + unshrunkcover, Double(self.numRadial) * self.strand.shrunkDimensionOverCover.radial + unshrunkcover)
        }
    }
    
    /**
        Designated initializer
    
        :param: type The CableType
        :param: strand The strand that makes up the cable
        :param: numRadial The number of strands radially. Note that for CTC, this  includes the "odd" cable - that is, for a 23-strand CTC cable, this would be equal to 12.
        :param: numAxial The number of strands axially
    */
    init(type:CableType, strand:PCH_Strand, numRadial:Int = 1, numAxial:Int = 1, coverInsulation:PCH_Insulation? = nil, coverThickness:Double = 0.0)
    {
        self.type = type
        self.strand = strand
        
        if (type == .CTC) && (numRadial % 2 != 0)
        {
            DLog("NOTE: For CTC cables, the numRadial parameter must be even! Adding '1' to passed value.")
            self.numRadial = numRadial + 1
        }
        else
        {
            self.numRadial = numRadial
        }
        
        self.numAxial = numAxial
        self.coverInsulation = coverInsulation
        self.coverThickness = coverThickness
    }
    
    /**
        Convenience initializer for single-strand cable
        
        :param: strand The strand that makes up the cable
    */
    convenience init(strand:PCH_Strand)
    {
        self.init(type:.Single, strand:strand)
    }
    
    /**
        Convenience initializer for double-radial-strand cable
    
        :param: doubledRadialStrand The strand that makes up the cable
    */
    convenience init(doubledRadialStrand:PCH_Strand, coverInsulation:PCH_Insulation, coverThickness:Double)
    {
        self.init(type:.MultipleRadial, strand:doubledRadialStrand, numRadial:2, numAxial:1, coverInsulation:coverInsulation, coverThickness:coverThickness)
    }
    
    /**
        Convenience initializer for double-axial-strand cable
    
        :param: doubledAxialStrand The strand that makes up the cable
    */
    convenience init(doubledAxialStrand:PCH_Strand, coverInsulation:PCH_Insulation, coverThickness:Double)
    {
        self.init(type:.MultipleAxial, strand:doubledAxialStrand, numRadial:1, numAxial:2, coverInsulation:coverInsulation, coverThickness:coverThickness)
    }
    
    /**
        Convenience initializer for CTC cable
    
        :param: strand The strand that makes up the cable
        :param: totalCTCStrands The total number of strands in the cable (must be odd)
    */
    convenience init(strand:PCH_Strand, totalCTCStrands:Int, coverInsulation:PCH_Insulation, coverThickness:Double)
    {
        if (totalCTCStrands % 2 == 0)
        {
            DLog("The number of strands in a CTC cable must be odd - rounding down!")
        }
        
        let numRadial = (totalCTCStrands + 1) / 2
        
        self.init(type:.CTC, strand:strand, numRadial:numRadial, numAxial:2, coverInsulation:coverInsulation, coverThickness:coverThickness)
    }
    
    /**
        Function to calculate the average perimeter of the covered cable (for insulation weight calculations)
        
        :returns: The average perimeter (ie: following a line through the center of the insulating cover)
    */
    func AveragePerimeter() -> Double
    {
        let cover = coverInsulation == nil ? 0.0 : self.coverThickness
        
        let width = self.unshrunkDimensionOverCover.axial - cover
        let thickness = self.unshrunkDimensionOverCover.radial - cover
        
        return 2.0 * (width + thickness)
    }
    
    /**
        Calculate the conducting cross-sectional area of the strand
    
        :returns: The x-section in meters-squared
    */
    func Area() -> Double
    {
        return self.strand.Area() * Double(self.totalStrands)
    }
    
    /**
        Find the resistance of the given length of cable at the given temperature
    
        :param: length The length of the cable
        :param: temperature The temperature at which we want to know the resistance
    
        ;returns: The resistance (in ohms) of the cable
    */
    func Resistance(length:Double, temperature:Double) -> Double
    {
        return self.strand.Resistance(length, temperature: temperature) / Double(self.totalStrands)
    }
    
    /**
        Calculate the weight of a given length of cable. Note that this weight includes the metal and insulation cover (if any)
        
        :param: length The length of the strand
        
        :returns: The total weight of the cable, including its insulating cover
    */
    func Weight(length:Double) -> Double
    {
        var cableWeight:Double = Double(self.totalStrands) * self.strand.Weight(length)
        
        if (self.coverInsulation != nil)
        {
            let coverWeight = self.coverInsulation!.Weight(area: self.coverThickness * self.AveragePerimeter(), length: length)
            
            cableWeight += coverWeight
            
        }
        
        return cableWeight
    }
    
    
}
