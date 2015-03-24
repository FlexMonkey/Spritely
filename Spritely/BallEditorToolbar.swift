//
//  BallEditorToolbar.swift
//  Spritely
//
//  Created by Simon Gladman on 23/03/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import SpriteKit

class BallEditorToolbar: SKView
{
    var delegate:BallEditorToolbarDelegate?
    
    var selectedInstrument: ShapeNodeWithOrigin?
    {
        didSet
        {
            if let oldValue = oldValue
            {
                oldValue.fillColor = UIColor.clearColor()
            }
            
            if let selectedInstrument = selectedInstrument
            {
                selectedInstrument.fillColor = selectedInstrument.strokeColor
            }
        }
    }
    
    override func didMoveToSuperview()
    {
        backgroundColor = UIColor.redColor()
        
        presentScene(SKScene())
    }
    
    var ballsArray: [ShapeNodeWithOrigin] = [ShapeNodeWithOrigin]()
    {
        didSet
        {
            scene?.removeAllChildren()
            
            for ball in ballsArray
            {
                let xyz = ShapeNodeWithOrigin(path: ball.path)
                xyz.id = ball.id
                xyz.strokeColor = ball.strokeColor
                
                xyz.position = CGPoint(x: ball.startingPostion!.x, y: 25)
                
                scene?.addChild(xyz)
            }
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        let locationInView = touches.anyObject()?.locationInView(self)
        
        if let touchX = locationInView?.x
        {
            selectInstrumentAtLocation(touchX)
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent)
    {
        let locationInView = touches.anyObject()?.locationInView(self)
        
        if let selectedInstrument = selectedInstrument
        {
            if let touchX = locationInView?.x
            {
                selectedInstrument.position.x = touchX
                
                if let delegate = delegate
                {
                    delegate.instrumentBallMoved(instrumentId: selectedInstrument.id, newX: touchX)
                }
            }
            
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!)
    {
         selectedInstrument = nil
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent)
    {
         selectedInstrument = nil
    }
    
    func selectInstrumentAtLocation(touchX: CGFloat)
    {
        selectedInstrument = nil
        
        if let children = scene?.children
        {
            for node in children
            {
                if let node = (node as? ShapeNodeWithOrigin)
                {
                    if abs(node.position.x - touchX) < 20
                    {
                        selectedInstrument = (node as ShapeNodeWithOrigin)
                        
                        break
                    }
                }
            }
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        scene?.backgroundColor = UIColor.darkGrayColor()
        
        scene?.size = bounds.size
    }
}

protocol BallEditorToolbarDelegate
{
    func instrumentBallMoved(#instrumentId: String, newX: CGFloat)
}

