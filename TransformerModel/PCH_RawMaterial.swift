//
//  PCH_RawMaterial.swift
//  TransformerModel
//
//  Created by PeterCoolAssHuber on 2015-07-03.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//


/// Base class for all materials. Base class is NSObject to get the -description function.

class PCH_RawMaterial {
    
    /**
        An optional name property (String). 
    */
    var name = ""
    
    /**
        The density of the material (in kg/cubic meter, at 0C and 100kPa)
    */
    var density = 0.0   // in kg/m3, at 0C and 100kPa
    
    /**
        The cost (including modifying factors, in Canadian dollars) per unit volume (cubic meters)
    */
    var cost = 0.0      // in CDN$/m3
    
    /**
        Designated initializer
    
        - parameter name: The optional name of the material
        - parameter density: The density of the material in kg/m3, at 0C and 100 kPa
        - parameter cost: The cost of the material in CDN$, per unit volume (kg/m3)
    
        - returns: A raw material object
    */
    init(name: String, density: Double, cost: Double)
    {
        self.name = name
        self.density = density
        self.cost = cost
    }
    
    /**
        Calculate the weight of a piece of material with given dimensions (for a 'rectangular box' shape)
    
        - parameter length: The 'length' dimension of the piece of material
        - parameter width: The 'width' dimension of the piece of material
        - parameter height: The 'height' dimension of the piece of material
    
        - returns: The weight of the piece in kilograms (Double)
    */
    
    func Weight(length:Double, width:Double, height:Double) -> Double
    {
        return length * width * height * self.density
    }
    
    /**
        Calculate the weight of a piece of material with given dimensions (for a 'cylindrical' shape)
        
        - parameter diameter: The 'diameter' of the piece of material
        - parameter length: The 'length' dimension of the piece of material
        
        - returns: The weight of the piece in kilograms (Double)
    */
    func Weight(diameter diameter:Double, length:Double) -> Double
    {
        let radius = diameter / 2.0
        
        return π * radius * radius * length * self.density
    }
    
    /**
        Calculate the weight of a piece of material with given area and length
        
        - parameter area: The area of the piece of material
        - parameter length: The length  of the piece of material
        
        - returns: The weight of the piece in kilograms (Double)
    */
    func Weight(area area:Double, length:Double) -> Double
    {
        return area * length * self.density
    }
    
    /**
        Calculate the cost of a piece of material with given dimensions
        
        - parameter length: The 'length' dimension of the piece of material
        - parameter width: The 'width' dimension of the piece of material
        - parameter height: The 'height' dimension of the piece of material
        
        - returns: The cost of the piece in Canadian dollars (Double)
    */
    
    func CanadianDollarValue(length:Double, width:Double, height:Double) -> Double
    {
        return length * width * height * self.cost
    }
    
}
