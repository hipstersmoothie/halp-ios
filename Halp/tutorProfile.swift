//
//  tutorProfile.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/1/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class tutorProfile: UIViewController, FloatRatingViewDelegate, LGChatControllerDelegate {
    
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
    @IBAction func requestOrStart(sender: AnyObject) {
        if rOSButton.titleLabel?.text == "Request Session" {
            
        } else if rOSButton.titleLabel?.text == "Start Session" {
            launchChatController()
        }
    }
    
    @IBOutlet var rating: FloatRatingView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = selectedTutor.name
        rating.rating = selectedTutor.rating
        price.text = "$\(selectedTutor.pph)/hour"
        
        profilePic.image = selectedTutor.profilePic
        profilePic.layer.borderWidth=1.0
        profilePic.layer.masksToBounds = false
        profilePic.layer.borderColor = UIColor.whiteColor().CGColor
        profilePic.layer.cornerRadius = 13
        profilePic.layer.cornerRadius = profilePic.frame.size.height/2
        profilePic.clipsToBounds = true
        
        if selectedTutor.interestedInTutoringYou == true {
            rOSButton.setTitle("Start Session", forState: .Normal)
        }
                
        rOSButton.backgroundColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1)
        rOSButton.layer.cornerRadius = 12
        rOSButton.layer.borderWidth = 1
        rOSButton.layer.borderColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1).CGColor
        rOSButton.clipsToBounds = true
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
    
    
    // MARK: Launch Chat Controller
    
    func launchChatController() {
        let chatController = LGChatController()
        chatController.opponentImage = UIImage(named: "tutor.jpeg")
        chatController.title = "Chat"
        let helloWorld = LGChatMessage(content: "Hello World!", sentBy: .Opponent)
        chatController.messages = [helloWorld]
        chatController.delegate = self
        
        LGChatMessageCell.Appearance.opponentColor = UIColor.lightGrayColor()
        LGChatMessageCell.Appearance.userColor = UIColor(red: 45/255, green: 188/255, blue: 188/255, alpha: 1)
        
        self.navigationController?.pushViewController(chatController, animated: true)
    }
    
    // MARK: LGChatControllerDelegate
    
    func chatController(chatController: LGChatController, didAddNewMessage message: LGChatMessage) {
        println("Did Add Message: \(message.content)")
    }
    
    func shouldChatController(chatController: LGChatController, addMessage message: LGChatMessage) -> Bool {
        /*
        Use this space to prevent sending a message, or to alter a message.  For example, you might want to hold a message until its successfully uploaded to a server.
        */
        return true
    }
}

