//
//  PCH_Strip.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-21.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

import Cocoa

class PCH_Strip: PCH_Insulation {

    /**
        The different types of strips that are available
    */
    enum StripShape {
        
        case rectangular, dovetail, tstrip
    }
    
    /**
        The strip type
    */
    let type:StripShape
    
    /// static dictionary for use with the description property
    static let typeName = [PCH_Strip.StripShape.rectangular:"RECT", PCH_Strip.StripShape.dovetail:"DOVETAIL", PCH_Strip.StripShape.tstrip:"T-STRIP"]
    
    /**
        Dimensions of the strip
    */
    var width:Double
    var thickness:Double
    var length:Double
    
    /// The description override
    override var description:String
    {
        get
        {
            var result = "Strip: \(self.material), "
            
            if let tString = PCH_Strip.typeName[self.type]
            {
                result += tString + ": "
            }
            
            return result + "\(self.thickness) x \(self.width) x \(self.length) (TxWxL)"
        }
    }
    
    init(materialType:PCH_Insulation.Insulation, stripType:StripShape, width:Double, thickness:Double, length:Double)
    {
        self.type = stripType
        self.width = width
        self.thickness = thickness
        self.length = length
        
        super.init(material: materialType)
    }
}
