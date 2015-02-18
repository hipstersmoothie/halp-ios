//
//  studentProfile.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/17/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class studentProfile: UIViewController {
    @IBOutlet var name: UILabel!
    @IBOutlet var course: UILabel!
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var skills: UILabel!
    @IBOutlet var pinDesc: UITextView!
    @IBOutlet var rOSButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Name and Image
        name.text = selectedTutor.user.firstname
        if selectedTutor.user.image != "" {
            profilePic.image = UIImage(named: selectedTutor.user.image)
        } else {
            profilePic.image = UIImage(named: "tutor.jpeg")
        }
        
        // Course
        for (university, courseList) in selectedTutor.courses {
            for courseText in courseList {
                course.text = "\(courseText.subject) \(courseText.number)"
            }
        }
        
        //Skills
        var skillsArr = ""
        for var i = 0; i < selectedTutor.skills.count; i++ {
            skillsArr += selectedTutor.skills[i]
            if i != selectedTutor.skills.count - 1 {
                skillsArr += ", "
            }
        }
        skills.text = skillsArr
        pinDesc.text = selectedTutor.pinDescription
        
        
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
