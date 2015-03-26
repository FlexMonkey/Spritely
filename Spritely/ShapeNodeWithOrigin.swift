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
            let trianglePath = CGPathCreateMutable()
            
            let vertexOne = angleToPoint(90, radius: 20)
            CGPathMoveToPoint(trianglePath, nil, vertexOne.x, vertexOne.y)
            
            let vertexTwo = angleToPoint(210, radius: 20)
            CGPathAddLineToPoint(trianglePath, nil, vertexTwo.x, vertexTwo.y)

            let vertexThree = angleToPoint(330, radius: 20)
            CGPathAddLineToPoint(trianglePath, nil, vertexThree.x, vertexThree.y)
            
            CGPathCloseSubpath(trianglePath)
            
            path = trianglePath
        }
    }
    
    func angleToPoint(angleInDegrees: Float, radius: Float) -> CGPoint
    {
        let xx = (sin(angleInDegrees.toRadians()) * radius)
        let yy = (cos(angleInDegrees.toRadians()) * radius)
        
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
