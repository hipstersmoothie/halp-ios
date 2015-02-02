//
//  TutorDetails.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/1/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class TutorDetails: UIViewController {
    @IBOutlet var university: UILabel!
    @IBOutlet var major: UILabel!
    @IBOutlet var year: UILabel!
    @IBOutlet var classes: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        university.text = selectedTutor.university
        major.text = selectedTutor.major
        year.text = "\(selectedTutor.year)"
        
        var classList = ""
        for classString in selectedTutor.classes {
            classList.extend("\(classString)\n")
        }
        
        classes.text = classList
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
