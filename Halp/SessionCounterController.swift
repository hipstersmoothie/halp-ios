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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rate.text = "$\(selectedTutor.pph)/hour"
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("increment"), userInfo: nil, repeats: true)
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
