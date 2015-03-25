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
        presentScene(SKScene())
    }
    
    var ballsArray: [ShapeNodeWithOrigin] = [ShapeNodeWithOrigin]()
    {
        didSet
        {
            scene?.removeAllChildren()
            
            for ball in ballsArray
            {
                let newBall = ShapeNodeWithOrigin(path: ball.path)
                newBall.id = ball.id
                newBall.strokeColor = ball.strokeColor
                
                newBall.position = CGPoint(x: ball.startingPostion!.x, y: frame.height / 2 )
                
                scene?.addChild(newBall)
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
                
                selectedInstrument.alpha = (touchX < 50 || touchX > frame.width - 50) ? 0.25 : 1
                
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
        let locationInView = touches.anyObject()?.locationInView(self)
        
        if locationInView?.x < 50 || locationInView?.x > frame.width - 50
        {
            if let delegate = delegate
            {
                delegate.instrumentBallDeleted(instrumentId: selectedInstrument!.id)
            }
            
            selectedInstrument?.animatedRemoveFromParent()
        }
        
         selectedInstrument = nil
    }
    

    
    func selectInstrumentAtLocation(touchX: CGFloat)
    {
        selectedInstrument = nil
        
        let children = scene?.children.filter({ $0 is ShapeNodeWithOrigin }) as [ShapeNodeWithOrigin]
        
        for node in children
        {
            if abs(node.position.x - touchX) < 20
            {
                selectedInstrument = (node as ShapeNodeWithOrigin)
                
                break
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
    
    func instrumentBallDeleted(#instrumentId: String)
}

