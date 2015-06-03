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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        styleButton(submit)
        approval.floatRatings = false
    }
    
    @IBAction func submitAction(sender: AnyObject) {
        let appVal = Int(approval.rating)
        let ratings = [
            "approval" : appVal == 1 ? appVal : -1,
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
