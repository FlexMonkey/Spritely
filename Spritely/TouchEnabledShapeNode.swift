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
    
    var frequency: Double = 0
    {
        didSet
        {
            label.text = "\(Int(frequency)) Hz"
            
            label.position = CGPoint(x: 0, y: 1 - label.frame.height / 2)
        }
    }

    var delegate: TouchEnabledShapeNodeDelegate?
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        if let delegate = delegate
        {
            delegate.touchEnabledShapeNodeSelected(self)
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!)
    {
        println("touchesCancelled")
        
        if let delegate = delegate
        {
            delegate.touchEnabledShapeNodeSelected(nil)
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent)
    {
        println("touchesEnded")
        
        if let delegate = delegate
        {
            delegate.touchEnabledShapeNodeSelected(nil)
        }
    }
    
}

protocol TouchEnabledShapeNodeDelegate
{
    func touchEnabledShapeNodeSelected(touchEnabledShapeNode: TouchEnabledShapeNode?)
}