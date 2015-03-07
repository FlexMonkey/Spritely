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
    override init()
    {
        super.init()
        
        userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        fillColor = UIColor.whiteColor()
        
        userInteractionEnabled = true
    }
    
    var delegate: TouchEnabledShapeNodeDelegate?
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        fillColor = UIColor.whiteColor()

        if let delegate = delegate
        {
            delegate.touchEnabledShapeNodeSelected(self)
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!)
    {
        fillColor = UIColor.clearColor()
        
        if let delegate = delegate
        {
            delegate.touchEnabledShapeNodeSelected(nil)
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent)
    {
        fillColor = UIColor.clearColor()
        
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