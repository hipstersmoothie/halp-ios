//
//  tutorProfile.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/1/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class tutorProfile: UIViewController {
    
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var rating: UIImageView!
    @IBOutlet var price: UILabel!
    
    @IBOutlet var first: UIView!
    @IBOutlet var second: UIView!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBAction func indexChanged(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            first.hidden = false
            second.hidden = true
        case 1:
            first.hidden = true
            second.hidden = false
        default:
            break;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = selectedTutor.name
        setRating(rating, selectedTutor.rating)
        price.text = "$\(selectedTutor.pph)/hour"
        
        profilePic.image = selectedTutor.profilePic
        profilePic.layer.borderWidth=1.0
        profilePic.layer.masksToBounds = false
        profilePic.layer.borderColor = UIColor.whiteColor().CGColor
        profilePic.layer.cornerRadius = 13
        profilePic.layer.cornerRadius = profilePic.frame.size.height/2
        profilePic.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
