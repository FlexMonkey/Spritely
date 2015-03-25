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
            
            assignPath()
        }
    }
    
    func assignPath()
    {
        switch instrument
        {
        case Instruments.mandolin:
            path = CGPathCreateWithRect(CGRect(x: -20, y: -20, width: 40, height: 40), nil)
            
        case Instruments.marimba:
            path = CGPathCreateWithEllipseInRect(CGRect(x: -20, y: -20, width: 40, height: 40), nil)
            
        case Instruments.vibes:
            let xyz = CGPathCreateMutable()
            
            let vertexOne = angleToPoint(0, radius: 20)
            CGPathMoveToPoint(xyz, nil, vertexOne.x, vertexOne.y)
            
            let vertexTwo = angleToPoint(120, radius: 20)
            CGPathAddLineToPoint(xyz, nil, vertexTwo.x, vertexTwo.y)

            let vertexThree = angleToPoint(240, radius: 20)
            CGPathAddLineToPoint(xyz, nil, vertexThree.x, vertexThree.y)
            
            CGPathCloseSubpath(xyz)
            
            path = xyz
        }
    }
    
    func angleToPoint(angleInDegrees: Float, radius: Float) -> CGPoint
    {
        let returnPoint = CGPointZero
        
        let xx = (sin(angleInDegrees.toRadians()) * radius)
        let yy = (cos(angleInDegrees.toRadians()) * radius) - sqrt(radius)
        
        return CGPoint(x: CGFloat(xx), y: CGFloat(yy))
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
