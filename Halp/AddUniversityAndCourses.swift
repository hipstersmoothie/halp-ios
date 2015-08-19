//
//  AddUniversityAndCourses.swift
//  Halp
//
//  Created by Andrew Lisowski on 8/18/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class AddUniversityAndCourses: UIViewController, MPGTextFieldDelegate {
    @IBOutlet var universityField: MPGTextField_Swift!
    @IBOutlet var courseField: MPGTextField_Swift!
    @IBOutlet var addButton: UIButton!
    
    @IBAction func addButtonAction(sender: AnyObject) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleButton(addButton)
        
        styleField(courseField, "course")
        courseField.mDelegate = self
        
        styleField(universityField, "school")
        universityField.mDelegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
