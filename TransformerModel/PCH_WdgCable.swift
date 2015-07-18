//
//  PCH_WdgCable.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-18.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// The basic cable that will make up a "turn" (note that a WdgCable may actually be a single strand). A cable is an entirely "packaged" subunit of a turn (ie: this is what is sepcified to and ordered from suppliers)

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
        Designated initializer
    
        :param: type The CableType
        :param: strand The strand that makes up the cable
        :param: numRadial The number of strands radially. Note that for CTC, this  includes the "odd" cable - that is, for a 23-strand CTC cable, this would be equal to 12.
        :param: numAxial The number of strands axially
    */
    init(type:CableType, strand:PCH_Strand, numRadial:Int, numAxial:Int)
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
    }
    
    /**
        Convenience initializer for single-strand cable
    */
    convenience init(strand:PCH_Strand)
    {
        self.init(type:.Single, strand:strand, numRadial:1, numAxial:1)
    }
    
    /**
        Convenience initializer for double-radial-strand cable
    */
    convenience init(doubledRadialStrand:PCH_Strand)
    {
        self.init(type:.MultipleRadial, strand:doubledRadialStrand, numRadial:2, numAxial:1)
    }
    
    /**
        Convenience initializer for double-axial-strand cable
    */
    convenience init(doubledAxialStrand:PCH_Strand)
    {
        self.init(type:.MultipleAxial, strand:doubledAxialStrand, numRadial:1, numAxial:2)
    }
    
    /**
        Convenience initializer for CTC cable
    */
    convenience init(strand:PCH_Strand, totalCTCStrands:Int)
    {
        if (totalCTCStrands % 2 == 0)
        {
            DLog("The number of strands in a CTC cable must be odd - rounding down!")
        }
        
        let numRadial = (totalCTCStrands + 1) / 2
        
        self.init(type:.CTC, strand:strand, numRadial:numRadial, numAxial:2)
    }
}
