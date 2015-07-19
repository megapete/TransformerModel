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
        The material of the conductor
    */
    let material:Conductor
    
    /**
        Resistivity, ⍴,  (at 20°C) of the conductor in Ω・m
    */
    var ρ = 0.0 // at 20°C
    
    /** 
        Conductivity, σ,  (inverse of Resistivity) [This is a computed property] in S/m at 20°C
    */
    var σ: Double
    {
        get
        {
            return (ρ != 0.0 ? 1.0 / ρ : 0.0)
        }
        
        set(newConductivity)
        {
            if (newConductivity == 0.0)
            {
                ρ = 0.0
            }
            else
            {
                ρ = 1.0 / newConductivity
            }
        }
    }
    
    /**
        Description of the conductor
    */
    var description: String
    {
        get
        {
            switch (self.material)
            {
                case .Copper:
                    return "Copper"
                case .Aluminum:
                    return "Aluminum"
                case .Steel:
                    return "Steel"
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
    init(type: Conductor, density: Double, cost: Double, resistivity:Double, tempCoeff:Double)
    {
        self.ρ = resistivity
        self.temperatureCoefficient = tempCoeff
        self.material = type

        super.init(name: "", density: density, cost: cost)
        
        self.name = self.description
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
    convenience init(type: Conductor, density: Double, cost: Double, conductivity:Double, tempCoeff:Double) {
        
        self.init(type:type, density:density, cost:cost, resistivity: 1.0 / conductivity, tempCoeff:tempCoeff)
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
            
                self.init(type: .Copper, density:8940.0, cost:PCH_Costs.sharedInstance.CostForKey(PCH_Costs.CostKey.Copper), resistivity:1.72E-8, tempCoeff:0.003862)
            
            case .Aluminum:
            
                self.init(type: .Aluminum, density:2700.0, cost:PCH_Costs.sharedInstance.CostForKey(PCH_Costs.CostKey.Aluminum), resistivity:2.82E-8, tempCoeff:0.0039)
            
            case .Steel:
            
                self.init(type: .Steel, density:7850.0, cost:0.50, resistivity:1.43E-7, tempCoeff:0.0)
            
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
        let resistivityAtNewTemp = self.ρ * (1.0 + self.temperatureCoefficient * (temperature - 20.0))
        
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
