//
//  tutorProfile.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/1/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class tutorProfile: UIViewController, FloatRatingViewDelegate {
    
    @IBOutlet var profilePic: UIImageView!
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
    
    @IBOutlet var rOSButton: UIButton!
    @IBOutlet var startSessionButton: UIButton!
    @IBAction func requestOrStart(sender: AnyObject) {
        let chat = Chat(rootMessage: JSON([
            "otherUser" : [
                "userId" : selectedTutor.user.userId,
                "firstname" : selectedTutor.user.firstname
            ],
            "lastMessage": [
                "body" : "",
                "timestamp" :  NSDate().timeIntervalSince1970
            ],
            "unreadMessages" : 0
        ]))
            
        let chatViewController = ConversationViewController(chat: chat)
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    @IBOutlet var rating: FloatRatingView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = selectedTutor.user.firstname
        rating.rating = selectedTutor.user.rating
        var rateString = NSString(format:"%.2f", selectedTutor.user.rate)
        price.text = "$\(rateString)/hour"
        
        if selectedTutor.user.image != "" {
            profilePic.image = UIImage(named: selectedTutor.user.image)
        } else {
            profilePic.image = UIImage(named: "tutor.jpeg")
        }
        
        profilePic.layer.borderWidth=1.0
        profilePic.layer.masksToBounds = false
        profilePic.layer.borderColor = UIColor.whiteColor().CGColor
        profilePic.layer.cornerRadius = 13
        profilePic.layer.cornerRadius = profilePic.frame.size.height/2
        profilePic.clipsToBounds = true
        
        rOSButton.backgroundColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1)
        rOSButton.layer.cornerRadius = 12
        rOSButton.layer.borderWidth = 1
        rOSButton.layer.borderColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1).CGColor
        rOSButton.clipsToBounds = true
        
        startSessionButton.backgroundColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1)
        startSessionButton.layer.cornerRadius = 12
        startSessionButton.layer.borderWidth = 1
        startSessionButton.layer.borderColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1).CGColor
        startSessionButton.clipsToBounds = true
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

