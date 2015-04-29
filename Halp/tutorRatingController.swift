//
//  tutorRatingController.swift
//  Halp
//
//  Created by Andrew Lisowski on 4/29/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class tutorRatingController: UIViewController, FloatRatingViewDelegate {
    @IBOutlet var submit: UIButton!
    @IBOutlet var approval: FloatRatingView!
    let halpApi = HalpAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1)
        
        submit.backgroundColor = buttonColor
        submit.layer.cornerRadius = 12
        submit.layer.borderWidth = 1
        submit.layer.borderColor = buttonColor.CGColor
        submit.clipsToBounds = true
        
        approval.floatRatings = false
    }
    
    @IBAction func submitAction(sender: AnyObject) {
        let appVal = Int(approval.rating)
        let ratings = [
            "approval" : appVal,
        ] as Dictionary<String, Int>
            
        halpApi.postReview(ratings) { success, json in
            if success {
                self.performSegueWithIdentifier("toMap", sender: nil)
            } else {
                println(json)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Review"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        
    }
    
}
