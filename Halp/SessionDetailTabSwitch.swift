//
//  SessionDetailTabSwitch.swift
//  Halp
//
//  Created by Andrew Lisowski on 5/15/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class SessionDetailTabSwitch: UIViewController {
    @IBOutlet var schoolDetailsButton: UIButton!
    @IBOutlet var problemButton: UIButton!
    let teal = UIColor(red: 136/255, green: 205/255, blue: 202/255, alpha: 1)
    let gray = UIColor(red: 181/255, green: 183/255, blue: 183/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("switchTab:"), name: "SessionTabSwitch", object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "SessionTabSwitch", object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func schoolDetailsAction(sender: AnyObject) {
        schoolDetailsButton.setTitleColor(teal, forState: .Normal)
        problemButton.setTitleColor(gray, forState: .Normal)
        NSNotificationCenter.defaultCenter().postNotificationName("TabSwitch", object: "SchoolPicker", userInfo: nil)
    }
    
    @IBAction func problemAction(sender: AnyObject) {
        schoolDetailsButton.setTitleColor(gray, forState: .Normal)
        problemButton.setTitleColor(teal, forState: .Normal)
        NSNotificationCenter.defaultCenter().postNotificationName("TabSwitch", object: "MoreDetails", userInfo: nil)
    }
    
    func switchTab(notification: NSNotification) {
        println(notification)
        let string = notification.object as! String
        if(string == "SchoolPicker") {
            schoolDetailsButton.setTitleColor(teal, forState: .Normal)
            problemButton.setTitleColor(gray, forState: .Normal)
        } else {
            schoolDetailsButton.setTitleColor(gray, forState: .Normal)
            problemButton.setTitleColor(teal, forState: .Normal)
        }
    }
}
