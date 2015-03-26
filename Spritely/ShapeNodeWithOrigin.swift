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
            
            path = getPath()
        }
    }
    
    func getPath() -> CGPath
    {
        var returnPath: CGPath!
        
        switch instrument
        {
        case Instruments.vibes:
            returnPath = CGPathCreateWithRect(CGRect(x: -20, y: -20, width: 40, height: 40), nil)
            
        case Instruments.marimba:
            returnPath = CGPathCreateWithEllipseInRect(CGRect(x: -20, y: -20, width: 40, height: 40), nil)
            
        case Instruments.mandolin:
            returnPath = CGMutablePathRef.equilateralTriangleOfRadius(20)
        }
        
        return returnPath
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
