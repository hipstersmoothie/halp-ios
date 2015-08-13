//
//  SchoolPicker.swift
//  Halp
//
//  Created by Andrew Lisowski on 5/14/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class SchoolPicker: UIViewController, XLPagerTabStripChildItem, MPGTextFieldDelegate {
    @IBOutlet var universityField: MPGTextField_Swift!
    @IBOutlet var courseField: MPGTextField_Swift!
    @IBOutlet var nextButton: UIButton!
    
    @IBAction func nextButtonAction(sender: AnyObject) {
        if(universityField.text == "") {
            createAlert(self, "Need more Info", "Please provide a school.")
        } else if (courseField.text == "") {
            createAlert(self, "Need more Info", "Please provide a course.")
        } else {
            let parent = self.parentViewController as? TabSessionCreate
            var course = split(courseField.text) {$0 == " "}
            if course.count < 2 {
                createAlert(self, "Invalid Class", "Must be formatted like CPE 123(name num)")
                return
            }
            parent?.params["courses"] = [
                universityField.text!: [
                    [
                    "subject": course[0],
                    "number": course[1]
                    ]
                ]
            ]
            
            parent?.switchTab(1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.backgroundColor = teal
        nextButton.layer.cornerRadius = 12
        nextButton.layer.borderWidth = 1
        nextButton.layer.borderColor = teal.CGColor
        nextButton.clipsToBounds = true
        
        styleField(courseField, "course")
        courseField.mDelegate = self
        
        styleField(universityField, "school")
        universityField.mDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func titleForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> String! {
        return "school details";
    }

    func colorForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> UIColor! {
        return teal
    }
    
    //MARK: uni and course picker
    func dataForPopoverInTextField(textfield: MPGTextField_Swift) -> [Dictionary<String, AnyObject>] {
        if textfield == universityField {
            return universities
        } else {
            return courses
        }
    }
    
    func textFieldShouldSelect(textField: MPGTextField_Swift) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(textField: MPGTextField_Swift, withSelection data: Dictionary<String,AnyObject>){
        if textField == universityField {
            let uni = data["DisplayText"] as! String
            var params = [
                "university": uni
            ]
            
            halpApi.getCourses(params) { success, json in
                courses = []
                let courseList = json["courses"].arrayValue
                for course in courseList {
                    let courseText = course["subject"].stringValue + " " + course["number"].stringValue
                    courses.append([
                        "DisplayText": courseText,
                        "CustomObject": Course(course: course)
                        ])
                }
            }
            courseField.enabled = true
        }
    }

}
