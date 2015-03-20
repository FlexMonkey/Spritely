//
//  TouchEnabledShapeNode.swift
//  Spritely
//
//  Created by Simon Gladman on 07/03/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import SpriteKit

class TouchEnabledShapeNode: SKShapeNode
{
    var delegate: TouchEnabledShapeNodeDelegate?
    private let label = SKLabelNode(text: "Hello!")
    
    override init()
    {
        super.init()
        
        userInteractionEnabled = true

        addChild(label)
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)

        addChild(label)
    }
    
    var frequency: Float = 440
    {
        didSet
        {
            label.text = "\(Int(frequency)) Hz"
            setLabelRotation()
        }
    }
    
    var selected: Bool = false
    {
        didSet
        {
            fillColor = selected ? UIColor.whiteColor() : UIColor.clearColor()
            label.fontColor = selected ? UIColor.blackColor() : UIColor.whiteColor()
        }
    }

    func displayCollision(#strokeColor: UIColor, fillColor: UIColor = UIColor.clearColor())
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
    
    func animatedRemoveFromParent()
    {
        displayCollision(strokeColor: UIColor.lightGrayColor(), fillColor: UIColor.darkGrayColor())
        
        super.removeFromParent()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        if let delegate = delegate
        {
            delegate.touchEnabledShapeNodeSelected(self)
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!)
    {
        if let delegate = delegate
        {
            delegate.touchEnabledShapeNodeSelected(nil)
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent)
    {
        if let delegate = delegate
        {
            delegate.touchEnabledShapeNodeSelected(nil)
        }
    }
    

    override var zRotation: CGFloat
    {
        didSet
        {
            super.zRotation = zRotation
            
            setLabelRotation()
        }
    }

    private func setLabelRotation()
    {
        if ((zRotation > CGFloat(M_PI * 0.5) && zRotation < CGFloat(M_PI * 1.5))) ||
            ((zRotation < 0 - CGFloat(M_PI * 0.5) && zRotation > 0 - CGFloat(M_PI * 1.5)))
        {
            label.zRotation = CGFloat(M_PI)
            label.position = CGPoint(x: 0, y: 0 + label.frame.height / 2)
        }
        else
        {
            label.zRotation = 0
            label.position = CGPoint(x: 0, y: 1 - label.frame.height / 2)
        }
    }
    
}


protocol TouchEnabledShapeNodeDelegate
{
    func touchEnabledShapeNodeSelected(touchEnabledShapeNode: TouchEnabledShapeNode?)
}