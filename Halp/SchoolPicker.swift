//
//  SchoolPicker.swift
//  Halp
//
//  Created by Andrew Lisowski on 5/14/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class SchoolPicker: UIViewController, XLPagerTabStripChildItem {
    @IBOutlet var nextButton: UIButton!
    let teal = UIColor(red: 136/255, green: 205/255, blue: 202/255, alpha: 1)
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.backgroundColor = teal
        nextButton.layer.cornerRadius = 12
        nextButton.layer.borderWidth = 1
        nextButton.layer.borderColor = teal.CGColor
        nextButton.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func titleForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> String! {
        return "school details";
    }

    func colorForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> UIColor! {
        return teal
    }
    
}
