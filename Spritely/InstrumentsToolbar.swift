//
//  InstrumentsToolbar.swift (was BallEditorToolbar.swift)
//  Spritely
//
//  Created by Simon Gladman on 23/03/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import SpriteKit

class InstrumentsToolbar: SKView
{
    var delegate:InstrumentsToolbarDelegate?
    
    var selectedInstrumentShapeNode: InstrumentShapeNode?
    {
        didSet
        {
            if let oldValue = oldValue
            {
                oldValue.fillColor = UIColor.clearColor()
            }
            
            if let selectedInstrumentShapeNode = selectedInstrumentShapeNode
            {
                selectedInstrumentShapeNode.fillColor = selectedInstrumentShapeNode.strokeColor
            }
        }
    }
    
    override func didMoveToSuperview()
    {
        presentScene(SKScene())
    }
    
    var instrumentShapeNodes: [InstrumentShapeNode] = [InstrumentShapeNode]()
    {
        didSet
        {
            scene?.removeAllChildren()
            
            for instrumentShape in instrumentShapeNodes
            {
                let newInstrumentShape = InstrumentShapeNode(path: instrumentShape.path!)
                newInstrumentShape.id = instrumentShape.id
                newInstrumentShape.strokeColor = instrumentShape.strokeColor
                
                newInstrumentShape.position = CGPoint(x: instrumentShape.startingPostion!.x, y: frame.height / 2 )
                
                scene?.addChild(newInstrumentShape)
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        let locationInView:CGPoint? = touches.first!.locationInView(self)
        
        if let touchX = locationInView?.x
        {
            selectInstrumentAtLocation(touchX)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        let locationInView:CGPoint? = touches.first!.locationInView(self)
        
        if let selectedInstrumentShapeNode = selectedInstrumentShapeNode
        {
            if let touchX = locationInView?.x
            {
                selectedInstrumentShapeNode.position.x = touchX
                
                selectedInstrumentShapeNode.alpha = (touchX < 50 || touchX > frame.width - 50) ? 0.25 : 1
                
                if let delegate = delegate
                {
                    delegate.instrumentShapeNodeMoved(instrumentId: selectedInstrumentShapeNode.id, newX: touchX)
                }
            }
            
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?)
    {
         selectedInstrumentShapeNode = nil
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        let locationInView:CGPoint? = touches.first!.locationInView(self)
        
        if locationInView?.x < 50 || locationInView?.x > frame.width - 50
        {
            if let delegate = delegate
            {
                delegate.instrumentShapeNodeDeleted(instrumentId: selectedInstrumentShapeNode!.id)
            }
            
            selectedInstrumentShapeNode?.animatedRemoveFromParent()
        }
        
         selectedInstrumentShapeNode = nil
    }
    

    
    func selectInstrumentAtLocation(touchX: CGFloat)
    {
        selectedInstrumentShapeNode = nil
        
        let children = scene?.children.filter({ $0 is InstrumentShapeNode }) as! [InstrumentShapeNode]
        
        for node in children
        {
            if abs(node.position.x - touchX) < 20
            {
                selectedInstrumentShapeNode = (node as InstrumentShapeNode)
                
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

protocol InstrumentsToolbarDelegate
{
    func instrumentShapeNodeMoved(instrumentId instrumentId: String, newX: CGFloat)
    
    func instrumentShapeNodeDeleted(instrumentId instrumentId: String)
}

