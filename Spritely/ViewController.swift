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
    var scene: SKScene!
    
    var panGestureOrigin: CGPoint?
    var selectedBox: TouchEnabledShapeNode?
 
    let floorCategoryBitMask: UInt32 = 0b000001
    let ballCategoryBitMask: UInt32 = 0xb10001
    let boxCategoryBitMask: UInt32 = 0b001111

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self, action: "longPressHandler:")
        view.addGestureRecognizer(longPressGestureRecogniser)
        
        let panGestureRecogniser = UIPanGestureRecognizer(target: self, action: "panHandler:")
        view.addGestureRecognizer(panGestureRecogniser)
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: "tapHandler:")
        view.addGestureRecognizer(tapGestureRecogniser)
        
        let rotateGestureRecogniser = UIRotationGestureRecognizer(target: self, action: "rotateHandler:")
        view.addGestureRecognizer(rotateGestureRecogniser)
        
        view.addSubview(skView)
        
        scene = SKScene(size: view.bounds.size)
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
        
        let leftWall = SKShapeNode(rectOfSize: CGSize(width: 2, height: 2000))
        leftWall.position = CGPoint(x: 0, y: 0)
        leftWall.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2, height: 2000))
        leftWall.physicsBody?.dynamic = false
        
        scene.addChild(leftWall)

        let rightWall = SKShapeNode(rectOfSize: CGSize(width: 2, height: 2000))
        rightWall.position = CGPoint(x: view.frame.width - 2, y: 0)
        rightWall.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2, height: 2000))
        rightWall.physicsBody?.dynamic = false
        
        scene.addChild(rightWall)
        
        
        let floor = SKShapeNode(rectOfSize: CGSize(width: 2000, height: 2))
        floor.position = CGPoint(x: 0, y: -20)
        floor.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2000, height: 2))
        floor.physicsBody?.dynamic = false

        scene.addChild(floor)
        
        createBox(position: CGPoint(x: view.frame.width / 2 - 20, y: 100), rotation: 100, width: 100)

        floor.physicsBody?.contactTestBitMask = 0b0001
        floor.physicsBody?.collisionBitMask =   0b0001
        floor.physicsBody?.categoryBitMask =   floorCategoryBitMask

        scene.physicsWorld.contactDelegate = self
        
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -2)
    }
    
    func createBall(#position: CGPoint)
    {
        let node = SKShapeNode(circleOfRadius: 20)
        let nodePhysicsBody = SKPhysicsBody(circleOfRadius: 20)
        
        node.position = position
        node.physicsBody = nodePhysicsBody
        
        node.physicsBody?.contactTestBitMask = 0b0001
        node.physicsBody?.collisionBitMask = 0b1000
        node.physicsBody?.categoryBitMask =  ballCategoryBitMask

        scene.addChild(node)
    }
    
    func createBox(#position: CGPoint, rotation: CGFloat, width: CGFloat)
    {
        let box = TouchEnabledShapeNode(rectOfSize: CGSize(width: width, height: 20))
        box.position = position
        box.zRotation = rotation
        box.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: width, height: 20))
        box.physicsBody?.dynamic = false
        box.physicsBody?.restitution = 0.5
        box.delegate = self
        
        box.physicsBody?.contactTestBitMask = 0b0010
        box.physicsBody?.collisionBitMask = 0b1111
        box.physicsBody?.categoryBitMask = boxCategoryBitMask
        
        scene.addChild(box)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        let touch = touches.anyObject() as UITouch

        // println("touch began \(touch.locationInView(view)) " )
    }
    
    var creatingBox: SKShapeNode?
    
    func longPressHandler(recogniser: UILongPressGestureRecognizer)
    {
        // create a new ball on long press...
        
        if recogniser.state == UIGestureRecognizerState.Began
        {
            let invertedLocationInView = CGPoint(x: recogniser.locationInView(view).x,
                y: view.frame.height - recogniser.locationInView(view).y)
            
            createBall(position: invertedLocationInView)
        }
    }
    
    func panHandler(recogniser: UIPanGestureRecognizer)
    {
        // if there's no box selected, start drawing one, otherwise move selected box....
        
        if let _ = selectedBox
        {
            if recogniser.state == UIGestureRecognizerState.Began
            {
                panGestureOrigin = recogniser.locationInView(view)
            }
            else if recogniser.state == UIGestureRecognizerState.Changed
            {
                let currentGestureLocation = recogniser.locationInView(view)
                
                selectedBox?.position.x += currentGestureLocation.x - panGestureOrigin!.x
                selectedBox?.position.y -= currentGestureLocation.y - panGestureOrigin!.y
                
                panGestureOrigin = recogniser.locationInView(view)
            }
            else
            {
                selectedBox = nil
                panGestureOrigin = nil
            }
        }
        else
        {
            if recogniser.state == UIGestureRecognizerState.Began
            {
                panGestureOrigin = CGPoint(x: recogniser.locationInView(view).x,
                    y: view.frame.height - recogniser.locationInView(view).y)
                
                creatingBox = SKShapeNode(rectOfSize: CGSize(width: 20, height: 20))
                creatingBox!.position = panGestureOrigin!
                
                scene.addChild(creatingBox!)
            }
            else if recogniser.state == UIGestureRecognizerState.Changed
            {
                creatingBox!.removeFromParent()
                
                let invertedLocationInView = CGPoint(x: recogniser.locationInView(view).x,
                    y: view.frame.height - recogniser.locationInView(view).y)
                
                let boxWidth = CGFloat(panGestureOrigin!.distance(invertedLocationInView)) * 2
                
                creatingBox = SKShapeNode(rectOfSize: CGSize(width: boxWidth, height: 20))
                creatingBox!.position = panGestureOrigin!
                
                creatingBox!.zRotation = atan2(panGestureOrigin!.x - invertedLocationInView.x, invertedLocationInView.y - panGestureOrigin!.y) + CGFloat(M_PI / 2)
                
                scene.addChild(creatingBox!)
            }
            else
            {
                let invertedLocationInView = CGPoint(x: recogniser.locationInView(view).x,
                    y: view.frame.height - recogniser.locationInView(view).y)
                
                let boxWidth = CGFloat(panGestureOrigin!.distance(invertedLocationInView)) * 2
                let boxRotation = creatingBox!.zRotation
                
                createBox(position: panGestureOrigin!, rotation: boxRotation, width: boxWidth)
                
                creatingBox!.removeFromParent()
            }
        }
        
        
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
        selectedBox = touchEnabledShapeNode
        
        println("\(touchEnabledShapeNode) is selected!")
    }

    func didBeginContact(contact: SKPhysicsContact)
    {
        var physicsBodyToReposition: SKPhysicsBody?
   
        // play a tone based on velocity (amplitude) and are (frequency) if either body is a box...
        
        if contact.bodyA.categoryBitMask == boxCategoryBitMask
        {
            // println("bing!!! \(contact.bodyB.velocity.dy) \(contact.bodyA.area)")
        }
        else if contact.bodyB.categoryBitMask == boxCategoryBitMask
        {
            // println("bong! \(contact.bodyA.velocity.dy) \(contact.bodyB.area)")
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

