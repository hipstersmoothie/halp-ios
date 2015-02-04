//
//  ReviewController.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/3/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class ReviewController: UIViewController {
    @IBOutlet var reviewSpace: UITextView!
    @IBOutlet var submit: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        reviewSpace.layer.borderWidth = 1
        reviewSpace.layer.cornerRadius = 9
        reviewSpace.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        let buttonColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1)
        
        submit.backgroundColor = buttonColor
        submit.layer.cornerRadius = 12
        submit.layer.borderWidth = 1
        submit.layer.borderColor = buttonColor.CGColor
        submit.clipsToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Review"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
