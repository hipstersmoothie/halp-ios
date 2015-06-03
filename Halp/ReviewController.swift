//
//  ReviewController.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/3/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class ReviewController: UIViewController, FloatRatingViewDelegate {
    @IBOutlet var submit: UIButton!
    @IBOutlet var metric1: FloatRatingView!
    @IBOutlet var metric1Label: UILabel!
    @IBOutlet var metric2: FloatRatingView!
    @IBOutlet var metric2Label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submit.backgroundColor = teal
        submit.layer.cornerRadius = 12
        submit.layer.borderWidth = 1
        submit.layer.borderColor = teal.CGColor
        submit.clipsToBounds = true
        
        metric1.floatRatings = false
        metric2.floatRatings = false
    }
    
    @IBAction func submitAction(sender: AnyObject) {
        if metric1.rating == 0 {
            createAlert(self, "Review not complete!", "Please provide a rating for \(metric1Label.text)")
        } else if metric2.rating == 0 {
            createAlert(self, "Review not complete!", "Please provide a rating for \(metric2Label.text)")
        } else {
            let ratings = [
                "friendliness" : Int(metric1.rating),
                "knowledge" : Int(metric2.rating)
            ] as Dictionary<String, Int>
            
            halpApi.postReview(ratings) { success, json in
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("toMap", sender: nil)
                    }
                } else {
                    println(json)
                }
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
