//
//  Tools.swift
//  CocoaSwift
//
//  Created by leig on 12/06/2017.
//  Copyright © 2017 leig. All rights reserved.
//

import Foundation

public class Tools {

    public init() {
    
    }
    
    // 随机数
    public func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    // 按最小值min和最大值max的范围取随机数
    public func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }

}
