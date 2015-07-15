//
//  PCH_RawMaterial.swift
//  TransformerModel
//
//  Created by PeterCoolAssHuber on 2015-07-03.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

/// Base class for all materials

class PCH_RawMaterial {
    
    /**
        An optional name property (String)
    */
    var name = ""
    
    /**
        The density of the material (in kg/cubic meter, at 0C and 100kPa)
    */
    var density = 0.0   // in kg/m3, at 0C and 100kPa
    
    /**
        The cost (in Canadian dollars) per unit volume (cubic meters)
    */
    var cost = 0.0      // in CDN$/m3
    
    /**
        Designated initializer
    
        :param: name The optional name of the material
        :param: density The density of the material in kg/m3, at 0C and 100 kPa
        :param: cost The cost of the material in CDN$, per unit volume (kg/m3)
    
        :returns: A raw material object
    */
    init(name: String, density: Double, cost: Double)
    {
        self.name = name
        self.density = density
        self.cost = cost
    }
    
    /**
        Calculate the weight of a piece of material with given dimensions (for a 'rectangular box' shape)
    
        :param: length The 'length' dimension of the piece of material
        :param: width The 'width' dimension of the piece of material
        :param: height The 'height' dimension of the piece of material
    
        :returns: The weight of the piece in kilograms (Double)
    */
    
    func Weight(length:Double, width:Double, height:Double) -> Double
    {
        return length * width * height * self.density
    }
    
    /**
        Calculate the weight of a piece of material with given dimensions (for a 'cylindrical' shape)
        
        :param: diameter The 'diameter' of the piece of material
        :param: length The 'length' dimension of the piece of material
        
        :returns: The weight of the piece in kilograms (Double)
    */
    func Weight(#diameter:Double, length:Double) -> Double
    {
        let radius = diameter / 2.0
        
        return pi * radius * radius * length * self.density
    }
    
    /**
        Calculate the weight of a piece of material with given area and length
        
        :param: area The area of the piece of material
        :param: length The length  of the piece of material
        
        :returns: The weight of the piece in kilograms (Double)
    */
    func Weight(#area:Double, length:Double) -> Double
    {
        return area * length * self.density
    }
    
    /**
        Calculate the cost of a piece of material with given dimensions
        
        :param: length The 'length' dimension of the piece of material
        :param: width The 'width' dimension of the piece of material
        :param: height The 'height' dimension of the piece of material
        
        :returns: The cost of the piece in Canadian dollars (Double)
    */
    
    func CanadianDollarValue(length:Double, width:Double, height:Double) -> Double
    {
        return length * width * height * self.cost
    }
    
}
