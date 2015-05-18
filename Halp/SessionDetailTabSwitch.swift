//
//  SessionDetailTabSwitch.swift
//  Halp
//
//  Created by Andrew Lisowski on 5/15/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

protocol SessionDetailDelegate {
    func switchTab(index:UInt)
}

class SessionDetailTabSwitch: UIViewController {
    @IBOutlet var schoolDetailsButton: UIButton!
    @IBOutlet var problemButton: UIButton!
    let gray = UIColor(red: 181/255, green: 183/255, blue: 183/255, alpha: 1)
    var delegate: SessionDetailDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self.childViewControllers[0] as? SessionDetailDelegate
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("switchTab:"), name: "SessionTabSwitch", object: nil)
        self.navigationItem.title = "Halp"
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
        self.delegate?.switchTab(0)
    }
    
    @IBAction func problemAction(sender: AnyObject) {
        schoolDetailsButton.setTitleColor(gray, forState: .Normal)
        problemButton.setTitleColor(teal, forState: .Normal)
        self.delegate?.switchTab(1)
    }
    
    func switchTab(notification: NSNotification) {
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
