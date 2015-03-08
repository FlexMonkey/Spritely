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
    var mandolin: Mandolin
    
    override init()
    {
        mandolin = InstrumentsCache.mandolins[InstrumentsCache.instrumentIndex++]
        
        super.init()
        
        userInteractionEnabled = true

        addChild(label)
    }

    required init?(coder aDecoder: NSCoder)
    {
        mandolin = InstrumentsCache.mandolins[InstrumentsCache.instrumentIndex++]
        
        super.init(coder: aDecoder)

        addChild(label)
    }
    
    var frequency: Double = 440
    {
        didSet
        {
            mandolin.mandolin.frequency.setValue(frequency, forKey: "value")
            
            label.text = "\(Int(frequency)) Hz"
            
            label.position = CGPoint(x: 0, y: 1 - label.frame.height / 2)
        }
    }

    

    func play()
    {
        mandolin.playForDuration(3.0);
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

struct InstrumentsCache
{
    static var instrumentIndex = 0
    
    static var mandolins = [Mandolin]()
}

protocol TouchEnabledShapeNodeDelegate
{
    func touchEnabledShapeNodeSelected(touchEnabledShapeNode: TouchEnabledShapeNode?)
}