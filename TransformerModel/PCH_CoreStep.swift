//
//  PCH_CoreStep.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-08.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// Class that represents a single core step, made up of a single type of lamination

class PCH_CoreStep
{
    /// The lamination that is used to make the step
    let lamination:PCH_Lamination?
    
    /// The number of laminations in a pack (the minimum stack height increment/decrement, usually 2
    let lamsPerPack:Int
    
    /// The NetArea/TheoreticalArea
    let stackingFactor:Double
    
    /// The physical height of the stack
    let stackHeight:Double
    
    /**
        Designated initializer
    
        - parameter lamination: The PCH_Lamination that makes up the step
        - parameter stackHeight: The physical stack height of the step
        - parameter lamsPerPack: The number of laminations in each pack (effectively, the minimum increment/decrement of the stack height). Defaults to 2
        - parameter stackingFactor: The fraction of the stack height that is used to calculate the net area of the core. Defaults to 0.96
    */
    init(lamination:PCH_Lamination?, stackHeight:Double, lamsPerPack:Int = 2, stackingFactor:Double = 0.96)
    {
        self.lamination = lamination
        self.stackHeight = stackHeight
        self.lamsPerPack = lamsPerPack
        self.stackingFactor = stackingFactor
    }
    
    /**
        Returns the net area of the step
    */
    func NetArea() -> Double
    {
        return self.lamination!.width * self.stackHeight * self.stackingFactor
    }
    
    /**
        Given the length of this step, this function returns the weight of the step.
    */
    func WeightForLength(_ length:Double) -> Double
    {
        return self.lamination!.steelType.Weight(length, width: self.lamination!.width, height: self.stackHeight)
    }
    
    /**
        The loss (without correction factros for joints or stacking) of this step. This function should be used to calculate the total core loss to allow for the (unlikely) possibility that different steps of the core use different core steel types.
    
        - parameter length: The length of the step
        - parameter Bmax: The induction level at which the loss should be calculated
    */
    func LossForLength(_ length:Double, atBmax:Double) -> Double
    {
        return self.lamination!.steelType.SpecificLossAtBmax(atBmax) * self.WeightForLength(length)
    }
}
