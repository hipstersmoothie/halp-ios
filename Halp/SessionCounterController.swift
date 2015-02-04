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
    
    @IBOutlet var hold: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        rate.text = "$\(selectedTutor.pph)/hour"
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("increment"), userInfo: nil, repeats: true)
        
        var btn_LongPress_gesture = UILongPressGestureRecognizer(target: self, action: "handleBtnLongPressgesture:")
        btn_LongPress_gesture.minimumPressDuration = 2.0;
        hold.addGestureRecognizer(btn_LongPress_gesture)
        
        let buttonColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1)
        
        hold.backgroundColor = buttonColor
        hold.layer.cornerRadius = 12
        hold.layer.borderWidth = 1
        hold.layer.borderColor = buttonColor.CGColor
        hold.clipsToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Details"
    }
    
    func handleBtnLongPressgesture(gestureRecognizer:UIGestureRecognizer) {
        if gestureRecognizer.state == .Began {
            timer.invalidate()
            
            var storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var chat:ReviewController = storyboard.instantiateViewControllerWithIdentifier("review") as ReviewController
            self.navigationController?.pushViewController(chat, animated: true)
        }
    }
    
    func increment() {
        ++totTime
        var seconds = totTime % 60
        var minutes = (totTime - seconds) / 60
        if seconds < 10 {
            time.text = "\(minutes):0\(seconds)"
        } else {
            time.text = "\(minutes):\(seconds)"
        }
        
        var price = Float(selectedTutor.pph)
        var timeF = Float(totTime)
        price =  (price / (60 * 60)) * timeF
        
        
        var str = NSString(format: "$%.2f", price)
        cost.text = str
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
