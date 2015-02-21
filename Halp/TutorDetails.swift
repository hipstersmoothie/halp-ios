//
//  TutorDetails.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/1/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class TutorDetails: UIViewController {
    @IBOutlet var bio: UITextView!
    @IBOutlet var classes: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        bio.text = selectedTutor.user.bio

        var classList = ""
        for (university, courseList) in selectedTutor.user.courses {
            for course in courseList {
                classList.extend("\(course.subject) \(course.number)\n")
            }
        }
        
        classes.text = classList
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
