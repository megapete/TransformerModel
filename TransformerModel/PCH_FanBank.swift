//
//  PCH_FanBank.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-08-13.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// Definition for a bank of cooling fans. This class is basically an interface to a plist file.

class PCH_FanBank {

    enum FanModels {
        
        case FAC262_850
        case FAC262_1140
        case FAC262_1750
        case FAC264_850
        case FAC264_1140
        // there is no FAC264_1750
        case FAC244_850
        case FAC244_1140
        case FAC244_1750
        case FAC164_850
        case FAC164_1140
        case FAC164_1750
    }
    
    private var fanDataDict:NSDictionary?
    
    let model:FanModels
    let numFans:Int

}
