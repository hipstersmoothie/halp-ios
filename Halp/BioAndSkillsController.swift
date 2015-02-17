//
//  BioAndSkillsController.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/14/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

var setUpTutorParams = Dictionary<String, AnyObject>()

class BioAndSkillsController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let next = UIBarButtonItem(title: "Next", style: .Bordered, target: self, action: "nextScreen")
        self.navigationItem.rightBarButtonItem = next
    }
    
    @IBOutlet var bio: UITextView!
    @IBOutlet var skills: UITextField!
    func nextScreen() {
        if bio.text == "" || bio.text == "Write a bio about yourself. This helps student get to know you before you meet." {
            createAlert("Error!", message: "Provide a bio.")
        } else if skills.text == "" {
            createAlert("Error!", message: "Provide some skills.")
        } else {
            setUpTutorParams.updateValue(bio.text, forKey: "bio")
            var skillsArr = split(skills.text) {$0 == ","}
            skillsArr = skillsArr.map({ skill in
                skill.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            })
            setUpTutorParams.updateValue(skillsArr, forKey: "skills")
            
            self.performSegueWithIdentifier("toAddClasses", sender: self)
        }
    }
    
    func createAlert(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
