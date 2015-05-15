//
//  SchoolPicker.swift
//  Halp
//
//  Created by Andrew Lisowski on 5/14/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class MoreDetails: UIViewController, XLPagerTabStripChildItem {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    NSNotificationCenter.defaultCenter().postNotificationName("SessionTabSwitch", object: "MoreDetails", userInfo: nil)
    }
    
    func titleForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> String! {
        return "what's the problem?";
    }
    
    func colorForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> UIColor! {
        return UIColor(red: 136/255, green: 205/255, blue: 202/255, alpha: 1)
    }
}
