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
    override func didMoveToSuperview()
    {
        backgroundColor = UIColor.redColor()
        
        presentScene(SKScene())
    }
    
    var ballsArray: [ShapeNodeWithOrigin] = [ShapeNodeWithOrigin]()
    {
        didSet
        {
            for ball in ballsArray
            {
               let xyz = ShapeNodeWithOrigin(path: ball.path)
                xyz.strokeColor = ball.strokeColor
                
                xyz.position = CGPoint(x: ball.startingPostion!.x, y: 25)
                
                scene?.addChild(xyz)
            }
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        scene?.backgroundColor = UIColor.darkGrayColor()
        
        scene?.size = bounds.size; println("size = \(bounds.size)")
    }
}


