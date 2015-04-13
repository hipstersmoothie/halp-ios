//
//  chatController.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/2/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

var sessionStartTime:Int = 0
var sessionRate:Double = 0
var otherUserId:Int = 0

class BumpController: UIViewController {
    @IBOutlet var startSessionButton: UIButton!
    let halpApi = HalpAPI()
    var timer = NSTimer()
    var totTime = 0
    var interval:Int!
    var duration:Int!
    
    @IBAction func startSession(sender: AnyObject) {
        startSessionButton.setTitle("Waiting", forState: .Normal)
        halpApi.startSession(selectedTutor.user.userId) { success, json in
            println(json)
            if success == true {
                let complete = json["complete"].boolValue
                if complete == true {
                    println("mockaina")

                    sessionStartTime = json["startTimestamp"].intValue
                    sessionRate = json["rate"].doubleValue
                    otherUserId = selectedTutor.user.userId
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("toSessionCounter", sender: nil)
                    }
                } else {
                    self.pollStartedEndpoint(json["pollDuration"].intValue, interval: json["pollInterval"].intValue)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.startSessionButton.setTitle("Start!", forState: .Normal)
                }
                createAlert(self, "Couldn't Start Session!", json["code"].stringValue)
            }
        }
    }
    
    func pollStartedEndpoint(duration:Int, interval:Int) {
        self.duration = duration
        self.interval = interval
        dispatch_async(dispatch_get_main_queue()) {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("checkStarted"), userInfo: nil, repeats: true)
        }
    }
    
    func checkStarted() {
        var label = startSessionButton.titleLabel?.text
        startSessionButton.setTitle("\(label!).", forState: .Normal)
        halpApi.isSessionStarted(selectedTutor.user.userId) { success, json in
            println(json)
            if success == true {
                dispatch_async(dispatch_get_main_queue()) {
                    let complete = json["complete"].boolValue
                    if complete == true {
                        self.timer.invalidate()
                        sessionStartTime = json["startTimestamp"].intValue
                        sessionRate = selectedTutor.user.rate
                        otherUserId = selectedTutor.user.userId
                        self.performSegueWithIdentifier("toSessionCounter", sender: nil)
                        self.startSessionButton.titleLabel?.text = "Start!"
                    } else {
                        self.totTime += self.interval
                        if self.totTime > self.duration {
                            self.timer.invalidate()
                            self.startSessionButton.setTitle("Start!", forState: .Normal)
                        }
                    }
                }
            } else {
                self.timer.invalidate()
                self.startSessionButton.setTitle("Start!", forState: .Normal)
                println(json)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startSessionButton.backgroundColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1)
        startSessionButton.layer.cornerRadius = 12
        startSessionButton.layer.borderWidth = 1
        startSessionButton.layer.borderColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1).CGColor
        startSessionButton.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
