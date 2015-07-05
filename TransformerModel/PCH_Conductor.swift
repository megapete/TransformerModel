//
//  PCH_Conductor.swift
//  TransformerModel
//
//  Created by PeterCoolAssHuber on 2015-07-03.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

/// Class for all conductor (ie: metal) materials. For now, only copper, aluminum and steel are recognized

class PCH_Conductor: PCH_RawMaterial {

    /**
        Resistivity, ⍴,  (at 20°C) of the conductor in Ω・m
    */
    var resistivity = 0.0 // at 20°C
    
    /** 
        Conductivity (inverse of Resistivity) [This is a computed property] in S/m at 20°C
    */
    var conductivity: Double
    {
        get
        {
            return (resistivity != 0.0 ? 1.0 / resistivity : 0.0)
        }
        
        set(newConductivity)
        {
            if (newConductivity == 0.0)
            {
                resistivity = 0.0
            }
            else
            {
                resistivity = 1.0 / newConductivity
            }
        }
    }
    
    /**
        Temperature coefficient of the conductor in 'per °K'
    */
    var temperatureCoefficient = 0.0 // per °K
    
    /**
        Designated initializer
        
        :param: name The optional name of the material
        :param: density The density of the material in kg/m3, at 0C and 100 kPa
        :param: cost The cost of the material in CDN$, per unit volume (kg/m3)
        :param: resistivity The resistivity of the conductor in Ω・m at 20°C
        :param: tempCoeff The temperature coefficient of the conductor in 'per °K'
    
        :returns: Conductor
    */
    init(name: String, density: Double, cost: Double, resistivity:Double, tempCoeff:Double)
    {
        super.init(name: name, density: density, cost: cost)
        self.resistivity = resistivity
        self.temperatureCoefficient = tempCoeff
    }
    
    /**
        Initializer using conductivity
        
        :param: name The optional name of the material
        :param: density The density of the material in kg/m3, at 0C and 100 kPa
        :param: cost The cost of the material in CDN$, per unit volume (kg/m3)
        :param: conductivity The conductivity of the conductor in S/m at 20°C
        :param: tempCoeff The temperature coefficient of the conductor in 'per °K'
        
        :returns: Conductor
    */
    convenience init(name: String, density: Double, cost: Double, conductivity:Double, tempCoeff:Double) {
        
        self.init(name:name, density:density, cost:cost, resistivity: 1.0 / conductivity, tempCoeff:tempCoeff)
    }
    
    /**
        Built-in conductor types
    
        - Copper
        - Aluminum
        - Steel
    */
    enum Conductor
    {
        case Copper, Aluminum, Steel
    }
    
    /**
        Convenience initializer for built-in materials
        
        :param: conductor Conductor type
        :returns: Conductor
    */
    convenience init(conductor:Conductor)
    {
        switch conductor
        {
            case .Copper:
            
                self.init(name:"Copper", density:8940.0, cost:3.00, resistivity:1.72E-8, tempCoeff:0.003862)
            
            case .Aluminum:
            
                self.init(name:"Aluminum", density:2700.0, cost:2.00, resistivity:2.82E-8, tempCoeff:0.0039)
            
            case .Steel:
            
                self.init(name:"Steel", density:7850.0, cost:0.50, resistivity:1.43E-7, tempCoeff:0.0)
            
        }
    }
    
    /**
        Calculate the resistance of the conductor with the given area and length at the given temperature
    
        :param: condArea The cross-sectional area of the conductor (in meters-squared)
        :param: length The length of the conductor (in meters)
        :param: temperature The temperature at which to calculate the resistance (°C)
    
        :returns: Resistance In ohms
    */
    func Resistance(condArea:Double, length:Double, temperature:Double) -> Double
    {
        let resistivityAtNewTemp = self.resistivity * (1.0 + self.temperatureCoefficient * (temperature - 20.0))
        
        return resistivityAtNewTemp * length / condArea
    }
    
    /**
    Calculate the resistance of the conductor with the given dimensions and length at the given temperature
    
    :param: condX The cross-sectional X-dimension of the conductor
    :param: condY The cross-sectional Y-dimension of the conductor
    :param: length The length of the conductor (in meters)
    :param: temperature The temperature at which to calculate the resistance (°C)
    
    :returns: Resistance In ohms
    */
    func Resistance(condX:Double, condY:Double, length:Double, temperature:Double) -> Double
    {
        return Resistance(condX * condY, length: length, temperature: temperature)
    }
    
}
