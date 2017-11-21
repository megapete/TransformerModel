//
//  PCH_DiskSection.swift
//  InductanceCalculator
//
//  Created by PeterCoolAssHuber on 2015-12-27.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/*
/// The == function must be defined for Hashable types
internal func ==(lhs:PCH_DiskSection, rhs:PCH_DiskSection) -> Bool
{
    return (lhs.data.serialNumber == rhs.data.serialNumber)
}
*/

class PCH_DiskSection:NSObject, NSCoding, NSCopying {
    
    /*
    override var hash: Int {
        
        return self.data.serialNumber
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        
        if let other = object as? PCH_DiskSection
        {
            return self.data.serialNumber == other.data.serialNumber
        }
        
        return false
    }
 */

    /// A reference number to the coil that "owns" the section.
    let coilRef:Int
    
    /// The number of turns in the section
    let N:Double
    
    /// The current density on the section
    var J:Double
    
    /// The window height of the core that holds the section
    let windHt:Double
    
    /// The core radius
    let coreRadius:Double
    
    /// The rectangle that the disk occupies
    let diskRect:NSRect
    
    /// A factor for "fudging" some calculations. The BlueBook says that a factor of three gives better results.
    // let windHtFactor = 3.0
    
    /// The electrical data associated with the section
    var data:PCH_SectionData
    
    /**
        Designated initializer
        
        - parameter N: The nuber of turns in the section
        - parameter J: The current density on the section
        - parameter windHt: The window height of the core
        - parameter coreRadius: The core radius

    */
    init(coilRef:Int, diskRect:NSRect, N:Double, J:Double, windHt:Double, coreRadius:Double, secData:PCH_SectionData)
    {
        self.coilRef = coilRef
        self.diskRect = diskRect
        self.N = N
        self.J = J
        self.windHt = windHt
        self.coreRadius = coreRadius
        self.data = secData
    }
    
    // Required initializer for archiving
    convenience required init?(coder aDecoder: NSCoder)
    {
        let coilRef = aDecoder.decodeInteger(forKey: "CoilRef")
        let diskRect = aDecoder.decodeRect(forKey: "DiskRect")
        let N = aDecoder.decodeDouble(forKey: "Turns")
        let J = aDecoder.decodeDouble(forKey: "CurrentDensity")
        let windHt = aDecoder.decodeDouble(forKey: "WindowHeight")
        let coreRadius = aDecoder.decodeDouble(forKey: "CoreRadius")
        let data = aDecoder.decodeObject(forKey: "Data") as! PCH_SectionData
        
        self.init(coilRef:coilRef, diskRect:diskRect, N:N, J:J, windHt:windHt, coreRadius:coreRadius, secData:data)
    }
    
    
    func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = PCH_DiskSection(coilRef: self.coilRef, diskRect: self.diskRect, N: self.N, J: self.J, windHt: self.windHt, coreRadius: self.coreRadius, secData: self.data)
        
        return copy
    }
 
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.coilRef, forKey:"CoilRef")
        aCoder.encode(self.diskRect, forKey:"DiskRect")
        aCoder.encode(self.N, forKey:"Turns")
        aCoder.encode(self.J, forKey:"CurrentDensity")
        aCoder.encode(self.windHt, forKey:"WindowHeight")
        aCoder.encode(self.coreRadius, forKey:"CoreRadius")
        aCoder.encode(self.data, forKey:"Data")
    }
    
    /// BlueBook function J0
    func J0(_ windHtFactor:Double) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        
        return self.J * Double(self.diskRect.size.height) / useWindht
    }
    
    /// BlueBook function Jn
    func J(_ n:Int, windHtFactor:Double) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        // let useOriginY = (useWindht - self.windHt) / 2.0 + Double(self.diskRect.origin.y)
        let useOriginY = Double(self.diskRect.origin.y)
        
        return (2.0 * self.J / (Double(n) * π)) * (sin(Double(n) * π * (useOriginY + Double(self.diskRect.size.height)) / useWindht) - sin(Double(n) * π * useOriginY / useWindht));
    }
    
    /// BlueBook function Cn
    func C(_ n:Int, windHtFactor:Double) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        let m = Double(n) * π / useWindht
        
        let x1 = m * Double(self.diskRect.origin.x)
        let x2 = m * Double(self.diskRect.origin.x + self.diskRect.size.width)
        
        return IntegralOf_tK1_from(x1, toB: x2)
    }
    
    /// BlueBook function Dn
    func D(_ n:Int, windHtFactor:Double) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        let xc = (Double(n) * π / useWindht) * self.coreRadius
        
        // Alternate method from BlueBook 2nd Ed., page 267
        let Ri0 = gsl_sf_bessel_I0_scaled(xc)
        let Rk0 = gsl_sf_bessel_K0_scaled(xc)
        let eBase = exp(2.0 * xc)
        
        let result = eBase * (Ri0 / Rk0) * self.C(n, windHtFactor:windHtFactor)
    
        return result
        
        /* old way
        
        let I0 = gsl_sf_bessel_I0(xc)
        let K0 = gsl_sf_bessel_K0(xc)
        
        return I0 / K0 * self.C(n)
        */
    }
    
    func ScaledD(_ n:Int, windHtFactor:Double) -> Double
    {
        // returns Rd where D = exp(2.0 * xc - x1) * Rd (xc and x1 are functions of n)
        
        let useWindht = windHtFactor * self.windHt
        let m = Double(n) * π / useWindht
        
        let x1 = m * Double(self.diskRect.origin.x)
        let x2 = m * Double(self.diskRect.origin.x + self.diskRect.size.width)
        let xc = (Double(n) * π / useWindht) * self.coreRadius
        
        let Ri0 = gsl_sf_bessel_I0_scaled(xc)
        let Rk0 = gsl_sf_bessel_K0_scaled(xc)
        
        let ScaledCn = ScaledIntegralOf_tK1_from(x1, toB: x2)
        
        return Ri0 / Rk0 * ScaledCn
    }
    
    func AlternateD(_ n:Int, windHtFactor:Double) -> Double
    {
        // The Dn function, using scaled methods
        
        let useWindht = windHtFactor * self.windHt
        let m = Double(n) * π / useWindht
        
        let x1 = m * Double(self.diskRect.origin.x)
        let x2 = m * Double(self.diskRect.origin.x + self.diskRect.size.width)
        let xc = (Double(n) * π / useWindht) * self.coreRadius
        
        let Ri0 = gsl_sf_bessel_I0_scaled(xc)
        let Rk0 = gsl_sf_bessel_K0_scaled(xc)
        
        let ScaledCn = ScaledIntegralOf_tK1_from(x1, toB: x2)
        
        return exp(2.0 * xc - x1) * Ri0 / Rk0 * ScaledCn
    }
    
    func ScaledC(_ n:Int, windHtFactor:Double) -> Double
    {
        // return IntCn where the actual integral = exp(-x1) * IntCn, where x1 = n * π / useWindht * self.diskRect.origin.x
        
        let useWindht = windHtFactor * self.windHt
        let m = Double(n) * π / useWindht
        
        let x1 = m * Double(self.diskRect.origin.x)
        let x2 = m * Double(self.diskRect.origin.x + self.diskRect.size.width)
        
        return ScaledIntegralOf_tK1_from(x1, toB: x2)
    }
    
    /// BlueBook function En
    func E(_ n:Int, windHtFactor:Double) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        let x2 = (Double(n) * π / useWindht) * Double(self.diskRect.origin.x + self.diskRect.size.width)
        
        return IntegralOf_tK1_from0_to(x2)
    }
    
    func ScaledE(_ n:Int, windHtFactor:Double) -> Double
    {
        // return Re where the actual integral = π / 2.0 * (1.0 - exp(-x2) * Re)
        let useWindht = windHtFactor * self.windHt
        let x2 = (Double(n) * π / useWindht) * Double(self.diskRect.origin.x + self.diskRect.size.width)
        
        return ScaledIntegralOf_tK1_from0_to(x2)
    }
    
    /// BlueBook function Fn
    func F(_ n:Int, windHtFactor:Double) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        let m = (Double(n) * π / useWindht)
        
        let x1 = m * Double(self.diskRect.origin.x)
        
        // Old way
        // let x2 = m * Double(self.diskRect.origin.x + self.diskRect.size.width)
        // let xc = m * self.coreRadius
        
        // Alternate method from BlueBook 2nd Ed., page 267
        // let Ri0 = gsl_sf_bessel_I0_scaled(xc)
        // let Rk0 = gsl_sf_bessel_K0_scaled(xc)
        // let eBase = exp(2.0 * xc)
 
        let result = AlternateD(n, windHtFactor:windHtFactor) - IntegralOf_tI1_from0_to(x1)
        
        return result
        
        // OLD return eBase * (Ri0 / Rk0) * IntegralOf_tK1_from(x1, toB: x2) - IntegralOf_tI1_from0_to(x1)
    }
    
    func AlternateF(_ n:Int, windHtFactor:Double) -> Double
    {
        // Best method of calculating F (uses scaling techniques)
        
        let useWindht = windHtFactor * self.windHt
        let m = (Double(n) * π / useWindht)
        
        let x1 = m * Double(self.diskRect.origin.x)
        let xc = m * self.coreRadius
        
        let exponent = 2.0 * xc - x1
        
        let result = exp(exponent) * (ScaledD(n, windHtFactor:windHtFactor) - exp(x1 - exponent) * ScaledIntegralOf_tI1_from0_to(x1))
        
        return result
    }
    
    func ScaledF(_ n:Int, windHtFactor:Double) -> Double
    {
        // return Rf where F = exp(2.0 * xc - x1) * Rf (xc and x1 are functions of n)
        
        let useWindht = windHtFactor * self.windHt
        let m = (Double(n) * π / useWindht)
        
        let x1 = m * Double(self.diskRect.origin.x)
        let xc = m * self.coreRadius
        
        let exponent = 2.0 * xc - x1
        
        let result = (ScaledD(n, windHtFactor:windHtFactor) - exp(x1 - exponent) * ScaledIntegralOf_tI1_from0_to(x1))
        
        return result
        
    }
    
    /// BlueBook function Gn
    func G(_ n:Int, windHtFactor:Double) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        let m = (Double(n) * π / useWindht)
        
        let x1 = m * Double(self.diskRect.origin.x)
        let x2 = m * Double(self.diskRect.origin.x + self.diskRect.size.width)
        let xc = m * self.coreRadius
        
        // Alternate method from BlueBook 2nd Ed., page 267
        let Ri0 = gsl_sf_bessel_I0_scaled(xc)
        let Rk0 = gsl_sf_bessel_K0_scaled(xc)
        let eBase = exp(2.0 * xc)
        
        return eBase * (Ri0 / Rk0) * IntegralOf_tK1_from(x1, toB: x2) + IntegralOf_tI1_from(x1, toB: x2)
    }
    
    func ScaledG(_ n:Int, windHtFactor:Double) -> Double
    {
        // return Rg where Gn = e(x1) * Rg
        
        let useWindht = windHtFactor * self.windHt
        let m = (Double(n) * π / useWindht)
        
        let x1 = m * Double(self.diskRect.origin.x)
        let x2 = m * Double(self.diskRect.origin.x + self.diskRect.size.width)
        let xc = m * self.coreRadius
        
        let Ri0 = gsl_sf_bessel_I0_scaled(xc)
        let Rk0 = gsl_sf_bessel_K0_scaled(xc)
        let RtK = ScaledIntegralOf_tK1_from(x1, toB: x2)
        let RtI = ScaledIntegralOf_tI1_from(x1, toB: x2)
        
        let exponent = 2.0 * xc - 2.0 * x1
        
        let Rg = e(exponent) * (Ri0 / Rk0) * RtK + RtI
        
        return Rg
    }
    
    /// Rabins' method for calculating self-inductance
    func SelfInductance(_ windHtFactor:Double) -> Double
    {
        let I1 = self.J * Double(self.diskRect.size.width * self.diskRect.size.height) / self.N
        
        let N1 = self.N
        
        let r1 = Double(self.diskRect.origin.x)
        let r2 = r1 + Double(self.diskRect.size.width)
        let rc = self.coreRadius
        
        var result = (π * µ0 * N1 * N1 / (6.0 * windHtFactor * self.windHt)) * (gsl_pow_2(r2 + r1) + 2.0 * gsl_pow_2(r1))
        
        
        let multiplier = π * µ0 * windHtFactor * self.windHt * N1 * N1 / gsl_pow_2(N1 * I1)
        
        let convergenceIterations = 200
        
        // Next line rendered obsolete by Swift 3 (I think, anyways - XCode updated the code and I didn't check everything it did)
        // let loopQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
        
        var currVal = [Double](repeating: 0.0, count: convergenceIterations)
        
        // for var n = 1; n <= 200 /* fabs((lastValue-currentValue) / lastValue) > epsilon */; n++
        DispatchQueue.concurrentPerform(iterations: convergenceIterations)
        {
            (i:Int) -> Void in // this is the way to specify one of those "dangling" closures
                
            let n = i + 1
            
            let m = Double(n) * π / (windHtFactor * self.windHt)
            
            let x1 = m * r1;
            let x2 = m * r2;
            let xc = m * rc;
            
            // After much mathematical manipulation and using scaled versions of the I and K functions, this is the most accurate method I came up with for calculating each iteration of the sum (the old method follows but is commented out). I have used a bunch of let statements for the different components of the equation to help debugging
            
            // The scaled version of Fn returns the remainder Rf where Fn = exp(2.0 * xc - x1) * Rf
            let scaledFn = self.ScaledF(n, windHtFactor:windHtFactor)
            
            // the exponent after combining the two scaled remainders is (2.0 * xc - 2.0 * x1)
            let exponent = 2.0 * (xc - x1)
            
            let scaledTK1 = ScaledIntegralOf_tK1_from(x1, toB: x2)
            
            let (IntI1TermUnscaled, scaledI1) = PartialScaledIntegralOf_tL1_from(x1, toB: x2)
            let mult = self.E(n, windHtFactor:windHtFactor) - π / 2.0
            
            let newWay = mult * exp(x1) * scaledI1 - (π / 2.0) *  IntI1TermUnscaled + exp(exponent) * (scaledFn * scaledTK1)
            
            currVal[i] = multiplier * (gsl_pow_2(self.J(n, windHtFactor:windHtFactor)) / gsl_pow_4(m)) * newWay
            
            // Old way
            // currVal[i] = multiplier * (gsl_pow_2(self.J(n)) / gsl_pow_4(m) * (self.E(n) * IntegralOf_tI1_from(x1, toB: x2) + self.F(n) * IntegralOf_tK1_from(x1, toB: x2) - π / 2.0 * IntegralOf_tL1_from(x1, toB: x2)))
        }
        
        // cool way to get the sum of the values in an array
        result += currVal.reduce(0.0, +)
        
        return result
    }
    
    /// Rabins' methods for mutual inductances
    func MutualInductanceTo(_ otherDisk:PCH_DiskSection, windHtFactor:Double) -> Double
    {
        /// If the inner radii of the two sections differ by less than 1mm, we assume that they are in the same radial position
        let isSameRadialPosition = fabs(Double(self.diskRect.origin.x - otherDisk.diskRect.origin.x)) <= 0.001
        
        let I1 = self.J * Double(self.diskRect.size.width * self.diskRect.size.height) / self.N
        let I2 = otherDisk.J * Double(otherDisk.diskRect.size.width * otherDisk.diskRect.size.height) / otherDisk.N
        
        let N1 = self.N
        let N2 = otherDisk.N
        
        // let testI1 = self.J0() * Double(self.diskRect.size.width) * windHtFactor * self.windHt / self.N
        
        let r1 = Double(self.diskRect.origin.x)
        let r2 = r1 + Double(self.diskRect.size.width)
        let r3 = Double(otherDisk.diskRect.origin.x)
        let r4 = r3 + Double(otherDisk.diskRect.size.width)
        let rc = self.coreRadius
        
        var result:Double
        
        if (isSameRadialPosition)
        {
            result = (π * µ0 * N1 * N2 / (6.0 * windHtFactor * self.windHt)) * (gsl_pow_2(r2 + r1) + 2.0 * gsl_pow_2(r1))
        }
        else
        {
            result = (π * µ0 * N1 * N2 / (3.0 * windHtFactor * self.windHt)) * (gsl_pow_2(r1) + r1 * r2 + gsl_pow_2(r2))
        }
        
        let multiplier = π * µ0 * windHtFactor * self.windHt * N1 * N2 / ((N1 * I1) * (N2 * I2))
        
        
        // After testing, I've decided to go with the BlueBook recommendation to simply execute the sumation 200 times insead of stopping after some informal definition of "convergence".
        
        let convergenceIterations =  200
        
        var currVal = [Double](repeating: 0.0, count: convergenceIterations)
        
        // for i in 0..<convergenceIterations
        DispatchQueue.concurrentPerform(iterations: convergenceIterations)
        {
            (i:Int) -> Void in // this is the way to specify one of those "dangling" closures
            
            let n = i + 1
            
            let m = Double(n) * π / (windHtFactor * self.windHt)
            
            let x1 = m * r1;
            let x2 = m * r2;
            let x3 = m * r3
            let x4 = m * r4
            let xc = m * rc;
            
            if (isSameRadialPosition)
            {
                // This uses the same "scaled" version of the iteration step as the SelfInductance() function above. See there for more comments.
                
                let scaledFn = self.ScaledF(n, windHtFactor:windHtFactor)
                let exponent = 2.0 * (xc - x1)
                let scaledTK1 = ScaledIntegralOf_tK1_from(x1, toB: x2)
                
                let (IntI1TermUnscaled, scaledI1) = PartialScaledIntegralOf_tL1_from(x1, toB: x2)
                let mult = self.E(n, windHtFactor:windHtFactor) - π / 2.0
                
                let newWay = mult * exp(x1) * scaledI1 - (π / 2.0) *  IntI1TermUnscaled + exp(exponent) * (scaledFn * scaledTK1)
                
                currVal[i] = multiplier * ((self.J(n, windHtFactor:windHtFactor) * otherDisk.J(n, windHtFactor:windHtFactor)) / gsl_pow_4(m)) * newWay
                
                // The old, non-precise way
                // currVal[i] = multiplier * ((self.J(n) * otherDisk.J(n)) / gsl_pow_4(m) * (self.E(n) * IntegralOf_tI1_from(x1, toB: x2) + self.F(n) * IntegralOf_tK1_from(x1, toB: x2) - π / 2.0 * IntegralOf_tL1_from(x1, toB: x2)))
            }
            else
            {
                // This uses the same "scaled" version of the iteration step, similarly to the SelfInductance() function above. See there for more comments.
                
                let outerExp = exp(2.0 * xc - x3 - x1)
                let innerExp = exp(-2.0 * xc + 2.0 * x1)
                
                let firstProduct = ScaledIntegralOf_tK1_from(x3, toB: x4) * ScaledIntegralOf_tI1_from(x1, toB: x2)
                let secondProduct = otherDisk.ScaledD(n, windHtFactor:windHtFactor) * ScaledIntegralOf_tK1_from(x1, toB: x2)
                let insideTerm = innerExp * firstProduct + secondProduct
                let newWay = outerExp * insideTerm

                currVal[i] = multiplier * ((self.J(n, windHtFactor:windHtFactor) * otherDisk.J(n, windHtFactor:windHtFactor)) / gsl_pow_4(m)) * newWay
                
                // The old, imprecise way
                // currVal[i] = multiplier * ((self.J(n) * otherDisk.J(n)) / gsl_pow_4(m) * (otherDisk.C(n) * IntegralOf_tI1_from(x1, toB: x2) + otherDisk.D(n) * IntegralOf_tK1_from(x1, toB: x2)))
                
            }
            
            
        }
        
        // cool way to get the sum of the values in an array
        result += currVal.reduce(0.0, +)
        
        return result
    }

} // end class declaration
