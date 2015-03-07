//
//  ViewController.swift
//  Spritely
//
//  Created by Simon Gladman on 05/03/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController, SKPhysicsContactDelegate
{
    let skView = SKView()
    
    let node = SKShapeNode(circleOfRadius: 20)
    let nodePhysicsBody = SKPhysicsBody(circleOfRadius: 20)

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.addSubview(skView)
        
        let scene = SKScene(size: view.bounds.size)
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
        

        let floor = SKShapeNode(rectOfSize: CGSize(width: 1000, height: 2))
        floor.position = CGPoint(x: 0, y: 10)
        floor.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 1000, height: 2))
        floor.physicsBody?.dynamic = false

        scene.addChild(floor)
        

        let box = SKShapeNode(rectOfSize: CGSize(width: 100, height: 2))
        box.position = CGPoint(x: view.frame.width / 2 - 50, y: 100)
        box.zRotation = 0.2
        box.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 100, height: 2))
        box.physicsBody?.dynamic = false
        
        scene.addChild(box)

        
        
        // node.glowWidth = 3
        node.position = CGPoint(x: view.frame.width / 2, y: view.frame.height)
        node.physicsBody = nodePhysicsBody
        
        scene.addChild(node)
        
        
        node.physicsBody?.contactTestBitMask = 0x1 << 1
        floor.physicsBody?.contactTestBitMask = 0x1 << 1
        // box.physicsBody?.contactTestBitMask = 0x1 << 2
        
        
        scene.physicsWorld.contactDelegate = self
        
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -2)
    }
    
    func didBeginContact(contact: SKPhysicsContact)
    {
        println("contact: \(contact.description) \(contact.bodyA.contactTestBitMask) \(contact.bodyB.contactTestBitMask)")
        
        if contact.bodyA.contactTestBitMask == contact.bodyB.contactTestBitMask
        {
            node.physicsBody = nil
            node.position = CGPoint(x: view.frame.width / 2, y: view.frame.height)
            node.physicsBody = nodePhysicsBody
        }
        
        
        if contact.bodyA == nodePhysicsBody
        {
            // contact.bodyA.node?.position = CGPoint(x: 0 , y: view.frame.height)
            // contact.bodyA.velocity = CGVector(dx: 0, dy: 0)
        }
        else
        {
            // contact.bodyB.node?.position = CGPoint(x: 0 , y: view.frame.height)
            // contact.bodyB.velocity = CGVector(dx: 0, dy: 0)
        }
        
    }
    

    override func viewDidLayoutSubviews()
    {
        skView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    }


}

