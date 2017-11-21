//
//  PCH_BlueBookFunctions.swift
//  InductanceCalculator
//
//  Created by PeterCoolAssHuber on 2015-12-27.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

/// This is basically an interface file which defines the functions we need to use Rabin's method for inductance calculations

import Foundation

let relError = 1.0E-4

func IntegralOf_tL1_from0_to(_ b:Double) -> Double
{
    let firstTerm = (-b * M0(b))
    let secondterm = -(b * b / π)
    let thirdTerm = IntegralOf_M0_from0_to(b)
    let fourthTerm = IntegralOf_tI1_from0_to(b)

    // DLog("First: \(firstTerm) Second: \(secondterm) Third: \(thirdTerm) Fourth: \(fourthTerm)")
    
    return firstTerm + secondterm + thirdTerm + fourthTerm //(-b * M0(b)) - (b * b / π) + IntegralOf_M0_from0_to(b) + IntegralOf_tI1_from0_to(b)
}

func IntegralOf_tL1_from(_ a:Double, toB:Double) -> Double
{
    return IntegralOf_tL1_from0_to(toB) - IntegralOf_tL1_from0_to(a)
}

func AlternateIntegralOf_tL1_from(_ a:Double, toB:Double) -> Double
{
    // More "mathematical" way of calculating the integral
    let b = toB
    let nonIntegralSum = a * M0(a) - b * M0(b) + (a*a - b*b) / π
    let m0integral = IntegralOfM0_from(a, toB: b)
    let i1integral = exp(a) * ScaledIntegralOf_tI1_from(a, toB: b)
    
    return nonIntegralSum + m0integral + i1integral
}

func PartialScaledIntegralOf_tL1_from(_ a:Double, toB b:Double) -> (Double, Double)
{
    // return a 2-tuple where the first number is unscaled and the second is scaled to exp(a)
    let nonIntegralSum = a * M0(a) - b * M0(b) + (a*a - b*b) / π
    let m0integral = IntegralOfM0_from(a, toB: b)
    let scaledI1integral = ScaledIntegralOf_tI1_from(a, toB: b)
    
    return (nonIntegralSum + m0integral, scaledI1integral)
}

func IntegralOf_tI1_from0_to(_ b:Double) -> Double
{
    
    // Alternate method from BlueBook 2nd Ed., page 267
    let Ri0 = gsl_sf_bessel_I0_scaled(b)
    let Ri1 = gsl_sf_bessel_I1_scaled(b)
    let eBase = exp(b)
    
    return (π / 2.0) * b * eBase * (M1(b) * Ri0 - M0(b) * Ri1)
}

func ScaledIntegralOf_tI1_from0_to(_ b:Double) -> Double
{
    // return IntRI1 where the actual integral = exp(b) * IntRI1
    
    let Ri0 = gsl_sf_bessel_I0_scaled(b)
    let Ri1 = gsl_sf_bessel_I1_scaled(b)
    
    return (π / 2.0) * b * (M1(b) * Ri0 - M0(b) * Ri1)
}

func IntegralOf_tI1_from(_ a:Double, toB:Double) -> Double
{
    return IntegralOf_tI1_from0_to(toB) - IntegralOf_tI1_from0_to(a)
}

func ScaledIntegralOf_tI1_from(_ a:Double, toB:Double) -> Double
{
    // return IntRI1 where the actual integral = exp(a) * IntRI1
    
    let b = toB
    
    let Ri0a = gsl_sf_bessel_I0_scaled(a)
    let Ri1a = gsl_sf_bessel_I1_scaled(a)
    let Ri0b = gsl_sf_bessel_I0_scaled(b)
    let Ri1b = gsl_sf_bessel_I1_scaled(b)
    
    let firstTerm = a * (M1(a) * Ri0a - M0(a) * Ri1a)
    let secondTerm = b * exp(b-a) * (M1(b) * Ri0b - M0(b) * Ri1b)
    
    return (π / 2.0) * (secondTerm - firstTerm)
}

func IntegralOf_tK1_from0_to(_ b:Double) -> Double
{
    // Alternate method from BlueBook 2nd Ed., page 267
    let Rk0 = gsl_sf_bessel_K0_scaled(b)
    let Rk1 = gsl_sf_bessel_K1_scaled(b)
    let eBase = exp(-b)
    
    let secondTerm = b * eBase * (M1(b) * Rk0 + M0(b) * Rk1)
    
    return (π / 2.0) * (1.0 - secondTerm)
}

func ScaledIntegralOf_tK1_from0_to(_ b:Double) -> Double
{
    // return IntK1 where the actual integral = π / 2.0 * (1.0 - exp(-b) * IntK1)
    let Rk0 = gsl_sf_bessel_K0_scaled(b)
    let Rk1 = gsl_sf_bessel_K1_scaled(b)
    
    let result = b * (M1(b) * Rk0 + M0(b) * Rk1)
    
    return result
}

func IntegralOf_tK1_from(_ a:Double, toB:Double) -> Double
{
    return IntegralOf_tK1_from0_to(toB) - IntegralOf_tK1_from0_to(a)
}

func ScaledIntegralOf_tK1_from(_ a:Double, toB:Double) -> Double
{
    // return IntRk1 where the actual integral = exp(-a) * IntRk1
    guard a <= toB
    else
    {
        DLog("Illegal range")
        return Double.greatestFiniteMagnitude
    }
    
    let b = toB
    
    let Rk0a = (a != 0 ? gsl_sf_bessel_K0_scaled(a) : 0.0)
    let Rk1a = (a != 0 ? gsl_sf_bessel_K1_scaled(a) : 0.0)
    let Rk0b = gsl_sf_bessel_K0_scaled(b)
    let Rk1b = gsl_sf_bessel_K1_scaled(b)
    
    /* Testing and debugging
    let integA = IntegralOf_tK1_from0_to(a)
    let integB = IntegralOf_tK1_from0_to(b)
    
    let testA = (π / 2.0) * a * exp(-a) * (M1(a) * Rk0a + M0(a) * Rk1a)
    let testB = (π / 2.0) * b * exp(-b) * (M1(b) * Rk0b + M0(b) * Rk1b)
    */
    
    let firstTerm = (a != 0 ? a * (M1(a) * Rk0a + M0(a) * Rk1a) : 1.0)
    let secondTerm = b * exp(a-b) * (M1(b) * Rk0b + M0(b) * Rk1b)
    
    return (π / 2.0) * (firstTerm - secondTerm)
    
}


func L0(_ x:Double) -> Double
{
    return gsl_sf_bessel_I0(x) - M0(x)
}

func L1(_ x:Double) -> Double
{
    return gsl_sf_bessel_I1(x) - M1(x)
}



/*
func M0X_integrand(_ theta:Double, params:UnsafeMutableRawPointer?) -> Double!
{
    
    
    // first we have to convert the params pointer to a Double
    let dpParams = UnsafeMutablePointer<Double>(params)
    let x:Double = params.pointee
    
    return exp(-x * cos(theta))
}
 */

func M0(_ x:Double) -> Double
{
    var iError:Double = 0.0
    var iNumEvals:Int = 0
    var result:Double = 0.0
    
    var params = x
    
    //var tst = gsl_function(function: <#T##((Double, UnsafeMutableRawPointer?) -> Double)!##((Double, UnsafeMutableRawPointer?) -> Double)!##(Double, UnsafeMutableRawPointer?) -> Double#>, params: <#T##UnsafeMutableRawPointer!#>)
    
    var integrand:gsl_function = gsl_function(function: {(theta:Double, p:UnsafeMutableRawPointer?) -> Double in
        
            guard (p != nil) else
            {
                return exp(cos(theta))
            }
        
            let pPtr:UnsafeMutablePointer<Double> = p!.bindMemory(to: Double.self, capacity: 1)
            let x:Double = pPtr.pointee
        
            return exp(-x * cos(theta))
        },
        params: &params)

    
    // var integrand:gsl_function = gsl_function(function: M0X_integrand, params: &params)
    
    let fRes = gsl_integration_qng(&integrand, 0.0, π / 2.0, 0.0, relError, &result, &iError, &iNumEvals)
    
    if (fRes > 0)
    {
        ALog("Error calling integration routine")
        return 0.0
    }
    
    return result * 2.0 / π
}

/*
func M1X_integrand(_ theta:Double, params:UnsafeMutableRawPointer?) -> Double
    {
    // first we have to convert the params pointer to a Double
    let dpParams = UnsafeMutablePointer<Double>(params)
    let x:Double = dpParams.pointee
    
    return exp(-x * cos(theta)) * cos(theta)
}
*/

func M1(_ x:Double) -> Double
{
    var iError:Double = 0.0
    var iNumEvals:Int = 0
    var result:Double = 0.0
    
    var params = x
    
    var integrand:gsl_function = gsl_function(function: {(theta:Double, p:UnsafeMutableRawPointer?) -> Double in
        
        guard (p != nil) else
        {
            return exp(cos(theta))
        }
        
        let pPtr:UnsafeMutablePointer<Double> = p!.bindMemory(to: Double.self, capacity: 1)
        let x:Double = pPtr.pointee
        
        return exp(-x * cos(theta)) * cos(theta)// * cos(theta) // second cos(theta) added becuase I think it's wrong in the book
        },
        params: &params)
    
    let fRes = gsl_integration_qng(&integrand, 0.0, π / 2.0, 0.0, relError, &result, &iError, &iNumEvals)
    
    if (fRes > 0)
    {
        ALog("Error calling integration routine")
        return 0.0
    }
    
    return (1.0 - result) * 2.0 / π
}

/*
func IntM0T_integrand(_ theta:Double, params:UnsafeMutablePointer<Void>) -> Double
{
    // first we have to convert the params pointer to a Double
    let dpParams = UnsafeMutablePointer<Double>(params)
    let x:Double = dpParams.pointee

    return (1.0 - exp(-x * cos(theta))) / cos(theta)
}
 */

func IntegralOf_M0_from0_to(_ b:Double) -> Double
{
    var iError:Double = 0.0
    var iNumEvals:Int = 0
    var result:Double = 0.0
    
    var params = b
    
    var integrand:gsl_function = gsl_function(function: {(theta:Double, p:UnsafeMutableRawPointer?) -> Double in
        
        guard (p != nil) else
        {
            return exp(cos(theta))
        }
        
        let pPtr:UnsafeMutablePointer<Double> = p!.bindMemory(to: Double.self, capacity: 1)
        let x:Double = pPtr.pointee
        
        return (1.0 - exp(-x * cos(theta))) / cos(theta)
        },
        params: &params)
    
    let fRes = gsl_integration_qng(&integrand, 0.0, π / 2.0, 0.0, relError, &result, &iError, &iNumEvals)
    
    if (fRes > 0)
    {
        ALog("Error calling integration routine")
        return 0.0
    }
    
    return result * 2.0 / π
}

func IntegralOfM0_from(_ a:Double, toB b:Double) -> Double
{
    return IntegralOf_M0_from0_to(b) - IntegralOf_M0_from0_to(a)
}
