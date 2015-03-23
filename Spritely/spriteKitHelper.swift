//
//  SpriteKitHelper.swift
//  Spritely
//
//  Created by Simon Gladman on 23/03/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import SpriteKit

struct SpriteKitHelper
{
    static func createWalls(#view: UIView, scene: SKScene, floorCategoryBitMask: UInt32)
    {
        let leftWall = SKShapeNode(rectOfSize: CGSize(width: 2, height: view.frame.height))
        leftWall.position = CGPoint(x: -2, y: view.frame.height / 2)
        leftWall.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2, height: view.frame.height))
        leftWall.physicsBody?.dynamic = false
        scene.addChild(leftWall)
        
        let rightWall = SKShapeNode(rectOfSize: CGSize(width: 2, height: view.frame.height))
        rightWall.position = CGPoint(x: view.frame.width + 2, y: view.frame.height / 2)
        rightWall.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2, height: view.frame.height))
        rightWall.physicsBody?.dynamic = false
        scene.addChild(rightWall)
        
        let floor = SKShapeNode(rectOfSize: CGSize(width: view.frame.width, height: 2))
        floor.position = CGPoint(x: view.frame.width / 2, y: -2)
        floor.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: view.frame.width, height: 2))
        floor.physicsBody?.dynamic = false
        scene.addChild(floor)
        
        floor.physicsBody?.contactTestBitMask = 0b0001
        floor.physicsBody?.collisionBitMask =   0b0001
        floor.physicsBody?.categoryBitMask =   floorCategoryBitMask
    }
}