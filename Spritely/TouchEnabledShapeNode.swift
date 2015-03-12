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
        if zRotation > CGFloat(M_PI * 0.25) && zRotation < CGFloat(M_PI * 1.5)
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