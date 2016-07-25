//
//  ContainerController.swift
//  Telemetry
//
//  Created by IMAC  on 22.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

//
//  ContainerViewController.swift
//  GBU
//
//  Created by Agentum on 03.12.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ContainerViewController: BaseViewController, UIGestureRecognizerDelegate {
    
    let CENTER_EMBED_SEGUE_IDENTIFIER = "centerEmbedSegue"
    
    let CONTAINER_OFFSET_VALUE: CGFloat = 280.0
    let GESTURE_RECOGNIZER_SCOPE: CGFloat = 40.0
    
    @IBOutlet weak var darkAlphaView: UIView!
    @IBOutlet weak var centerContainer: UIView!
    @IBOutlet weak var leftContainer: UIView!
    
    @IBOutlet var leftLeadingContainerConstraint: NSLayoutConstraint!
    
    var gestureRecognizer = UIPanGestureRecognizer()
    weak var centerTabBarController: UITabBarController?
    
    //Block Central View when left panel is opened
    var leftPanelOpen = true{
        didSet{
            if(self.leftPanelOpen == true){
                self.setUserInteractionEnabledForTabBarControllers(false)
            } else {
                self.setUserInteractionEnabledForTabBarControllers(true)
            }
        }
    }
    var translation: CGPoint?
    var velocity: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApplicationState.sharedInstance().containerViewController = self
        setInitialState()
        
        
        let dAlphaView = darkAlphaView as! DarkAlphaView
        dAlphaView.centerContainer = centerContainer
        dAlphaView.leftContainer = leftContainer
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setObservers()
    }
    
    func setObservers(){
        self.leftLeadingContainerConstraint.addObserver(self, forKeyPath: "constant", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    func removeObservers(){
        self.leftLeadingContainerConstraint.removeObserver(self, forKeyPath: "constant")
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if(keyPath == "constant"){
            if let new = change?["new"] as? CGFloat{
                let alpha = (1 - fabs(new/CONTAINER_OFFSET_VALUE))*0.5
                darkAlphaView.alpha = CGFloat(round(Float(alpha)*Float(100.0))/Float(100.0))
                if(new == 0.0){
                    self.leftPanelOpen = false
                } else if(new == -CONTAINER_OFFSET_VALUE){
                    self.leftPanelOpen = true
                }
            }
        }
    }
    
    func setInitialState(){
        gestureRecognizer.delegate = self
        gestureRecognizer.addTarget(self, action: #selector(ContainerViewController.panRecognizerHandler(_:)))
        centerContainer.addGestureRecognizer(self.gestureRecognizer ?? UIGestureRecognizer())
    }
    
    func panRecognizerHandler(recognizer: UIPanGestureRecognizer){
        func deltaXFromPreviousPoint(point: CGPoint, toCurrent currentPoint: CGPoint) -> CGFloat{
            return currentPoint.x - point.x
        }
        
        if(gestureRecognizer.state == UIGestureRecognizerState.Began){
            translation = recognizer.locationInView(self.centerContainer)
            
        } else if(gestureRecognizer.state == UIGestureRecognizerState.Changed){
            
            let newTranslation = recognizer.locationInView(self.centerContainer)
            moveLeftPanelFromCurrentPositionToX(deltaXFromPreviousPoint(translation!, toCurrent: newTranslation))
            translation = newTranslation
            velocity = recognizer.velocityInView(self.centerContainer)
            
        } else if(gestureRecognizer.state == UIGestureRecognizerState.Ended){
            if let vel = velocity{
                if(vel.x > 0){
                    animatedLeftMoveViewToRightEdge()
                } else {
                    animatedLeftMoveViewToLeftEdge()
                }
            }
        }
    }
    
    func moveLeftPanelFromCurrentPositionToX(value: CGFloat){
        let newX = self.leftLeadingContainerConstraint.constant + value
        if(newX > -CONTAINER_OFFSET_VALUE && newX < 0){
            self.leftLeadingContainerConstraint.constant = newX
        } else{
            if(newX >= 0){
                self.leftLeadingContainerConstraint.constant = 0
            } else {
                self.leftLeadingContainerConstraint.constant = -CONTAINER_OFFSET_VALUE
            }
        }
    }
    
    func animatedLeftMoveViewToRightEdge(){
        animatedLeftPanelMoveToX(0.0)
        self.leftPanelOpen = true
    }
    
    func animatedLeftMoveViewToLeftEdge(){
        animatedLeftPanelMoveToX(-CONTAINER_OFFSET_VALUE)
        self.leftPanelOpen = false
    }
    
    func animatedLeftPanelMoveToX(value: CGFloat){
        UIView.setAnimationDuration(1.0)
        self.view.layoutIfNeeded()
        
        UIView.beginAnimations("move", context: nil)
        self.leftLeadingContainerConstraint.constant = value
        self.view.layoutIfNeeded()
        UIView.commitAnimations()
    }
    
    func setUserInteractionEnabledForTabBarControllers(value: Bool){
        if let tabBarViewControllers = self.centerTabBarController?.viewControllers{
            for vc in tabBarViewControllers{
                for(childController) in (vc as! UINavigationController).childViewControllers{
                    childController.view.userInteractionEnabled = value
                }
            }
        }
    }
    
    //MARK: -Gesture Recognizers Delegate
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        //It must be performed on the right edge of UIView
        if(leftPanelOpen){
            return true
        } else {
            let location = gestureRecognizer.locationInView(self.centerContainer)
            if(location.x < GESTURE_RECOGNIZER_SCOPE){
                return true
            } else {
                return false
            }
        }
    }
    
    //MARK: Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == CENTER_EMBED_SEGUE_IDENTIFIER){
            if let tabBarController =  segue.destinationViewController as? TabBarViewController{
                self.centerTabBarController = tabBarController
            }
        }
    }
    
    deinit{
        print("CONTAINER CONTROLLER DEINIT")
    }
}
