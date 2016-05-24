//
//  ViewController.swift
//  Breakout
//
//  Created by Ryan Barrett on 5/20/16.
//  Copyright © 2016 Ryan Barrett. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    
    private var animator: UIDynamicAnimator!
    private var gravity: UIGravityBehavior!
    private var collision: UICollisionBehavior!
    
    //private var bricks = [UIView]()
    private var speed = 0.5
    
    private var numBricks = 10
    private var brick:UIView?
    private var bricks = [Int:UIView]()
    
    private var bricksRemoved = Int()
    
    private var ball:UIView?
    
    private var paddle:UIView?
    
    private var doneCall = true
    
    private var ballExists = Bool()
    
    let panRec = UIPanGestureRecognizer()
    let tapRec = UITapGestureRecognizer()

    
    
    lazy var dynamicItemBehavior:UIDynamicItemBehavior = {
        let lazyBehavior = UIDynamicItemBehavior()
        lazyBehavior.elasticity = 1.0
        lazyBehavior.allowsRotation = false
        lazyBehavior.friction = 0.0
        lazyBehavior.resistance = 0.0
        
        return lazyBehavior
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ballExists = false
        
        collision = UICollisionBehavior()
        collision.collisionDelegate = self
        animator = UIDynamicAnimator(referenceView: view)
        
        addViewBoundaries()
        addPaddle()
        panRec.addTarget(self, action: "draggedView:")
        paddle!.addGestureRecognizer(panRec)
        paddle!.userInteractionEnabled = true
        
        tapRec.addTarget(self, action: "tappedView")
        self.view.addGestureRecognizer(tapRec)
        
        startGame()

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tappedView(){
        if ballExists {
            if ball!.frame.origin.x > self.view.frame.maxX || ball!.frame.origin.x < self.view.frame.minX || ball!.frame.origin.y > self.view.frame.maxY || ball!.frame.origin.y < self.view.frame.minY {
                ballExists = false
                addBall()
            }
            else {
                let push = UIPushBehavior(items: [ball!], mode: .Instantaneous)
                push.magnitude = CGFloat(speed+0.2)
                
                push.angle = CGFloat(Double(arc4random_uniform(100)) * M_PI * 2 / 100.0)
                animator.addBehavior(push)
            }
        }
        else {
            addBall()
        }
    }
    
    
    func draggedView(sender:UIPanGestureRecognizer){
        self.view!.bringSubviewToFront(sender.view!)
        let translation = sender.translationInView(self.view)
        
        sender.view!.center = CGPointMake(sender.view!.center.x + translation.x, sender.view!.center.y)
        sender.setTranslation(CGPointZero, inView: self.view)
        
        collision.removeBoundaryWithIdentifier("paddle")
        collision.addBoundaryWithIdentifier("paddle", forPath: UIBezierPath(rect: sender.view!.frame))
        animator.addBehavior(collision)
    }
    
    
    private func startGame() {
        
        bricksRemoved = 0
        addBricks()

    }
    
    
    func collisionBehavior(behavior: UICollisionBehavior!, beganContactForItem item: UIDynamicItem!, withBoundaryIdentifier identifier: NSCopying!, atPoint p: CGPoint) {
        print("Boundary contact occurred- \(identifier)")
        
        if let num = identifier as? Int{
            collision.removeBoundaryWithIdentifier(num)
            UIView.animateWithDuration(1, animations: {
                self.bricks[num]!.alpha = 0
                }) { _ in
                    self.bricks[num]!.removeFromSuperview()
                    self.bricksRemoved += 1
            }
            
        }
        if doneCall {
            checkIfFinished()
        }
        
    }
    
    private func addBricks() {
        let width = 30
        let yCoord = 30
        
        
        
        for i in 0...numBricks {
            brick = UIView(frame: CGRect(x: (10 + width*i + 5*i), y: yCoord, width: width, height: 10))
            //brick = UIView(frame: CGRect(x: 0, y: self.view.frame.minY + 20.0, width: self.view.frame.maxX, height: 10))
            brick!.backgroundColor = UIColor.redColor()
            view.addSubview(brick!)
            
            collision.addBoundaryWithIdentifier(i, forPath: UIBezierPath(rect: brick!.frame))
            animator.addBehavior(collision)
            
            bricks[i] = brick!
        }
    }
    
    private func addViewBoundaries() {
        //add view boundaries except for bottom of screen
        let lowerLeft = CGPointMake(self.view.frame.minX, self.view.frame.maxY)
        let upperLeft = CGPointMake(self.view.frame.minX, self.view.frame.minY)
        let upperRight = CGPointMake(self.view.frame.maxX, self.view.frame.minY)
        let lowerRight = CGPointMake(self.view.frame.maxX, self.view.frame.maxY)
        
        
        
        collision.addBoundaryWithIdentifier("left", fromPoint: lowerLeft, toPoint: upperLeft)
        collision.addBoundaryWithIdentifier("right", fromPoint: lowerRight, toPoint: upperRight)
        collision.addBoundaryWithIdentifier("top", fromPoint: upperLeft, toPoint: upperRight)
        animator.addBehavior(collision)
    }
    
    private func addPaddle() {
        //add paddle
        paddle = UIView(frame: CGRect(x: self.view.frame.maxX/3.0, y: self.view.frame.maxY - 40.0, width: 150, height: 25))
        //paddle = UIView(frame: CGRect(x: 0, y: self.view.frame.maxY - 20.0, width: self.view.frame.maxX, height: 10))
        paddle!.backgroundColor = UIColor.greenColor()
        view.addSubview(paddle!)
        
        collision.addBoundaryWithIdentifier("paddle", forPath: UIBezierPath(rect: paddle!.frame))
        animator.addBehavior(collision)
    }
    
    private func addBall() {
        //add ball
        ball = UIView(frame:CGRect(x: self.view.frame.maxX/2.0, y: self.view.frame.maxY/2.0, width: 30, height: 30))
        ball!.layer.cornerRadius = ball!.frame.size.width/2
        ball!.layer.masksToBounds = true
        
        ball!.backgroundColor = UIColor.blackColor()
        
        
        view.addSubview(ball!)
        collision.addItem(ball!)
        
        animator.addBehavior(dynamicItemBehavior)
        dynamicItemBehavior.addItem(ball!)
        
        let push = UIPushBehavior(items: [ball!], mode: .Instantaneous)
        push.magnitude = CGFloat(speed)
        
        push.angle = CGFloat(Double(arc4random_uniform(100)) * M_PI * 2 / 100.0)
        animator.addBehavior(push)
        
        ballExists = true
    }
    
    private func removeBall() {
        collision.removeItem(ball!)
        ball!.removeFromSuperview()
        ballExists = false
    }
    
    private func checkIfFinished() {
        doneCall = false
        if bricksRemoved >= (numBricks+1) {
            
            removeBall()
            
            let winMessage = UIAlertController(title: "You won!", message: "", preferredStyle: .Alert)
            winMessage.addAction(UIAlertAction(title: "Play Again", style: .Default, handler: { (action) in
                self.startGame()
                self.doneCall = true
            }))
            presentViewController(winMessage, animated: true, completion: nil)
        }
        else {
            doneCall = true
        }
    }


}

