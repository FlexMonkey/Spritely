//
//  ViewController.swift
//  Spritely
//
//  Created by Simon Gladman on 05/03/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController, SKPhysicsContactDelegate, TouchEnabledShapeNodeDelegate, UIGestureRecognizerDelegate
{
    let frequencies = [246.942, 261.626, 277.183, 293.665, 311.127, 329.628, 349.228, 369.994, 391.995, 415.305, 440.000, 466.164, 493.883, 523.251, 554.365, 587.330, 622.254, 659.255, 698.456, 739.989].sorted({$0 > $1})
    let minBoxLength: CGFloat = 100
    let maxBoxLength: CGFloat = 700
    
    let skView = SKView()
    var scene: SKScene!
    
    var panGestureOrigin: CGPoint?
    var rotateGestureAngleOrigin: CGFloat?
 
    let floorCategoryBitMask: UInt32 = 0b000001
    let ballCategoryBitMask: UInt32 = 0xb10001
    let boxCategoryBitMask: UInt32 = 0b001111
    
    let boxHeight = CGFloat(30)

    let longPressGestureRecogniser: UILongPressGestureRecognizer!
    
    override init()
    {
        super.init()
        
        longPressGestureRecogniser = UILongPressGestureRecognizer(target: {return self}(), action: "longPressHandler:")
    }

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        longPressGestureRecogniser = UILongPressGestureRecognizer(target: {return self}(), action: "longPressHandler:")
    }
    
    var selectedBox: TouchEnabledShapeNode?
    {
        didSet
        {
            if let previousSelection = oldValue
            {
                previousSelection.fillColor = UIColor.clearColor()
            }
            
            if let newSelection = selectedBox
            {
                newSelection.fillColor = UIColor.whiteColor()
                
                view.removeGestureRecognizer(longPressGestureRecogniser)
            }
            else
            {
                view.addGestureRecognizer(longPressGestureRecogniser)
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        view.addGestureRecognizer(longPressGestureRecogniser)
        
        let panGestureRecogniser = UIPanGestureRecognizer(target: self, action: "panHandler:")
        panGestureRecogniser.maximumNumberOfTouches = 1
        panGestureRecogniser.delegate = self
        view.addGestureRecognizer(panGestureRecogniser)
   
        let rotateGestureRecogniser = UIRotationGestureRecognizer(target: self, action: "rotateHandler:")
        rotateGestureRecogniser.delegate = self
        view.addGestureRecognizer(rotateGestureRecogniser)
        
        
        view.addSubview(skView)
        
        scene = SKScene(size: view.bounds.size)
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
        
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
        let actualWidth = max(min(width, maxBoxLength), minBoxLength)
        
        let box = TouchEnabledShapeNode(rectOfSize: CGSize(width: actualWidth, height: boxHeight))
        box.position = position
        box.zRotation = rotation
        box.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: actualWidth, height: boxHeight))
        box.physicsBody?.dynamic = false
        box.physicsBody?.restitution = 0.5
        box.delegate = self
        
        let frequencyIndex = Int(round((actualWidth - minBoxLength) / (maxBoxLength - minBoxLength) * CGFloat(frequencies.count - 1)))

        box.frequency = frequencies[frequencyIndex]
        
        box.physicsBody?.contactTestBitMask = 0b0010
        box.physicsBody?.collisionBitMask = 0b1111
        box.physicsBody?.categoryBitMask = boxCategoryBitMask
        
        scene.addChild(box)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }

    var creatingBox: SKShapeNode?
    
    func longPressHandler(recogniser: UILongPressGestureRecognizer)
    {
        // create a new ball on long press...
  
        if selectedBox == nil
        {
            if recogniser.state == UIGestureRecognizerState.Began
            {
                let invertedLocationInView = CGPoint(x: recogniser.locationInView(view).x,
                    y: view.frame.height - recogniser.locationInView(view).y)
                
                createBall(position: invertedLocationInView)
            }
        }
    }
    
    func panHandler(recogniser: UIPanGestureRecognizer)
    {
        // if there's no box selected, start drawing one, otherwise move selected box....
        
        if selectedBox != nil
        {
            if recogniser.state == UIGestureRecognizerState.Began
            {
                panGestureOrigin = recogniser.locationInView(view)
            }
            else if recogniser.state == UIGestureRecognizerState.Changed
            {
                let currentGestureLocation = recogniser.locationInView(view)
                
                selectedBox!.position.x += currentGestureLocation.x - panGestureOrigin!.x
                selectedBox!.position.y -= currentGestureLocation.y - panGestureOrigin!.y
                
                panGestureOrigin = recogniser.locationInView(view)
            }
            else
            {
                rotateGestureAngleOrigin = nil
                panGestureOrigin = nil
                selectedBox = nil
            }
        }
        else
        {
            if recogniser.state == UIGestureRecognizerState.Began
            {
                panGestureOrigin = CGPoint(x: recogniser.locationInView(view).x,
                    y: view.frame.height - recogniser.locationInView(view).y)
                
                creatingBox = SKShapeNode(rectOfSize: CGSize(width: boxHeight, height: boxHeight))
                creatingBox!.position = panGestureOrigin!
                
                scene.addChild(creatingBox!)
            }
            else if recogniser.state == UIGestureRecognizerState.Changed
            {
                creatingBox!.removeFromParent()
                
                let invertedLocationInView = CGPoint(x: recogniser.locationInView(view).x,
                    y: view.frame.height - recogniser.locationInView(view).y)
                
                let boxWidth = CGFloat(panGestureOrigin!.distance(invertedLocationInView)) * 2
                
                creatingBox = SKShapeNode(rectOfSize: CGSize(width: boxWidth, height: boxHeight))
                creatingBox!.position = panGestureOrigin!
                
                creatingBox!.zRotation = atan2(panGestureOrigin!.x - invertedLocationInView.x, invertedLocationInView.y - panGestureOrigin!.y) + CGFloat(M_PI / 2)
                
                scene.addChild(creatingBox!)
            }
            else
            {
                creatingBox?.removeFromParent()
                
                if panGestureOrigin != nil
                {
                    let invertedLocationInView = CGPoint(x: recogniser.locationInView(view).x,
                        y: view.frame.height - recogniser.locationInView(view).y)
                    
                    let boxWidth = CGFloat(panGestureOrigin!.distance(invertedLocationInView)) * 2
                    let boxRotation = creatingBox!.zRotation
                    
                    createBox(position: panGestureOrigin!, rotation: boxRotation, width: boxWidth)
                }
  
                panGestureOrigin = nil
                rotateGestureAngleOrigin = nil
            }
        }
        
        
    }

    func rotateHandler(recogniser: UIRotationGestureRecognizer)
    {
        if selectedBox != nil
        {
            if recogniser.state == UIGestureRecognizerState.Began
            {
                rotateGestureAngleOrigin = recogniser.rotation
            }
            else if recogniser.state == UIGestureRecognizerState.Changed
            {
                selectedBox?.zRotation += rotateGestureAngleOrigin! - recogniser.rotation
                
                rotateGestureAngleOrigin = recogniser.rotation
            }
            else
            {
                rotateGestureAngleOrigin = nil
                panGestureOrigin = nil
                selectedBox = nil
            }
        }
    }

    
    
    func touchEnabledShapeNodeSelected(touchEnabledShapeNode: TouchEnabledShapeNode?)
    {
        if panGestureOrigin == nil && rotateGestureAngleOrigin == nil
        {
            selectedBox = touchEnabledShapeNode
        }
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
    
    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }

    override func viewDidLayoutSubviews()
    {
        skView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    }


}

