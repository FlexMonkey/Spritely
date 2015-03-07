//
//  ViewController.swift
//  Spritely
//
//  Created by Simon Gladman on 05/03/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController, SKPhysicsContactDelegate, TouchEnabledShapeNodeDelegate
{
    let skView = SKView()
 
    let floorCategoryBitMask: UInt32 =  0b000001
    let ballCategoryBitMask: UInt32 =   0xb10001
    let boxCategoryBitMask: UInt32 =    0b001111
    
    let node = SKShapeNode(circleOfRadius: 20)
    let nodePhysicsBody = SKPhysicsBody(circleOfRadius: 20)
    
    let node2 = SKShapeNode(circleOfRadius: 20)
    let nodePhysicsBody2 = SKPhysicsBody(circleOfRadius: 20)

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let panHandler = UIPanGestureRecognizer(target: self, action: "panHandler:")
        view.addGestureRecognizer(panHandler)
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: "tapHandler:")
        view.addGestureRecognizer(tapGestureRecogniser)
        
        let rotateGestureRecogniser = UIRotationGestureRecognizer(target: self, action: "rotateHandler:")
        view.addGestureRecognizer(rotateGestureRecogniser)
        
        view.addSubview(skView)
        
        let scene = SKScene(size: view.bounds.size)
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
        

        let floor = SKShapeNode(rectOfSize: CGSize(width: 2000, height: 2))
        floor.position = CGPoint(x: 0, y: -20)
        floor.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2000, height: 2))
        floor.physicsBody?.dynamic = false

        scene.addChild(floor)
        

        let box = TouchEnabledShapeNode(rectOfSize: CGSize(width: 100, height: 20))
        box.position = CGPoint(x: view.frame.width / 2 - 20, y: 100)
        box.zRotation = 0.1
        box.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 100, height: 20))
        box.physicsBody?.dynamic = false
        box.physicsBody?.restitution = 0.5
        box.delegate = self
   
        scene.addChild(box)

        node.position = CGPoint(x: view.frame.width / 2 - 10, y: view.frame.height)
        node.physicsBody = nodePhysicsBody
        
        scene.addChild(node)
        
        node2.position = CGPoint(x: view.frame.width / 2, y: view.frame.height - 50)
        node2.physicsBody = nodePhysicsBody2
        
        scene.addChild(node2)
        
        let ballCategoryBitMask: Int = 0xb10001
        
        node.physicsBody?.contactTestBitMask =  0b0001
        node2.physicsBody?.contactTestBitMask =  0b0001
        floor.physicsBody?.contactTestBitMask = 0b0001
        box.physicsBody?.contactTestBitMask =   0b0010
        
        node.physicsBody?.collisionBitMask =    0b1000
        node2.physicsBody?.collisionBitMask =   0b0100
        floor.physicsBody?.collisionBitMask =   0b0001
        box.physicsBody?.collisionBitMask =     0b1111
        
        node.physicsBody?.categoryBitMask =    0b1000 | 0xb10001
        node2.physicsBody?.categoryBitMask =   0b0100 | 0xb10001
        floor.physicsBody?.categoryBitMask =   floorCategoryBitMask
        box.physicsBody?.categoryBitMask =     boxCategoryBitMask
        
        scene.physicsWorld.contactDelegate = self
        
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -2)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        let touch = touches.anyObject() as UITouch

        // println("touch began \(touch.locationInView(view)) " )
    }
    
    func panHandler(recogniser: UIPanGestureRecognizer)
    {
        // if there's no box selected, start drawing one, otherwise move selected box....
        
        println("panning! \(recogniser.locationInView(self.view))")
    }
    
    func tapHandler(recogniser: UITapGestureRecognizer)
    {
        //println("tap \(recogniser.locationInView(self.view))")
    }
    
    func rotateHandler(recogniser: UIRotationGestureRecognizer)
    {
        //println(" \(recogniser.locationInView(self.view))   \(recogniser.rotation) ")
    }

    func touchEnabledShapeNodeSelected(touchEnabledShapeNode: TouchEnabledShapeNode?)
    {
        println("\(touchEnabledShapeNode) is selected!")
    }

    func didBeginContact(contact: SKPhysicsContact)
    {
        var physicsBodyToReposition: SKPhysicsBody?
   
        // play a tone based on velocity (amplitude) and are (frequency) if either body is a box...
        
        if contact.bodyA.categoryBitMask == boxCategoryBitMask
        {
            println("bing!!! \(contact.bodyB.velocity.dy) \(contact.bodyA.area)")
        }
        else if contact.bodyB.categoryBitMask == boxCategoryBitMask
        {
            println("bing! \(contact.bodyA.velocity.dy) \(contact.bodyB.area)")
        }
        
        // wrap around body if other body is floor....
        
        if contact.bodyA.categoryBitMask & ballCategoryBitMask == ballCategoryBitMask && contact.bodyB.categoryBitMask == floorCategoryBitMask
        {
            physicsBodyToReposition = contact.bodyA
        }
        else if contact.bodyB.categoryBitMask & ballCategoryBitMask == ballCategoryBitMask && contact.bodyA.categoryBitMask == floorCategoryBitMask
        {
            physicsBodyToReposition = contact.bodyB
        }
        
        if let physicsBodyToReposition = physicsBodyToReposition
        {
            let nodeToReposition = physicsBodyToReposition.node
            let nodeX: CGFloat = nodeToReposition?.position.x ?? 0
            
            nodeToReposition?.physicsBody = nil
            nodeToReposition?.position = CGPoint(x: nodeX, y: view.frame.height)
            nodeToReposition?.physicsBody = physicsBodyToReposition
        }
        
    }
    

    override func viewDidLayoutSubviews()
    {
        skView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    }


}

