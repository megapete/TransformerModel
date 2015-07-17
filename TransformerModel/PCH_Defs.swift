//
//  PCH_Defs.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-15.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

// Standard defs that should be included in all PCH projects.

import Foundation

/** 

    My standard debug logging function (this will probably change with time)
    
    :param: message The debug message
    :param: file The name of the file where the debug message was invoked
    :param: function The name of the function where the debug message was invoked
    :param: line The line number of the file where the debug message was invoked

*/
func DLog(message:String, file:String = __FILE__, function:String = __FUNCTION__, line:Int = __LINE__)
{
    #if DEBUG
        
        print("\(file) : \(function) : \(line) : \(message)\n")
        
    #endif
}

/**

    My standard assertion/debugging logging function (this will probably change with time)

    :param: message The debug message
    :param: file The name of the file where the debug message was invoked
    :param: function The name of the function where the debug message was invoked
    :param: line The line number of the file where the debug message was invoked

*/
func ALog(message:String, file:String = __FILE__, function:String = __FUNCTION__, line:Int = __LINE__)
{
    #if DEBUG
    
        msgString = file + " : " + function + " : " + String(line) + " : " + message
        
        assert(false, msgString)
        
    #else
    
        print("\(file) : \(function) : \(line) : \(message)\n")
        
    #endif
}

/**
    My standard "assert" function
    
    :param: condition The condition that must be true to not assert
    :param: message The message to show if condition is false
*/
func ZAssert(condition:Bool, message:String)
{
    if !condition
    {
        ALog(message)
    }
}