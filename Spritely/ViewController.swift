//
//  ViewController.swift
//  Spritely
//
//  Created by Simon Gladman on 05/03/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.

import UIKit
import SpriteKit

class ViewController: UIViewController, SKPhysicsContactDelegate, BarShapeNodeDelegate, UIGestureRecognizerDelegate, InstrumentsToolbarDelegate
{
    let frequencies: [Float] = [130.813, 138.591, 146.832, 155.563, 164.814, 174.614, 184.997, 195.998, 207.652, 220, 233.082, 246.942, 261.626, 277.183, 293.665, 311.127, 329.628, 349.228, 369.994, 391.995, 415.305, 440.000, 466.164, 493.883, 523.251, 554.365, 587.330, 622.254, 659.255, 698.456, 739.989, 783.991, 830.609, 880, 932.328, 987.767 ].sorted({$0 > $1})
    
    let minBarLength: CGFloat = 100
    let maxBarLength: CGFloat = 700
    let barHeight = CGFloat(30)
    
    let skView = SKView()
    var scene = SKScene()
    
    var panGestureOrigin: CGPoint?
    var rotateGestureAngleOrigin: CGFloat?
 
    let floorCategoryBitMask: UInt32 = 0b000001
    let instrumentCategoryBitMask: UInt32 = 0xb10001
    let barCategoryBitMask: UInt32 = 0b001111
    
    let longPressGestureRecogniser: UILongPressGestureRecognizer!
    let conductor = Conductor()
    
    let newInstrumentAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    let instrumentsToolbar = InstrumentsToolbar(frame: CGRectZero)
    var newInstrumentShapeNode: InstrumentShapeNode?
    var transientCreatingBar: BarShapeNode?
    
    let rollingWaveformPlot = AKAudioOutputRollingWaveformPlot()
    
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
    
    var selectedBar: BarShapeNode?
    {
        didSet
        {
            if let previousSelection = oldValue
            {
                previousSelection.selected = false
            }
            
            if let newSelection = selectedBar
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
        
        AKManager.addBinding(rollingWaveformPlot)
        view.addSubview(rollingWaveformPlot)

        skView.addGestureRecognizer(longPressGestureRecogniser)
        
        let panGestureRecogniser = UIPanGestureRecognizer(target: self, action: "panHandler:")
        panGestureRecogniser.maximumNumberOfTouches = 1
        panGestureRecogniser.delegate = self
        skView.addGestureRecognizer(panGestureRecogniser)
   
        let rotateGestureRecogniser = UIRotationGestureRecognizer(target: self, action: "rotateHandler:")
        rotateGestureRecogniser.delegate = self
        skView.addGestureRecognizer(rotateGestureRecogniser)

        skView.alpha = 0.95
        view.addSubview(skView)

        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
        
        SpriteKitHelper.createWalls(view: view, scene: scene, floorCategoryBitMask: floorCategoryBitMask)
        
        createBarShapeNode(position: CGPoint(x: view.frame.width / 2 - 20, y: 100), rotation: 100, width: 100)
        //createBall(position: CGPoint(x: view.frame.width / 2, y: view.frame.height))

        scene.physicsWorld.contactDelegate = self
        
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -2)
        
        instrumentsToolbar.delegate = self
        view.addSubview(instrumentsToolbar)
    }
    
    func createInstrumentShapeNode(#position: CGPoint)
    {
        transientCreatingBar?.removeFromParent()
        
        newInstrumentShapeNode = InstrumentShapeNode(rectOfSize: CGSize(width: 40, height: 40), cornerRadius: 10)
        newInstrumentShapeNode?.alpha = 0.5

        newInstrumentShapeNode?.position = position
        newInstrumentShapeNode?.startingPostion = position
        
        scene.addChild(newInstrumentShapeNode!)
        
        let newInstrumentAlertPosition = CGPoint(x: position.x - 20, y: view.frame.height - position.y - 20)
        
        newInstrumentAlertController.popoverPresentationController?.sourceRect = CGRect(x: newInstrumentAlertPosition.x, y: newInstrumentAlertPosition.y, width: 40, height: 40)
        
        newInstrumentAlertController.popoverPresentationController?.sourceView = self.view
        
        presentViewController(newInstrumentAlertController, animated: true, completion: nil)
    }
    
    func assignInstrumentToBall(value : UIAlertAction!) -> Void
    {
        if let newInstrumentShapeNode = newInstrumentShapeNode
        {
            newInstrumentShapeNode.instrument = Instruments(rawValue: value.title) ?? Instruments.mandolin
            
            // TODO: move this stuff into instument code :)
            
            let nodePhysicsBody = SKPhysicsBody(polygonFromPath: newInstrumentShapeNode.path)
            
            newInstrumentShapeNode.physicsBody = nodePhysicsBody
            
            newInstrumentShapeNode.physicsBody?.contactTestBitMask = 0b0001
            newInstrumentShapeNode.physicsBody?.collisionBitMask = 0b1000
            newInstrumentShapeNode.physicsBody?.categoryBitMask =  instrumentCategoryBitMask
            
            newInstrumentShapeNode.alpha = 1
            
            populateToolbar()
        }
    }
    
    func instrumentShapeNodeDeleted(instrumentId id: String)
    {
        if let instrumentShapeNode = getInstrumentShapeNodeById(id)
        {
            instrumentShapeNode.animatedRemoveFromParent()
        }
    }
    
    func instrumentShapeNodeMoved(instrumentId id: String, newX: CGFloat)
    {
        if let instrumentShapeNode = getInstrumentShapeNodeById(id)
        {
            instrumentShapeNode.startingPostion?.x = newX // add starting position invalid flag to grey out during this run
        }
    }
    
    func getInstrumentShapeNodeById(id: String) -> InstrumentShapeNode?
    {
        return scene.children.filter({ $0 is InstrumentShapeNode && ($0 as InstrumentShapeNode).id == id })[0] as? InstrumentShapeNode
    }
    
    func populateToolbar()
    {
        instrumentsToolbar.instrumentShapeNodes = scene.children.filter({ $0 is InstrumentShapeNode }) as [InstrumentShapeNode]
    }
    
    func cancelBallCreation(value : UIAlertAction!) -> Void
    {
        newInstrumentShapeNode?.removeFromParent()
        newInstrumentShapeNode = nil
    }
    

    func createBarShapeNode(#position: CGPoint, rotation: CGFloat, width: CGFloat) -> BarShapeNode
    {
        let actualWidth = max(min(width, maxBarLength), minBarLength)
        
        let barShapeNode = BarShapeNode(rectOfSize: CGSize(width: actualWidth, height: barHeight))
        barShapeNode.position = position
        barShapeNode.zRotation = rotation
        barShapeNode.physicsBody = SKPhysicsBody(polygonFromPath: barShapeNode.path)
        barShapeNode.physicsBody?.dynamic = false
        barShapeNode.physicsBody?.restitution = 0.5
        barShapeNode.delegate = self
        
        let frequencyIndex = Int(round((actualWidth - minBarLength) / (maxBarLength - minBarLength) * CGFloat(frequencies.count - 1)))

        barShapeNode.frequency = frequencies[frequencyIndex]
        
        barShapeNode.physicsBody?.contactTestBitMask = 0b0010
        barShapeNode.physicsBody?.collisionBitMask = 0b1111
        barShapeNode.physicsBody?.categoryBitMask = barCategoryBitMask
        
        scene.addChild(barShapeNode)
        
        return barShapeNode
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    func longPressHandler(recogniser: UILongPressGestureRecognizer)
    {
        // create a new instrument on long press...
  
        if selectedBar == nil
        {
            if recogniser.state == UIGestureRecognizerState.Began
            {
                let invertedLocationInView = CGPoint(x: recogniser.locationInView(view).x,
                    y: view.frame.height - recogniser.locationInView(view).y)
                
                createInstrumentShapeNode(position: invertedLocationInView)
            }
        }
    }
    
    func panHandler(recogniser: UIPanGestureRecognizer)
    {
        // if there's no box selected, start drawing one, otherwise move selected box....
        
        if let selectedBar = selectedBar
        {
            let currentGestureLocation = recogniser.locationInView(view)
            
            if recogniser.state == UIGestureRecognizerState.Began
            {
                panGestureOrigin = currentGestureLocation
            }
            else if recogniser.state == UIGestureRecognizerState.Changed
            {
                selectedBar.position.x += currentGestureLocation.x - panGestureOrigin!.x
                selectedBar.position.y -= currentGestureLocation.y - panGestureOrigin!.y
                
                selectedBar.alpha = (currentGestureLocation.x < 50 || currentGestureLocation.x > view.frame.width - 50) ? 0.25 : 1
                
                panGestureOrigin = recogniser.locationInView(view)
            }
            else
            {
                if currentGestureLocation.x < 50 || currentGestureLocation.x > view.frame.width - 50
                {
                    selectedBar.animatedRemoveFromParent()
                }
                
                rotateGestureAngleOrigin = nil
                panGestureOrigin = nil
                unselectBar()
            }
        }
        else
        {
            if recogniser.state == UIGestureRecognizerState.Began
            {
                panGestureOrigin = CGPoint(x: recogniser.locationInView(view).x,
                    y: view.frame.height - recogniser.locationInView(view).y)
                
                transientCreatingBar = createBarShapeNode(position: panGestureOrigin!, rotation: 0, width: barHeight)
            }
            else if recogniser.state == UIGestureRecognizerState.Changed
            {
                transientCreatingBar!.removeFromParent()
                
                let invertedLocationInView = CGPoint(x: recogniser.locationInView(view).x,
                    y: view.frame.height - recogniser.locationInView(view).y)
                
                let boxWidth = CGFloat(panGestureOrigin!.distance(invertedLocationInView)) * 2
                
                let boxRotation = atan2(panGestureOrigin!.x - invertedLocationInView.x, invertedLocationInView.y - panGestureOrigin!.y) + CGFloat(M_PI / 2)
                
                transientCreatingBar = createBarShapeNode(position: panGestureOrigin!, rotation: boxRotation, width: boxWidth)
                
                transientCreatingBar?.alpha = (boxWidth > minBarLength / 2) ? 1.0 : 0.5
            }
            else
            {
                transientCreatingBar?.removeFromParent()
                
                if panGestureOrigin != nil
                {
                    let invertedLocationInView = CGPoint(x: recogniser.locationInView(view).x,
                        y: view.frame.height - recogniser.locationInView(view).y)
                    
                    let boxWidth = CGFloat(panGestureOrigin!.distance(invertedLocationInView)) * 2
                    let boxRotation = transientCreatingBar!.zRotation
                    
                    if boxWidth > minBarLength / 2
                    {
                        createBarShapeNode(position: panGestureOrigin!, rotation: boxRotation, width: boxWidth)
                    }
                }
  
                panGestureOrigin = nil
                rotateGestureAngleOrigin = nil
            }
        }
    }

    func unselectBar()
    {
        selectedBar = nil
    }
    
    func rotateHandler(recogniser: UIRotationGestureRecognizer)
    {
        if selectedBar != nil
        {
            if recogniser.state == UIGestureRecognizerState.Began
            {
                rotateGestureAngleOrigin = recogniser.rotation
            }
            else if recogniser.state == UIGestureRecognizerState.Changed
            {
                selectedBar?.zRotation += rotateGestureAngleOrigin! - recogniser.rotation
                
                rotateGestureAngleOrigin = recogniser.rotation
            }
            else
            {
                rotateGestureAngleOrigin = nil
                panGestureOrigin = nil
                selectedBar = nil
            }
        }
    }

    
    
    func barShapeNodeSelected(barShapeNode: BarShapeNode?)
    {
        if panGestureOrigin == nil && rotateGestureAngleOrigin == nil
        {
            selectedBar = barShapeNode
        }
    }

    func didBeginContact(contact: SKPhysicsContact)
    {
        var physicsBodyToReposition: SKPhysicsBody?
   
        // play a tone based on velocity (amplitude) and are (frequency) if either body is a box...
        
        var barShapeNode: BarShapeNode?
        var instrumentShapeNode: InstrumentShapeNode?
        
        if contact.bodyA.categoryBitMask == barCategoryBitMask
        {
            barShapeNode = (contact.bodyA.node as? BarShapeNode)
            instrumentShapeNode = (contact.bodyB.node as? InstrumentShapeNode)
        }
        else if contact.bodyB.categoryBitMask == barCategoryBitMask
        {
            barShapeNode = (contact.bodyB.node as? BarShapeNode)
            instrumentShapeNode = (contact.bodyA.node as? InstrumentShapeNode)
        }
        
        if let barShapeNode = barShapeNode
        {
            if let instrumentShapeNode = instrumentShapeNode
            {
                let instrumentPhysicsBody = instrumentShapeNode.physicsBody!
                
                let amplitude = Float(sqrt((instrumentPhysicsBody.velocity.dx * instrumentPhysicsBody.velocity.dx) + (instrumentPhysicsBody.velocity.dy * instrumentPhysicsBody.velocity.dy)) / 1500)
                
                conductor.play(frequency: barShapeNode.frequency, amplitude: amplitude, instrument: instrumentShapeNode.instrument)
                
                barShapeNode.pulse(strokeColor: instrumentShapeNode.getColor())
            }
        }
        
        // wrap around body if other body is floor....
        
        if contact.bodyA.categoryBitMask & instrumentCategoryBitMask == instrumentCategoryBitMask && contact.bodyB.categoryBitMask == floorCategoryBitMask
        {
            physicsBodyToReposition = contact.bodyA
        }
        else if contact.bodyB.categoryBitMask & instrumentCategoryBitMask == instrumentCategoryBitMask && contact.bodyA.categoryBitMask == floorCategoryBitMask
        {
            physicsBodyToReposition = contact.bodyB
        }
        
        if let physicsBodyToReposition = physicsBodyToReposition
        {
            let nodeToReposition = physicsBodyToReposition.node
            let nodeX: CGFloat = (nodeToReposition as? InstrumentShapeNode)?.startingPostion?.x ?? 0
            
            nodeToReposition?.physicsBody = nil
            nodeToReposition?.position = CGPoint(x: nodeX, y: view.frame.height)
            nodeToReposition?.zRotation = 0
            nodeToReposition?.physicsBody = physicsBodyToReposition
        }
        
    }
    
    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }

    override func viewDidLayoutSubviews()
    {
        let topMargin = topLayoutGuide.length
        let toolbarHeight: CGFloat = 50
        let sceneHeight = view.frame.height - topMargin - toolbarHeight

        skView.frame = CGRect(x: 0, y: topMargin + toolbarHeight, width: view.frame.width, height: sceneHeight)
        scene.size = CGSize(width: view.frame.width, height: sceneHeight)

        rollingWaveformPlot.frame = CGRect(x: 0, y: topMargin + toolbarHeight, width: view.frame.width, height: sceneHeight)
        
        instrumentsToolbar.frame = CGRect(x: 0, y: topMargin, width: view.frame.width, height: toolbarHeight)
    }


}

