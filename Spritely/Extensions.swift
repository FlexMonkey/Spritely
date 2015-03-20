//
//  Extensions.swift
//  Spritely
//
//  Created by Simon Gladman on 07/03/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

extension CGPoint
{
    func distance(otherPoint: CGPoint) -> Float
    {
        let xSquare = Float((self.x - otherPoint.x) * (self.x - otherPoint.x))
        let ySquare = Float((self.y - otherPoint.y) * (self.y - otherPoint.y))
        
        return sqrt(xSquare + ySquare)
    }
}

extension Float
{
    func toRadians() -> Float
    {
        return self / Float(180.0 / M_PI)
    }
    
    func toDegrees() -> Float
    {
        return self * Float(180.0 / M_PI)
    }
}

extension SKShapeNode
{
    func pulse(#strokeColor: UIColor, fillColor: UIColor = UIColor.clearColor())
    {
        let newNode = SKShapeNode(path: self.path)
        
        newNode.strokeColor = strokeColor
        newNode.fillColor = fillColor
        newNode.position = position
        newNode.zRotation = zRotation
        
        scene?.addChild(newNode)
        
        let boundingBox = CGPathGetPathBoundingBox(self.path)
        let targetWidth = boundingBox.width + 50
        let targetHeight = boundingBox.height + 50
        let scaleX = targetWidth / boundingBox.width
        let scaleY = targetHeight / boundingBox.height
        
        let scaleAction = SKAction.scaleXTo(scaleX, y: scaleY , duration: 0.25)
        scaleAction.timingMode = SKActionTimingMode.EaseOut
        
        let fadeAction = SKAction.fadeAlphaTo(0, duration: 0.25)
        fadeAction.timingMode = SKActionTimingMode.EaseOut
        
        let actionGroup = SKAction.group([scaleAction, fadeAction])
        
        newNode.runAction(actionGroup, completion: { newNode.removeFromParent(); })
    }
}