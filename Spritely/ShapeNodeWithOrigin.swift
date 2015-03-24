//
//  ShapeNodeWithOrigin.swift
//  Spritely
//
//  Created by Simon Gladman on 08/03/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import Foundation
import SpriteKit

class ShapeNodeWithOrigin: SKShapeNode
{
    var id = NSUUID().UUIDString
    
    var startingPostion: CGPoint?
    
    var instrument: Instruments = Instruments.mandolin
    {
        didSet
        {
            strokeColor = getColor()
        }
    }
    
    func getColor() -> UIColor
    {
        var returnColor: UIColor = UIColor.whiteColor()
        
        switch instrument
        {
        case Instruments.mandolin:
            returnColor = UIColor.magentaColor()
            
        case Instruments.marimba:
            returnColor = UIColor.yellowColor();
            
        case Instruments.vibes:
            returnColor = UIColor.cyanColor()
        }
        
        return returnColor
    }
}
