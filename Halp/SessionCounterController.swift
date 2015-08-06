//
//  SessionCounterController.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/2/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class SessionCounterController: UIViewController {
    @IBOutlet var cost: UILabel!
    @IBOutlet var rate: UILabel!
    @IBOutlet var time: UILabel!
    var timer = NSTimer()
    var totTime = 0
    var currentAlert:UIAlertController!
    
    @IBOutlet var hold: UIButton!
    override func viewDidLoad() {
       println(sessionRate)
        super.viewDidLoad()
        rate.text = "$\(sessionRate)/hour"
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("increment"), userInfo: nil, repeats: true)
        
        var btn_LongPress_gesture = UILongPressGestureRecognizer(target: self, action: "handleBtnLongPressgesture:")
        btn_LongPress_gesture.minimumPressDuration = 2.0;
        hold.addGestureRecognizer(btn_LongPress_gesture)
        styleButton(hold)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Details"
    }
    
    @IBAction func endAction(sender: AnyObject) {
        currentAlert = UIAlertController(title: "Do you want to end the session?", message: "The session has run for \(self.time.text!) and cost \(self.cost.text!)", preferredStyle: .Alert)
        currentAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            halpApi.endSession(self.totTime) { success, json in
                if success == true{
                    self.currentAlert = nil
                    self.endAlert()
                    self.timer.invalidate()
                } else {
                    createAlert(self, "Couldn't end session", "")
                }
            }
        }))
        self.presentViewController(currentAlert, animated: true, completion: nil)
    }
    
    func handleBtnLongPressgesture(gestureRecognizer:UIGestureRecognizer) {
        if gestureRecognizer.state == .Began {
            timer.invalidate()
            
            var storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var chat:ReviewController = storyboard.instantiateViewControllerWithIdentifier("review") as! ReviewController
            self.navigationController?.pushViewController(chat, animated: true)
        }
    }
    
    func increment() {
        println(totTime)
        ++totTime
        var seconds = totTime % 60
        var minutes = (totTime - seconds) / 60
        if seconds < 10 {
            time.text = "\(minutes):0\(seconds)"
        } else {
            time.text = "\(minutes):\(seconds)"
        }
        
        var price = Float(sessionRate)
        var timeF = Float(totTime)
        price =  (price / (60 * 60)) * timeF
        
        
        var str = NSString(format: "$%.2f", price)
        cost.text = str as String
        
        halpApi.hasSessionEnded() { success, json in
            if success == true {
                let complete = json["ended"].boolValue
                if complete == true {
                    self.endAlert()
                    self.timer.invalidate()
                }
            }
        }
    }
    
    func endAlert() {
        if(currentAlert != nil) {
            currentAlert.dismissViewControllerAnimated(true) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.currentAlert = UIAlertController(title: "Session has Ended", message: "The session ran for \(self.time.text!) and cost \(self.cost.text!)", preferredStyle: .Alert)
                    self.currentAlert.addAction(UIAlertAction(title: "Rate!", style: .Default, handler: { action in
                    if pinMode == "student" {
                        self.performSegueWithIdentifier("writeReviewForTutor", sender: self)
                    } else {
                        self.performSegueWithIdentifier("writeReviewForStudent", sender: self)
                    }
                    }))
                    self.presentViewController(self.currentAlert, animated: true, completion: nil)
                }
            }
        } else {
            self.currentAlert = UIAlertController(title: "Session has Ended", message: "The session ran for \(self.time.text!) and cost \(self.cost.text!)", preferredStyle: .Alert)
            self.currentAlert.addAction(UIAlertAction(title: "Rate!", style: .Default, handler: { action in
                if pinMode == "student" {
                    self.performSegueWithIdentifier("writeReviewForTutor", sender: self)
                } else {
                    self.performSegueWithIdentifier("writeReviewForStudent", sender: self)
                }
            }))
            self.presentViewController(self.currentAlert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
