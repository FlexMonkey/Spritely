//
//  ViewController.swift
//  Spritely
//
//  Created by Simon Gladman on 05/03/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.

import UIKit
import SpriteKit

class ViewController: UIViewController, SKPhysicsContactDelegate, TouchEnabledShapeNodeDelegate, UIGestureRecognizerDelegate
{
    let frequencies: [Float] = [130.813, 138.591, 146.832, 155.563, 164.814, 174.614, 184.997, 195.998, 207.652, 220, 233.082, 246.942, 261.626, 277.183, 293.665, 311.127, 329.628, 349.228, 369.994, 391.995, 415.305, 440.000, 466.164, 493.883, 523.251, 554.365, 587.330, 622.254, 659.255, 698.456, 739.989, 783.991, 830.609, 880, 932.328, 987.767 ].sorted({$0 > $1})
    
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
    let conductor = Conductor()
    
    let newInstrumentAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    override init()
    {
        super.init()
        
        createNewInstrumentActionSheet()
        
        longPressGestureRecogniser = UILongPressGestureRecognizer(target: {return self}(), action: "longPressHandler:")
    }

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        createNewInstrumentActionSheet()
        
        longPressGestureRecogniser = UILongPressGestureRecognizer(target: {return self}(), action: "longPressHandler:")
    }
    
    func createNewInstrumentActionSheet()
    {
        for instrument in [Instruments.vibes, Instruments.marimba, Instruments.mandolin]
        {
            let instrumentAction = UIAlertAction(title: instrument.rawValue, style: UIAlertActionStyle.Default, handler: assignInstrumentToBall)
            
            newInstrumentAlertController.addAction(instrumentAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: cancelBallCreation)
        
        newInstrumentAlertController.addAction(cancelAction)
    }
    
    var selectedBox: TouchEnabledShapeNode?
    {
        didSet
        {
            if let previousSelection = oldValue
            {
                previousSelection.selected = false
            }
            
            if let newSelection = selectedBox
            {
                newSelection.selected = true
                
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
        
        floor.physicsBody?.contactTestBitMask = 0b0001
        floor.physicsBody?.collisionBitMask =   0b0001
        floor.physicsBody?.categoryBitMask =   floorCategoryBitMask
        
        createBox(position: CGPoint(x: view.frame.width / 2 - 20, y: 100), rotation: 100, width: 100)
        //createBall(position: CGPoint(x: view.frame.width / 2, y: view.frame.height))

        scene.physicsWorld.contactDelegate = self
        
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -2)
    }
    
    var newBallNode: ShapeNodeWithOrigin?
    
    func createBall(#position: CGPoint)
    {
        newBallNode = ShapeNodeWithOrigin(circleOfRadius: 20)

        newBallNode?.position = position
        newBallNode?.startingPostion = position
        
        scene.addChild(newBallNode!)
        
        let newInstrumentAlertPosition = CGPoint(x: position.x - 20, y: view.frame.height - position.y - 20)
        
        newInstrumentAlertController.popoverPresentationController?.sourceRect = CGRect(x: newInstrumentAlertPosition.x, y: newInstrumentAlertPosition.y, width: 40, height: 40)
        
        newInstrumentAlertController.popoverPresentationController?.sourceView = self.view
        
        presentViewController(newInstrumentAlertController, animated: true, completion: nil)
    }
    
    func assignInstrumentToBall(value : UIAlertAction!) -> Void
    {
        if let newBallNode = newBallNode
        {
            let nodePhysicsBody = SKPhysicsBody(circleOfRadius: 20)
            
            newBallNode.instrument = Instruments(rawValue: value.title)
            
            newBallNode.physicsBody = nodePhysicsBody
            
            newBallNode.physicsBody?.contactTestBitMask = 0b0001
            newBallNode.physicsBody?.collisionBitMask = 0b1000
            newBallNode.physicsBody?.categoryBitMask =  ballCategoryBitMask
        }
    }
    
    func cancelBallCreation(value : UIAlertAction!) -> Void
    {
        newBallNode?.removeFromParent()
        newBallNode = nil
    }
    

    func createBox(#position: CGPoint, rotation: CGFloat, width: CGFloat) -> TouchEnabledShapeNode
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
        
        return box
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }

    var creatingBox: TouchEnabledShapeNode?
    
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
                
                creatingBox = createBox(position: panGestureOrigin!, rotation: 0, width: boxHeight)
            }
            else if recogniser.state == UIGestureRecognizerState.Changed
            {
                creatingBox!.removeFromParent()
                
                let invertedLocationInView = CGPoint(x: recogniser.locationInView(view).x,
                    y: view.frame.height - recogniser.locationInView(view).y)
                
                let boxWidth = CGFloat(panGestureOrigin!.distance(invertedLocationInView)) * 2
                
                let boxRotation = atan2(panGestureOrigin!.x - invertedLocationInView.x, invertedLocationInView.y - panGestureOrigin!.y) + CGFloat(M_PI / 2)
                
                creatingBox = createBox(position: panGestureOrigin!, rotation: boxRotation, width: boxWidth)
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
        
        var box: TouchEnabledShapeNode?
        var ball: ShapeNodeWithOrigin?
        
        if contact.bodyA.categoryBitMask == boxCategoryBitMask
        {
            box = (contact.bodyA.node as? TouchEnabledShapeNode)
            ball = (contact.bodyB.node as? ShapeNodeWithOrigin)
        }
        else if contact.bodyB.categoryBitMask == boxCategoryBitMask
        {
            box = (contact.bodyB.node as? TouchEnabledShapeNode)
            ball = (contact.bodyA.node as? ShapeNodeWithOrigin)
        }
        
        if let box = box
        {
            if let ball = ball
            {
                let ballPhysicsBody = ball.physicsBody!
                
                let amplitude = Float(sqrt((ballPhysicsBody.velocity.dx * ballPhysicsBody.velocity.dx) + (ballPhysicsBody.velocity.dy * ballPhysicsBody.velocity.dy)) / 1500)
                
                let frequency = box.frequency
                
                if let instrument = ball.instrument
                {
                    conductor.play(frequency, amplitude: amplitude, instrument: instrument)
                    
                    box.displayCollision(ball.getColor())
                }
            }
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
            let nodeX: CGFloat = (nodeToReposition as? ShapeNodeWithOrigin)?.startingPostion?.x ?? 0
            
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

