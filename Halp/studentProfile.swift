//
//  studentProfile.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/17/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

func loadProfilePic(profilePic:UIImageView, user:User) {
    if user.image != "" {
        let url = NSURL(string: user.image)
        let data = NSData(contentsOfURL: url!)
        profilePic.image = UIImage(data: data!)
    } else {
        profilePic.image = UIImage(named: "tutor.jpeg")
    }
    
    profilePic.layer.borderWidth=1.0
    profilePic.layer.masksToBounds = false
    profilePic.layer.borderColor = UIColor.whiteColor().CGColor
    profilePic.layer.cornerRadius = profilePic.frame.size.height/2
    profilePic.clipsToBounds = true
}

class studentProfile: UIViewController {
    @IBOutlet var name: UILabel!
    @IBOutlet var course: UILabel!
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var skills: UILabel!
    @IBOutlet var pinDesc: UITextView!
    @IBOutlet var rOSButton: UIButton!
    @IBOutlet var startSessionButton: UIButton!
    @IBAction func startChat(sender: AnyObject) {
        let chat = Chat(rootMessage: JSON([
            "otherUser" : [
                "userId" : selectedTutor.user.userId,
                "firstname" : "\(selectedTutor.user.firstname) \(selectedTutor.user.lastname[selectedTutor.user.lastname.startIndex])"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Name and Image
        name.text = "\(selectedTutor.user.firstname) \(selectedTutor.user.lastname[selectedTutor.user.lastname.startIndex])"
        loadProfilePic(profilePic, selectedTutor.user)
        
        // Course
        for (university, courseList) in selectedTutor.courses {
            for courseText in courseList {
                course.text = "\(courseText.subject) \(courseText.number)"
            }
        }
        
        skills.text = ", ".join(selectedTutor.skills)
        pinDesc.text = selectedTutor.pinDescription
        
        styleButton(rOSButton)
        styleButton(startSessionButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
